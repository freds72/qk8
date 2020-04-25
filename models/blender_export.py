import bpy
import bmesh
import argparse
import sys
import math
from mathutils import Vector, Matrix

argv = sys.argv
if "--" not in argv:
    argv = []
else:
   argv = argv[argv.index("--") + 1:]

try:
    parser = argparse.ArgumentParser(description='Exports Blender model as a byte array for wireframe rendering',prog = "blender -b -P "+__file__+" --")
    parser.add_argument('-o','--out', help='Output file', required=True, dest='out')
    args = parser.parse_args(argv)
except Exception as e:
    sys.exit(repr(e))

scene = bpy.context.scene

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

p8_colors = ['000000','1D2B53','7E2553','008751','AB5236','5F574F','C2C3C7','FFF1E8','FF004D','FFA300','FFEC27','00E436','29ADFF','83769C','FF77A8','FFCCAA']
def diffuse_to_p8color(rgb):
    h = "{:02X}{:02X}{:02X}".format(int(round(255*rgb.r)),int(round(255*rgb.g)),int(round(255*rgb.b)))
    try:
        #print("diffuse:{} -> {}\n".format(rgb,p8_colors.index(h)))
        return p8_colors.index(h)
    except Exception as e:
        # unknown color
        raise Exception('Unknown color: 0x{}'.format(h))

def find_faces_by_group(bm, obcontext, name):
    if name in obcontext.vertex_groups:
        obdata = obcontext.data
        group_idx = obcontext.vertex_groups[name].index
        group_verts = [v.index for v in obdata.vertices if group_idx in [ vg.group for vg in v.groups ] ]

        return [f for f in bm.faces if len(f.verts)==len([v for v in f.verts if v.index in group_verts])]    

def find_faces_by_group(bm, obcontext, group_idx):
    obdata = obcontext.data
    group_verts = [v.index for v in obdata.vertices if group_idx in [ vg.group for vg in v.groups ] ]

    return [f for f in bm.faces if len(f.verts)==len([v for v in f.verts if v.index in group_verts])]    

def export_face(obcontext, f):
    fs = ""
    # default values
    color = 1
    verts = [l.vert for l in f.loops]
    if len(verts)>4:
        raise Exception('Face has too many vertices: {}'.format(len(verts)))
    if len(obcontext.material_slots)>0:
        slot = obcontext.material_slots[f.material_index]
        mat = slot.material
        color = diffuse_to_p8color(mat.diffuse_color)

    # face flags bit layout:
    # 1: tri/quad
    fs += "{:02x}".format(
        (2 if len(verts)==4 else 0))
    # color
    fs += "{:02x}".format(color)

    # + vertex id (= edge loop)
    for v in verts:        
        fs += pack_variant(v.index+1)

    return fs

# export room faces (vertex groups) and portals
def export_rooms(obcontext):
    # data
    s = ""
    obdata = obcontext.data
    bm = bmesh.new()
    bm.from_mesh(obdata)
    bm.verts.ensure_lookup_table()

    # create vertex group lookup dictionary for rooms
    vgroup_names = {vgroup.index: vgroup.name for vgroup in obcontext.vertex_groups}
    
    vertex_by_group = {vgroup.index : [v for v in obdata.vertices if vgroup.index in [g.group for g in v.groups if len(v.groups)>1]] for vgroup in obcontext.vertex_groups}
    vertex_by_group = {k: v for k, v in vertex_by_group.items() if len(v)>0}

    # all vertices
    lens = pack_variant(len(obdata.vertices))
    s += lens
    for v in obdata.vertices:
        s += "{}{}{}".format(pack_double(v.co.x), pack_double(v.co.z), pack_double(v.co.y))

    # export faces grouped by vertex groups
    # groups are linked by portals
    lens = pack_variant(len(vgroup_names))
    s += lens
    for vgi,vgname in vgroup_names.items():
        # room id (eg vertex group)
        s += pack_variant(vgi)
        # export faces
        faces = find_faces_by_group(bm, obcontext, vgi)
        s += pack_variant(len(faces))
        for f in faces:
            s += export_face(obcontext, f)        

        print("portal(s) for room: {}".format(vgroup_names[vgi]))
        # find all vertices with multiple vertex groups = portal
        # find unique set of groups (not equal to current group)    
        vg_portals=set()
        for v in vertex_by_group[vgi]:
            for g in v.groups:
                if g.group!=vgi:
                    vg_portals.add(g.group)
        # export connected portals (if any)
        s += pack_variant(len(vg_portals))
        for gi in vg_portals:
            print("to: {}".format(vgroup_names[gi]))
            # find vertex at boundary (eg. belongs to both groups)
            bm_verts_portal=[bm.verts[v.index] for v in vertex_by_group[vgi] if gi in vertex_by_group and v in vertex_by_group[gi]]
            if len(bm_verts_portal)>2:
                # contains an ordered list of vertex
                out=[]
                # starting point
                v=bm_verts_portal[0]
                while len(out)!=len(bm_verts_portal):
                    out.append(v)
                    for e in v.link_edges:
                        # portal vertex (not yet added?)
                        other = e.other_vert(v)
                        if other in bm_verts_portal and other not in out:
                            v = other
                            break
                print("portal vertices: {}".format([v.index for v in out]))
                # connecting room id
                s += pack_variant(gi)
                s += pack_variant(len(out))
                for v in out:
                    s += pack_variant(v.index+1)

    return s

# model data
s = ""

# export start position
# note: direction is always fwd
plyr = [o for o in scene.objects if o.name == 'plyr'][0]
s += "{}{}{}".format(pack_double(plyr.location.x), pack_double(plyr.location.z), pack_double(plyr.location.y))

# select first mesh object
obcontext = [o for o in scene.objects if o.type == 'MESH'][0]

s += export_rooms(obcontext)

#
with open(args.out, 'w') as f:
    f.write(s)

