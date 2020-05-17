import struct
import os
import re
import io
import math
from collections import namedtuple
from udmf_reader import UDMF
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
SEG = namedtuple('SEG',['v1','line','side'])
AABB = namedtuple('AABB',['top','bottom','left','right'])
ZNODE = namedtuple('ZNODE',['n','d','flags','child','aabb'])
ZMAP = namedtuple('ZMAP',['vertices','other_vertices','lines','sides','sectors','nodes'])

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
    print("subs: {}".format(subs_size))
    segs_total = 0
    segs = []
    for i in range(0, subs_size):
      segs_size = int.from_bytes(file.read(4), 'little')
      print("segs: {}".format(segs_size))
      segs_total += segs_size
      segs.append(segs_size)
    segs_size = int.from_bytes(file.read(4), 'little')
    
    # sub sector sides (segs)
    sub_sectors=[]
    for n in segs:
      print("seg#: {}".format(n))
      segs = []
      for i in range(0,n):
        header_data = file.read(struct.calcsize(fmt_SEGHeader))
        header = SEGHeader._make(struct.unpack(fmt_SEGHeader, header_data))
        print("{}".format(header.v1, header.lineword))
        segs.append(SEG(header.v1, header.lineword==0xFFFF and -1 or header.lineword, header.side))
      sub_sectors.append(segs)
 
    # bsp nodes
    num_nodes = int.from_bytes(file.read(4), 'little')
    print("znodes: {}".format(num_nodes))
    nodes = []
    for i in range(0, num_nodes):
      header_data = file.read(struct.calcsize(fmt_ZNODEHeader))
      header = ZNODEHeader._make(struct.unpack(fmt_ZNODEHeader, header_data))
      n=normal((header.dx,header.dy))
      d=dot(n, (header.x,header.y))
      node = ZNODE(n,d,0x00,[None,None],[None, None])
      # left child
      if header.child0 & 0x80000000 != 0:
        node = node._replace(flags=1)
        node.child[0]=sub_sectors[header.child0 & 0x7FFFFFFF]
      else:
        # actual reference resolved by p8 code
        node.child[0]=header.child0
      # right child
      if header.child1 & 0x80000000 != 0:
        node = node._replace(flags=node.flags|2)
        node.child[1]=sub_sectors[header.child1 & 0x7FFFFFFF]
      else:
        # actual reference resolved by p8 code
        node.child[1]=header.child1
      # bounding boxes
      node.aabb[0] = AABB(header.top0,header.bottom0,header.left0,header.right0)
      node.aabb[1] = AABB(header.top1,header.bottom1,header.left1,header.right1)
      nodes.append(node)
    return ZMAP(udmf.vertices, vertices, udmf.lines, udmf.sides, udmf.sectors, nodes)

# ZMAP export to pico8 format
def pack_segs(segs):
  s = pack_variant(len(segs))
  for seg in segs:
    s += pack_variant(seg.v1+1)
    s += "{:02X}".format(seg.side==0 and 0 or 1)
    s += pack_variant(seg.line+1)
  return s

def pack_zmap(map):
  # export data
  s = pack_variant(len(map.sectors))
  for sector in map.sectors:
    s += pack_int(sector.heightceiling)
    s += pack_int(sector.heightfloor)

  s += pack_variant(len(map.sides))
  for side in map.sides:
    s += pack_variant(side.sector+1)

  s += pack_variant(len(map.vertices)+len(map.other_vertices))
  for v in map.vertices:
    s += pack_fixed(v[0])
    s += pack_fixed(v[1])
  for v in map.other_vertices:
    s += pack_int32(v[0])
    s += pack_int32(v[1])

  s += pack_variant(len(map.lines))
  for line in map.lines:
    print("{} / {}".format(line.sidefront+1,line.sideback+1))
    s += pack_variant(line.sidefront+1)
    s += pack_variant(line.sideback+1)
    flags = 0
    if line.twosided==True:
      flags |= 1
    # todo: other game flags
    s += "{:02X}".format(flags)
  
  s += pack_variant(len(map.nodes))
  for node in map.nodes:
    # n
    s += pack_fixed(node.n[0])
    s += pack_fixed(node.n[1])
    s += pack_fixed(node.d)
    s += "{:02X}".format(node.flags)
    # segs list
    if node.flags & 0x1:
      s += pack_segs(node.child[0])
    else:
      s += pack_variant(node.child[0]+1)
    # segs list
    if node.flags & 0x2:
      s += pack_segs(node.child[1])
    else:
      s += pack_variant(node.child[1]+1)
  print(s)

  to_multicart(s, "poom")

def load_WAD(filepath,mapname):
  with open(filepath, 'rb') as file:
    # read file header
    header_data = file.read(struct.calcsize(fmt_WADHeader))
    header = WADHeader._make(struct.unpack(fmt_WADHeader, header_data))

    print("WAD type: {}".format(header.type))

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
      else:
        print("skipping: {}".format(lump_name))
      i += 1

    # pick map
    zmap = maps[mapname].read(file)
    pack_zmap(zmap)

load_WAD("C:\\Users\\fsouchu\\Documents\\e1m1.wad", "E1M2")