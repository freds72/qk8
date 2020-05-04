import bpy
import bmesh
import argparse
import sys
import math
from mathutils import Vector, Matrix

# references:
# https://blenderartists.org/t/change-a-faces-uv-image-via-bmesh/626353/2
# https://blenderartists.org/t/accessing-uv-data-in-python-script/540440/15
# loops
# https://blenderartists.org/t/accessing-uv-data-in-python-script/540440/10
# qk lightmaps
# http://latchup.blogspot.com/2015/06/quake-lightmaps.html

scale = 8

def get_face_uvs(face):
  verts = [l.vert.co for l in face.loops]
  n = face.normal
  uidx = -1
  vidx = -1
  if abs(n.z)>=abs(n.x) and abs(n.z)>=abs(n.y):
    uidx = 0 # x
    vidx = 1 # y
  elif abs(n.y)>=abs(n.x) and abs(n.y)>=abs(n.z):
    uidx = 2 # z
    vidx = 1 # x
  elif abs(n.x)>=abs(n.y) and abs(n.x)>=abs(n.z):
    uidx = 1 # y
    vidx = 2 # z
  # fallback
  if uidx<0 or vidx<0:
    raise Exception('Unable to find planar major for face: {} n:{}'.format(face.index,face.normal))

  # find min coords
  umin = min([v[uidx] for v in verts])
  vmin = min([v[vidx] for v in verts])
  width = abs(max([v[uidx] for v in verts]) - umin)
  height = abs(max([v[vidx] for v in verts]) - vmin)
  if width<=0 or height<=0:
     raise Exception('Invalid extent: {}/{} for face: {}'.format(width, height, face.index))
  uvs = []
  for v in verts:
    # rebase to 0/height/width
    uvs.append(Vector((v[uidx]-umin,v[vidx]-vmin))/scale)
  
  print("Face: {} extent: {}/{}".format(face.index, width, height))

  return (int(round(width/scale+0.5,0)), int(round(height/scale+0.5,0)), uvs)

def create_lightmaps(obcontext):
  obdata = obcontext.data
  bm = bmesh.new()
  bm.from_mesh(obdata)
  
  for face in bm.faces:
    # find extents
    width, height, uvs = get_face_uvs(face)

    #
    #t = bm.faces.layers.tex.new("lightmap_{}".format(face.index))
    #face[t].images = bpy.ops.image.new(name="uvmap", width=width, height=height, color=(0.0, 0.0, 0.0, 1.0), alpha=True, float=False)
    
    # uv coords
    # u = bm.loops.layers.uv.new("uvmap")
    # assign
    # face.loops[face.index][u].uv = uvs

scene = bpy.context.scene

# select first mesh object
obcontext = [o for o in scene.objects if o.type == 'MESH'][0]
create_lightmaps(obcontext)
