import math
import svgwrite

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
  return (-dy, dx)

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

class Polygon:
  def __init__(self, v0, v1):
    self.v0 = v0
    self.v1 = v1
    # plane equation
    self.n = normal(ortho(v0,v1))
    self.d = dot(self.n, v0)

# constants
COPLANAR=0
FRONT=1
BACK=2
STRADDLING=3
CLASSIFY_ON=4

PLANE_THICKNESS=0.001

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
        poly_type = classify_polygon(poly, hyperplane)
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

def classify_polygon(poly, hyperplane):
  num_front = 0
  num_back = 0
  for p in (poly.v0, poly.v1):
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

def split_polygon(poly, hyperplane):
  # polygons are 2d segments
  v0 = poly.v0
  v1 = poly.v1
  t0, d0 = classify_point(v0, hyperplane)
  t1, d1 = classify_point(v1, hyperplane)
  if t0 == FRONT:
    if t1 == FRONT or t1 == CLASSIFY_ON:
      return (poly, None)
    elif t1 == BACK:
      v2 = lerp(v0, v1, d0 / (d0-d1))
      return (Polygon(v0, v2), Polygon(v2, v1))
  elif t0 == CLASSIFY_ON:
    if t1 == FRONT or t1 == CLASSIFY_ON:
      return (poly, None)
    elif t1 == BACK:
      return (None, poly)
  # BACK
  if t1 == FRONT:
    v2 = lerp(v0, v1, d0 / (d0-d1))
    return (Polygon(v2, v1), Polygon(v0, v2))
  elif t1 == BACK or t1 == CLASSIFY_ON:
    return (None, poly)

  raise Exception('Unhandled case: {} - {}'.format(t0, t1))  

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
    poly_type = classify_polygon(poly,split_plane)
    if poly_type==COPLANAR or poly_type==FRONT:
      front_list.add(poly)
    elif poly_type==BACK:
      back_list.add(poly)
    elif poly_type==STRADDLING:
      front,back = split_polygon(poly, split_plane)
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

# debug output
# https://stackoverflow.com/questions/17127083/python-svgwrite-and-font-styles-sizes
dwg = svgwrite.Drawing(filename='bsp.svg', size=(256, 256))

# tests
polygons = {
  # room
  Polygon((0,0), (15,0)), 
  Polygon((15,0), (15,15)), 
  Polygon((15,15), (0,15)), 
  Polygon((0,15), (0,0)),
  # pillar
  Polygon((12,6), (6,6)), 
  Polygon((12,10), (12,6)), 
  Polygon((6,6), (12,10) )}

for poly in polygons:
  dwg.add(dwg.line(poly.v0, poly.v1, stroke='green'))
  dwg.add(dwg.circle(poly.v0, 0.5, stroke='green'))
  dwg.add(dwg.circle(poly.v1, 0.5, stroke='green'))
  # normal
  n0 = lerp(poly.v0, poly.v1, 0.5)
  dwg.add(dwg.line(n0, (n0[0] + 2*poly.n[0], n0[1] + 2*poly.n[1]), stroke='grey'))

tree = build_bsp_tree(polygons, 0)

root = dwg.g()
root.translate(128,0)
draw_bsp_tree(tree, dwg, root, 'blue')
dwg.add(root)
dwg.save()

print_bsp_tree(tree, 0)

