"""Approved mining-boss concept, editable two-phase static construction only."""
from pathlib import Path
import base64,collections,copy,hashlib,io,json,math,sys,uuid,zipfile
import numpy as np
from PIL import Image,ImageDraw,ImageFont
import build_forest_stag_static_20261123 as s
from check_forest_stag_static_20261123 import volume_connectivity,coplanar_probe

ROOT=Path(__file__).resolve().parents[1]
P=ROOT/'模型设计/矿洞层主_凿脉者_概念_20261125';D=P/'阶段一_两阶段静态模型'
NAMES=['凿脉者_一阶段负矿','凿脉者_二阶段卸甲']
JAR=Path('D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar')
load,sha,write,jsave=s.load,s.sha,s.write,s.jsave
UID=lambda text:str(uuid.uuid5(uuid.UUID('72ac286b-4f24-5b07-88b8-e4a5621d856e'),text))
MATS=['ore','slate','stone_edge','iron','steel','rust','rust_edge','wood','lamp','lamp_edge','black','joint']


def atlas():
    result=Image.new('RGBA',(256,256),(36,38,42,255));sources=[]
    vanilla={'ore':'deepslate_iron_ore','slate':'deepslate','stone_edge':'polished_deepslate',
             'iron':'netherite_block','steel':'iron_block','wood':'stripped_dark_oak_log'}
    colors={'rust':(107,68,49),'rust_edge':(143,94,63),'lamp':(245,190,70),'lamp_edge':(173,105,28),
            'black':(33,35,40),'joint':(67,69,74)}
    with zipfile.ZipFile(JAR) as z:
        for i,name in enumerate(MATS):
            if name in vanilla:
                resource='assets/minecraft/textures/block/'+vanilla[name]+'.png';data=z.read(resource)
                tile=Image.open(io.BytesIO(data)).convert('RGBA');sources.append({'material':name,'resource':resource,'sha256':hashlib.sha256(data).hexdigest()})
            else:
                col=colors[name];tile=Image.new('RGBA',(16,16));draw=ImageDraw.Draw(tile)
                for y in range(16):
                    for x in range(16):
                        value=[-9,-4,0,3,6][((x//2)*7+(y//3)*11)%5]
                        tile.putpixel((x,y),tuple(max(0,min(255,c+value)) for c in col)+(255,))
                if name=='lamp':
                    draw.rectangle((1,1,14,14),fill=(248,192,65,255));draw.rectangle((4,3,11,12),fill=(255,224,125,255));draw.rectangle((7,5,9,10),fill=(255,239,166,255))
                elif name.startswith('rust'):
                    draw.line((0,0,15,0),fill=tuple(min(255,c+15) for c in col)+(255,));draw.line((0,15,15,15),fill=tuple(max(0,c-18) for c in col)+(255,))
            for y in range(4):
                for x in range(4):result.paste(tile,(i%4*64+x*16,i//4*64+y*16))
    out=io.BytesIO();result.save(out,format='PNG');return out.getvalue(),sources


class Builder(s.Builder):
    def __init__(self):
        self.b={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':NAMES[1],
            'resolution':{'width':256,'height':256},'ambientocclusion':True,'visible_box':[10,8,0],
            'elements':[],'groups':[],'outliner':[],'textures':[],'animations':[]}
        self.tid=UID('mining_atlas_256');self.gs={};self.nodes={};self.shell=set();self.links=[];self.chains={}
        self.b['textures']=[{'uuid':self.tid,'id':'0','name':'mine_excavator_256.png','width':256,'height':256,
            'uv_width':256,'uv_height':256,'source':'data:image/png;base64,'+base64.b64encode(ATLAS).decode(),
            'internal':True,'saved':True,'visible':True,'render_mode':'default','render_sides':'auto','wrap_mode':'limited',
            'folder':'','namespace':'','particle':False}]
        self.group('excavator_root',[0,0,0]);self.group('pelvis',[0,37,1],'excavator_root');self.group('body',[0,40,1],'pelvis')

    def group(self,n,origin,parent=None,rot=None,shell=False):
        result=super().group(n,origin,parent,rot,shell)
        old=self.gs[n]['uuid'];new=UID('group:'+n);self.gs[n]['uuid']=new;self.nodes[n]['uuid']=new
        self.shell.discard(old)
        if shell:self.shell.add(new)
        return result

    def uv(self,mat,size,name,face):
        i=MATS.index(mat);d=np.abs(size);w,h=([d[0],d[1]] if face in ['north','south'] else [d[2],d[1]] if face in ['east','west'] else [d[0],d[2]])
        w,h=min(58,max(1,w)),min(58,max(1,h));seed=int(hashlib.sha1((name+face).encode()).hexdigest()[:6],16)
        x,y=2+seed%max(1,int(60-w)),2+(seed//103)%max(1,int(60-h))
        if mat=='lamp':x,y,w,h=0,0,16,16
        return [float(i%4*64+x),float(i//4*64+y),float(i%4*64+x+w),float(i//4*64+y+h)]

    def box(self,n,c,size,parent,mat='iron',rot=None,cap=False,skip=()):
        e=super().box(n,c,size,parent,mat,rot,False,skip);old=e['uuid'];e['uuid']=UID('element:'+n)
        self.nodes[parent]['children'][-1]=e['uuid'];return e

    def beam(self,n,a,z,w,d,parent,mat='iron',shell=False):
        a,z=np.array(a,float),np.array(z,float);length=float(np.linalg.norm(z-a))
        self.group(n,a,parent,s.euler(s.align([0,1,0],z-a)),shell)
        self.box(n+'_solid',a+[0,length/2,0],[w,length+.20,d],n,mat)
        return n

    def bevel(self,n,c,size,parent,mat='slate'):
        c=np.array(c,float);w,h,d=size
        self.box(n+'_middle',c,[w*.78,h,d],parent,mat)
        for sign in [-1,1]:self.box(n+('_edge_l' if sign<0 else '_edge_r'),c+[sign*w*.444,0,0],[w*.112,h*.88,d*.86],parent,mat)

    def rivet(self,n,c,parent,normal='front'):
        self.box(n,c,[1.6,1.6,.9] if normal=='front' else [.9,1.6,1.6],parent,'steel')

    def cuff(self,n,c,w,h,d,parent):
        c=np.array(c,float)
        for sign in [-1,1]:
            self.box(n+f'_face_{sign}',c+[0,0,sign*(d/2+.6)],[w+2.4,h,1.2],parent,'rust')
            self.box(n+f'_side_{sign}',c+[sign*(w/2+.6),0,0],[1.2,h,d],parent,'rust')
        for sign in [-1,1]:self.rivet(n+f'_rivet_{sign}',c+[sign*(w*.32),0,-d/2-1.65],parent)


def legs(x):
    for sign,side in [(1,'right'),(-1,'left')]:
        hip=np.array([sign*8.,37,1]);knee=np.array([sign*9.,21,2]);ankle=np.array([sign*10.,7,.5])
        upper=x.group('thigh_'+side,hip,'pelvis');lower=x.group('shin_'+side,knee,upper);foot=x.group('foot_'+side,ankle,lower)
        x.chains['leg_'+side]={'points':[hip.tolist(),knee.tolist(),ankle.tolist()],'groups':[upper,lower,foot]}
        x.beam(side+'_thigh_core',hip,knee,7,7,upper,'iron')
        x.beam(side+'_shin_core',knee,ankle,5.5,5.5,lower,'joint')
        x.box(side+'_hip_axle',hip,[9,8.4,10],upper,'joint')
        x.bevel(side+'_upper_leg_plate',(hip+knee)/2+[0,.6,-3.3],[9,13,4.6],upper,'slate')
        x.box(side+'_knee_block',knee,[9.7,7,10],lower,'stone_edge')
        x.box(side+'_knee_face',knee+[0,0,-5.4],[7,4,1.5],lower,'iron')
        x.bevel(side+'_shin_plate',(knee+ankle)/2+[0,0,-2.6],[7.5,10.5,4.4],lower,'slate')
        x.cuff(side+'_thigh_band',(hip+knee)/2+[0,1,-1.0],9,3,9,upper)
        x.cuff(side+'_ankle_band',ankle+[0,1.5,0],7,2.8,8,foot)
        x.box(side+'_ankle_joint',ankle,[6.2,6,7],foot,'joint')
        x.bevel(side+'_boot_base',[sign*10,3.7,-1.8],[12.5,5.4,17],foot,'slate')
        x.box(side+'_boot_sole',[sign*10,1,-1.8],[13,2,17.5],foot,'iron')
        x.box(side+'_boot_toecap',[sign*10,5.2,-7.4],[11,3,6.5],foot,'stone_edge')
        for dx in [-3.7,3.7]:x.box(side+'_toe_strip_'+str(dx),[sign*10+dx,4.5,-10.1],[1.3,3.2,1.0],foot,'iron')


def torso(x):
    x.bevel('pelvis_casting',[0,37,1],[24,8,13],'pelvis','iron')
    x.box('waist_joint',[0,41,1],[10,7,9],'body','joint')
    x.box('spine_pillar',[0,53,2.5],[7,23,6.5],'body','iron')
    for sign in [-1,1]:
        x.box('chest_side_'+str(sign),[sign*10,53,0],[4,22,11],'body','iron')
        x.box('chest_side_skin_'+str(sign),[sign*10.5,53,-5.2],[3.8,16,2],'body','slate')
        x.box('back_rail_'+str(sign),[sign*7.5,53,6],[3,22.6,3],'body','iron')
    x.box('shoulder_yoke',[0,62,0],[29,5,12],'body','iron')
    x.box('chest_lower_crossbar',[0,43.5,0],[23.4,4,12],'body','iron')
    for y in [44.5,61.4]:
        x.box('frame_front_'+str(y),[0,y,-6.5],[25,2.8,2.4],'body','rust')
        for sign in [-1,1]:x.rivet('frame_bolt_'+str(y)+str(sign),[sign*10.5,y,-8.0],'body')
    for sign in [-1,1]:x.box('frame_vertical_'+str(sign),[sign*10.5,53,-6.25],[2.6,15.5,2.4],'body','rust')
    x.group('chest_work_lamp',[0,53,-4],'body')
    x.box('lantern_suspension',[0,59,-3.5],[1.8,6,2],'chest_work_lamp','iron')
    x.box('lantern_body',[0,52.5,-4],[7,9,5],'chest_work_lamp','lamp')
    for y in [47.5,57.5]:x.box('lantern_cap_'+str(y),[0,y,-4],[9,2,7],'chest_work_lamp','rust')
    for sign in [-1,1]:x.box('lantern_guard_'+str(sign),[sign*3.5,52.5,-7],[1,9,1.3],'chest_work_lamp','iron')
    for sign in [-1,1]:
        x.box('belt_side_'+str(sign),[sign*9,37,-6.4],[5,5.5,2.2],'pelvis','rust')
        x.rivet('belt_bolt_'+str(sign),[sign*9,37,-7.9],'pelvis')
    x.box('belt_buckle',[0,37,-6.4],[7,6,2.8],'pelvis','rust_edge')
    x.box('buckle_inset',[0,37,-8.0],[3,3,.8],'pelvis','iron')


def head(x):
    x.group('head',[0,64,0],'body');x.box('neck_peg',[0,64,0],[7,6,7],'head','joint')
    x.box('head_casing',[0,70,-.8],[11,12,10],'head','black')
    for dx in [-4,0,4]:x.box('face_rib_'+str(dx),[dx,70,-6.1],[2.5,11,1.8],'head','iron')
    x.box('helmet_brim',[0,75.5,-1],[18,2,15],'head','rust')
    x.bevel('helmet_crown',[0,78,0],[14,4,12],'head','slate')
    x.box('helmet_center_strap',[0,78.3,-.3],[4,4.4,12.8],'head','rust')
    x.group('helmet_lamp',[0,78,-7.3],'head')
    x.box('helmet_lamp_frame',[0,78,-7.3],[6.8,6.2,3],'helmet_lamp','rust_edge')
    x.box('helmet_lamp_dark_gasket',[0,78,-9],[5.2,4.8,.6],'helmet_lamp','black')
    x.box('helmet_lamp_lens',[0,78,-9.5],[3.8,3.5,.6],'helmet_lamp','lamp')


def arms(x):
    for sign,side in [(1,'right'),(-1,'left')]:
        shoulder=np.array([sign*15.2,62,0]);elbow=np.array([sign*19.,48,-.4]);wrist=np.array([sign*22.,35,-2])
        upper=x.group('upper_arm_'+side,shoulder,'body');lower=x.group('forearm_'+side,elbow,upper);hand=x.group('hand_'+side,wrist,lower)
        x.chains['arm_'+side]={'points':[shoulder.tolist(),elbow.tolist(),wrist.tolist()],'groups':[upper,lower,hand]}
        x.box(side+'_shoulder_axle',shoulder,[8.5,8.5,10],upper,'joint')
        x.beam(side+'_arm_core',shoulder,elbow,6,6,upper,'iron')
        x.bevel(side+'_small_pauldron',shoulder+[sign*1.1,-1.4,0],[12.5,9.5,13],upper,'slate')
        x.box(side+'_elbow_axle',elbow,[8,7,9],lower,'joint')
        x.beam(side+'_forearm_core',elbow,wrist,6.2,6.2,lower,'iron')
        x.cuff(side+'_elbow_band',elbow+[0,-1,0],8,3,9,lower)
        x.cuff(side+'_wrist_band',wrist+[0,2,0],8.5,3,8.5,hand)
        x.box(side+'_hand_palm',wrist+[0,-2,0],[7.6,7,7.8],hand,'iron')
        x.box(side+'_hand_thumb',wrist+[-sign*3.5,-1,-1],[2.8,4.5,4],hand,'joint')
        for i,dx in enumerate([-2.4,0,2.4]):x.box(side+'_finger_'+str(i),wrist+[dx,-3.2,-4],[2.0,5.2,2.4],hand,'iron')
    wrist=np.array([22,35,-2]);x.group('long_pick',wrist,'hand_right')
    hub=np.array([31,16,-4]);tail=np.array([17.5,43,-1])
    x.beam('pick_shaft',hub,tail,3.6,3.6,'long_pick','wood')
    grip=hub+(tail-hub)*.63
    x.beam('pick_grip_wrap',grip-[1,-2,.1],grip+[1,-2,.1],4.2,4.2,'long_pick','rust')
    x.box('pick_eye',hub,[7,7,6.8],'long_pick','rust')
    # Continuous, broad forged pick with two bent tapering points.
    for label,points in [('lower',[hub,hub+[-8,-4,0],hub+[-12,-9,0],hub+[-13,-14,0]]),
                         ('upper',[hub,hub+[8,4,0],hub+[13,8,0],hub+[16,13,0]])]:
        for i,(a,z) in enumerate(zip(points,points[1:])):
            x.beam('pick_'+label+'_'+str(i),a,z,5.8-i*1.55,4.8-i*.7,'long_pick','steel')
    x.group('short_chisel',[-22,33,-2],'hand_left')
    x.box('chisel_mount',[-22,31.5,-2],[8,8,8],'short_chisel','rust')
    x.box('chisel_ferrule',[-22,27,-2],[6.8,7,5.8],'short_chisel','iron')
    for i,(y,w) in enumerate([(23,6),(20.5,4.5),(18.5,2.5)]):x.box('chisel_taper_'+str(i),[-22,y,-2],[w,3.2,4-i*.7],'short_chisel','steel')


def armor(x):
    for sign,side in [(1,'right'),(-1,'left')]:
        n='ore_pauldron_'+side;x.group(n,[sign*15.2,62,0],'upper_arm_'+side,shell=True)
        center=np.array([sign*18.2,61.0,-.4]);x.bevel(n,center,[23,23,21],n,'ore')
        for off in [-6.5,6.5]:
            x.box(n+'_strap_'+str(off),center+[off,0,-11.4],[2.6,22.0,2.4],n,'rust')
            x.box(n+'_top_strap_'+str(off),center+[off,11.9,0],[2.6,1.8,22.2],n,'rust')
            for dy in [-9,9]:x.rivet(n+'_bolt_'+str(off)+str(dy),center+[off,dy,-13],n)
    n='chest_ore_plate';x.group(n,[0,53,-8],'body',shell=True)
    x.bevel(n,[0,52.3,-9.8],[26,18,6.8],n,'ore')
    for sign in [-1,1]:
        x.box('chest_plate_rim_'+str(sign),[sign*12.1,52.3,-13.5],[2.4,19,2.0],n,'rust')
        x.rivet('chest_plate_rivet_'+str(sign),[sign*10,44.5,-14.9],n)
    x.box('chest_plate_bottom',[0,43.7,-13.8],[26,2.4,2.4],n,'rust')
    n='left_stone_counterweight';x.group(n,[-22,35,-2],'hand_left',shell=True)
    x.bevel('counterweight_stone',[-23,34,-2],[20,35,20],n,'ore')
    for y in [22,43]:
        x.cuff('counterweight_band_'+str(y),[-23,y,-2],20,3.7,20,n)
    # Fully attached hauling frame, with a real three-dimensional packed load.
    n='loaded_back_frame';x.group(n,[0,52,8],'body',shell=True)
    x.box('pack_deck',[0,42,18],[40,4,23],n,'iron')
    for sign in [-1,1]:
        x.beam('pack_mount_'+str(sign),[sign*9,46,5],[sign*15,43,16],4.5,5,n,'rust')
        x.box('pack_upright_'+str(sign),[sign*18.7,59,18],[3.4,36,24.6],n,'rust')
        for y in [45,61,74]:x.box('pack_side_rail_'+str(sign)+str(y),[sign*19.6,y,18],[3.2,3.2,25],n,'rust')
    for y in [45,61,74]:
        x.box('pack_rear_rail_'+str(y),[0,y,30],[42,3.4,3.4],n,'rust')
        for dx in [-17,17]:x.rivet('pack_rear_bolt_'+str(y)+str(dx),[dx,y,32],n)
    for row,(y,z,width,height) in enumerate([(50,18,12.8,13.8),(62,18.5,13.8,14),(72,18,11.8,10.5)]):
        for i,xx in enumerate([-12,0,12]):
            x.bevel('ore_load_'+str(row)+str(i),[xx,y+([1,-1,0][i] if row==2 else [0,.3,-.3][i]),z+row*.23+[-.7,.3,-.2][i]],
                [width,height*[1,.96,1.04][i],19 if row<2 else 15],n,'ore' if i!=1 or row==2 else 'slate')


def loaded_pose(x):
    pose={'pelvis':{'position':[0,-7,2]},'body':{'rotation':[-12,0,0]},'head':{'rotation':[12,0,0]}}
    scene=s.Scene(x.b);m=scene.matrices(pose)
    for side in ['right','left']:
        chain=x.chains['leg_'+side];a,k,z=map(np.array,chain['points']);names=chain['groups']
        start=m[names[0]][:3,3];target=z
        knee=s.two_bone(start,target,np.linalg.norm(k-a),np.linalg.norm(z-k),[0,0,-1])
        r1=s.align(k-a,knee-start);r2=s.align(z-k,target-knee)
        pose[names[0]]={'rotation':s.euler(r1).tolist()};pose[names[1]]={'rotation':s.euler(r1.T@r2).tolist()};pose[names[2]]={'rotation':s.euler(r2.T).tolist()}
    for side in ['right','left']:
        chain=x.chains['arm_'+side];a,k,z=map(np.array,chain['points']);names=chain['groups']
        start=m[names[0]][:3,3];target=z+([0,0,0] if side=='right' else [-3,-4,-1])
        elbow=s.two_bone(start,target,np.linalg.norm(k-a),np.linalg.norm(z-k),[0,0,1])
        r1=s.align(k-a,elbow-start);r2=s.align(z-k,target-elbow)
        pose[names[0]]={'rotation':s.euler(m['body'][:3,:3].T@r1).tolist()}
        pose[names[1]]={'rotation':s.euler(r1.T@r2).tolist()};pose[names[2]]={'rotation':s.euler(r2.T).tolist()}
    return pose


def save(b,title,phase):
    b=copy.deepcopy(b);b['name']=title
    for t in b['textures']:
        path=D/'纹理'/t['name'];write(path,base64.b64decode(t['source'].split(',',1)[1]));t.update({'path':str(path),'relative_path':'纹理/'+t['name']})
    jsave(D/(title+'.bbmodel'),b)
    aj=copy.deepcopy(b);bid='fallendream_boss:mine_excavator_'+phase
    aj['meta']={'format':'animated-java:format/blueprint','format_version':'1.11.0','uuid':UID(title+':aj'),'save_location':str(D/(title+'.ajblueprint')),'last_used_blueprint_id':bid}
    aj['blueprint_settings']={'blueprint_id':bid,'auto_render_box':False,'render_box':[10,8],'resource_pack_export_mode':'none','data_pack_export_mode':'none','target_minecraft_version':'1.21.5'}
    aj['texture_groups']=[];aj['variants']={'default':{'name':'default','display_name':'Default','uuid':UID(title+':variant'),'slot_textures':{},'excluded_nodes':[],'is_default':True},'list':[]}
    jsave(D/(title+'.ajblueprint'),aj)
    old=s.D
    try:s.D=D;error=s.display(b,title+'_整体Display调整')
    finally:s.D=old
    return error


def build():
    record=D/'制作记录.json'
    if record.exists():
        assert '--revise' in sys.argv,'Preserve saved model'
        for rel,h in load(record)['owned_hashes'].items():assert sha(D/rel)==h,'Preserve user edit: '+rel
    else:assert not D.exists(),'Preserve existing stage'
    x=Builder();legs(x);torso(x);head(x);arms(x);armor(x)
    pose=loaded_pose(x);b1=s.bake_pose(x.b,pose);b2,removed_g,removed_e=s.without_shell(x.b,x.shell)
    # A small positive sole plane avoids numerical ground contact ambiguity.
    for b in [b1,b2]:
        for g in b['groups']:g['origin'][1]+=.08
        for e in b['elements']:
            for field in ['from','to','origin']:e[field][1]+=.08
    errors=[save(b,n,p) for b,n,p in zip([b1,b2],NAMES,['loaded','unloaded'])]
    jsave(record,{'date':'2026-11-25','approved_concept_sha256':sha(P/'凿脉者_两阶段概念.png'),
        'user_scope':'只做建模，先不接入','phase1_pose':pose,'removable_shell_groups':sorted(x.shell),
        'phase2_removed_groups':removed_g,'phase2_removed_elements':removed_e,'shared_limb_chains':x.chains,
        'phase_cubes':[len(b['elements']) for b in [b1,b2]],'phase_groups':[len(b['groups']) for b in [b1,b2]],
        'display_errors':errors,'texture_sources':SOURCES,'custom_pixel_tiles':['rust','rust_edge','lamp','lamp_edge','black','joint'],
        'owned_hashes':{p.relative_to(D).as_posix():sha(p) for p in D.rglob('*') if p.suffix in ['.bbmodel','.ajblueprint'] or p.parent==D/'纹理'},
        'animations':0,'native_reopened':False,'native_exported':False,'game_tested':False,'live_DP_RP_map_changed':False})
    print('Saved',[(n,len(b['elements']),len(b['groups'])) for n,b in zip(NAMES,[b1,b2])],flush=True)


def export_check(b,phase):
    sc=s.Scene(b);m=sc.matrices();gs={g['name']:g for g in b['groups']};bybone=collections.defaultdict(list)
    for e in b['elements']:bybone[sc.element_bone[e['uuid']]].append(e)
    out=D/'离线导出核验'/phase;transforms={};maxerror=0.;codes=set()
    for name,es in bybone.items():
        origin=np.array(gs[name]['origin']);lo=np.min([np.array(e['from'])-origin for e in es],axis=0);hi=np.max([np.array(e['to'])-origin for e in es],axis=0);center=(lo+hi)/2
        model={'textures':{'0':'fallendream_boss:item/mine_excavator_256'},'elements':[]}
        for e in es:
            cv=lambda v:(np.array(v)-origin-center+8).tolist()
            asset={'from':cv(e['from']),'to':cv(e['to']),'faces':{}}
            assert all(-16-1e-7<=v<=32+1e-7 for field in ['from','to'] for v in asset[field]),(name,lo,hi)
            assert e['rotation']==[0,0,0]
            for face,f in e['faces'].items():asset['faces'][face]={'texture':'#0','uv':(np.array(f['uv'])/16).tolist()}
            model['elements'].append(asset)
            points=np.array([[asset['to'][k] if mask>>k&1 else asset['from'][k] for k in range(3)] for mask in range(8)])
            points=(points-8+center)@m[name][:3,:3].T+m[name][:3,3]
            expected=sc.corners[e['uuid']]@m[name][:3,:3].T+m[name][:3,3];maxerror=max(maxerror,float(abs(points-expected).max()))
        code=hashlib.sha256(json.dumps(model,sort_keys=True).encode()).hexdigest()[:16];codes.add(code);resource='mine_excavator/'+code
        jsave(out/f'assets/fallendream_boss/models/{resource}.json',model)
        jsave(out/f'assets/fallendream_boss/items/{resource}.json',{'model':{'type':'minecraft:model','model':'fallendream_boss:'+resource}})
        transforms[name]={'model':'fallendream_boss:'+resource,'center':center.tolist(),'matrix':m[name].tolist()}
    write(out/'assets/fallendream_boss/textures/item/mine_excavator_256.png',ATLAS)
    jsave(out/'assets/minecraft/atlases/blocks.json',{'sources':[{'type':'minecraft:single','resource':'fallendream_boss:item/mine_excavator_256','sprite':'fallendream_boss:item/mine_excavator_256'}]})
    jsave(out/'分部变换.json',transforms);assert maxerror<1e-7
    return {'geometry_models':len(codes),'bones_with_geometry':len(bybone),'maximum_vertex_error':maxerror,'legal_java_and_atlas':True,'native_export':False}


def check():
    rec=load(D/'制作记录.json');assert sha(P/'凿脉者_两阶段概念.png')==rec['approved_concept_sha256']
    for rel,h in rec['owned_hashes'].items():assert sha(D/rel)==h
    results=[]
    for title,phase in zip(NAMES,['loaded','unloaded']):
        b=load(D/(title+'.bbmodel'));aj=load(D/(title+'.ajblueprint'));sc=s.Scene(b)
        for key in ['elements','groups','outliner','textures','animations']:assert b[key]==aj[key]
        assert not b['animations'];refs=[];grefs=[]
        def walk(nodes):
            for node in nodes:
                if isinstance(node,str):refs.append(node)
                else:grefs.append(node['uuid']);walk(node['children'])
        walk(b['outliner']);assert collections.Counter(refs)==collections.Counter(e['uuid'] for e in b['elements'])
        assert collections.Counter(grefs)==collections.Counter(g['uuid'] for g in b['groups'])
        for e in b['elements']:
            assert np.all(np.array(e['to'])>e['from']) and e['rotation']==[0,0,0]
            for f in e['faces'].values():assert f['texture']==b['textures'][0]['uuid'] and all(0<=v<=256 for v in f['uv'])
        assert (D/b['textures'][0]['relative_path']).read_bytes()==ATLAS
        contact=volume_connectivity(b);coplanar=coplanar_probe(b);points=sc.pose()[0];lo,hi=points.min(0),points.max(0)
        exported=export_check(b,phase)
        result={'name':title,'cubes':len(b['elements']),'groups':len(b['groups']),'dimensions_blocks':((hi-lo)/16).tolist(),
            'minimum_y':float(lo[1]),'connectivity':contact,'limited_coplanar':coplanar,'offline_export':exported,
            'passed':bool(contact['connected_components']==1 and lo[1]>=-.015 and not coplanar['exposed_centroid_candidates'])}
        results.append(result);print(title,'components',contact['connected_components'],'coplanar',len(coplanar['exposed_centroid_candidates']),'minY',lo[1],flush=True)
    b1,b2=[load(D/(n+'.bbmodel')) for n in NAMES];e1={e['uuid']:e for e in b1['elements']}
    assert all(e1[e['uuid']]['faces']==e['faces'] and np.allclose(np.array(e1[e['uuid']]['to'])-e1[e['uuid']]['from'],np.array(e['to'])-e['from']) for e in b2['elements'])
    report={'passed':all(r['passed'] for r in results),'results':results,'phase2_shared_geometry_UVs':True,
       'animations':0,'native_reopened':False,'native_exported':False,'game_tested':False,'FPS_tested':False,'live_DP_RP_map_changed':False}
    jsave(D/'静态模型核验.json',report)
    assert report['passed'],'Inspect static geometry report'


def render():
    scenes=[s.Scene(load(D/(n+'.bbmodel'))) for n in NAMES]
    font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',25);small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',18)
    for direction,label,filename in [((.72,.23,-1),'斜前','两阶段_实际模型对照.png'),((0,.06,-1),'正面','两阶段_正面.png'),((1,.08,0),'侧面','两阶段_侧面.png'),((-.5,.18,1),'斜背','两阶段_背面.png')]:
        center,ppu=s.fit(scenes,direction,(880,780),48)
        board=Image.new('RGB',(1760,870),'#20252d');draw=ImageDraw.Draw(board)
        for j,sc in enumerate(scenes):
            board.paste(sc.render(direction,size=(880,780),center=center,ppu=ppu),(j*880,48));draw.text((j*880+20,10),NAMES[j].replace('_',' · ')+' · '+label,font=font,fill='#e5dfcb')
        draw.text((22,833),'实际保存几何与UV · 同尺度静态预览 · 非概念图 / 非游戏截图',font=small,fill='#bec6b0');board.save(D/filename)
    for j,sc in enumerate(scenes):
        board=Image.new('RGB',(1680,740),'#20252d');draw=ImageDraw.Draw(board)
        for k,(direction,label) in enumerate([((0,.05,-1),'正面'),((1,.05,0),'侧面'),((0,.07,1),'背面')]):
            center,ppu=s.fit([sc],direction,(560,650),38);board.paste(sc.render(direction,size=(560,650),center=center,ppu=ppu),(k*560,40));draw.text((k*560+18,8),label,font=font,fill='#e5dfcb')
        draw.text((20,701),NAMES[j]+' · 实际保存模型 / UV',font=small,fill='#bec6b0');board.save(D/(NAMES[j]+'_三视图.png'))
    print('Saved six actual geometry and UV preview boards.',flush=True)
    seal_previews()


def seal_previews():
    # Rendering is an intentional mutation of these six owned review images.
    # Keep their new hashes without weakening native-master/texture guards.
    record=load(D/'制作记录.json')
    for rel,h in record['owned_hashes'].items():
        if Path(rel).suffix in ['.bbmodel','.ajblueprint'] or rel.startswith('纹理/'):
            assert sha(D/rel)==h,'Preserve native edit: '+rel
    previews=['两阶段_实际模型对照.png','两阶段_正面.png','两阶段_侧面.png','两阶段_背面.png']+[n+'_三视图.png' for n in NAMES]
    for rel in previews:record['owned_hashes'][rel]=sha(D/rel)
    jsave(D/'制作记录.json',record)


def documents():
    r=load(D/'静态模型核验.json');assert r['passed']
    counts='、'.join(str(x['cubes']) for x in r['results']);groups='、'.join(str(x['groups']) for x in r['results'])
    write(D/'打开与制作说明.md',f'''# 凿脉者 两阶段静态模型

2026-11-25。用户认可概念后明确“做一下建模，先不接入”。本轮完成一阶段负矿与二阶段卸甲的静态可编辑模型，不制作战斗程序、部署或修改数值。

一阶段有实际装载矿石的完整背架、大块矿石肩甲、胸甲和左臂石配重；在同一内部骨架上压低骨盆、屈膝负重、前倾躯干，双脚保持接地。二阶段卸掉这些外层组件，挺身露出胸前工作矿灯、铁石结构及左短凿，右长镐和矿灯盔保持身份。两阶段分别{counts}块、{groups}个实际分组，0动画。精确外包围尺寸见 `静态模型核验.json`，不可直接用整件包围盒当作战斗判定。

## 打开

每形态提供同名 `.bbmodel` 和 `.ajblueprint`。BB是可编辑分组母版，纹理内嵌且在 `纹理/mine_excavator_256.png` 外置；AJ导出模式关闭，目标1.21.5。另各提供包含整件几何和正确纹理的 `整体Display调整.bbmodel`，经统一居中缩放并补偿显示倍率；统一调整工程有复杂骨旋转展开，不能直接当作单个合法Java模型。

骨盆、身体、头、矿灯、双臂上下段/手掌、双腿上下段/脚、长镐和短凿、可卸甲与背架均有真实编辑层级。用骨组旋转表示长工具和构件方向，Cube自身均无非法多轴旋转。后续从本阶段保存母版追加动作，不能用初建器覆盖用户手改。

## 材质和预览

256图集，原版深板岩铁矿/深板岩/磨制深板岩/下界合金块/铁块/去皮深色橡木来自本机1.21.5客户端，来源哈希在制作记录；锈铁、矿灯和关节是本轮离散像素材质。未复制概念图作为纹理，未加模型不存在的泛光。概念图仍仅为参考，所有“实际模型”PNG均由当前保存几何及真实UV渲染。

包含两阶段同尺度斜前、正、侧、斜背对照和各自完整三视图。检查镐头与木柄/握手、脚底、关节连接、背架承载与矿石体积及卸甲后背面，避免只让正面成立。

## 核验和范围

正体积、骨组/元素覆盖、BB/AJ一致、内外纹理、UV、统一Display反算、静态接触单连通、限定外露共面及离线合法Java分部/图集引用反算通过。两形态共用构件保持Cube尺寸、面UV和材质，主要差异来自姿态及外甲移除。`离线导出核验/`仅为分部几何核验样本，并非可直接启用的资源包。

当前实际静态形体待审阅。未操作Blockbench、未原生重开/编译、未制作动画/技能、未游戏接入或FPS实测。未改主DP/RP、PCL存档、地图、其他Boss/小怪、奖励或伤害数值。
''')
    write(D/'阶段状态.md','''# 凿脉者 静态阶段

2026-11-25：用户明确只做建模，先不接入。两阶段实际静态模型、BB/AJ、完整Display、256像素图集、实际多角度预览与离线静态/Java分部核验完成。新形体待审阅；0动画，未游戏接入/实测。后续从本阶段保存工程继续，入口 `打开与制作说明.md`。
''')


def package():
    assert load(D/'静态模型核验.json')['passed'];record=load(D/'制作记录.json')
    for rel,h in record['owned_hashes'].items():assert sha(D/rel)==h
    archive=D/'凿脉者_两阶段静态工程_20261125.zip';assert not archive.exists()
    paths=[p for p in D.rglob('*') if p.is_file() and p.suffix!='.zip' and p.name!='交付封装.json']
    with zipfile.ZipFile(archive,'x',zipfile.ZIP_DEFLATED,compresslevel=7) as z:
        for p in paths:z.write(p,p.relative_to(D).as_posix())
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for p in paths:assert hashlib.sha256(z.read(p.relative_to(D).as_posix())).hexdigest()==sha(p)
    jsave(D/'交付封装.json',{'archive':str(archive),'bytes':archive.stat().st_size,'sha256':sha(archive),'all_file_hashes_and_CRC_verified':True})
    print('Packaged',archive.stat().st_size,'bytes',flush=True)


ATLAS,SOURCES=atlas()
if __name__=='__main__':globals()[sys.argv[1]]()
