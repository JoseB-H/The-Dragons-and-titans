"""Build the two original Frontera wave models with Blender 4.3."""
import math
from pathlib import Path
import bpy
from mathutils import Vector

DEST = Path(__file__).resolve().parents[2] / "game/assets/minions"


def paint(name, rgb, metal=0, glow=0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*rgb, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*rgb, 1)
    shader.inputs["Metallic"].default_value = metal
    shader.inputs["Roughness"].default_value = .44
    shader.inputs["Emission Color"].default_value = (*rgb, 1)
    shader.inputs["Emission Strength"].default_value = glow
    return mat


def finish(name, mat):
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    return obj


def oval(name, pos, size, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, location=pos)
    obj = finish(name, mat)
    obj.scale = size
    return obj


def taper(name, start, end, base, tip, mat):
    a, b = Vector(start), Vector(end)
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=base, radius2=tip,
                                    depth=(b-a).length, location=(a+b)/2)
    obj = finish(name, mat)
    obj.rotation_euler = (b-a).to_track_quat('Z','Y').to_euler()
    return obj


def join(parts, name):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in parts:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    bpy.context.object.name = name
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)


def build(angel):
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    ivory = paint("Marfil", (.87,.83,.64))
    gold = paint("Oro", (.76,.40,.08), .55)
    blue = paint("Azul noche", (.038,.12,.24), .4)
    skin = ivory if angel else paint("Escoria", (.29,.045,.038))
    armor = gold if angel else paint("Hierro negro", (.105,.06,.08), .65)
    cloth = blue if angel else paint("Granate", (.35,.025,.04))
    light = paint("Luz", (.08,.75,1) if angel else (1,.23,.023), glow=1)
    oval("Peto", (0,0,.07), (.23,.13,.27), armor)
    taper("Tabardo", (0,-.025,-.35),(0,0,-.02), .23,.145,cloth)
    oval("Cabeza", (0,.005,.40), (.14,.13,.157), skin)
    oval("Yelmo", (0,-.022,.475), (.155,.141,.104), armor)
    oval("Gema", (0,.131,.11), (.062,.026,.083),light)
    for s in [-1,1]:
        oval("Ojo", (s*.059,.120,.415), (.037,.017,.015),light)
        oval("Hombrera", (s*.219,0,.19), (.122,.14,.112), armor)
        taper("Brazo", (s*.20,0,.16),(s*.32,.05,-.05),.073,.048,skin)
        taper("Guante", (s*.32,.05,-.05),(s*.31,.18,-.10),.065,.05,armor)
        taper("Greba", (s*.11,0,-.21),(s*.145,-.06,-.49),.085,.055,armor)
        oval("Bota", (s*.145,-.016,-.49),(.064,.103,.056),cloth)
        if not angel:
            taper("Cuerno", (s*.10,0,.49),(s*.24,-.03,.59),.077,.049,armor)
            taper("Punta", (s*.24,-.03,.59),(s*.29,-.065,.75),.049,.002,ivory)
    if angel:
        bpy.ops.mesh.primitive_torus_add(major_segments=32,minor_segments=6,
            location=(0,-.025,.67), major_radius=.189, minor_radius=.022)
        finish("Aureola",gold)
        taper("Lanza", (.31,-.24,-.42),(.31,.55,.32),.017,.017,gold)
        taper("Hoja", (.31,.54,.31),(.31,.74,.51),.069,.001,light)
    else:
        taper("Cola", (0,-.05,-.18),(0,-.45,-.31),.073,.047,skin)
        taper("Aguijon", (0,-.45,-.31),(0,-.66,-.11),.061,.001,armor)
    join(list(bpy.context.scene.objects), "Body")
    for s, name in [(-1,'WingL'),(1,'WingR')]:
        before = set(bpy.context.scene.objects)
        root = (s*.14,-.07,.20)
        elbow = (s*.54,-.13,.52)
        taper("Anteala", root,elbow,.08,.048,armor)
        if angel:
            for i in range(7):
                a = Vector(root).lerp(Vector(elbow),i/7)
                end = Vector((s*(.37+i*.092),-.29-i*.025,-.19+i*.092))
                feather = oval("Pluma",(a+end)/2,(.085,.038,(end-a).length*.54),ivory)
                feather.rotation_euler = (end-a).to_track_quat('Z','Y').to_euler()
        else:
            rim = [(s*.98,-.23,.31),(s*.75,-.25,.18),(s*.69,-.39,-.09),
                   (s*.52,-.31,.04),(s*.43,-.43,-.24),(s*.30,-.29,-.08),root]
            mesh = bpy.data.meshes.new("Membrana")
            mesh.from_pydata([elbow]+rim,[],[(0,i,i+1) for i in range(1,len(rim))])
            mesh.materials.append(cloth)
            obj=bpy.data.objects.new("Membrana",mesh)
            bpy.context.collection.objects.link(obj)
            for point in rim[::2]:
                taper("Nervio",elbow,point,.031,.004,skin)
        join(list(set(bpy.context.scene.objects)-before), name)
    bpy.ops.export_scene.gltf(filepath=str(DEST / ("angel.glb" if angel else "demonio.glb")),
                              export_format='GLB',export_animations=False)


for allied in (True,False):
    build(allied)
