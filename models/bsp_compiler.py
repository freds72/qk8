import os
from subprocess import Popen, PIPE
import re
import tempfile
import random
import math
import socket

# file helpers
local_dir = os.path.dirname(os.path.realpath(__file__))
pico_dir = ""
if socket.gethostname()=="FRWS3706":
    pico_dir = os.path.join("C:",os.path.sep,"pico-8-0.2.0")
else:
    pico_dir = os.path.join("D:",os.path.sep,"pico-8_0.1.12c")

def call(args):
    proc = Popen(args, stdout=PIPE, stderr=PIPE)
    out, err = proc.communicate()
    exitcode = proc.returncode
    #
    return exitcode, out, err


# pack helpers
def tohex(val, nbits):
    return (hex((int(round(val,0)) + (1<<nbits)) % (1<<nbits))[2:]).zfill(nbits>>2)

# variable length packing (1 or 2 bytes)
def pack_variant(x):
    if x>0x7fff:
      raise Exception('Unable to convert: {} into a 1 or 2 bytes'.format(x))
    # 2 bytes
    if x>127:
        h = "{:04x}".format(x + 0x8000)
        if len(h)!=4:
            raise Exception('Unable to convert: {} into a word: {}'.format(x,h))
        return h
    # 1 byte
    h = "{:02x}".format(x)
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h

# short must be between -32000/32000
def pack_int(x):
    h = tohex(x,16)
    if len(h)!=4:
        raise Exception('Unable to convert: {} into a word: {}'.format(x,h))
    return h

# 16:16 fixed point value
def pack_fixed(x):
    h = tohex(int(x*(1<<16)),32)
    if len(h)!=8:
        raise Exception('Unable to convert: {} into a dword: {}'.format(x,h))
    return h

# short must be between -127/127
def pack_short(x):
    h = "{:02x}".format(int(round(x+128,0)))
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h

# float must be between -4/+3.968 resolution: 0.03125
def pack_float(x):
    h = "{:02x}".format(int(round(32*x+128,0)))
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h
# double must be between -128/+127 resolution: 0.0078
def pack_double(x):
    h = "{}".format(tohex(128*x+16384,16))
    if len(h)!=4:
        raise Exception('Unable to convert: {} into a word: {}'.format(x,h))
    return h

# helper classes
class BSP_Tree:
  def __init__(self, front, root, back):
    self.root = root
    self.front = front
    self.back = back

def dot(v0,v1):
  return v0[0]*v1[0]+v0[1]*v1[1]

def ortho(v0, v1):
  dx = v1[0] - v0[0]
  dy = v1[1] - v0[1]
  return (dy, -dx)

def lerp(v0, v1, t):
  return (v0[0]*(1-t)+t*v1[0], v0[1]*(1-t)+t*v1[1])

def normal(v0):
  dx = v0[0]
  dy = v0[1]
  d = math.sqrt(dx*dx + dy*dy)
  if d!=0:
    dx /= d
    dy /= d
  return (dx, dy)

# constants
COPLANAR=0
FRONT=1
BACK=2
STRADDLING=3
CLASSIFY_ON=4

PLANE_THICKNESS=0.001

# linedef
class Polygon():
  def __init__(self, v0, v1, extra=None, vertices=None):
    if v0<0:
      raise Exception("Invalid vertex id: {}".format(v0))
    if v1<0:
      raise Exception("Invalid vertex id: {}".format(v1))
    self.v0 = v0
    self.v1 = v1
    self.vertices = vertices
    # copy constructor
    if isinstance(extra, Polygon):
      self.properties = extra.properties
      self.vertices = extra.vertices
      self.n = extra.n
      self.d = extra.d
    else:
      self.properties = extra
      if vertices is None:
        raise Exception("Missing vertices parameter for Polygon")
      self.vertices = vertices
      v0 = vertices[v0]
      v1 = vertices[v1]
      # plane equation
      self.n = normal(ortho(v0,v1))
      self.d = dot(self.n, v0)
  def split(self, hyperplane):
    # polygons are 2d segments
    # de-reference vertices
    v0 = self.vertices[self.v0]
    v1 = self.vertices[self.v1]
    t0, d0 = classify_point(v0, hyperplane)
    t1, d1 = classify_point(v1, hyperplane)
    if t0 == FRONT:
      if t1 == FRONT or t1 == CLASSIFY_ON:
        return (self, None)
      elif t1 == BACK: 
        v2idx = len(self.vertices)
        self.vertices.append(lerp(v0, v1, d0 / (d0-d1)))
        return (Polygon(self.v0, v2idx, self), Polygon(v2idx, self.v1, self))
    elif t0 == CLASSIFY_ON:
      if t1 == FRONT or t1 == CLASSIFY_ON:
        return (self, None)
      elif t1 == BACK:
        return (None, self)
    # BACK
    if t1 == FRONT:
      v2idx = len(self.vertices)
      self.vertices.append(lerp(v0, v1, d0 / (d0-d1)))
      return (Polygon(v2idx, self.v1, self), Polygon(self.v0, v2idx, self))
    elif t1 == BACK or t1 == CLASSIFY_ON:
      return (None, self)

    raise Exception('Unhandled case: {} - {}'.format(t0, t1))
  def classify(self, hyperplane):
    num_front = 0
    num_back = 0
    v0 = self.vertices[self.v0]
    v1 = self.vertices[self.v1]
    for p in (v0, v1):
      t, d = classify_point(p, hyperplane)
      if t == FRONT:
        num_front += 1
      elif t == BACK:
        num_back += 1
    # decide
    if num_back !=0 and num_front != 0:
      return STRADDLING
    if num_front != 0:
      return FRONT
    if num_back != 0:
      return BACK
    
    return COPLANAR

def pick_splitting_plane(polygons):
  K = 0.8

  best_plane = None
  best_score = math.inf
  for hyperplane in polygons:
    num_front = 0
    num_back = 0
    num_straddling = 0
    for poly in polygons:
      if hyperplane!=poly:
        poly_type = poly.classify(hyperplane)
        if poly_type==COPLANAR or poly_type==FRONT:
          num_front += 1
        elif poly_type==BACK:
          num_front += 1
        elif poly_type==STRADDLING:
          num_straddling += 1
        score = K*num_straddling + (1-K)*abs(num_front - num_back)
        if score<best_score:
          best_score = score
          best_plane = hyperplane
  return best_plane

#  Classify point p to a plane thickened by a given thickness epsilon 
def classify_point(p, plane):
  d = dot(plane.n, p) - plane.d
  if d > PLANE_THICKNESS:
    return (FRONT, d)
  elif d < -PLANE_THICKNESS:
    return (BACK, d)
  return (CLASSIFY_ON, d)

def build_bsp_tree(polygons, depth):
  if len(polygons)==0: return None
  if len(polygons)==1: return BSP_Tree(None, polygons.pop(), None)

  front_list=set()
  back_list=set()

  # pick a dividing plane
  split_plane = pick_splitting_plane(polygons)
  polygons.remove(split_plane)

  # iterate over polygons, triage or split them
  for poly in polygons:
    poly_type = poly.classify(split_plane)
    if poly_type==COPLANAR or poly_type==FRONT:
      front_list.add(poly)
    elif poly_type==BACK:
      back_list.add(poly)
    elif poly_type==STRADDLING:
      front,back = poly.split(split_plane)
      front_list.add(front)
      back_list.add(back)
  
  # go deeper
  front_tree = build_bsp_tree(front_list, depth + 1)
  back_tree = build_bsp_tree(back_list, depth + 1)
  return BSP_Tree(front_tree, split_plane, back_tree)

def print_bsp_tree(tree, depth):
  if tree is None: return
  tabs=depth * '\t'
  print("{}{} - {}".format(tabs, tree.root.v0, tree.root.v1))
  print("{}front:".format(tabs))
  print_bsp_tree(tree.front, depth + 1)
  print("{}back:".format(tabs))
  print_bsp_tree(tree.back, depth + 1)

def draw_bsp_tree(tree, dwg, parent, color):
  if tree is None: return
  level = dwg.g()
  #level.translate(0,20)
  # front group
  g = dwg.g()
  #g.translate(-20,20)
  draw_bsp_tree(tree.front, dwg, g, 'green')
  level.add(g)
  # current root/poly
  root = tree.root
  level.add(dwg.line(root.v0, root.v1, stroke=color))
  level.add(dwg.circle(root.v0, 0.5, stroke=color))
  level.add(dwg.circle(root.v1, 0.5, stroke=color))
  
  # back group
  g = dwg.g()
  #g.translate(20,20)
  draw_bsp_tree(tree.back, dwg, g, 'red')
  level.add(g)
  parent.add(level)

def lua_vector(pair):
  return "{}{}".format(pack_fixed(pair[0]),pack_fixed(pair[1]))

def export_bsp_tree(tree, depth):
  root = tree.root
  properties = root.properties

  s = '{}{}{}{}{}{}'.format(
    pack_variant(root.v0+1),
    pack_variant(root.v1+1),
    lua_vector(root.n),
    pack_fixed(root.d),
    pack_variant(properties.sidefront+1),
    pack_variant(properties.sideback+1))

  flags = 0
  if properties.twosided==True:
    flags |= 1
  subtree = ""
  if tree.front is not None:
    flags |= 2
    subtree += export_bsp_tree(tree.front, depth + 1)
  if tree.back is not None:
    flags |= 4
    subtree += export_bsp_tree(tree.back, depth + 1)

  s += "{:02X}{}".format(flags, subtree)
  return s

def to_cart(s,cart_name,cart_id):
    cart="""\
pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- data cart for POOM
local data="{}"
local mem=0x3100
for i=1,#data,2 do
    poke(mem,tonum("0x"..sub(data,i,i+1)))
    mem+=1
end
cstore()
"""
    tmp=s[:2*0x2000]
    # swap bytes
    gfx_data = ""
    for i in range(0,len(tmp),2):
        gfx_data = gfx_data + tmp[i+1:i+2] + tmp[i:i+1]
    cart += "__gfx__\n"
    cart += re.sub("(.{128})", "\\1\n", gfx_data, 0, re.DOTALL)

    map_data=s[2*0x2000:2*0x3000]
    if len(map_data)>0:
        cart += "__map__\n"
        cart += re.sub("(.{256})", "\\1\n", map_data, 0, re.DOTALL)

    gfx_props=s[2*0x3000:2*0x3100]
    if len(gfx_props)>0:
        cart += "__gff__\n"
        cart += re.sub("(.{256})", "\\1\n", gfx_props, 0, re.DOTALL)

    # save cart + export cryptic music+sfx part
    sfx_data=s[2*0x3100:2*0x4300]
    cart_path = os.path.join(local_dir, "..", "carts", "{}_{}.p8".format(cart_name,cart_id))
    f = open(cart_path, "w")
    f.write(cart.format(sfx_data))
    f.close()

    # run cart
    exitcode, out, err = call([os.path.join(pico_dir,"pico8.exe"),"-x",cart_path])
    if err:
        raise Exception('Unable to process pico-8 cart: {}. Exception: {}'.format(cart_path,err))

class BSP_Compiler():
  def __init__(self, vertices, lines, sides, sectors):
    polygons = set()
    for line in lines:
      polygons.add(Polygon(line.v1, line.v2, line, vertices))
    tree = build_bsp_tree(polygons, 0)
    # print_bsp_tree(tree, 0)

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

    cart_id = 0
    cart_data = ""
    for b in s:
        cart_data += b
        # full cart?
        if len(cart_data)==2*0x4300:
            to_cart(cart_data,"poom",cart_id)
            cart_id += 1
            cart_data = ""
    # remaining data?
    if len(cart_data)!=0:
        to_cart(cart_data,"poom",cart_id)