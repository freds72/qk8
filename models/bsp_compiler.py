import os
import re
import tempfile
import random
import math
from enum import IntFlag

# helper functions
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
class POLYGON_CLASSIFICATION(IntFlag):
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
    if t0 == POLYGON_CLASSIFICATION.FRONT:
      if t1 == POLYGON_CLASSIFICATION.FRONT or t1 == POLYGON_CLASSIFICATION.CLASSIFY_ON:
        return (self, None)
      elif t1 == POLYGON_CLASSIFICATION.BACK: 
        v2idx = len(self.vertices)
        self.vertices.append(lerp(v0, v1, d0 / (d0-d1)))
        return (Polygon(self.v0, v2idx, self), Polygon(v2idx, self.v1, self))
    elif t0 == POLYGON_CLASSIFICATION.CLASSIFY_ON:
      if t1 == POLYGON_CLASSIFICATION.FRONT or t1 == POLYGON_CLASSIFICATION.CLASSIFY_ON:
        return (self, None)
      elif t1 == POLYGON_CLASSIFICATION.BACK:
        return (None, self)
    # BACK
    if t1 == POLYGON_CLASSIFICATION.FRONT:
      v2idx = len(self.vertices)
      self.vertices.append(lerp(v0, v1, d0 / (d0-d1)))
      return (Polygon(v2idx, self.v1, self), Polygon(self.v0, v2idx, self))
    elif t1 == POLYGON_CLASSIFICATION.BACK or t1 == POLYGON_CLASSIFICATION.CLASSIFY_ON:
      return (None, self)

    raise Exception('Unhandled case: {} - {}'.format(t0, t1))
  def classify(self, hyperplane):
    num_front = 0
    num_back = 0
    v0 = self.vertices[self.v0]
    v1 = self.vertices[self.v1]
    for p in (v0, v1):
      t, d = classify_point(p, hyperplane)
      if t == POLYGON_CLASSIFICATION.FRONT:
        num_front += 1
      elif t == POLYGON_CLASSIFICATION.BACK:
        num_back += 1
    # decide
    if num_back !=0 and num_front != 0:
      return POLYGON_CLASSIFICATION.STRADDLING
    if num_front != 0:
      return POLYGON_CLASSIFICATION.FRONT
    if num_back != 0:
      return POLYGON_CLASSIFICATION.BACK
    
    return POLYGON_CLASSIFICATION.COPLANAR

#  Classify point p to a plane thickened by a given thickness epsilon 
def classify_point(p, plane):
  d = dot(plane.n, p) - plane.d
  if d > PLANE_THICKNESS:
    return (POLYGON_CLASSIFICATION.FRONT, d)
  elif d < -PLANE_THICKNESS:
    return (POLYGON_CLASSIFICATION.BACK, d)
  return (POLYGON_CLASSIFICATION.CLASSIFY_ON, d)

    