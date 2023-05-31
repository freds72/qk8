import os
import argparse
from PIL import Image, ImageFilter, ImageDraw
from colormap_reader import rgba_palette

mainpal=[0,1,5,13,6,7,130,4,9,10,15,8,14,3,11,12]
painpal=[
  [128,128,130,132,136,136,8],
  [1,133,2,2,136,136,8],
  [5,141,2,136,136,136,8],
  [13,13,134,136,136,136,8],
  [6,14,14,14,142,8,8],
  [7,15,14,14,14,142,8],
  [130,2,2,136,136,136,8],
  [4,4,136,136,136,8,8],
  [9,137,137,137,137,8,8],
  [10,9,137,137,137,142,8],
  [15,143,143,142,142,8,8],
  [8,8,8,8,8,8,8],
  [14,14,14,142,8,8,8],
  [3,5,5,141,2,136,136],
  [139,139,5,5,4,4,136],
  [12,13,13,13,13,136,8]
]

def main():
    pal = rgba_palette()
    index_to_rgb={v:k for k,v in pal.items()}
    with open("painpal.png","wb") as f:
        img = Image.new('RGBA', (16, 16), (0,0,0))
        for j in range(16):
            ramp = painpal[j]            
            for i in range(16):
              c = mainpal[j]
              if i>0 and i<len(ramp):
                  c = ramp[i]
              elif i>=len(ramp):
                  c = 8              
              img.putpixel((i,j),index_to_rgb[c])
        img.save(f)
if __name__ == '__main__':
    main()