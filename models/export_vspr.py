import os
from image_reader import ImageReader
from file_stream import FileStream
from colormap_reader import ColormapReader
from python2pico import pack_variant
from python2pico import pack_short
from python2pico import to_multicart

from lzs import *

class Flashbits:
  def __init__(self,src):  
    self.src = src
    self.i = 0
    self.mask = 0x01

  def get1(self):
    r = (self.src[self.i] & self.mask) !=0 and 1 or 0
    self.mask <<= 1
    if self.mask>0x80:
      self.mask = 1
      self.i += 1
    return r

  def getn(self,n):
    r = 0
    for i in range(n):
      r <<= 1
      r |= self.get1()
    # print("got: {:02x} i: {}".format(r,self.i))
    return r

def decompress(src):
  dst=bytearray()
  history=bytearray()

  BS = Flashbits(src)
  O = BS.getn(4)
  max_offset = 1<<O
  L = BS.getn(4)
  M = BS.getn(2)
  end = BS.getn(32)
  print("max. offset:{} length:{} min. length:{} total length:{}".format(max_offset,L,M,end))
  while len(dst)<end:
    if BS.get1() == 0:
      v = BS.getn(8)
      dst.append(v)
      history.append(v)
      if len(history)>max_offset:
        history=history[1:]
    else:
      offset = -BS.getn(O) - 1
      length = BS.getn(L) + M
      for k in range(length):
        print("{} : {} = {}".format(len(history),len(history)+offset,history[len(history)+offset]))
        v = history[len(history)+offset]
        # print("offset: {} : {} => {:02x} : {:02x}".format(offset,255+offset,v,history[len(history)+offset]))
        dst.append(v)
        history.append(v)
        if len(history)>max_offset:
          history=history[1:]
    # print("LZ: {}".format(len(dst)))
  return dst

if __name__ == "__main__":
  local_dir = os.path.dirname(os.path.realpath(__file__))
  colormap = ColormapReader(FileStream(os.path.join(local_dir, "..", "mods", "poom")))
  image_reader = ImageReader(FileStream(os.path.join(local_dir, "..", "mods", "poom", "graphics")), colormap.palette)
  # collect images
  images = []
  frames = image_reader.read_frames("CYBR","A")
  frames += image_reader.read_frames("CYBR","B")
  frames += image_reader.read_frames("CYBR","C")
  frames += image_reader.read_frames("CYBR","D")
  # remove "flipped" duplicate sprites for serialization
  for frame in [frame for frame in frames if frame[1]==False]:
    images.append(image_reader.read(frame[0]))
  
  print("Packing {} frames".format(len(images)))

  s = ""
  s += pack_variant(len(images))
  # export frame metadata
  tiles_count = 0
  for i,image_data in enumerate(images):
    print("Packing sprite: {}".format(image_data.name))
    s += "{:02x}".format(image_data.width|image_data.background<<4)
    s += pack_short(image_data.xoffset)
    s += pack_short(image_data.yoffset)
    tiles = image_data.tiles
    s += pack_variant(len(tiles))
    print("Tiles per frame: {}".format(len(tiles)))
    for i,tile in tiles.items():
      s += "{:02x}{}".format(i,pack_variant((tiles_count+tile)*32+1))
    tiles_count += len(tiles)

  print("Packing {} 16x16 tiles".format(tiles_count))
  image_s = pack_variant(tiles_count)
  for image_bytes in [img.data for img in images]:
    for b in image_bytes:
      image_s += "{:02x}".format(b)
  s += image_s

  byte_data = bytes.fromhex(s)
  cc = Codec(b_off = 8, b_len = 3) 
  compressed_data = cc.toarray(byte_data) 
  print("Raw: {} - Compressed: {}(0x{:04x})".format(len(byte_data),len(compressed_data),len(compressed_data)))

  # export as cart
  # uncompressed_data=decompress(compressed_data)
  # to_multicart("".join(map("{:02x}".format, compressed_data)), "D:\\pico-8_0.2.0",os.path.join(local_dir,"..","carts"),"vsspr")
  # to_multicart(s, "D:\\pico-8_0.2.0",os.path.join(local_dir,"..","carts"),"vsspr")
  # to_multicart(s, "vsspr")




  

  


