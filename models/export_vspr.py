import os
from image_reader import ImageReader
from file_stream import FileStream
from colormap_reader import ColormapReader
from python2pico import pack_variant
from python2pico import pack_short
from python2pico import to_multicart

from lzw import lzw_encode

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
    for i,tile in tiles.items():
      s += "{:02x}{}".format(i,pack_variant((tiles_count+tile)*32+1))
    tiles_count += len(tiles)

  print("Packing {} 16x16 tiles".format(tiles_count))
  image_s = pack_variant(tiles_count)
  for image_bytes in [img.data for img in images]:
    for b in image_bytes:
      image_s += "{:02x}".format(b)
  s += image_s

  raw_data = bytes.fromhex(s)
  compressed_data = lzw_encode(raw_data)
  print("Raw: {} - Compressed: {}(0x{:04x})".format(len(raw_data),len(compressed_data),len(compressed_data)))

  # export as cart
  to_multicart("".join(map("{:02x}".format, compressed_data)), "vsspr")
  # to_multicart(s, "vsspr")

  


