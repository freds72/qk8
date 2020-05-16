import struct
import os
import re
from collections import namedtuple

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


def load_WAD(filepath):
  with open(filepath, 'rb') as file:
    # read file header
    header_data = file.read(struct.calcsize(fmt_WADHeader))
    header = WADHeader._make(struct.unpack(fmt_WADHeader, header_data))

    print("WAD type: {}".format(header.type))

    # go to directory
    file.seek(header.dir_ofs)
    for i in range(0,header.dir_size):
      entry_data = file.read(struct.calcsize(fmt_WADDirectory))
      entry = WADDirectory._make(struct.unpack(fmt_WADDirectory, entry_data))
      lump_name = entry.lump_name.decode('ascii').rstrip('\x00')
      # https://github.com/rheit/zdoom/blob/4f21ff275c639de4b92f039868c1a637a8e43f49/src/p_glnodes.cpp
      # https://github.com/rheit/zdoom/blob/4f21ff275c639de4b92f039868c1a637a8e43f49/src/p_setup.cpp
      if lump_name == "ZNODES":
        file.seek(entry.lump_ofs)
        header_data =  file.read(struct.calcsize(fmt_ZNODESHeader))
        header = ZNODESHeader._make(struct.unpack(fmt_ZNODESHeader, header_data))
        print("ZNODES type: {}".format(header.type))
        header_data = file.read(struct.calcsize(fmt_VERTEXHeader))
        header = VERTEXHeader._make(struct.unpack(fmt_VERTEXHeader, header_data))
        print("map verts: {} / extra verts: {}".format(header.verts_size, header.additional_verts_size))
        for i in range(0, header.additional_verts_size):
          print("{:04X} / {:04X}".format(
            int.from_bytes(file.read(4), 'little'),
            int.from_bytes(file.read(4), 'little')))
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
        print("segs (check): {} / {}".format(segs_size, segs_total))
        for n in segs:
          print("seg#: {}".format(n))
          for i in range(0,n):
            header_data = file.read(struct.calcsize(fmt_SUBSECTORHeader))
            header = SUBSECTORHeader._make(struct.unpack(fmt_SUBSECTORHeader, header_data))
            print("{}".format(header.v1, header.lineword))
        num_nodes = int.from_bytes(file.read(4), 'little')
        print("znodes: {}".format(num_nodes))
        for i in range(0, num_nodes):
            header_data = file.read(struct.calcsize(fmt_ZNODEHeader))
            header = ZNODEHeader._make(struct.unpack(fmt_ZNODEHeader, header_data))
            if header.child0 & 0x80000000 != 0:
              print("sub-sector 0: {}".format(header.child0 & 0x7FFFFFFF))  
            else:
              print("child node 0: {}".format(header.child0))            
        #    v0 = int.from_bytes(file.read(4), 'little')
        #    v1 = int.from_bytes(file.read(4), 'little')
        #    # linedef
        #    file.read(2)
        #    # front/back
        #    file.read(1)
        #    print("v0: {} - v1: {}".format(v0,v1))
        break

load_WAD("C:\\Users\\fsouchu\\Documents\\e1m1.wad")