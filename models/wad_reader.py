import struct
import os
import re
import io
import math
from collections import namedtuple
from udmf_reader import UDMF
from textures_reader import WADTextureReader
from decorate_reader import ACTORS
from decorate_reader import ACTOR_KIND
from dotdict import dotdict
from python2pico import pack_int
from python2pico import pack_variant
from python2pico import pack_fixed
from python2pico import pack_byte
from python2pico import to_multicart
from python2pico import pack_int32
from python2pico import pack_short
from bsp_compiler import Polygon
from bsp_compiler import POLYGON_CLASSIFICATION
from bsp_compiler import normal,ortho
from image_reader import WADImageReader

# debug/draw
import sys, pygame

# helper funcs
def get_or_default(owner, name, default):
  return name in owner and owner[name] or default

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
  def __init__(self,file, name, entry):
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
      print("{}: section: {}".format(name, lump_name))
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
    print("ZNODES type: {}".format(header.type))
    header_data = file.read(struct.calcsize(fmt_VERTEXHeader))
    header = VERTEXHeader._make(struct.unpack(fmt_VERTEXHeader, header_data))
    print("map verts: {} / extra verts: {}".format(header.verts_size, header.additional_verts_size))
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
    return "04080202"
  return pack_texture(textures[name])

def pack_lightlevel(owner, name):
  if name in owner:
    return "{:02x}".format(4-int(owner[name]))
  return "04"

def pack_aabb(aabb):
  s = ""
  for v in aabb:
    s += pack_fixed(v)
  return s

# find all sectors
def find_sectors_by_tag(tag, sectors):
  return [i for i,sector in enumerate(sectors) if 'id' in sector and sector.id==tag]

def pack_sectors_by_tag(ids):
  s = pack_variant(len(ids))
  for id in ids:
    s += pack_variant(id+1)
  return s

def find_other_sectors(id, lines, sides, sectors):
  # find sector sides
  all_sides = [i for i,side in enumerate(sides) if side.sector==id]
  other_sectors = [sectors[sides[line.sidefront].sector] for line in lines if line.sideback in all_sides and line.sidefront!=-1] + [sectors[sides[line.sideback].sector] for line in lines if line.sidefront in all_sides and line.sideback!=-1]
  if len(other_sectors)<1:
    raise Exception("Sector: {} missing reference sector".format(id))
  return other_sectors

def pack_special(line, lines, sides, sectors):
  special = line.special
  s = "{:02x}".format(special)
  # door open
  if special==202:
    print("generic door")
    sector_ids = find_sectors_by_tag(line.arg0, sectors)
    s += pack_sectors_by_tag(sector_ids)
    # speed
    s += "{:02x}".format(line.arg1)
    # door type
    s += "{:02x}".format(get_or_default(line,'arg2',0)) 
    # delay
    s += "{:02x}".format(get_or_default(line,'arg3',10))
    # lock
    s += pack_variant(get_or_default(line,'arg4',0))
  elif special==64:
    print("platform up/stay/down special")
    sector_ids = find_sectors_by_tag(line.arg0, sectors)
    if len(sector_ids)>1:
      raise Exception("Not supported - multiple elevators for 1 trigger")
    sector_id = sector_ids[0]
    sector = sectors[sector_id]
    other_sectors = find_other_sectors(sector_id, lines, sides, sectors)
    # find floor just above elevator floor
    other_floor = min([other_sector.heightfloor for other_sector in other_sectors if other_sector.heightfloor>sector.heightfloor])
    # elevator sector
    s += pack_variant(sector_id + 1)
    # target height
    s += pack_fixed(other_floor)
    # speed
    s += "{:02x}".format(line.arg1)
  elif special==80:
    # script execute
    # function ID
    s += "{:02x}".format(line.arg0)
    # arg1
    s += "{:02x}".format(line.arg1)
  return s

# returns reference to image frame(s) (multiple sides if any)
def get_image_frames(lumps,image,variant):
  pattern = "{}{}".format(image,variant)
  frames = []
  if pattern+"1" in lumps:
    # multi-sided image
    angles = [
      re.compile("({}{}1)".format(image,variant)),
      re.compile("({}{}2)".format(image,variant)),
      re.compile("({}{}3)".format(image,variant)),
      re.compile("({}{}4)".format(image,variant)),
      re.compile("({}{}5)".format(image,variant)),
      re.compile("({}{}6)|({}{}4{}6)".format(image,variant,image,variant,variant)),
      re.compile("({}{}7)|({}{}3{}7)".format(image,variant,image,variant,variant)),
      re.compile("({}{}8)|({}{}2{}8)".format(image,variant,image,variant,variant))]
    for angle in angles:
      match = [m for m in map(angle.match, lumps) if m is not None][0]
      if match:
        if match.group(1):
          frames.append((match.string, False))
        elif match.group(2):
          frames.append((match.string, True))
      else:
        raise Exception("Missing angle: {} for image: {} {}".format(angle,image,variant))
  elif pattern+"0" in lumps:
    # single image
    frames.append((pattern+"0",False))
  else:
    raise Exception("Missing image: {} {}".format(image,variant))
  return frames

def pack_thing(thing, actors):
  if thing.type not in [actor.id for actor in actors]:
    raise Exception("Thing: {} references unknown actor: {}".format(thing, thing.type))

  # id
  s = pack_variant(thing.type)
  s += pack_fixed(thing.x)
  s += pack_fixed(thing.y)
  s += pack_variant(thing.get('angle',0))
  return s

def pack_flag(owner, name):
  return owner.get(name,False) and 1 or 0

def pack_zmap(map, textures):
  # shortcut to wall textures
  flats = textures.flats

  # export data
  s = pack_variant(len(map.sectors))
  for sector in map.sectors:
    # see: https://zdoom.org/wiki/Sector_specials
    s += "{:02x}".format(sector.special)
    s += pack_int(sector.heightceiling)
    s += pack_int(sector.heightfloor)
    # sector ceiling/floor textures
    s += pack_named_texture(sector, flats, 'textureceiling')
    s += pack_named_texture(sector, flats, 'texturefloor')
    # lights
    s += pack_lightlevel(sector, 'lightceiling')
    s += pack_lightlevel(sector, 'lightfloor')
            
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
  
  s += pack_variant(len(map.sub_sectors))
  for i in range(len(map.sub_sectors)):
    s += pack_segs(map.sub_sectors[i])
    # PVS
    pvs,clips,vert = get_PVS(map, i)
    s += pack_variant(len(pvs)+1)
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

  s += pack_variant(len(flats))
  for name,texture in flats.items():
    s+= pack_texture(texture)
    # get pair or self
    s+= pack_texture(texture_pairs.get(name, texture))
  return s

def pack_ratio(x):
  if x<0 or x>255:
    raise Exception("Invalid ratio: {}, must be in range [0;1]".format(x))
  return pack_byte(int(255*x))

def pack_actors(file, lumps, map, actors, palette):
  s = ""
  # actors/inventory (e.g. items with assigned unique id)
  concrete_actors = [actor for actor in actors.values() if actor.id!=-1]
  
  # collect active images
  images = []
  image_reader = WADImageReader(palette)
  frames_by_name = {}
  for actor in concrete_actors:
    for state in [state for state in actor._states if 'image' in state]:
      image_name = "{}{}".format(state.image,state.variant)
      frames = get_image_frames(lumps, state.image, state.variant)
      frames_by_name[image_name] = frames
      # remove "flipped" duplicate sprites for serialization
      for frame in [frame for frame in frames if frame[1]==False]:
        images.append(image_reader.read(file, lumps, frame[0]))
  
  s += pack_variant(len(images))
  # export frame metadata
  tiles_count = 0
  sprites = {}
  for i,image_data in enumerate(images):
    print("Packing sprite: {}".format(image_data.name))
    sprites[image_data.name] = i
    s += "{:02x}".format(image_data.width|image_data.background<<4)
    s += pack_short(image_data.xoffset)
    s += pack_short(image_data.yoffset)
    tiles = image_data.tiles
    s += pack_variant(len(tiles))
    for i,tile in tiles.items():
      s += "{:02x}{}".format(i,pack_variant((tiles_count+tile)*32+1))
    tiles_count += len(tiles)

  # export all images bytes
  if tiles_count>32763-32:
    # exceeded pico8 array size?
    raise Exception("Tiles count ({}) exceeds PICO8 table size - not yet supported".format(tiles_count))
  print("Packing {} 16x16 tiles".format(tiles_count))
  image_s = pack_variant(tiles_count)
  for image_bytes in [img.data for img in images]:
    for b in image_bytes:
      image_s += "{:02x}".format(b)
  s += image_s

  # know state names
  # max: 16
  all_states = ['Spawn','Idle','See','Melee','Missile','Death','XDeath','Ready','Hold','Fire','Pickup']

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
    flags = pack_flag(actor, 'solid') | pack_flag(actor, 'shootable')<<1 | pack_flag(actor, 'missile')<<2
    s += "{:02x}".format(flags)
    
    ################## properties
    properties = 0
#{0x0.0001,"health"},
#{0x0.0002,"armor"},
#{0x0.0004,"amount"},
#{0x0.0008,maxamount"},
#{0x0.000a,"icon",function() return chr(mpeek()) end},
#{0x0.000c,"slot",mpeek},
#{0x0.000f,"ammouse",unpack_actor_ref},
#{0x0.0010,"speed"},
#{0x0.0020,"damage"},
#{0x0.0040,"ammotype"},
    properties_data = ""
    if actor.get('health'):
      properties |= 0x1
      properties_data += pack_variant(actor.health)
    if actor.get('armor'):
      properties |= 0x2
      properties_data += pack_variant(actor.armor)
    if actor.get('amount'):
      properties |= 0x4
      properties_data += pack_variant(actor.amount)
    if actor.get('maxamount'):
      properties |= 0x8
      properties_data += pack_variant(actor.maxamount)
    if actor.get('icon'):
      properties |= 0x10
      properties_data += "{:02x}".format(actor.get('icon',63))
    if actor.get('slotnumber'):
      properties |= 0x20
      properties_data += "{:02x}".format(actor.slotnumber)
    if actor.get('ammouse'):
      properties |= 0x40
      properties_data += pack_variant(actor.ammouse)
    if actor.get('speed'):
      properties |= 0x80
      properties_data += pack_variant(actor.speed)
    if actor.get('damage'):
      properties |= 0x100
      properties_data += pack_variant(actor.damage)
    if actor.get('ammotype'):
      properties |= 0x200
      properties_data += pack_variant(actor.ammotype)
    if actor.get('startitems'):
      properties |= 0x400
      startitems = actor.startitems
      properties_data += pack_variant(len(startitems))
      for si in startitems:
        # other actor reference
        properties_data += pack_variant(si[0])
        # amount
        properties_data += pack_variant(si[1])
    if actor.get('mass'):
      properties |= 0x800
      properties_data += pack_variant(actor.mass)      
    s += pack_int32(properties)
    s += properties_data
  
    # class properties
    if actor.kind==ACTOR_KIND.WEAPON:
      s += pack_variant(actor.ammogive)

    if actor.kind==ACTOR_KIND.AMMO:
      # ammo variants (normal, large) are tied to their parent type
      s += pack_variant(actor.get('parent',actor.id))
    
    ############ states
    # export state jump table
    s += pack_variant(len(actor._labels))
    for state_label,state_address in actor._labels.items():
      if state_label not in all_states:
        raise Exception("Unkown state: {} for actor: {} - Custom state names are not supported.".format(state_label.actor.name))
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
        state_s += pack_fixed(state.ticks)
        pattern = "{}{}".format(state.image,state.variant)
        frames = frames_by_name[pattern]
        # flipped?
        flipbits = 0
        for i,frame in enumerate(frames):
          flipbits|=(frame[1]==True and 1 or 0)<<i
        state_s += "{:02x}".format(flipbits)
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
  # things
  s += pack_variant(len(map.things))
  for thing in map.things:
    s += pack_thing(thing, concrete_actors)

  return s

def read_palette(file, lumps):
  entry = lumps.get("PLAYPAL",None)
  if not entry:
    raise Exception("Missing 'PLAYPAL' palette in WAD")
  
  file.seek(entry.lump_ofs)
  palette_data = file.read(entry.lump_size)
  if len(palette_data)!=16*16*3:
    raise Exception("Invalid 'PLAYPAL' palette size: {} - must be 16*16*3".format(len(palette_data)))
  palette = []
  for i in range(0,16*16*3,3*16):
    i += 3*8
    r,g,b = palette_data[i],palette_data[i+1],palette_data[i+2]
    palette.append((r,g,b,255))
  return palette

# RGB to pico8 color index
rgb_to_pico8={
  "0x000000":0,
  "0x1d2b53":1,
  "0x7e2553":2,
  "0x008751":3,
  "0xab5236":4,
  "0x5f574f":5,
  "0xc2c3c7":6,
  "0xfff1e8":7,
  "0xff004d":8,
  "0xffa300":9,
  "0xffec27":10,
  "0x00e436":11,
  "0x29adff":12,
  "0x83769c":13,
  "0xff77a8":14,
  "0xffccaa":15,
  "0x291814":128,
  "0x111d35":129,
  "0x422136":130,
  "0x125359":131,
  "0x742f29":132,
  "0x49333b":133,
  "0xa28879":134,
  "0xf3ef7d":135,
  "0xbe1250":136,
  "0xff6c24":137,
  "0xa8e72e":138,
  "0x00b543":139,
  "0x065ab5":140,
  "0x754665":141,
  "0xff6e59":142,
  "0xff9d81":143}

# returns a pico8 compatible array of gradients from a WAD palette entry
def read_gradient(name, file, lumps, palette = None):
  entry = lumps.get(name,None)
  if entry is None:
    raise Exception("Unable to find: {} palette in WAD.".format(name))
  file.seek(entry.lump_ofs)
  palette_data = file.read(entry.lump_size)

  # align color formats
  if palette is not None:
    palette = ["0x{:02x}{:02x}{:02x}".format(pal[0],pal[1],pal[2]) for pal in palette]

  # transpose
  columns = [[] for i in range(16)]
  for i,rgb in enumerate(["0x{:02x}{:02x}{:02x}".format(palette_data[i],palette_data[i+1],palette_data[i+2]) for i in range(0,3*16*16,3)]):
    if palette is None:
      # get hardware color (inc. extended color ids)
      p8 = rgb_to_pico8.get(rgb, None)
      if p8 is None:
        raise Exception("Unknown PICO8 color: {} in palette: {}".format(rgb, name))
    else:
      # remap hardware color identifiers (0-15/129-145) to palette index (0-15) (for shading gradients)
      if rgb not in palette:
        raise Exception("Unable to reference: {}  in remap palette: {}".format(rgb,palette))
      p8 = palette.index(rgb)
    c = i%16
    columns[c].append(p8)
  # flatten list
  return [item for sublist in columns for item in sublist]

# generate main game cart
def pack_sprite(arr):
    return ["".join(map("{:02x}".format,arr[i*4:i*4+4])) for i in range(8)]

def to_gamecart(name,width,map_data,gfx_data,palette):
    cart="""\
pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- poom
-- @freds72
#include main.lua
"""
    # transpose gfx
    gfx_data=[pack_sprite(data) for data in gfx_data]
    print("Packing {} texture tiles".format(len(gfx_data)))

    s = ""
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
    # fill until spritesheet 2
    s += "0"*(128*64-len(s))

    # palette (e.g. gradients or screen palettes)
    #print("\n".join([" ".join(map("{:02x}".format,palette[i:i+16])) for i in range(0,len(palette),16)]))
    tmp = "".join(map("{:02x}".format,palette))
    # preserve byte orders
    for i in range(0,len(tmp),2):
      s += tmp[i+1:i+2] + tmp[i:i+1]

    # convert to string
    cart += "__gfx__\n"
    cart += re.sub("(.{128})", "\\1\n", s, 0, re.DOTALL)
    cart += "\n"

    # pad map
    map_data = ["".join(map("{:02x}".format,map_data[i:i+width] + [0]*(128-width))) for i in range(0,len(map_data),width)]
    map_data = "".join(map_data)
    cart += "__map__\n"
    cart += re.sub("(.{256})", "\\1\n", map_data, 0, re.DOTALL)

    cart_path = os.path.join(local_dir, "..", "carts", "{}.p8".format(name))
    f = open(cart_path, "w")
    f.write(cart)
    f.close()

# ################## compression #########################
def requiredBits(value):
    bits = 1
    while(value > 0):
        bits+=1
        value = value >> 1
    return bits

# https://github.com/coells/100days
def lzw_encode(data):
    code, code_bits = {bytes([i]): i for i in range(256)}, 8
    buffer, buffer_bits = 0, 0
    index, aux = 0, []

    while index < len(data):
        # find word
        for j in range(index + 1, len(data) + 1):
            word = data[index:j]

            # store word
            if word not in code:
                code[word] = len(code)
                word = word[:-1]
                break

        # write buffer
        buffer <<= code_bits
        buffer |= code[word]
        buffer_bits += code_bits

        # code length
        if len(code) > 2 ** code_bits:
            code_bits += 1

        # shift
        index += len(word)

        # buffer alignment
        if index >= len(data) and buffer_bits % 8:
            r = 8 - (buffer_bits % 8)
            buffer <<= r
            buffer_bits += r

        # emit output
        if not buffer_bits % 8:
            aux += int.to_bytes(buffer, buffer_bits >> 3, 'big')
            buffer, buffer_bits = 0, 0

    return bytes(aux)

def load_WAD(filepath,mapname):
  with open(filepath, 'rb') as file:
    # read file header
    header_data = file.read(struct.calcsize(fmt_WADHeader))
    header = WADHeader._make(struct.unpack(fmt_WADHeader, header_data))

    print("WAD type: {}".format(header.type))

    maps = {}
    lumps = {}
    textures_entry = None
    decorate_entry = None
    # go to directory
    file.seek(header.dir_ofs)
    i = 0
    while i<header.dir_size:
      entry_data = file.read(struct.calcsize(fmt_WADDirectory))
      entry = WADDirectory._make(struct.unpack(fmt_WADDirectory, entry_data))
      lump_name = entry.lump_name.decode('ascii').rstrip('\x00')
      # https://github.com/rheit/zdoom/blob/4f21ff275c639de4b92f039868c1a637a8e43f49/src/p_glnodes.cpp
      # https://github.com/rheit/zdoom/blob/4f21ff275c639de4b92f039868c1a637a8e43f49/src/p_setup.cpp
      lumps[lump_name] = entry
      if re.match("E[0-9]M[0-9]",lump_name):
        # read UDMF
        map_dir = MAPDirectory(file, lump_name, entry)
        maps[lump_name] = map_dir
        # skip map entries + ENDMAP
        i += len(map_dir.lumps) + 1
      elif lump_name == 'TEXTURES':
        textures_entry = entry
      elif lump_name == 'DECORATE':
        decorate_entry = entry
      i += 1

    # extract palette
    palette = read_palette(file, lumps)
    gradients = read_gradient("PLAYPAL", file, lumps, palette) + read_gradient("PAINPAL", file, lumps)

    # decode textures
    textures = None
    if textures_entry is not None:
      file.seek(textures_entry.lump_ofs)
      textmap_data = file.read(textures_entry.lump_size).decode('ascii')
      reader = WADTextureReader(palette)
      textures = reader.read(textmap_data, file, lumps)

    # decode actors
    actors = {}
    image_reader = WADImageReader(palette)
    if decorate_entry is not None:
      file.seek(decorate_entry.lump_ofs)
      textmap_data = file.read(decorate_entry.lump_size).decode('ascii')
      actors = ACTORS(textmap_data).actors
    
    # pick map
    zmap = maps[mapname].read(file)
    data = pack_actors(file, lumps, zmap, actors, palette) + pack_zmap(zmap, textures)

    to_multicart(data, "poom")

    to_gamecart("poom",textures.width,textures.map,textures.gfx,gradients)

def to_float(n):
  return float((n-0x100000000)/65535.0) if n>0x7fffffff else float(n/65535.0)

def project(v):
  return (v[0]/4+320,320-v[1]/4)

black = 0, 0, 0
white = (255, 255, 255)
grey = (128, 128, 128)
red = (255, 0, 0)
dark_red = (128, 0 , 0)
yellow = (255, 0, 255)
blue = (0,0,255)
light_blue = (128, 128, 255)

def draw_plane(surface, v0, v1, color):
  pygame.draw.line(surface, color, project(v0), project(v1), 2)
  x = (v0[0]+v1[0])/2
  y = (v0[1]+v1[1])/2
  n = normal(ortho(v0,v1))
  n = (x + 8*n[0], y + 8*n[1])
  pygame.draw.line(surface, light_blue, project((x,y)), project(n), 2)


def get_PVS(zmap, sub_id):
  vertices = zmap.vertices + [(to_float(v[0]),to_float(v[1])) for v in zmap.other_vertices]

  # init PVS for sector 6
  pvs = set()
  # already processed portal pairs
  pairs = set()
  portals = []
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
          if portal0.classify(portal1)==POLYGON_CLASSIFICATION.FRONT:
            portals.append(dotdict({
              'src':portal0,
              'dst':portal1,
              'sub_id':os0.partner
            }))
            pairs.add("{}:{}".format( s0.partner, os0.partner))
            # print("portal: {}:{} -> {}".format(0, s0.partner, os0.partner))
        os0 = os1
    s0 = s1
  
  clips = []
  # clip portals
  while len(portals)>0:
    portal = portals.pop()
    clip0 = Polygon(v0=portal.dst.v1,v1=portal.src.v0, vertices=vertices)
    clip1 = Polygon(v0=portal.src.v1,v1=portal.dst.v0, vertices=vertices)

    # check all segs from the other side of the destination portal
    sub0 = zmap.sub_sectors[portal.sub_id]
    s0 = sub0[len(sub0)-1]
    for i in range(len(sub0)):
      s1 = sub0[i]
      seg = Polygon(v0=s0.v1, v1=s1.v1, vertices=vertices)
      # exclude coplanar segments
      if seg.classify(portal.dst)==POLYGON_CLASSIFICATION.BACK:
        front, back = seg.split(clip0)
        if front is not None:
          front, back = front.split(clip1)
          if front is not None:
            clips.append(front)
            # anything remains?
            pvs.add(portal.sub_id)
            # is seg connected?
            next_portal = "{}:{}".format(portal.sub_id, s0.partner)
            if s0.partner!=-1 and next_portal not in pairs:
              portals.append(dotdict({
                'src': portal.src,
                'dst': front,
                'sub_id': s0.partner
              }))
              pairs.add(next_portal)
              #print("*portal*: {}:{} -> {}".format(0, portal.sub_id, s0.partner))
      s0 = s1

  #print("pvs: {}".format(pvs))
  # remove self from PVS
  if sub_id in pvs: pvs.remove(sub_id)
  return (pvs, clips, vertices)

def display_WAD(filepath,mapname):
  with open(filepath, 'rb') as file:
    # read file header
    header_data = file.read(struct.calcsize(fmt_WADHeader))
    header = WADHeader._make(struct.unpack(fmt_WADHeader, header_data))

    maps = {}
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
        map_dir = MAPDirectory(file, lump_name, entry)
        maps[lump_name] = map_dir
        # skip map entries + ENDMAP
        i += len(map_dir.lumps) + 1
      i += 1

    # pick map
    zmap = maps[mapname].read(file)
    
    pvs, clips, vertices = get_PVS(zmap, 38)

    #  debug display
    pygame.init()

    size = width, height = 640, 640
    screen = pygame.display.set_mode(size)
    my_font = pygame.font.SysFont("Courier", 16)
    my_bold_font = pygame.font.SysFont("Courier", 16, bold=1)

    while 1:
      for event in pygame.event.get():
        if event.type == pygame.QUIT: sys.exit()

      screen.fill(black)

      # draw segments
      for k in range(len(zmap.sub_sectors)):
        segs = zmap.sub_sectors[k]
        n = len(segs)
        s0 = segs[n-1]
        v0 = vertices[s0.v1]
        xc = 0
        yc = 0
        
        for i in range(n):
          s1 = segs[i]
          v1 = vertices[s1.v1]
          xc += v1[0]
          yc += v1[1]
          r = 2
          c = dark_red
          pygame.draw.line(screen, s0.partner==-1 and grey or c, project(v0), project(v1), r)
          s0 = s1
          v0 = v1
        xc /= n
        yc /= n
        font = my_font
        if k in pvs:
          font = my_bold_font
        the_text = font.render("{}".format(k), True, grey)
        screen.blit(the_text, project((xc, yc)))
      # portals
      #for portal in portals:
      #  # draw frustrum
      #  draw_plane(screen, vertices[portal.dst.v1], vertices[portal.src.v0], yellow)
      #  draw_plane(screen, vertices[portal.src.v1], vertices[portal.dst.v0], yellow)

      for portal in clips:
        # draw frustrum
        pygame.draw.line(screen, blue, project(vertices[portal.v0]), project(vertices[portal.v1]), 2)

      pygame.display.flip()

local_dir = os.path.dirname(os.path.realpath(__file__))
load_WAD("{}\\..\\levels\\poom.wad".format(local_dir), "E1M1")
#display_WAD("C:\\Users\\fsouchu\\Documents\\e1m1.wad", "E1M1")

