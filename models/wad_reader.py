import struct
import os
import re
import io
import math
from collections import namedtuple
from udmf_reader import UDMF
from dotdict import dotdict

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

SUBSECTORHeader = namedtuple('SUBSECTORHeader', 
    ("v1,partner,lineword,side")
    )
fmt_SUBSECTORHeader = '<2iHc'

ZNODEHeader = namedtuple('ZNODEHeader', 
    ("x,y,dx,dy,top0,bottom0,left0,right0,top1,bottom1,left1,right1,child0,child1")
    )
fmt_ZNODEHeader = '<4h4h4h2i'

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
    znodes=dotdict()
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
    znodes['vertices'] = vertices

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
        header_data = file.read(struct.calcsize(fmt_SUBSECTORHeader))
        header = SUBSECTORHeader._make(struct.unpack(fmt_SUBSECTORHeader, header_data))
        print("{}".format(header.v1, header.lineword))
        segs.append(header)
      sub_sectors.append(segs)
    znodes['sub_sectors'] = sub_sectors
    # bsp nodes
    num_nodes = int.from_bytes(file.read(4), 'little')
    print("znodes: {}".format(num_nodes))
    nodes = []
    for i in range(0, num_nodes):
      header_data = file.read(struct.calcsize(fmt_ZNODEHeader))
      header = ZNODEHeader._make(struct.unpack(fmt_ZNODEHeader, header_data))
      if header.child0 & 0x80000000 != 0:
        print("sub-sector 0: {}".format(len(sub_sectors[header.child0 & 0x7FFFFFFF])))  
      else:
        print("child node 0: {}".format(nodes[header.child0]))
      nodes.append(header)
    
class MAPWriter():
  def __init__(self):
    # export data
    s = pack_variant(len(sectors))
    for sector in sectors:
      s += pack_int(sector.heightceiling)
      s += pack_int(sector.heightfloor)

    s += pack_variant(len(sides))
    for side in sides:
      s += pack_variant(side.sector+1)

    s += pack_variant(len(vertices))
    for v in vertices:
      s += lua_vector(v)

    s += export_bsp_tree(tree, 0)

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
    maps[mapname].read(file)
  
load_WAD("C:\\Users\\fsouchu\\Documents\\e1m1.wad", "E1M1")