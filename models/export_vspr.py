import os
from image_reader import ImageReader
from file_stream import FileStream
from colormap_reader import ColormapReader
from python2pico import pack_variant
from python2pico import pack_short
from python2pico import to_multicart

from lzs import *

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
  # export frame metadata & prepare tileset
  tiles_count = 0
  unique_tiles = []
  for image_index,image_data in enumerate(images):
    print("Packing sprite: {}".format(image_data.name))
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
  print("Packing {} 16x16 tiles".format(tiles_count))
  image_s = pack_variant(tiles_count)
  for image_bytes in unique_tiles:
    for b in image_bytes:
      image_s += "{:02x}".format(b)
  s += image_s

  # byte_data = bytes.fromhex(s)
  # cc = Codec(b_off = 8, b_len = 3) 
  # compressed_data = cc.toarray(byte_data) 
  # print("Raw: {} - Compressed: {}(0x{:04x})".format(len(byte_data),len(compressed_data),len(compressed_data)))
 
  # export as cart
  to_multicart(s, "D:\\pico-8_0.2.2",os.path.join(local_dir,"..","carts"),"vsspr")
  # to_multicart(s, "D:\\pico-8_0.2.0",os.path.join(local_dir,"..","carts"),"vsspr")
  # to_multicart(s, "vsspr")




  

  


