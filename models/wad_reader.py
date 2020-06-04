import struct
import os
import re
import io
import math
from collections import namedtuple
from udmf_reader import UDMF
from textures_reader import TEXTURES
from dotdict import dotdict
from python2pico import pack_int
from python2pico import pack_variant
from python2pico import pack_fixed
from python2pico import to_multicart
from python2pico import pack_int32

# helper funcs
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

def pack_texture(owner, textures, name):
  if name not in owner: return "FFFFFFFF"
  # de-reference texture name
  name = owner[name]
  # no texture/blank texture
  if name not in textures: return "FFFFFFFF"
  texture = textures[name]
  return "{:02x}{:02x}{:02x}{:02x}".format(texture.my,texture.mx,texture.height,texture.width)

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
  if special==11:
    print("door open/stay special")
    sector_ids = find_sectors_by_tag(line.arg0, sectors)
    s += pack_sectors_by_tag(sector_ids)
    # speed
    s += "{:02x}".format(line.arg1)
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

def pack_thing(thing):
  print("thing: {}".format(thing.type))
  # id
  s = pack_variant(thing.type)
  s += pack_fixed(thing.x)
  s += pack_fixed(thing.y)
  return s

def pack_zmap(map, textures):
  # export data
  s = pack_variant(len(map.sectors))
  for sector in map.sectors:
    s += pack_int(sector.heightceiling)
    s += pack_int(sector.heightfloor)
    # sector ceiling/floor textures
    s += pack_texture(sector, textures, 'textureceiling')
    s += pack_texture(sector, textures, 'texturefloor')
    # lights
    s += pack_lightlevel(sector, 'lightceiling')
    s += pack_lightlevel(sector, 'lightfloor')
            
  s += pack_variant(len(map.sides))
  for side in map.sides:
    s += pack_variant(side.sector+1)
    s += pack_texture(side, textures, 'texturetop')
    s += pack_texture(side, textures, 'texturemiddle')
    s += pack_texture(side, textures, 'texturebottom')

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
    s += "{:02x}".format(flags)
    s += special_data
  
  s += pack_variant(len(map.sub_sectors))
  for segs in map.sub_sectors:
    s += pack_segs(segs)

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

  s += pack_variant(len(map.things))
  for thing in map.things:
    s += pack_thing(thing)

  to_multicart(s, "poom")

def load_WAD(filepath,mapname):
  with open(filepath, 'rb') as file:
    # read file header
    header_data = file.read(struct.calcsize(fmt_WADHeader))
    header = WADHeader._make(struct.unpack(fmt_WADHeader, header_data))

    print("WAD type: {}".format(header.type))

    maps = {}
    textures_entry = None
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
      elif lump_name == 'TEXTURES':
        textures_entry = entry
      else:
        print("skipping: {}".format(lump_name))
      i += 1

    # decode textures
    textures = {}
    if textures_entry is not None:
      file.seek(textures_entry.lump_ofs)
      textmap_data = file.read(textures_entry.lump_size).decode('ascii')
      textures = TEXTURES(textmap_data).textures

    # pick map
    zmap = maps[mapname].read(file)
    pack_zmap(zmap, textures)

load_WAD("C:\\Users\\fsouchu\\Documents\\e1m1.wad", "E1M1")