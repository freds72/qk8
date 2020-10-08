import struct
import os
import re
import io
import math
import logging
import argparse
import sys
import pygame

from collections import namedtuple
from dotdict import dotdict
from bsp_compiler import Polygon
from bsp_compiler import POLYGON_CLASSIFICATION
from bsp_compiler import normal,ortho
from image_reader import ImageReader
from wad_stream import WADStream
from file_stream import FileStream

from wad_reader import load_WAD
from wad_reader import get_PVS

black = 0, 0, 0
white = (255, 255, 255)
grey = (128, 128, 128)
red = (255, 0, 0)
dark_red = (128, 0 , 0)
yellow = (255, 0, 255)
blue = (0,0,255)
light_blue = (128, 128, 255)
green = (0,255,0)

map_offset = [320,320]
map_scale = 1

def project(v):
  global map_scale
  return (v[0]*map_scale+map_offset[0],map_offset[1]-v[1]*map_scale)

def draw_plane(surface, v0, v1, color):
  pygame.draw.line(surface, color, project(v0), project(v1), 2)
  x = (v0[0]+v1[0])/2
  y = (v0[1]+v1[1])/2
  n = normal(ortho(v0,v1))
  n = (x + 8*n[0], y + 8*n[1])
  pygame.draw.line(surface, light_blue, project((x,y)), project(n), 2)

def display_WAD(root, mapname, ssid):
    maps_stream = FileStream(os.path.join(root, "maps"))

    zmap = load_WAD(maps_stream, mapname)  
    
    pvs, clips, vertices = get_PVS(zmap, ssid)

    #  debug display
    pygame.init()

    size = width, height = 640, 640
    screen = pygame.display.set_mode(size)
    my_font = pygame.font.SysFont("Courier", 16)
    my_bold_font = pygame.font.SysFont("Courier", 16, bold=1)
    
    clock = pygame.time.Clock()

    old_offset = [0,0]
    mouse_pos = [0,0]
    mouse_held = False
    while 1:
      global map_scale
      for event_var in pygame.event.get():
        if event_var.type == pygame.QUIT:
            pygame.quit()
            return
        elif event_var.type == pygame.MOUSEBUTTONDOWN:
          if event_var.button==4:
            map_scale += 0.5
          elif  event_var.button==5:
            map_scale -= 0.5
            map_scale = max(map_scale, 0.5)
          else:
            old_offset[0] = map_offset[0]
            old_offset[1] = map_offset[1]
            mouse_pos[0],mouse_pos[1] = pygame.mouse.get_pos()
            mouse_held = True
        elif event_var.type == pygame.MOUSEMOTION:
          if mouse_held:
            mx,my = pygame.mouse.get_pos()
            map_offset[0] = old_offset[0] + (mx-mouse_pos[0])
            map_offset[1] = old_offset[1] + (my-mouse_pos[1])
        elif event_var.type == pygame.MOUSEBUTTONUP:
          mouse_held = False
        elif event_var.type == pygame.KEYUP:
          if event_var.key == pygame.K_LEFT:
            ssid -= 1
            ssid = max(ssid, 0)
            pvs, clips, vertices = get_PVS(zmap, ssid)
          elif event_var.key == pygame.K_RIGHT:
            ssid += 1
            pvs, clips, vertices = get_PVS(zmap, ssid)

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
        color = grey
        if k in pvs:
          font = my_bold_font
          color = green
        the_text = font.render("{}".format(k), True, color)
        screen.blit(the_text, project((xc, yc)))
      # portals
      #for portal in portals:
      #  # draw frustrum
      #  draw_plane(screen, vertices[portal.dst.v1], vertices[portal.src.v0], yellow)
      #  draw_plane(screen, vertices[portal.src.v1], vertices[portal.dst.v0], yellow)

      for portal in clips:
        # draw frustrum
        pygame.draw.line(screen, blue, project(vertices[portal.v0]), project(vertices[portal.v1]), 2)

      pygame.display.update()
      pygame.display.flip()
      clock.tick(30)

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument("--sector", type=int, required=False, default=0, help="sub-sector identifier")
  parser.add_argument("--map", type=str, help="map name to compile (ex: E1M1)")
  args = parser.parse_args()

  logging.basicConfig(level=logging.INFO)

  display_WAD(os.path.curdir, args.map, args.sector)

if __name__ == '__main__':
    main()
