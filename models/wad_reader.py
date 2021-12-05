import struct
import os
import re
import io
import math
import logging
import argparse
from collections import namedtuple
from udmf_reader import UDMF
from textures_reader import TextureReader
from decorate_reader import DecorateReader
from mapinfo_reader import MapinfoReader
from decorate_reader import ACTOR_KIND
from dotdict import dotdict
from python2pico import pack_int
from python2pico import pack_variant
from python2pico import pack_fixed
from python2pico import pack_byte
from python2pico import to_multicart
from python2pico import pack_int32
from python2pico import pack_short
from python2pico import pack_release
from python2pico import bytes_to_base255
from python2pico import minify_file

from bsp_compiler import Polygon
from bsp_compiler import POLYGON_CLASSIFICATION
from bsp_compiler import normal,ortho
from image_reader import ImageReader
from colormap_reader import ColormapReader, std_palette, AutoPalette
from wad_stream import WADStream
from file_stream import FileStream
from PIL import Image
from lzs import *
from tqdm import tqdm

# debug/draw
import sys

# helper funcs
def get_at_or_default(list, index, defaults):
  return list[index] if index < len(list) else defaults[index]

# helper math functions
def dot(v0,v1):
  return v0[0]*v1[0]+v0[1]*v1[1]

def normal(v0):
  dx = v0[0]
  dy = v0[1]
  d = math.sqrt(dx*dx + dy*dy)
  if d!=0:
    dx /= d
    dy /= d
  return (dx, dy)

# specs: https://zdoom.org/wiki/WAD

# type definitions
WADHeader = namedtuple('WADHeader', 
    ("type,dir_size,dir_ofs")
    )
fmt_WADHeader = '<4s2i'

WADDirectory = namedtuple('WADDirectory', 
    ("lump_ofs,lump_size,lump_name")
    )
fmt_WADDirectory = '<2i8s'

ZNODESHeader = namedtuple('ZNODESHeader', 
    ("type")
    )
fmt_ZNODESHeader = '<4s'

VERTEXHeader = namedtuple('VERTEXHeader', 
    ("verts_size,additional_verts_size")
    )
fmt_VERTEXHeader = '<2i'

SEGHeader = namedtuple('SEGHeader', 
    ("v1,partner,lineword,side")
    )
fmt_SEGHeader = '<2iHc'

ZNODEHeader = namedtuple('ZNODEHeader', 
    ("x,y,dx,dy,top0,bottom0,left0,right0,top1,bottom1,left1,right1,child0,child1")
    )
fmt_ZNODEHeader = '<4h4h4h2i'

# helper structures
SEG = namedtuple('SEG',['id','v1','line','side','partner'])
AABB = namedtuple('AABB',['top','bottom','left','right'])
ZNODE = namedtuple('ZNODE',['n','d','flags','child','aabb'])
ZMAP = namedtuple('ZMAP',['vertices','other_vertices','lines','sides','sectors','things', 'sub_sectors', 'nodes'])

class MAPDirectory():
  def __init__(self, file, name, entry):
    # map name
    self.name = name    
    lumps={}
    # read until ENDMAP
    while(True):
      entry_data = file.read(struct.calcsize(fmt_WADDirectory))
      entry = WADDirectory._make(struct.unpack(fmt_WADDirectory, entry_data))
      lump_name = entry.lump_name.decode('ascii').rstrip('\x00')
      if lump_name == 'ENDMAP':
        break
      logging.debug("Lump {}: section: {}".format(name, lump_name))
      lumps[lump_name] = entry
    self.lumps=lumps
  def read(self, file):
    # read UDMF entry
    entry = self.lumps['TEXTMAP']
    file.seek(entry.lump_ofs)
    textmap_data = file.read(entry.lump_size).decode('ascii')
    udmf = UDMF(textmap_data)
    # ZNODES
    entry = self.lumps['ZNODES']
    file.seek(entry.lump_ofs)
    header_data =  file.read(struct.calcsize(fmt_ZNODESHeader))
    header = ZNODESHeader._make(struct.unpack(fmt_ZNODESHeader, header_data))
    logging.debug("ZNODES type: {}".format(header.type))
    header_data = file.read(struct.calcsize(fmt_VERTEXHeader))
    header = VERTEXHeader._make(struct.unpack(fmt_VERTEXHeader, header_data))
    logging.debug("map verts: {} / extra verts: {}".format(header.verts_size, header.additional_verts_size))
    # additional vertices
    vertices = []
    for i in range(0, header.additional_verts_size):
      vertices.append((int.from_bytes(file.read(4), 'little'),int.from_bytes(file.read(4), 'little')))
 
    # sub sectors
    subs_size = int.from_bytes(file.read(4), 'little')
    segs_total = 0
    segs = []
    for i in range(0, subs_size):
      segs_size = int.from_bytes(file.read(4), 'little')
      segs_total += segs_size
      segs.append(segs_size)
    segs_size = int.from_bytes(file.read(4), 'little')
    
    # sub sector sides (segs)
    sub_sectors=[]
    # reverse lookup: seg->
    subsector_by_seg= {}
    seg_id=0
    for n in segs:
      segs = []
      for i in range(0,n):
        header_data = file.read(struct.calcsize(fmt_SEGHeader))
        header = SEGHeader._make(struct.unpack(fmt_SEGHeader, header_data))
        segs.append(SEG(seg_id, header.v1, header.lineword==0xFFFF and -1 or header.lineword, header.side, header.partner))
        # map absolute segment ids to sub-sector id
        subsector_by_seg[seg_id] = len(sub_sectors)
        seg_id += 1
      sub_sectors.append(segs)
 
    # replace partner links to sub-sector reference
    for subs in sub_sectors:
      for i in range(0,len(subs)):
        seg = subs[i]
        if seg.partner!=-1:
          subs[i] = seg._replace(partner=subsector_by_seg[seg.partner])
      
    # bsp nodes
    num_nodes = int.from_bytes(file.read(4), 'little')
    nodes = []
    for i in range(0, num_nodes):
      header_data = file.read(struct.calcsize(fmt_ZNODEHeader))
      header = ZNODEHeader._make(struct.unpack(fmt_ZNODEHeader, header_data))
      n=normal((-header.dy,header.dx))
      d=dot(n, (header.x,header.y))
      node = ZNODE(n,d,0x00,[None,None],[None, None])
      # left child
      if header.child0 & 0x80000000 != 0:
        node = node._replace(flags=1)
        node.child[0]=header.child0 & 0x7FFFFFFF
      else:
        # actual reference resolved by p8 code
        node.child[0]=header.child0
      # right child
      if header.child1 & 0x80000000 != 0:
        node = node._replace(flags=node.flags|2)
        node.child[1]=header.child1 & 0x7FFFFFFF
      else:
        # actual reference resolved by p8 code
        node.child[1]=header.child1
      # bounding boxes
      node.aabb[0] = [header.top0,header.bottom0,header.left0,header.right0]
      node.aabb[1] = [header.top1,header.bottom1,header.left1,header.right1]
      nodes.append(node)
    return ZMAP(udmf.vertices, vertices, udmf.lines, udmf.sides, udmf.sectors, udmf.things, sub_sectors, nodes)

# ZMAP export to pico8 format
def pack_segs(segs):
  s = pack_variant(len(segs))
  for seg in segs:
    s += pack_variant(seg.v1+1)
    # side? + extra flags
    flags = seg.side[0]
    extra_data = ""
    if seg.line!=-1:
      flags |= 2
      # linedef ref
      extra_data += pack_variant(seg.line+1)
    if seg.partner!=-1:
      flags |= 4
      # reference to connected sub-sector
      extra_data += pack_variant(seg.partner+1)
    s += "{:02x}".format(flags)
    s += extra_data
  return s

def pack_texture(texture):
  return "{:02x}{:02x}{:02x}{:02x}".format(texture.my,texture.mx,texture.height,texture.width)

def pack_named_texture(owner, textures, name):
  # no upper/middle/lower/ceiling/floor entries?
  if name not in owner: 
    return "00000000"
  # de-reference texture name
  name = owner[name]
  # logical 'no texture'
  if name == '-': 
    return "00000000"

  # no texture/blank texture
  if name not in textures: 
    return "00000000"
  return pack_texture(textures[name])

def pack_lightlevel(owner, name):
  return "{:02x}".format(owner.get(name, 160))

def pack_aabb(aabb):
  return "".join(map(pack_fixed, aabb))

# find all sectors
def find_sectors_by_tag(tag, sectors):
  return [i for i,sector in enumerate(sectors) if 'id' in sector and sector.id==tag]

def pack_sectors_by_tag(ids,extra=None):
  s = pack_variant(len(ids))
  for id in ids:
    s += pack_variant(id+1)
    # extra sector data?
    if extra:
      s += extra[id]
  return s

def find_other_sectors(id, lines, sides, sectors):
  # find sector sides
  all_sides = [i for i,side in enumerate(sides) if side.sector==id]
  other_sectors = [sectors[sides[line.sidefront].sector] for line in lines if line.sideback in all_sides and line.sidefront!=-1] + [sectors[sides[line.sideback].sector] for line in lines if line.sidefront in all_sides and line.sideback!=-1]
  if len(other_sectors)<1:
    raise Exception("Sector: {} missing reference sector".format(id))
  return other_sectors

# helper for default args (or missing)
def is_missing_or_zero(owner, arg):
  return arg not in owner or owner[arg]==0

# clamp platform/door speed to supported
def get_safe_speed(owner, arg):
  speed = owner.get(arg,16)
  if speed==0 or speed>127:
    logging.warning("Clamping platform/door speed to: 1-127 (was: {})".format(speed))
  return max(1, min(speed,127))

def pack_special(owner, lines, sides, sectors):
  special = owner.special
  # use "generic" variants
  if special == 62:
    s = "{:02x}".format(64)  
  elif special in [11,12,13]:
    s = "{:02x}".format(13)
  else:
    s = "{:02x}".format(special)

  if special==202:
    logging.error("Unsupported special: {}".format(special))
  elif special in [11,12,13]:
    # start delay (poom extension!)
    s += pack_variant(owner.get('arg4',0))

    # door open
    logging.debug("Special: Door_Open/Door_Raise/Door_LockedRaise")
    sector_ids = []
    if is_missing_or_zero(owner,'arg0'):
      if 'sideback' not in owner:
        raise Exception("Special trigger must be a linedef to use tag 0")
      # find sector from line other side
      sector_ids.append(sides[owner.sideback].sector)
    else:
      sector_ids = find_sectors_by_tag(owner.arg0, sectors)
    # pack sector id + target ceiling height
    target_heights = {}
    for sector_id in sector_ids:
      sector = sectors[sector_id]
      other_sectors = find_other_sectors(sector_id, lines, sides, sectors)
      # find lowest surrouding ceiling
      target_height = min([other_sector.heightceiling for other_sector in other_sectors])
      target_heights[sector_id]=pack_fixed(target_height-4)
    # speed
    s += "{:02x}".format(128+get_safe_speed(owner,'arg1'))
    # delay (can be larger than 256)
    # door_open(11): cannot reopen
    if special==11:
      s += pack_variant(0)
    else:  
      s += pack_variant(owner.get('arg2',0))
    # lock (if any)
    s += pack_variant(owner.get('arg3',0))
    s += pack_sectors_by_tag(sector_ids,target_heights)
  elif special==10:
    # door close
    logging.debug("Special: Door_Close")
    sector_ids = []
    if is_missing_or_zero(owner,'arg0'):
      # find sector from line other side
      if 'sideback' not in owner:
        raise Exception("Special trigger must be a linedef to use tag 0")
      sector_ids.append(sides[owner.sideback].sector)
    else:
      sector_ids = find_sectors_by_tag(owner.arg0, sectors)
    # pack sector id + target floor height
    target_heights = {}
    for sector_id in sector_ids:
      sector = sectors[sector_id]
      target_heights[sector_id]=pack_fixed(sector.heightfloor)
    # speed
    s += "{:02x}".format(get_safe_speed(owner,'arg1'))
    # delay (not supported)
    s += pack_variant(0)
    # lock (not supported)
    s += pack_variant(0)
    s += pack_sectors_by_tag(sector_ids,target_heights)
  elif special==64: 
    logging.debug("Sector: Plat_UpWaitDownStay")
    sector_ids = []
    if is_missing_or_zero(owner,'arg0'):
      # find sector from line other side
      if 'sideback' not in owner:
        raise Exception("Special trigger must be a linedef to use tag 0")
      sector_ids.append(sides[owner.sideback].sector)
    else:
      sector_ids = find_sectors_by_tag(owner.arg0, sectors)
    target_heights = {}
    for sector_id in sector_ids:
      sector = sectors[sector_id]
      other_sectors = find_other_sectors(sector_id, lines, sides, sectors)
      # find floor just above elevator floor
      other_floor = min([other_sector.heightfloor for other_sector in other_sectors if other_sector.heightfloor>sector.heightfloor])
      target_heights[sector_id]=pack_fixed(other_floor)
    # speed
    s += "{:02x}".format(128+get_safe_speed(owner,'arg1'))
    # delay
    s += pack_variant(owner.get('arg2',0))
    # lock (not supported)
    s += pack_variant(0)
    s += pack_sectors_by_tag(sector_ids,target_heights)
  elif special==62: 
    logging.debug("Special: Plat_DownWaitUpStay")
    sector_ids = []
    if is_missing_or_zero(owner,'arg0'):
      # find sector from line other side
      if 'sideback' not in owner:
        raise Exception("Special trigger must be a linedef to use tag 0")
      sector_ids.append(sides[owner.sideback].sector)
    else:
      sector_ids = find_sectors_by_tag(owner.arg0, sectors)
    target_heights = {}
    for sector_id in sector_ids:
      sector = sectors[sector_id]
      other_sectors = find_other_sectors(sector_id, lines, sides, sectors)
      # find floor just below elevator floor
      other_floor = min([other_sector.heightfloor for other_sector in other_sectors if other_sector.heightfloor<sector.heightfloor])
      target_heights[sector_id]=pack_fixed(other_floor+8)
    # speed
    s += "{:02x}".format(get_safe_speed(owner,'arg1'))
    # delay (default: 3s)
    s += pack_variant(owner.get('arg2',0))
    # lock (not supported)
    s += pack_variant(0)
    # sectors
    s += pack_sectors_by_tag(sector_ids,target_heights)
  elif special==243:
    # exit level
    logging.debug("Special: exit level")
    # optional delay
    s += pack_variant(owner.get('arg2',0))
  elif special==112:
    logging.debug("Special: set light level")
    # set lightlevel
    sector_ids = find_sectors_by_tag(owner.arg0, sectors)
    # light level
    s += "{:02x}".format(owner.get('arg1',0))
    # sectors
    s += pack_sectors_by_tag(sector_ids)
  return s

def get_skillmask(thing, skill):
  name = "skill{}".format(skill)
  if thing.get(name,False)==True:
    return 1<<(skill-1)
  return 0
  
def pack_thing(thing):
  s = ""
  # pack angle + skills (1-4)
  skills = 0
  for i in range(4):
    skills |= get_skillmask(thing, i+1)
  # edge case = no flags = visible on all skills
  if skills==0:
    skills = 15
  angle = math.floor(thing.get('angle',0)/45)%8
  s += "{:02x}".format(angle|skills<<4)
  # id
  s += pack_variant(thing.type)
  # position
  s += pack_fixed(thing.x)
  s += pack_fixed(thing.y)
  return s

def pack_flag(owner, name):
  return owner.get(name,False) and 1 or 0

# return active textures/flats from map
def get_zmap_textures(map):
  textures = set()
  for sector in map.sectors:
    textures.add(sector.get('textureceiling',None))
    textures.add(sector.get('texturefloor',None))
            
  for side in map.sides:
    textures.add(side.get('texturetop',None))
    textures.add(side.get('texturemiddle',None))
    textures.add(side.get('texturebottom',None))
  textures.remove(None)

  # make sure on/off textures are included
  onoff_textures=set()
  for name in textures:
    if '_ON' in name:
      onoff_textures.add(name.replace('_ON','_OFF'))
    elif '_OFF' in name:
      onoff_textures.add(name.replace('_OFF','_ON'))

  return textures|onoff_textures

def pack_zmap(map, textures):
  # shortcut to wall textures
  flats = textures.flats

  # export data
  s = pack_variant(len(map.sectors))
  for sector in map.sectors:
    # see: https://zdoom.org/wiki/Sector_specials
    s += "{:02x}".format(sector.special)
    s += pack_fixed(sector.heightceiling)
    s += pack_fixed(sector.heightfloor)
    # sector ceiling/floor textures
    s += pack_named_texture(sector, flats, 'textureceiling')
    s += pack_named_texture(sector, flats, 'texturefloor')
    # light level
    s += pack_lightlevel(sector, 'lightlevel')
            
  s += pack_variant(len(map.sides))
  for side in map.sides:
    s += pack_variant(side.sector+1)
    s += pack_named_texture(side, flats, 'texturetop')
    s += pack_named_texture(side, flats, 'texturemiddle')
    s += pack_named_texture(side, flats, 'texturebottom')

  s += pack_variant(len(map.vertices)+len(map.other_vertices))
  for v in map.vertices:
    s += pack_fixed(v[0])
    s += pack_fixed(v[1])
  for v in map.other_vertices:
    s += pack_int32(v[0])
    s += pack_int32(v[1])

  s += pack_variant(len(map.lines))
  for line in map.lines:
    s += pack_variant(line.sidefront+1)
    s += pack_variant(line.sideback+1)
    flags = 0
    if line.twosided==True:
      flags |= 1
    if 'dontpegtop' in line:
      flags |= 4
    # pack other game flags
    special_data = ""
    if 'special' in line:
      flags |= 2
      special_data += pack_special(line, map.lines, map.sides, map.sectors)
    if 'playeruse' in line and line.playeruse==True:
      flags |= 8
    if 'playercross' in line and line.playercross==True:
      flags |= 16
    if 'repeatspecial' in line and line.repeatspecial==True:
      flags |= 32
    if 'blocking' in line and line.blocking==True:
      flags |= 64
    s += "{:02x}".format(flags)
    s += special_data
  
  all_pvs = []
  for i in tqdm(range(len(map.sub_sectors)), desc="PVS generation",unit="sector"):
    # PVS
    pvs,clips,vert = get_PVS(map, i)
    all_pvs.append(pvs)
  
  # optimize PVS (cross check)
  for i in range(len(map.sub_sectors)):
    src_pvs = all_pvs[i]
    new_pvs = []
    for j in src_pvs:
      if i!=j:
        dst_pvs = all_pvs[j]
        if i in dst_pvs:
          new_pvs.append(j)
    # replace    
    all_pvs[i] = new_pvs

  s += pack_variant(len(map.sub_sectors))
  for i in range(len(map.sub_sectors)):
    s += pack_segs(map.sub_sectors[i])
    # PVS
    pvs = all_pvs[i]
    s += pack_variant(len(pvs)+1)
    # record current sub-sector id
    s += pack_variant(i + 1)
    for sub_id in pvs:
      s += pack_variant(sub_id + 1)

  s += pack_variant(len(map.nodes))
  for node in map.nodes:
    # n
    s += pack_fixed(node.n[0])
    s += pack_fixed(node.n[1])
    s += pack_fixed(node.d)
    s += "{:02x}".format(node.flags)
    # segs reference
    if node.flags & 0x1:
      s += pack_variant(node.child[0]+1)
    else:
      s += pack_aabb(node.aabb[0])
      s += pack_variant(node.child[0]+1)
    # segs reference
    if node.flags & 0x2:
      s += pack_variant(node.child[1]+1)
    else:
      s += pack_aabb(node.aabb[1])
      s += pack_variant(node.child[1]+1)

  # pack texture switches
  texture_pairs = {}
  for name,texture in flats.items():
    other_texture = None 
    if '_ON' in name:
      other_texture = flats.get(name.replace('_ON','_OFF'))
    elif '_OFF' in name:
      other_texture = flats.get(name.replace('_OFF','_ON'))
    
    if other_texture is not None:
      texture_pairs[name] = other_texture

  # on/off textures
  s += pack_variant(len(flats))
  for name,texture in flats.items():
    s+= pack_texture(texture)
    # get pair or self
    s+= pack_texture(texture_pairs.get(name, texture))

  # transparent textures
  transparent_textures=list([texture for name,texture in flats.items() if texture.transparent])
  s += pack_variant(len(transparent_textures))
  for texture in transparent_textures:
    s+= pack_texture(texture)

  return s

def pack_things(map, actors):
  s = ""
  # things
  things = []
  actors = [actor.get('id',-1) for actor in actors.values()]
  if 1 not in actors:
    raise Exception("Missing player start location in WAD")
  for thing in map.things:
    if thing.type not in actors:
      logging.warning("Thing: {} references unknown actor: {} - skipping".format(thing, thing.type))
    else:
      things.append(thing)
  
  logging.info("Packing: {} things".format(len(things)))

  # split into 2 sets (with special/no special)
  standard_things = [t for t in things if 'special' not in t]
  s += pack_variant(len(standard_things))
  for thing in standard_things:
    s += pack_thing(thing)
  
  special_things = [t for t in things if 'special' in t]
  s += pack_variant(len(special_things))
  for thing in special_things:
    s += pack_thing(thing)
    s += pack_special(thing, map.lines, map.sides, map.sectors)

  return s

def pack_ratio(x):
  if x<0 or x>255:
    raise Exception("Invalid ratio: {}, must be in range [0;1]".format(x))
  return pack_byte(int(255*x))

def pack_actor_properties(actor):
  properties = 0
  properties_data = ""
  actor_properties={
    0x1     :('health',pack_variant),
    0x2     :('armor',pack_variant),
    0x4     :('amount',pack_variant),
    0x8     :('maxamount',pack_variant),
    0x10    :('icon',lambda v:"{:02x}".format(v)),
    0x20    :('slotnumber',pack_byte),
    0x40    :('ammouse',pack_variant),
    0x80    :('speed',pack_variant),
    0x100   :('damage',pack_variant),
    0x200   :('ammotype',pack_variant),
    # 0x400 custom format
    0x800   :('mass',pack_variant),
    0x1000  :('pickupsound',pack_variant),
    0x2000  :('attacksound',pack_variant),
    0x4000  :('hudcolor',pack_variant),
    0x8000  :('deathsound',pack_variant),
    0x10000 :('meleerange',pack_variant),
    0x20000 :('maxtargetrange',pack_variant),
    0x40000 :('ammogive',pack_variant),
    0x80000 :('trailtype',pack_variant),
    0x100000:('drag',pack_fixed),
    0x200000:('respawntics',pack_variant),
    0x400000:('recoil',pack_fixed)
  }
  for mask,info in actor_properties.items():
    name, packer = info
    if actor.get(name):
      properties |= mask
      properties_data += packer(actor.get(name))
  return (properties, properties_data)

def pack_actors(image_reader, actors):
  s = ""
  # actors/inventory (e.g. items with assigned unique id)
  concrete_actors = [actor for actor in actors.values() if actor.id!=-1]
  
  # collect active images
  images = []
  frames_by_name = {}
  for actor in concrete_actors:
    for state in [state for state in actor._states if 'image' in state]:
      image_name = "{}{}".format(state.image,state.variant)
      frames = image_reader.read_frames(state.image, state.variant)
      frames_by_name[image_name] = frames
      # remove "flipped" duplicate sprites for serialization
      for frame in [frame for frame in frames if frame[1]==False]:
        images.append(image_reader.read(frame[0]))
  
  logging.info("Found {} sprites".format(len(images)))
  
  s += pack_variant(len(images))
  # export frame metadata & prepare tileset
  tiles_count = 0
  sprites = {}
  unique_tiles = []
  for image_index,image_data in enumerate(images):
    logging.debug("Packing sprite: {}".format(image_data.name))
    sprites[image_data.name] = image_index
    s += "{:02x}".format(image_data.width|image_data.background<<4)
    s += pack_short(image_data.xoffset)
    s += pack_short(image_data.yoffset)
    tiles = image_data.tiles
    s += pack_variant(len(tiles))
    for i,tile in tiles.items():
      tile_id = tiles_count
      # find duplicates in already registered tiles
      tile_data = image_data.data[tile]
      if tile_data in unique_tiles:
        # reuse global tile id
        tile_id = unique_tiles.index(tile_data)
      else:                  
        # unique tile? register
        unique_tiles.append(tile_data)
        tiles_count += 1
      s += "{:02x}{}".format(i,pack_variant(tile_id*32+1))

  # export all images bytes
  if tiles_count>32763-32:
    # exceeded pico8 array size?
    raise Exception("Tiles count ({}) exceeds PICO8 table size".format(tiles_count))
  logging.info("Packing {} 16x16 tiles".format(tiles_count))
  image_s = pack_variant(tiles_count)
  for image_bytes in unique_tiles:
    for b in image_bytes:
      image_s += "{:02x}".format(b)
  s += image_s

  # know state names
  # max: 16
  all_states = ['Spawn','Idle','See','Melee','Missile','Death','XDeath','Ready','Hold','Fire','Pickup','Pain']

  # known functions
  # max: 256 (ahah!)
  all_functions = dotdict({
    'A_FireBullets': dotdict({'id':1, 'args':[pack_fixed, pack_fixed, pack_byte, pack_byte, pack_variant]}),
    'A_PlaySound': dotdict({'id':2, 'args':[pack_byte]}),
    'A_FireProjectile': dotdict({'id':3, 'args': [pack_variant]}),
    'A_WeaponReady': dotdict({'id':4, 'args':[]}),
    'A_Explode': dotdict({'id':5, 'args': [pack_variant, pack_variant]}),
    'A_FaceTarget': dotdict({'id':6, 'args': [pack_ratio], 'defaults': [1]}),
    'A_Look': dotdict({'id':7, 'args': []}),
    'A_Chase': dotdict({'id':8, 'args': []}),
    'A_Light': dotdict({'id':9, 'args': [pack_byte]}),
    'A_MeleeAttack':dotdict({'id':10, 'args': [pack_byte, pack_variant]}),
    'A_SkullAttack': dotdict({'id':11, 'args': [pack_variant], 'defaults': [20]})
  })

  s += pack_variant(len(concrete_actors))
  for actor in concrete_actors:
    # actor "class"
    s += pack_variant(actor.kind)
    s += pack_variant(actor.id)
    # mandatory/shared properties
    s += pack_fixed(actor.radius)
    s += pack_fixed(actor.height)
    # behavior flags
    flags = pack_flag(actor, 'solid') | pack_flag(actor, 'shootable')<<1 | pack_flag(actor, 'missile')<<2 | pack_flag(actor, 'ismonster')<<3 | pack_flag(actor, 'nogravity')<<4 | pack_flag(actor, 'float')<<5 | pack_flag(actor, 'dropoff')<<6 | pack_flag(actor, 'dontfall')<<7
    s += "{:02x}".format(flags)
    # behavior flags (cont.)
    flags = pack_flag(actor, 'randomize') | pack_flag(actor, 'countkill')<<1 | pack_flag(actor, 'nosectordmg')<<2 | pack_flag(actor, 'noblood')<<3
    s += "{:02x}".format(flags)
    
    ################## properties
    properties, properties_data = pack_actor_properties(actor)

    # must be at the end 
    if actor.get('startitems'):
      properties |= 0x400
      startitems = actor.startitems
      properties_data += pack_variant(len(startitems))
      for si in startitems:
        # other actor reference
        properties_data += pack_variant(si[0])
        # amount
        properties_data += pack_variant(si[1])

    s += pack_int32(properties)
    s += properties_data
  
    ############ states
    # export state jump table
    s += pack_variant(len(actor._labels))
    for state_label,state_address in actor._labels.items():
      if state_label not in all_states:
        raise Exception("Unkown state: \"{}\" for actor: {} - Custom state names are not supported.".format(state_label,actor.name))
      s += "{:02x}{:02x}".format(all_states.index(state_label),state_address+1)
    # export states
    s += pack_variant(len(actor._states))
    for state in actor._states:
      state_s = ""
      # layout:
      # 0-1: control type (0/1/2/3)
      # 2: sprite modifier
      # 3: custom function
      # 4-7: jump label id
      flags = 0
      if 'stop' in state:
        flags=0x1
      elif 'goto' in state:
        flags=0x2
        flags|=all_states.index(state.goto)<<4
      else:
        # bright?
        if state.bright:
          flags|=0x4
        # pack all sides for a given pose (variant)
        if state.ticks>127:
          raise Exception("Invalid ticks value: {} at state: {} - ticks must be in [-1;127]".format(state.ticks,state))
        state_s += pack_short(state.ticks)
        pattern = "{}{}".format(state.image,state.variant)
        # get frame information
        frames = frames_by_name[pattern]
        # flipped?
        flipbits = 0
        for i,frame in enumerate(frames):
          flipbits|=(frame[1]==True and 1 or 0)<<i
        state_s += "{:02x}".format(flipbits) 
        # transparency
        state_s += "{:04x}".format(state.alpha)
        # images references
        state_s += pack_variant(len(frames))
        for frame in frames:
          # index to sprite metadata
          state_s += pack_variant(sprites[frame[0]]+1)
        if state.function is not None:
          if state.function not in all_functions:
            raise Exception("Unknown state function: {}".format(state.function))
          flags|=0x8
          fn = all_functions[state.function]
          state_s += "{:02x}".format(fn.id)
          for i,arg_pack in enumerate(fn.args):
            state_s += arg_pack(get_at_or_default(state.args,i,fn.get('defaults'))) 
      # print("{} -> 0x{:02x}".format(state, flags))
      s += "{:02x}".format(flags)
      s += state_s

  return s

# generate main game cart
def pack_sprite(arr):
  return ["".join(map("{:02x}".format,arr[i*4:i*4+4])) for i in range(8)]

# remap image to given palette and export to byte string
# if palette is not given, produces a dynamic palette
# raises an exception if #colors>16
def pack_image(img, palette=None, label=False):
  p = AutoPalette(palette=palette)

  data = bytearray()
  for y in range(img.size[1]):
    for x in range(0,img.size[0],2):
      low = p.register(img.getpixel((x, y)))
      high = p.register(img.getpixel((x + 1,y)))
      data.append(low)
      data.append(high)
  
  s = ""
  pal = p.pal(label=label)
  if label:
    s = "".join([pal[c] for c in data])
  else:
    s = "".join(map("{:01x}".format,data))
  return s, pal

# convert image to pico8 format
def pack_p8image(stream, asset, palette=None, swap=False, min_size=(0,0), max_size=(128,128), crop=False, mandatory=False, label=False):
  src = None
  try:
    src = Image.open(io.BytesIO(stream.read(asset)))
  except:
    if mandatory:
      raise Exception("Image not found: {}".format(asset))
    # no image
    logging.debug("Image not found: {}".format(asset))
    return (None,None,None)
  
  logging.info("Packing image: {}".format(asset))
  # check allowed size  
  size = src.size
  if crop and size>max_size:
    size = max_size
  if size>max_size or size<min_size:
    raise Exception("Image: {} invalid size: {} - Must be between {} and {}".format(asset, size, min_size, max_size))

  img = Image.new('RGBA', size, (0,0,0,0))
  img.paste(src)
  data,autopalette = pack_image(img, palette=palette, label=label)
  if swap:
    s = ""
    for i in range(0,len(data),2):
      s += data[i+1:i+2] + data[i:i+1]
    data = s
  # convert palette into a "pal" call
  return data, "[0]={},".format(autopalette[0])+",".join(str(c) for c in autopalette[1:]), size

def to_gamecart(carts_path, name, group_name, width, map_data, gfx_data, palette, skybox_data, compress=False, release=None):
  cart="""\
pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- {0}
-- @freds72 + @gamecactus
-- *********************************
-- generated code - do not edit
-- *********************************
#include {0}_atlas.lua
#include {1}
#include {2}
""".format(
  name,
  compress and "lzs.lua" or "plain.lua",
  release and "{}_main_mini.lua".format(name) or "main.lua")

  # transpose gfx
  gfx_data=[pack_sprite(data) for data in gfx_data]

  s = ""
  # palette (e.g. gradients or screen palettes)
  #print("\n".join([" ".join(map("{:02x}".format,palette[i:i+16])) for i in range(0,len(palette),16)]))
  tmp = "".join(map("{:02x}".format,palette))
  # preserve byte orders
  for i in range(0,len(tmp),2):
    s += tmp[i+1:i+2] + tmp[i:i+1]

  s += skybox_data
  # fill until spritesheet 2
  s += "0"*(128*64-len(s))

  # tiles
  rows = [""]*8
  for i,img in enumerate(gfx_data):
      # full row?
      if i%16==0:
        # collect
        s += "".join(rows)
        rows = [""]*8           
      for j in range(8):
        rows[j] += img[j]
  # remaining tiles (+ padding)
  s += "".join([row + "0" * (128-len(row)) for row in rows])

  # convert to string
  cart += "__gfx__\n"
  cart += re.sub("(.{128})", "\\1\n", s, 0, re.DOTALL)
  cart += "\n"

  # pad map
  map_data = ["".join(map("{:02x}".format,map_data[i:i+width] + [0]*(128-width))) for i in range(0,len(map_data),width)]
  map_data = "".join(map_data)
  cart += "__map__\n"
  cart += re.sub("(.{256})", "\\1\n", map_data, 0, re.DOTALL)

  # music and sfx (from external cart)
  # group cart?
  music_path = os.path.join(carts_path, "music_{}.p8".format(group_name))    
  if not os.path.isfile(music_path):
    # generic cart?
    music_path = os.path.join(carts_path, "music.p8")    
  if os.path.isfile(music_path):
    logging.info("Found music&sfx cart: {}".format(music_path))

    copy = False
    with open(music_path, "r") as f:
      for line in f:
        line = line.rstrip("\n\r")
        if line in ["__music__","__sfx__"]:
          copy = True
        elif re.match("__([a-z]+)__",line):
          # any other section
          copy = False
        if copy:
          cart += line
          cart += "\n"

  cart_path = os.path.join(carts_path, "{}_{}.p8".format(name, group_name))
  with open(cart_path, "w") as f:
    f.write(cart)

def load_WAD(stream, mapname):
  with stream.open(mapname) as file:
    # read file header
    header_data = file.read(struct.calcsize(fmt_WADHeader))
    header = WADHeader._make(struct.unpack(fmt_WADHeader, header_data))

    logging.debug("Map: {} WAD type: {}".format(mapname, header.type))

    # go to directory
    file.seek(header.dir_ofs)
    i = 0
    while i<header.dir_size:
      entry_data = file.read(struct.calcsize(fmt_WADDirectory))
      entry = WADDirectory._make(struct.unpack(fmt_WADDirectory, entry_data))
      lump_name = entry.lump_name.decode('ascii').rstrip('\x00')
      # https://github.com/rheit/zdoom/blob/4f21ff275c639de4b92f039868c1a637a8e43f49/src/p_glnodes.cpp
      # https://github.com/rheit/zdoom/blob/4f21ff275c639de4b92f039868c1a637a8e43f49/src/p_setup.cpp
      if re.match("E[0-9]M[0-9]",lump_name):
        # read UDMF
        return MAPDirectory(file, lump_name, entry).read(file)
      i += 1
  raise Exception("No entry matching E[0-9]M[0-9] found in WAD: {}".format(mapname))

# compress the given byte string
# raw = True returns an array of bytes (a byte string otherwise)
def compress_byte_str(s,raw=False,more=False):
  b = bytes.fromhex(s)
  min_size = len(b)
  min_off = 8
  min_len = 3
  if more:
    for l in tqdm(range(8), desc="Compression optimization"):
      cc = Codec(b_off = min_off, b_len = l) 
      compressed = cc.toarray(b)
      if len(compressed)<min_size:
        min_size=len(compressed)
        min_len = l      
  
    logging.debug("Best compression parameters: O:{} L:{} - ratio: {}%".format(min_off, min_len, round(100*min_size/len(b),2)))

  # LZSS compressor  
  cc = Codec(b_off = min_off, b_len = min_len) 
  compressed = cc.toarray(b)
  if raw:
    return compressed
  return "".join(map("{:02x}".format, compressed))

def pack_archive(pico_path, carts_path, root, modname, mapname, compress=False, release=None, skybox=None, dump_sprites=False, compress_more=False):
  # resource readers
  maps_stream = FileStream(os.path.join(root, "maps"))
  file_stream = FileStream(os.path.join(root))
  graphics_stream = FileStream(os.path.join(root, "graphics"))

  all_maps = []
  gameinfo = {}
  rounds = [dotdict({
    'duration': 100,
    'label': 'test'
  })]
  if mapname=="":
    # all maps
    logging.info("Packing all mod maps")
    all_maps,gameinfo,rounds = MapinfoReader(file_stream).read()
  else:
    # single map
    logging.info("Packing single map: {}".format(mapname))
    all_maps = [dotdict({
      'name': mapname,
      'group' : mapname[:2].lower(),
      'label': mapname,
      'location': (-1,-1),
      'sky': skybox,
      'music': -1
    })]

  if len(all_maps)>1:
    raise Exception("Too many maps: {} - BBS supports only 1 map.".format(len(all_maps)))

  # extract palette
  colormap = ColormapReader(file_stream)
  gradients = colormap.read("PLAYPAL", use_palette=True) + colormap.read("PAINPAL")

  # decode actors & sprites
  image_reader = ImageReader(graphics_stream, colormap.palette, debug=dump_sprites)
  actors = DecorateReader(file_stream).actors
  
  # cart label (optional) - uses title image
  label_image,label_pal,label_size = pack_p8image(graphics_stream, "G_TITLE", min_size=(128,128), crop=True, label=True)

  # pack actors (shared by all maps)
  game_data = pack_actors(image_reader, actors)
  game_data = compress and compress_byte_str(game_data,more=compress_more) or game_data

  # save png file
  if dump_sprites:
    image_reader.poster.save(os.path.join(carts_path,"{}_sprites.png".format(modname)), "PNG")

  # extract map + things
  cart_len = 2*0x4300
  map_groups = sorted(set(m.group for m in all_maps))

  all_carts = []
  # export maps
  for map_group in map_groups:
      maps = list(m for m in all_maps if m.group==map_group)
      logging.info("Packing map group: {}".format(map_group))

      active_textures = set()
      for m in maps:
        logging.info("Reading map WAD: {}".format(m.name))
        zmap = load_WAD(maps_stream, m.name) 
        m.zmap = zmap
        # records number of secrets
        m.secrets = len([sector for sector in zmap.sectors if sector.special==195])
        active_textures |= get_zmap_textures(zmap)

      # decode textures
      reader = TextureReader(file_stream, colormap.palette)
      textures = reader.read(active_textures)

      skybox_data = ""
      skyboxes = {}
      for i,m in enumerate(maps):
        # locate maps in multicarts
        logging.info("Packing map: {}".format(m.name))
        m.cart_id = int(len(game_data)/cart_len)
        m.cart_offset = int((len(game_data)%cart_len)/2)        
        if m.sky:
          if m.sky not in skyboxes:            
            skybox_img,skybox_code,skybox_size = pack_p8image(graphics_stream, m.sky, palette=colormap.palette, mandatory=True, min_size=(2,0), max_size=(2,128))
            skyboxes[m.sky] = dotdict({
              'height': skybox_size[1]-1,
              'offset': int(len(skybox_data)/2)+len(gradients)+0x4300
            })
            skybox_data += skybox_img
          m.sky = skyboxes[m.sky]   
        else:
          m.sky = dotdict({
            'height': 0,
            'offset': 0
          }) 
        # compress each map separately 
        map_data = pack_zmap(m.zmap, textures)
        # things
        map_data += pack_things(m.zmap, actors)

        game_data += compress and compress_byte_str(map_data, more=compress_more) or map_data
      
      # export game cart (hub for maps from same group)
      to_gamecart(carts_path, modname, map_group, textures.width, textures.map, textures.gfx, gradients, skybox_data, compress, release)

  # list of weapons
  wp_anchors = [50,64,78,64,64]
  wp_templates=[
    "1|rectfill|{1},86,{2},94,0|{0}|print|⬅️,52,88,5|{0}|print|{3},{4},88,11",
    "2|rectfill|{1},102,{2},110,0|{0}|print|⬇️,60,94,5|{0}|print|{3},{4},104,11",
    "3|rectfill|{1},86,{2},94,0|{0}|print|➡️,68,88,5|{0}|print|{3},{4},88,11",
    "4|rectfill|{1},70,{2},78,0|{0}|print|⬆️,60,82,5|{0}|print|{3},{4},72,11",
    "5|print|🅾️,60,88,5"
  ]
  wp_wheel_data = "-1|ovalfill|51,81,75,99,0x22"
  for i,wp in enumerate(sorted([wp for wp in actors.values() if 'slotnumber' in wp and wp.kind==ACTOR_KIND.WEAPON], key=lambda wp: wp.slotnumber)):
    name = wp.get('hudlabel',wp.name)
    x0 = wp_anchors[i]
    x1 = wp_anchors[i]
    if i==0:
      # left justified
      x0 -= len(name)*4
    elif i==2:
      # right justified
      x1 += len(name)*4
    else:
      x0 -= len(name)*2
      x1 += len(name)*2
    wp_wheel_data += "|" + wp_templates[wp.slotnumber-1].format(wp.slotnumber,x0-1,x1-1,name,x0)

  # get loading game image
  logging.info("Packing title images")  
  title_images = dotdict({
    'title': pack_p8image(graphics_stream, "G_TITLE", swap=True, mandatory=True, min_size=(128,140),max_size=(128,140)),    
    'loading': pack_p8image(graphics_stream, "G_LOAD", palette=colormap.palette, swap=True, mandatory=True)
  })

  m = all_maps[0]
  atlas_code="""
-- *********************************
-- generated code - do not edit
-- *********************************
mod_name,title_cart="{0}","{0}_0"
_map_offset=0x{1:04x}
local _sky_height,_sky_offset={2},0x{3:04x}
_map_music={4}
_wp_wheel=split("{5}","|")
  """.format(
  modname,
  0x8000 + m.cart_id * 0x4300 + m.cart_offset,
  m.sky.height,m.sky.offset,
  m.music,
  wp_wheel_data)

  with open(os.path.join(carts_path, "{}_atlas.lua".format(modname)), "w", encoding='utf-8') as f:
    f.write(atlas_code)

  title_code="""\
pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- {0}
-- by @freds72
-- bootstrap cart
-- *********************************
-- generated code - do not edit
-- *********************************
#include {0}_atlas.lua
{1}
_maps_label=split"{2}"
_maps_loc=split("{3}",",",1)
_credits=split"{4}"
_secrets=split("{5}",",",1)
#include {6}
""".format(
  modname,
  "\n".join(['{0}_gfx={{bytes="{1}",pal={{{2}}},w={3[0]},h={3[1]}}}'.format(k,bytes_to_base255(bytes.fromhex(data[0])),data[1],data[2]) for k,data in title_images.items()]),
  ",".join(["{}".format(m.label) for m in all_maps]),
  ",".join(["{0[0]},{0[1]}".format(m.location) for m in all_maps]),
  gameinfo.get('credits',""),
  ",".join(["{}".format(m.secrets) for m in all_maps]),
  release and "{}_title_mini.lua".format(modname) or "title.lua")

  dat1_code="""\
pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- {0}
-- by @freds72
-- bootstrap cart
-- *********************************
-- generated code - do not edit
-- *********************************
-- extended memory support
poke(0x5f36,0x10)
memcpy(0xc300,0x0,0x3d00)
load("{0}_{1}.p8",nil,stat(6)) 
""".format(modname, m.group)

  to_multicart(game_data, pico_path, carts_path, modname, boot_code=(title_code, dat1_code), label=label_image)

  if release:
    all_carts = []
    for i in range(int(len(game_data)/cart_len)+1):
      all_carts.append(i)
    all_carts += map_groups

    # minifying main
    minify_file(os.path.join(carts_path, "main.lua"), os.path.join(carts_path, "{}_main_mini.lua".format(modname)))
    minify_file(os.path.join(carts_path, "title.lua"), os.path.join(carts_path, "{}_title_mini.lua".format(modname)))

    logging.info("Generating {} binaries".format(release))

    # pico8 command line export is totally broken :/
    # pack_release(modname, pico_path, carts_path, all_carts, release, mode="bin")
    pack_release(modname, pico_path, carts_path, all_carts, release, mode="html")

def to_float(n):
  return float((n-0x100000000)/65535.0) if n>0x7fffffff else float(n/65535.0)

def get_PVS(zmap, sub_id):
  vertices = zmap.vertices + [(to_float(v[0]),to_float(v[1])) for v in zmap.other_vertices]

  # init PVS for sector
  pvs = set()
  # already processed portal pairs
  pairs = set()
  portals = []
  clips = []
  # starting sub sector
  sub0 = zmap.sub_sectors[sub_id]
  s0 = sub0[len(sub0)-1]
  for i in range(len(sub0)):
    s1 = sub0[i]
    # only double-sided segments are relevant
    if s0.partner!=-1:
      # portal plane
      portal0 = Polygon(v0=s0.v1, v1=s1.v1, vertices=vertices)
      # connected sub-sectors are visible
      pvs.add(s0.partner)
      pairs.add("{}:{}".format(sub_id, s0.partner))

      sub1 = zmap.sub_sectors[s0.partner]
      # find all anti-portals
      os0 = sub1[len(sub1)-1]
      for j in range(len(sub1)):
        os1 = sub1[j]
        # only double-sided segments are relevant
        if os0.partner!=-1:
          portal1 = Polygon(v0=os0.v1, v1=os1.v1, vertices=vertices)
          if portal0.classify(portal1)!=POLYGON_CLASSIFICATION.BACK:
            
            clips.append(Polygon(v0=portal1.v1,v1=portal0.v0, vertices=vertices))
            clips.append(Polygon(v0=portal0.v1,v1=portal1.v0, vertices=vertices))

            portals.append(dotdict({
              'src':portal0,
              'dst':portal1,
              'sub_id':os0.partner
            }))
            pairs.add("{}-{}:{}-{}".format(portal0.v0, portal0.v1, portal1.v0, portal1.v1))
            # print("portal: {}:{} -> {}".format(0, s0.partner, os0.partner))
        os0 = os1
    s0 = s1
  

  # clip portals
  while len(portals)>0:
    portal = portals.pop()
    # antipenumbra region
    clip0 = Polygon(v0=portal.dst.v1,v1=portal.src.v0, vertices=vertices)
    clip1 = Polygon(v0=portal.src.v1,v1=portal.dst.v0, vertices=vertices)

    # check all segs from the other side of the destination portal
    sub0 = zmap.sub_sectors[portal.sub_id]
    s0 = sub0[len(sub0)-1]
    for i in range(len(sub0)):
      s1 = sub0[i]
      seg = Polygon(v0=s0.v1, v1=s1.v1, vertices=vertices)
      # exclude front segments
      classification = seg.classify(portal.dst)
      if classification==POLYGON_CLASSIFICATION.BACK or classification==POLYGON_CLASSIFICATION.STRADDLING:
        front, back = seg.split(clip0)
        if front is not None:
          front, back = front.split(clip1)
          if front is not None:
            # anything remains?
            pvs.add(portal.sub_id)
            clips.append(front)
            # is seg connected?
            # next_portal = "{}:{}".format(portal.sub_id, s0.partner)
            next_portal = "{}-{}:{}-{}".format(portal.src.v0, portal.src.v1, front.v0, front.v1)
            if s0.partner!=-1 and next_portal not in pairs:
              portals.append(dotdict({
                'src': portal.src,
                'dst': front,
                'sub_id': s0.partner
              }))
              pairs.add(next_portal)
              #print("*portal*: {}".format(next_portal))
      s0 = s1
      
  #print("pvs: {}".format(pvs))
  # remove self from PVS
  if sub_id in pvs: pvs.remove(sub_id)
  return (pvs, clips, vertices)

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--pico-home", required=True, type=str, help="Full path to PICO8 folder")
  parser.add_argument("--carts-path", required=True,type=str, help="Path to carts folder where game is exported")
  parser.add_argument("--mod-name", required=True,type=str, help="Game cart name (ex: poom)")
  parser.add_argument("--map", type=str, default="", required=False, help="Map name to compile (ex: E1M1)")
  parser.add_argument("--compress", action='store_true', required=False, help="Enable compression (default: false)")
  parser.add_argument("--compress-more", action='store_true', required=False, help="Brute force search of best compression parameters. Warning: takes time (default: false)")
  parser.add_argument("--release", required=False,  type=str, help="Generate html+bin packages with given version. Note: compression mandatory if number of carts above 16.")
  parser.add_argument("--sky", required=False, type=str, help="Skybox texture name (only for single map compilation)")
  parser.add_argument("--dump-sprites", action='store_true', required=False, help="Writes all sprites to a single image with their 16x16 tile overlay.")
  args = parser.parse_args()

  logging.basicConfig(level=logging.INFO)
  
  pack_archive(args.pico_home, args.carts_path, os.path.curdir, args.mod_name, args.map, compress=args.compress or args.compress_more, release=args.release, skybox=args.sky, dump_sprites=args.dump_sprites, compress_more=args.compress_more)
  logging.info('DONE')

if __name__ == '__main__':
    main()

