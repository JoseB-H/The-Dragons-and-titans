"""Arte original reproducible. Blender 4.3+: blender -b --python tools/art/build_dragons.py.
Sin recursos externos. Coordenadas de diseño: X derecha, Y arriba, -Z frente.
Exporta tres GLB con malla skinned, texturas propias y cuatro clips.
"""
import bpy, math, sys
from mathutils import Vector
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'game/assets/dragons'
OUT.mkdir(parents=True, exist_ok=True)
def V(p): return Vector((p[0], -p[2], p[1]))

def material(name, color, metal=0, rough=.48, glow=0):
    m=bpy.data.materials.new(name);m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
    if glow:
        p.inputs['Emission Color'].default_value=(*color,1);p.inputs['Emission Strength'].default_value=glow
    m.diffuse_color=(*color,1)
    return m

def surface_texture(mat, color, membrane=False, chevrons=False):
    resolution = 512
    image = bpy.data.images.new(mat.name + '_Pigment', width=resolution, height=resolution)
    pixels = []
    relief = []
    for y in range(resolution):
        row = y // 48
        for x in range(resolution):
            u = ((x + (24 if row % 2 else 0)) % 48) / 48
            v = (y % 48) / 48
            grain = math.sin(x * 13 + y * 7)
            if membrane:
                span = x / resolution
                depth = y / resolution
                vein = abs(math.sin(span * math.tau * 3.2 + depth * 3.8))
                factor = .66 + .32 * math.sin(math.pi * depth) + .13 * vein + .025 * grain
                if vein < .11:
                    factor *= .68
                if chevrons and abs(depth - .26 - .18 * abs(span * 2 - 1)) < .045:
                    factor *= .32
                relief.append(1.0 - vein)
            else:
                curve = .15 + .60 * (abs(u - .5) * 2) ** 1.6
                ridge = math.exp(-((v - curve - .065) * 19) ** 2)
                seam = abs(v - curve) < .028
                factor = .52 if seam else .74 + .36 * ridge + .10 * (1 - v) + .04 * grain
                relief.append(ridge - .30 * float(seam))
            pixels.extend([min(1, channel * factor) for channel in color] + [1])
    image.pixels = pixels
    image.pack()
    nodes = mat.node_tree.nodes
    texture = nodes.new('ShaderNodeTexImage')
    texture.image = image
    principled = nodes.get('Principled BSDF')
    links = mat.node_tree.links
    links.new(texture.outputs['Color'], principled.inputs['Base Color'])

    normal_pixels = []
    strength = 1.0 if membrane else 1.8
    for y in range(resolution):
        for x in range(resolution):
            dx = (relief[y * resolution + (x - 1) % resolution] -
                  relief[y * resolution + (x + 1) % resolution]) * strength
            dy = (relief[((y - 1) % resolution) * resolution + x] -
                  relief[((y + 1) % resolution) * resolution + x]) * strength
            length = math.sqrt(dx * dx + dy * dy + 1.0)
            normal_pixels.extend((.5 + .5 * dx / length, .5 + .5 * dy / length,
                                  .5 + .5 / length, 1.0))
    normals = bpy.data.images.new(mat.name + '_Relief', width=resolution, height=resolution)
    normals.colorspace_settings.name = 'Non-Color'
    normals.pixels = normal_pixels
    normals.pack()
    relief_texture = nodes.new('ShaderNodeTexImage')
    relief_texture.image = normals
    normal_map = nodes.new('ShaderNodeNormalMap')
    normal_map.inputs['Strength'].default_value = .32 if membrane else .62
    links.new(relief_texture.outputs['Color'], normal_map.inputs['Color'])
    links.new(normal_map.outputs['Normal'], principled.inputs['Normal'])

class Dragon:
    def __init__(self,kind):
        self.kind=kind;self.jade=kind=='jade';self.sentinel=kind=='sentinela';self.parts=[]
        if self.jade: skin=(.065,.36,.23);accent=(.43,.73,.42);mem=(.055,.26,.19);horn=(.79,.91,.73);eye=(.95,.85,.25)
        elif self.sentinel: skin=(.06,.27,.37);accent=(.23,.63,.68);mem=(.025,.13,.23);horn=(.64,.80,.85);eye=(.3,.95,1)
        else: skin=(.60,.135,.075);accent=(.85,.46,.16);mem=(.93,.57,.22);horn=(.88,.77,.53);eye=(1,.57,.065)
        self.mats=[material('Skin',skin,.15,.48),material('Ventral',accent,.12,.48),material('Membrane',mem,0,.65),material('Ivory',horn,0,.35),material('Eye',eye,0,.2,.8),material('Obsidian',(.018,.024,.027),.12,.3),material('Armor',accent,.20,.51)]
        if self.jade:
            self.mats.append(material('Aurora', (.07,.78,.58), .16, .33, .7))
        if kind == 'cobre':
            self.mats.extend([material('ForgedSilver',(.57,.64,.65),.75,.32),
                              material('Turquoise',(.02,.69,.67),.18,.22,.42)])
        surface_texture(self.mats[0], skin)
        surface_texture(self.mats[2], mem, membrane=True, chevrons=kind == "cobre")
        self.mats[2].surface_render_method='DITHERED'
        self.mats[2].use_backface_culling=False
        # Esqueleto común con diferencias de forma, no de balance.
        arm=bpy.data.armatures.new('DragonSkeleton');self.rig=bpy.data.objects.new('DragonRig',arm);bpy.context.collection.objects.link(self.rig)
        bpy.context.view_layer.objects.active=self.rig;self.rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
        specs=[('Root',(0,0,0),(0,.4,0),None),('Spine',(0,0,.5),(0,.15,-.55),'Root'),('Neck',(0,.18,-.48),(0,.43,-1.02),'Spine'),('Head',(0,.43,-1.02),(0,.45,-1.7),'Neck'),('Jaw',(0,.25,-1.0),(0,.21,-1.65),'Head'),('Tail1',(0,0,.55),(0,.04,1.2),'Spine'),('Tail2',(0,.04,1.2),(0,.1,1.8),'Tail1'),('Tail3',(0,.1,1.8),(0,.18,2.5),'Tail2')]
        for side in [-1,1]:
            tag='L' if side<0 else 'R'
            specs.extend([(f'Wing{tag}',(side*.34,.22,-.35),(side*1.12,.47,-.55),'Spine'),(f'Tip{tag}',(side*1.12,.47,-.55),(side*2.35,.24,-.65),f'Wing{tag}'),(f'Front{tag}',(side*.32,-.13,-.42),(side*.49,-.43,-.05),'Spine'),(f'Hind{tag}',(side*.32,-.08,.4),(side*.55,-.42,.65),'Spine')])
        for name,a,b,parent in specs:
            bone=arm.edit_bones.new(name);bone.head=V(a);bone.tail=V(b)
            if parent:bone.parent=arm.edit_bones[parent]
        bpy.ops.object.mode_set(mode='OBJECT');self.rig.select_set(False)
    def mesh(self,name,verts,faces,mat,bone,uv=None,weights=None):
        data=bpy.data.meshes.new(name);data.from_pydata([V(p) for p in verts],[],faces);data.update()
        ob=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(ob);ob.data.materials.append(self.mats[mat])
        for poly in data.polygons:poly.use_smooth=True
        if uv:
            layer=data.uv_layers.new(name='UVMap')
            for poly in data.polygons:
                for li in poly.loop_indices:layer.data[li].uv=uv[data.loops[li].vertex_index]
        if weights:
            for i,groups in enumerate(weights):
                for b,w in groups.items():
                    if b not in ob.vertex_groups:ob.vertex_groups.new(name=b)
                    ob.vertex_groups[b].add([i],w,'REPLACE')
        else:
            group=ob.vertex_groups.new(name=bone);group.add(list(range(len(verts))),1,'REPLACE')
        mod=ob.modifiers.new('Skin','ARMATURE');mod.object=self.rig;ob.parent=self.rig
        self.parts.append(ob);return ob
    def tube(self,name,rings,mat,bone,segments=16):
        verts=[];uv=[]
        for i,(x,y,z,rx,ry) in enumerate(rings):
            for k in range(segments+1):
                a=math.tau*k/segments;verts.append((x+math.cos(a)*rx,y+math.sin(a)*ry,z));uv.append((k/segments*2,i/max(1,len(rings)-1)*2))
        faces=[]
        for i in range(len(rings)-1):
            for k in range(segments):
                a=i*(segments+1)+k;b=a+segments+1;faces.append((a,a+1,b+1,b))
        faces.extend([tuple(reversed(range(segments))),tuple((len(rings)-1)*(segments+1)+k for k in range(segments))])
        return self.mesh(name,verts,faces,mat,bone,uv)
    def ellipsoid(self,name,at,size,mat,bone):
        rings=[]
        for i in range(13):
            a=math.pi*i/12;f=max(.001,math.sin(a));rings.append((at[0],at[1],at[2]+math.cos(a)*size[2],f*size[0],f*size[1]))
        return self.tube(name,rings,mat,bone,20)
    def curve(self,name,points,radii,mat,bone,segments=10):
        verts=[];uv=[]
        for i,p in enumerate(points):
            tangent=Vector(points[min(i+1,len(points)-1)])-Vector(points[max(0,i-1)])
            tangent.normalize();normal=tangent.cross(Vector((0,0,1)))
            if normal.length<.01:normal=tangent.cross(Vector((0,1,0)))
            normal.normalize();other=tangent.cross(normal).normalized()
            for k in range(segments+1):
                a=math.tau*k/segments;v=Vector(p)+(normal*math.cos(a)+other*math.sin(a))*radii[i];verts.append(v);uv.append((k/segments,i/max(1,len(points)-1)))
        faces=[]
        for i in range(len(points)-1):
            for k in range(segments):
                a=i*(segments+1)+k;b=a+segments+1;faces.append((a,b,b+1,a+1))
        faces.extend([tuple(range(segments)),tuple(reversed([(len(points)-1)*(segments+1)+k for k in range(segments)]))])
        return self.mesh(name,verts,faces,mat,bone,uv)
    def shield(self,name,at,size,mat,bone):
        x,y,z=at;w,h,l=size
        verts=[(x,y+h,z-l*.62),(x-w,y,z),(x,y,z+l),(x+w,y,z),(x,y+h*.75,z+l*.18),(x,y-h*.18,z)]
        faces=[(0,1,4),(1,2,4),(2,3,4),(3,0,4),(0,5,1),(1,5,2),(2,5,3),(3,5,0)]
        ob=self.mesh(name,verts,faces,mat,bone)
        for poly in ob.data.polygons:poly.use_smooth=False
        return ob
    def build(self):
        lean=.64 if self.jade else 1
        self.tube('Torso',[(0,.02,.83,.07,.09),(0,.02,.67,.24*lean,.22),(0,.04,.32,.43*lean,.35),(0,.05,-.1,.46*lean,.38),(0,.12,-.44,.34*lean,.33),(0,.20,-.65,.24*lean,.27)],0,'Spine',24)
        self.tube('S_Curve_Neck',[(0,.14,-.44,.29*lean,.27),(0,.18,-.66,.25*lean,.27),(0,.32,-.83,.22*lean,.25),(0,.45,-1.01,.23*lean,.24),(0,.47,-1.18,.25*lean,.22)],0,'Neck',20)
        # Cabeza y mandíbula orgánicas, mejillas anchas y puente nasal definido.
        self.tube('Skull',[(0,.46,-.96,.17,.19),(0,.5,-1.10,.29*lean,.25),(0,.47,-1.29,.3*lean,.22),(0,.38,-1.47,.21*lean,.14),(0,.34,-1.77,.17*lean,.105),(0,.34,-1.87,.11*lean,.08)],0,'Head',20)
        self.tube('Lower_Jaw',[(0,.29,-1.12,.2*lean,.1),(0,.22,-1.37,.23*lean,.08),(0,.22,-1.73,.16*lean,.06),(0,.25,-1.86,.1*lean,.025)],1,'Jaw',16)
        for s in [-1,1]:
            self.ellipsoid('Cheek', (s*.23*lean,.35,-1.22),(.13,.15,.19),0,'Head')
            eye=(s*.265*lean,.54,-1.31)
            self.ellipsoid('EyeSocket',eye,(.088,.074,.12),5,'Head')
            self.ellipsoid('Eye',(s*.33*lean,eye[1]+.014,eye[2]-.015),(.052,.035,.072),4,'Head')
            self.ellipsoid('SlitPupil',(s*.382*lean,eye[1]+.025,eye[2]-.025),(.013,.028,.033),5,'Head')
            self.curve('Brow',[(s*.16,.66,-1.10),(s*.33*lean,.61,-1.28),(s*.31*lean,.56,-1.43)],[.075,.055,.012],6,'Head')
            self.curve('Jawline',[(s*.17*lean,.27,-1.14),(s*.23*lean,.26,-1.42),
                                  (s*.13*lean,.27,-1.76)],[.041,.032,.007],0,'Jaw')
            self.ellipsoid('Nostril',(s*.1*lean,.405,-1.76),(.038,.017,.046),5,'Head')
            horn_end=.93 if self.jade else 1.23
            if self.kind == 'cobre':
                self.curve('BasaltCrown',[(s*.21,.64,-1.10),(s*.38,.81,-.99),(s*.47,.96,-.74),
                           (s*.49,.98,-.49),(s*.42,1.06,-.33)],[.145,.12,.084,.047,.002],5,'Head',14)
            else:
                self.curve('SweptCrown',[(s*.2*lean,.64,-1.06),(s*.31,.82,-.97),(s*.38,horn_end,-.73),(s*.43,horn_end+.06,-.53)],[.1,.075,.04,.002],3,'Head',12)
            self.curve('TempleFin',[(s*.22,.52,-1.02),(s*.48,.6,-.86),(s*(.63 if self.jade else .53),.63,-.65)],[.09,.06,.001],6,'Head')
            self.curve('CheekSpike',[(s*.24,.35,-1.11),(s*.42,.38,-.95),(s*.5,.4,-.8)],[.075,.046,.002],3,'Head')
            for i in range(4):
                z=-1.42-i*.095
                self.curve('UpperFang',[(s*(.20-i*.01)*lean,.29,z),(s*(.19-i*.01)*lean,.16,z-.025)],[.028,.001],3,'Head',8)
            tag='L' if s<0 else 'R'
            # Patas recogidas en vuelo, con muslo y codo claramente articulados.
            for front in [True,False]:
                z=-.42 if front else .38;bone=('Front' if front else 'Hind')+tag
                self.curve('Foreleg' if front else 'Haunch',[(s*.29,-.08,z),(s*.48,-.28,z+.18),(s*.46,-.46,z+.06),(s*.41,-.5,z-.13)],[.16 if not front else .12,.12,.08,.075],0,bone,12)
                for toe in range(3):
                    x=s*(.34+toe*.065)
                    self.curve('Digit',[(x,-.47,z-.05),(x,-.5,z-.20),(x,-.47,z-.29)],[.04,.032,.001],3,bone,8)
            # Ala: hombro, muñeca y cinco dedos con membranas combadas.
            width=2.52 if self.jade else 2.28
            wrist=(s*1.0,.48,-.60)
            endpoints=[(s*width,.24,-.84),(s*(width-.12),.12,.04),(s*1.78,.17,.70),(s*1.10,.25,1.0),(s*.39,.2,.48)]
            if self.jade:
                # Jade, ala de hoz con flecos largos y raíces estrechas.
                wrist = (s*1.08,.56,-.68)
                endpoints = [(s*3.08,.61,-.54),(s*2.66,.38,.52),(s*2.03,.09,1.43),
                             (s*1.10,.13,1.61),(s*.36,.22,.50)]
            elif self.sentinel:
                # Sentinela, un borde de cristal ancho y quebrado.
                endpoints = [(s*2.48,.36,-.99),(s*2.53,.22,-.10),(s*2.05,.17,.36),
                             (s*1.51,.31,.88),(s*.41,.19,.52)]
            self.curve('UpperWing',[(s*.32,.2,-.4),(s*.63,.4,-.41),wrist],[.13,.10,.075],0,'Wing'+tag,12)
            for k,end in enumerate(endpoints):
                mid=Vector(wrist).lerp(Vector(end),.53);mid.y+=.08
                self.curve('WingFinger',[wrist,tuple(mid),end],[.055,.032,.008],0,'Tip'+tag,8)
                if self.jade and k < 4:
                    p = Vector(wrist).lerp(Vector(end), .64)
                    p.y += .04
                    q = Vector(wrist).lerp(Vector(end), .84)
                    q.y += .028
                    self.curve('AuroraQuill',[tuple(p), tuple(q), end],[.026,.041,.003],7,'Tip'+tag,8)
            # Quatre panneaux tissés: courbure réelle, pas des triangles plans.
            for panel in range(4):
                verts=[];uv=[];rows=8;cols=8
                for i in range(rows+1):
                    t=i/rows
                    for j in range(cols+1):
                        u=j/cols;edge=Vector(endpoints[panel]).lerp(Vector(endpoints[panel+1]),u)
                        edge=edge.lerp(Vector(wrist),math.sin(u*math.pi)*(.25 if self.jade else .12))
                        p=Vector(wrist).lerp(edge,t);p.y-=math.sin(t*math.pi)*math.sin(u*math.pi)*.16
                        verts.append(p);uv.append((u,t))
                faces=[]
                for i in range(rows):
                    for j in range(cols):
                        a=i*(cols+1)+j;f=(a,a+1,a+cols+2,a+cols+1);faces.append(f if s<0 else tuple(reversed(f)))
                self.mesh('WingSail',verts,faces,2,'Tip'+tag,uv)
            self.curve('WingClaw',[wrist,(s*1.08,.65,-.65),(s*1.14,.68,-.78)],[.06,.035,.001],3,'Tip'+tag)
        if self.kind == 'cobre':
            self.ellipsoid('RiderCuirass',(0,.74,-.02),(.14,.20,.11),7,'Spine')
            self.ellipsoid('RiderHelm',(0,1.00,-.055),(.097,.12,.095),7,'Spine')
            self.shield('HelmVisor',(0,1.00,-.14),(.08,.04,.04),5,'Spine')
            for side in [-1,1]:
                self.curve('RiderBoot',[(side*.08,.57,0),(side*.25,.47,-.13),(side*.27,.24,-.03)],[.086,.072,.052],5,'Spine')
                self.curve('RiderArm',[(side*.13,.83,-.01),(side*.21,.69,-.08),(side*.13,.62,-.29)],[.062,.05,.04],7,'Spine')
                tag = 'L' if side < 0 else 'R'
                self.shield('WingBracer',(side*1.02,.52,-.59),(.15,.071,.21),7,'Tip'+tag)
                self.ellipsoid('WingStone',(side*1.02,.595,-.61),(.062,.042,.074),8,'Tip'+tag)
            self.curve('NasalHorn',[(0,.41,-1.70),(0,.53,-1.75),(0,.60,-1.81)],[.077,.041,.002],5,'Head')
            self.ellipsoid('LeatherSaddle',(0,.39,-.03),(.29,.10,.32),5,'Spine')
            for z in [-.26,.20]:
                self.ellipsoid('SaddleRoll',(0,.46,z),(.30,.075,.07),5,'Spine')
        # Cola articulada de tres segmentos effilés.
        for i,(a,b,r1,r2) in enumerate([(.64,1.30,.20,.12),(1.27,1.93,.125,.065),(1.90,2.58,.068,.003)]):
            self.tube('TailSegment',[(0,.015,a,r1,r1*.85),(.025,.05,(a+b)/2,(r1+r2)/2,(r1+r2)*.43),(0,.10,b,r2,r2)],0,'Tail'+str(i+1),14)
        if self.jade:
            self.curve('RibbonTail',[(0,.10,2.51),(.09,.19,2.84),(.07,.25,3.14),
                                     (-.06,.30,3.46)],[.039,.031,.025,.002],0,'Tail3',12)
            for side in [-1, 1]:
                self.shield('AuroraTailVane',(side*.12,.29,3.16),(.25,.055,.36),7,'Tail3')
        # Écailles ventrales superposées et crête dorsale progressive.
        for i in range(10):
            z=.55-i*.17;w=(.30 if i<6 else .20)*lean
            self.ellipsoid('VentralScute',(0,-.22+max(0,i-5)*.09,z),(w,.075,.12),1,'Spine' if i<6 else 'Neck')
        for i in range(11):
            z=-.8+i*.27;y=.44 if i<5 else .23-i*.008
            bone='Neck' if i<2 else ('Spine' if i<6 else 'Tail'+str(min(3,1+(i-6)//2)))
            self.curve('DorsalCrest',[(0,y,z),(0,y+(.30 if not self.jade else .22),z+.06),(0,y+.10,z+.22)],[.085,.032,.002],6,bone,8)
        # Épaulières en losange pour Cobre; crête foliacée pour Jade.
        for s in [-1,1]:
            for i in range(6):
                z=-.4+i*.19
                self.shield('ShoulderScale',(s*.30*lean,.32,z),(.18*lean,.075,.22),6,'Spine')
        self.add_signature()
        self.finish()
    def add_signature(self):
        for side in [-1, 1]:
            wing = 'TipL' if side < 0 else 'TipR'
            if self.jade:
                for index in range(4):
                    z = -.88 + index * .16
                    self.curve('LeafCrown', [(side*.12,.57,z),(side*.28,.79,z+.17),
                                             (side*(.56-index*.04),.91,z+.28)],
                               [.067,.043,.002], 6, 'Neck', 10)
                for index in range(3):
                    self.shield('TailFin',(side*.10,.18,2.10+index*.12),
                                (.22+index*.09,.06,.15),6,'Tail3')
            elif self.sentinel:
                for index in range(5):
                    x = side * (1.02 + index * .24)
                    self.shield('WingCrystal',(x,.47-index*.04,-.57-index*.06),
                                (.12,.40-index*.035,.16),3,wing)
                for index in range(4):
                    self.shield('IceChest',(side*.36,.29,.30-index*.24),
                                (.15,.25,.17),6,'Spine')
            else:
                for index in range(4):
                    self.shield('BronzeScale',(side*.35,.32,.42-index*.20),
                                (.22,.17,.20),6,'Spine')
                self.curve('RamHorn',[(side*.22,.65,-1.06),(side*.39,.79,-.90),
                                      (side*.53,.74,-.82),(side*.56,.58,-.96),
                                      (side*.48,.53,-1.12)],
                           [.14,.12,.095,.066,.003],3,'Head',14)
                self.shield('TailBlade',(side*.08,.16,2.47),(.23,.10,.33),6,'Tail3')

    def finish(self):
        bpy.ops.object.select_all(action='DESELECT')
        for ob in self.parts:ob.select_set(True)
        bpy.context.view_layer.objects.active=self.parts[0];bpy.ops.object.join();body=bpy.context.object;body.name='DragonSkin'
        bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.normals_make_consistent(inside=False);bpy.ops.object.mode_set(mode='OBJECT')
        bpy.context.view_layer.objects.active=self.rig
        self.rig.animation_data_create()
        for clip,frames in [('Flight',32),('Attack',14),('Hit',12),('Death',32)]:
            action=bpy.data.actions.new(clip);self.rig.animation_data.action=action
            for frame in range(0,frames+1,2):
                t=frame/frames
                for pb in self.rig.pose.bones:pb.rotation_mode='XYZ';pb.rotation_euler=(0,0,0);pb.location=(0,0,0)
                for s in [-1,1]:
                    tag='L' if s<0 else 'R';wing=self.rig.pose.bones['Wing'+tag];tip=self.rig.pose.bones['Tip'+tag]
                    if clip=='Flight':
                        wing.rotation_euler.y=s*(math.sin(t*math.tau)*(.19 if self.jade else .27)+.04);tip.rotation_euler.y=s*math.sin(t*math.tau-.6)*(.21 if self.jade else .16)
                    elif clip=='Death':wing.rotation_euler.y=s*t*.95;tip.rotation_euler.y=s*t*.4
                if clip=='Flight':
                    self.rig.pose.bones['Root'].location.y=math.sin(t*math.tau)*.04
                    for i in range(1,4):self.rig.pose.bones['Tail'+str(i)].rotation_euler.z=math.sin(t*math.tau-i*.55)*.1
                    for tag in ['L','R']:
                        self.rig.pose.bones['Front'+tag].rotation_euler.x=math.sin(t*math.tau)*.07
                elif clip=='Attack':
                    amount=math.sin(t*math.pi);self.rig.pose.bones['Jaw'].rotation_euler.x=-amount*.34;self.rig.pose.bones['Neck'].rotation_euler.x=-amount*.12
                elif clip=='Hit':self.rig.pose.bones['Root'].rotation_euler.z=math.sin(t*math.tau*2)*(1-t)*.13
                else:
                    self.rig.pose.bones['Root'].location.y=-.62*t;self.rig.pose.bones['Root'].rotation_euler.z=.36*t
                    self.rig.pose.bones['Neck'].rotation_euler.x=.45*t
                for pb in self.rig.pose.bones:
                    pb.keyframe_insert('rotation_euler',frame=frame);pb.keyframe_insert('location',frame=frame)
            track=self.rig.animation_data.nla_tracks.new();track.name=clip
            strip=track.strips.new(clip,0,action);strip.action_frame_start=0;strip.action_frame_end=frames
            track.mute=True
        self.rig.animation_data.action=None
        for pb in self.rig.pose.bones:pb.rotation_euler=(0,0,0);pb.location=(0,0,0)
        bpy.context.scene.frame_set(0)
        bpy.ops.object.select_all(action='DESELECT');self.rig.select_set(True);body.select_set(True)
        # glTF NLA tracks export one clip per action; no external Blender dependency at runtime.
        bpy.ops.export_scene.gltf(filepath=str(OUT/(self.kind+'.glb')),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_skins=True,export_yup=True,export_apply=False)
        print('DRAGON',self.kind,'vertices',len(body.data.vertices),'polygons',len(body.data.polygons),'bones',len(self.rig.data.bones))

models = ['cobre', 'jade', 'sentinela']
selected = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else models
if not selected or any(kind not in models for kind in selected):
    raise ValueError('Modelos disponibles: cobre, jade, sentinela')
for kind in selected:
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    for action in list(bpy.data.actions):bpy.data.actions.remove(action)
    Dragon(kind).build()
