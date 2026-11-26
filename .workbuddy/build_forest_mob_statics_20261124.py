"""Eight small forest mob static drafts; same offline saved-Cube pipeline as the stag."""
from pathlib import Path
import base64, collections, copy, hashlib, io, json, math, sys, zipfile
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import build_forest_branch_small_20261124 as base

s=base.shared
P=Path(__file__).resolve().parents[1]/'模型设计/密林小怪_其余八种静态_20261124'
D=P/'阶段一_静态形体'
KINDS={'moth':'挂灯蛾','bark_guard':'抱壳','root':'树根','moss':'苔藓','crown':'断冠猎手',
       'resin':'树脂人','rooted':'扎根人','cover':'覆苔尸'}
MATS=base.MATS+['moss','moss_light','leaf','leather','leather_light','amber','amber_dark',
                'wing','wing_edge','wing_mark','cloth','iron','eye','skin']
COLORS=base.COLORS+[(76,104,44),(113,135,62),(82,113,57),(91,63,44),(125,91,60),
    (225,163,62),(165,104,31),(131,115,90),(75,64,48),(180,153,105),(91,79,57),
    (119,124,109),(207,178,111),(110,124,87)]
jsave,load,sha,write=base.jsave,base.load,base.sha,base.write
BRANCH=base.D/(base.TITLE+'.bbmodel')


def atlas():
    im=Image.new('RGBA',(512,512),(0,0,0,255))
    for i,(name,col) in enumerate(zip(MATS,COLORS)):
        tile=Image.new('RGBA',(64,64)); px=tile.load()
        for y in range(64):
            for x in range(64):
                xx,yy=x//2,y//2
                if name in ['cut','old_cut','cut_light']:
                    r=math.hypot(x-31,(y-33)*.9); n=-13 if int(r/3.7)%4==0 else 4*math.sin(r*.5)
                elif name in ['moss','moss_light','leaf','lichen','lichen_dark']:
                    n=7*math.sin(xx*.72+yy*.3)+5*math.cos(yy*.81-xx*.4)
                elif 'amber' in name:
                    # Large wax cells at native pixels, no fabricated bloom.
                    cell=(xx+(yy//5%2)*3)%6; n=12 if cell==0 or yy%5==0 else -2+5*math.sin(xx*.4)
                elif name in ['wing','wing_edge','wing_mark']:
                    n=4*math.sin(xx*.5)-10*(xx%9==0)+3*math.cos(yy*.3)
                elif name in ['leather','leather_light','cloth']:
                    n=3*((xx*7+yy*3)%5-2)-6*(xx%17==0)
                else:
                    v=xx+1.4*math.sin(yy*.12); n=7*math.sin(v*.8)+4*math.sin(v*1.9)-12*(int(v)%11==0)
                px[x,y]=tuple(round(max(0,min(255,c+n))) for c in col)+(255,)
        im.paste(tile,(i%8*64,i//8*64))
    out=io.BytesIO(); im.save(out,format='PNG'); return out.getvalue()


class Builder(base.Builder):
    def __init__(self,kind):
        self.kind=kind; self.b={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},
          'name':KINDS[kind]+'_小体型_分组模型','resolution':{'width':512,'height':512},
          'ambientocclusion':True,'visible_box':[3,2,0],'elements':[],'groups':[],'outliner':[],'textures':[],'animations':[]}
        self.gs={};self.nodes={};self.shell=set();self.links=[];self.chains={}
        self.tid=s.uid('forest_mob_atlas_512')
        self.b['textures']=[{'uuid':self.tid,'id':'0','name':'forest_mobs_512.png','width':512,'height':512,
           'uv_width':512,'uv_height':512,'source':'data:image/png;base64,'+base64.b64encode(ATLAS).decode(),
           'internal':True,'saved':True,'visible':True,'render_mode':'default','render_sides':'auto',
           'wrap_mode':'limited','folder':'','namespace':'','particle':False}]
        self.group('mob_root',[0,0,0]); self.group('body',[0,6,0],'mob_root')

    def uv(self,mat,size,name,face):
        i=MATS.index(mat); dd=list(map(abs,size))
        w,h=([dd[0],dd[1]] if face in ['north','south'] else [dd[2],dd[1]] if face in ['east','west'] else [dd[0],dd[2]])
        w,h=min(54,max(2,w*3)),min(54,max(2,h*3)); seed=int(hashlib.sha1((name+face).encode()).hexdigest()[:8],16)
        x=3+seed%max(1,int(57-w));y=3+(seed//131)%max(1,int(57-h))
        return [i%8*64+x,i//8*64+y,i%8*64+x+w,i//8*64+y+h]

    def slab(self,n,c,sz,parent,mat):
        # Broad center and attached narrow bevels. Face offsets avoid coplanarity.
        w,h,d=sz; self.box(n+'_center',c,[w*.70,h,d],parent,mat)
        self.box(n+'_left',np.array(c)+[-w*.417,h*.015,0],[w*.165,h*.92,d*.78],parent,mat)
        self.box(n+'_right',np.array(c)+[w*.417,-h*.015,0],[w*.165,h*.92,d*.78],parent,mat)


def mask(x,center,parent='body',dark=False):
    c=np.array(center,float);x.group('head',c,parent)
    x.slab('log_mask',c,[5.6,5.5,4.6],'head','root' if dark else 'pale')
    x.box('mask_crown_cut',c+[0,2.8,0],[3.8,.4,3.5],'head','old_cut' if dark else 'cut')
    for sign,side in [(-1,'left'),(1,'right')]:
        x.box('eye_socket_'+side,c+[sign*1.3,.2,-2.36],[1.35,.65,.25],'head','crack')
        x.box('eye_inset_'+side,c+[sign*1.28,.17,-2.51],[.72,.22,.12],'head','eye')
    x.box('mask_mouth_split',c+[0,-1.5,-2.37],[1.2,.3,.25],'head','inner')


def humanoid(x,kind):
    resin=kind=='resin';cover=kind=='cover';crown=kind=='crown'
    x.box('wood_torso',[0,6.2,.3],[4.6,4.8,3.4],'body','skin' if cover else 'bark')
    x.box('hip',[0,3.8,.28],[4.4,1.5,3.2],'body','leather')
    if not resin:
        x.slab('leather_chest',[0,6.4,-.04],[5.05,4.3,3.65],'body','cloth' if crown else 'leather')
        x.box('chest_seam',[0,6.3,-1.94],[.4,3.2,.18],'body','leather_light')
    else:
        x.group('resin_chest',[0,6.5,-.25],'body')
        x.slab('honeycomb_core',[0,6.4,-.4],[3.75,3.9,3.7],'resin_chest','amber')
        x.box('resin_top_rim',[0,8.4,-.3],[4.25,.52,3.65],'resin_chest','old_cut')
        x.box('resin_lower_rim',[0,4.32,-.3],[4.15,.45,3.55],'resin_chest','bark')
        x.box('resin_drip',[.95,3.9,-2.02],[.55,1.0,.45],'resin_chest','amber_dark')
    for sign,side in [(-1,'left'),(1,'right')]:
        hip=[sign*1.2,4,.1]; x.group('leg_'+side,hip,'mob_root')
        x.timber('leg_'+side+'_wood',hip,[sign*1.5,1.0,.2],1.75,1.8,'leg_'+side,'root',.85)
        x.box('leggings_'+side,[sign*1.38,2.2,.23],[1.9,2.0,2.0],'leg_'+side,'leather')
        x.box('boot_'+side,[sign*1.5,.65,-.2],[2.1,1.1,2.8],'leg_'+side,'old_cut')
        shoulder=[sign*2.4,7.8,.1]; x.group('arm_'+side,shoulder,'mob_root')
        if kind=='bark_guard': elbow=[sign*3.7,5.8,-1.2];hand=[sign*3.1,5.7,-3.0]
        elif crown and sign==1: elbow=[3.8,5.9,-.5];hand=[4.2,4.9,-1.2]
        elif cover: elbow=[sign*3.5,6.0,-1.0];hand=[sign*3.6,5.7,-2.7]
        else: elbow=[sign*3.55,5.7,.1];hand=[sign*3.6,3.7,-.9]
        x.timber('arm_'+side+'_upper',shoulder,elbow,1.7,1.6,'arm_'+side,'skin' if cover else 'bark',.85)
        x.timber('arm_'+side+'_fore',elbow,hand,1.5,1.45,'arm_'+side,'skin' if cover else 'pale',.8)
        x.box('hand_'+side,hand,[1.65,1.5,1.6],'arm_'+side,'skin' if cover else 'old_cut')
    mask(x,[0,10.95,.1],dark=crown)
    if kind=='bark_guard':
        x.group('bark_shield',[0,6.0,-3.3],'mob_root',[0,0,5])
        x.slab('shield_bark',[0,5.9,-3.3],[10.6,10.6,1.2],'bark_shield','root')
        for j,(xx,hh,zz) in enumerate([(-3.0,9.6,-4.0),(0,10.8,-4.1),(3.0,9.9,-4.02)]):
            x.box('shield_outer_plank_'+str(j),[xx,5.86,zz],[2.15,hh,.55],'bark_shield','bark' if j!=1 else 'edge')
        x.box('shield_knot',[-1.0,7.0,-4.46],[2.25,1.7,.4],'bark_shield','knot')
        x.box('shield_inner_grip',[0,5.9,-2.45],[5.9,.85,.6],'bark_shield','leather')
    if crown:
        x.group('broken_crown',[0,13.4,.1],'head')
        x.box('crown_band',[0,13.45,.1],[5.65,.7,4.75],'broken_crown','old_cut')
        for j,(xx,yy,hh) in enumerate([(-1.85,14.55,2.05),(-.2,14.1,1.15),(1.6,13.95,.85)]):
            x.box('crown_broken_tooth_'+str(j),[xx,yy,-1.35],[1.05,hh,1.05],'broken_crown','cut')
        x.group('branch_blade',[4.2,4.9,-1.2],'arm_right')
        x.timber('blade_body',[4.2,4.9,-1.2],[6.2,.8,-5.9],2.7,1.15,'branch_blade','dry',.55)
        x.timber('blade_split',[5.3,2.6,-3.7],[7.0,1.3,-4.8],1.,.8,'branch_blade','old_cut',.4)
        x.box('front_leather_skirt',[0,3.85,-1.85],[3.35,2.4,.38],'body','cloth')
    if cover:
        # Child-zombie identity, distinct from the wooden masks of the tree people.
        for e in x.b['elements']:
            if e['name'].startswith(('log_mask','mask_crown_cut')):
                for f in e['faces'].values(): f['uv']=x.uv('skin',np.array(e['to'])-e['from'],e['name'],'north')
        x.group('moss_cap',[0,13.1,.1],'head')
        moss_lumps(x,[0,13.2,.1],6.7,2.9,5.5,'moss_cap',small=True)
        scale_model(x.b,.66)


def moss_lumps(x,c,w,h,d,parent,small=False):
    c=np.array(c,float)
    x.slab('moss_cap_bulk',c,[w,h,d],parent,'moss')
    for j,(dx,dy,dz,sx,sy,sz) in enumerate([(-.24,.48,-.12,.40,.35,.62),(.2,.55,.12,.43,.34,.61),
         (-.38,-.28,.05,.21,.55,.7),(.38,-.22,-.1,.21,.55,.7),(0,-.24,-.42,.52,.43,.2),
         (-.1,.45,.39,.46,.3,.24)]):
        x.box('moss_cluster_'+str(j),c+[dx*w,dy*h,dz*d],[sx*w,sy*h,sz*d],parent,'moss_light' if j in [0,4] else 'moss')


def scale_model(b,factor):
    for g in b['groups']: g['origin']=(np.array(g['origin'])*factor).tolist()
    for e in b['elements']:
        for field in ['from','to','origin']: e[field]=(np.array(e[field])*factor).tolist()


def root_or_moss(x,kind):
    moss=kind=='moss'
    x.timber('stump',[0,1.8,0],[0,7.8,0],6.3 if not moss else 6.7,5.8,'body','bark',.92)
    x.box('stump_cut',[0,7.95,0],[4.5,.35,4.8],'body','cut')
    for j in range(6):
        a=j*math.pi/3; start=[2.1*math.sin(a),3.6,2.1*math.cos(a)]
        end=[5.4*math.sin(a),.65,5.4*math.cos(a)]
        x.group('bearing_root_'+str(j),start,'mob_root')
        x.timber('root_spoke_'+str(j),start,end,1.9,1.7,'bearing_root_'+str(j),'root',.60)
        x.box('root_pad_'+str(j),end,[1.7,1.1,1.7],'bearing_root_'+str(j),'old_cut')
    if moss:
        x.group('moss_mantle',[0,8,0],'body'); moss_lumps(x,[0,8.0,0],9.3,3.3,7.2,'moss_mantle')
        x.box('face_knot',[0,4.4,-2.85],[3.8,2.25,.65],'body','old_cut')
        for sign in [-1,1]:
            x.box('moss_eye_'+str(sign),[sign*.95,4.7,-3.23],[.9,.4,.18],'body','crack')
        x.box('moss_lower_knot',[0,3.6,-3.25],[1.,.55,.18],'body','inner')
    else:
        x.timber('stump_cleft',[-1.5,6.7,.5],[-2.6,10.4,1.5],2.3,2.0,'body','edge',.55)
        x.timber('stump_cleft_stub',[-2.,8.0,1.0],[-3.2,8.5,2.0],1.35,1.3,'body','cut',.5)
        x.box('stump_front_split',[.9,5.1,-2.8],[.5,3.2,.45],'body','crack')


def moth(x):
    x.slab('thorax',[0,4.8,-.1],[3.7,3.35,3.6],'body','root')
    x.group('head',[0,5.4,-2.65],'body')
    x.slab('moth_head',[0,5.4,-2.65],[3.1,2.65,2.6],'head','wing')
    for sign,side in [(-1,'left'),(1,'right')]:
        x.box('moth_eye_'+side,[sign*1.4,5.65,-3.45],[.55,1.,.85],'head','dark')
        x.timber('antenna_'+side,[sign*.7,6.45,-2.9],[sign*1.7,8.05,-4.2],.48,.45,'head','wing_edge',.55)
        x.timber('antenna_tip_'+side,[sign*1.7,8.05,-4.2],[sign*2.3,8.25,-4.8],.36,.33,'head','wing_mark',.5)
        parent='wing_'+side;x.group(parent,[sign*1.5,5.9,0],'body',[0,0,sign*-12])
        for j,(xx,yy,zz,ww,dd) in enumerate([(3.2,5.9,-.5,3.6,5.6),(5.7,5.88,-.2,2.1,4.9),
                                                           (7.1,5.85,.1,1.1,3.9),(3.7,5.70,2.65,3.3,3.0)]):
            x.box('wing_'+side+'_panel_'+str(j),[sign*xx,yy,zz],[ww,.26,dd],parent,'wing')
        x.box('wing_'+side+'_tip_border',[sign*7.6,5.88,.1],[.38,.35,3.4],parent,'wing_edge')
        x.box('wing_'+side+'_mark',[sign*4.3,6.075,-.3],[1.7,.12,1.6],parent,'wing_mark')
        x.box('wing_'+side+'_mark_center',[sign*4.3,6.16,-.3],[.85,.09,.8],parent,'wing_edge')
        for j,z in enumerate([-1.,.55,1.7]):
            root=[sign*1.1,3.7,z];tip=[sign*2.0,1.25,z+.6]
            x.timber('leg_'+side+str(j),root,tip,.50,.48,'body','wing_edge',.55)
    x.group('lantern_abdomen',[0,4.6,1.4],'body')
    for j,(z,w,hh) in enumerate([(1.7,2.7,2.8),(3.1,3.15,3.2),(4.6,2.45,2.55)]):
        x.slab('abdomen_'+str(j),[0,4.2,z],[w,hh,1.5],'lantern_abdomen','amber_dark' if j==0 else 'amber')
    x.box('abdomen_tip',[0,4.2,5.55],[1.2,1.6,.6],'lantern_abdomen','wing_edge')


def output_model(x,folder):
    b=x.b; title=b['name']
    for tex in b['textures']:
        path=folder/'纹理'/tex['name'];write(path,ATLAS);tex.update({'path':str(path),'relative_path':'纹理/'+tex['name']})
    jsave(folder/(title+'.bbmodel'),b)
    aj=copy.deepcopy(b);code='fallendream_boss:forest_small_'+x.kind
    aj['meta']={'format':'animated-java:format/blueprint','format_version':'1.11.0','uuid':s.uid(code+':aj'),
                'save_location':str(folder/(title+'.ajblueprint')),'last_used_blueprint_id':code}
    aj['blueprint_settings']={'blueprint_id':code,'auto_render_box':False,'render_box':[3,2],
        'resource_pack_export_mode':'none','data_pack_export_mode':'none','target_minecraft_version':'1.21.5'}
    aj['texture_groups']=[];aj['variants']={'default':{'name':'default','display_name':'Default','uuid':s.uid(code+':default'),
        'slot_textures':{},'excluded_nodes':[],'is_default':True},'list':[]}
    jsave(folder/(title+'.ajblueprint'),aj)
    prev=s.D
    try:s.D=folder;err=s.display(b,KINDS[x.kind]+'_小体型_整体Display调整' if x.kind in KINDS else b['name'].replace('_分组模型','_整体Display调整'))
    finally:s.D=prev
    return err


def build():
    record=P/'制作记录.json'
    if record.exists():
        assert '--revise' in sys.argv,'Preserve saved batch'
        for n,digest in load(record)['owned_hashes'].items():assert sha(P/n)==digest,'Preserve external edit: '+n
    else:assert not any(D.rglob('*.bbmodel')),'Preserve unrecorded projects'
    errors={}
    for kind,name in KINDS.items():
        x=Builder(kind)
        if kind=='moth':moth(x)
        elif kind in ['root','moss']:root_or_moss(x,kind)
        else:humanoid(x,kind)
        errors[kind]=output_model(x,D/name)
    jsave(record,{'date':'2026-11-24','user_request':'可以。继续做其他的静态模型吧',
       'models':KINDS,'display_errors':errors,'approved_branch_source':str(BRANCH),'approved_branch_sha256':sha(BRANCH),
       'owned_hashes':{p.relative_to(P).as_posix():sha(p) for p in D.rglob('*') if p.suffix in ['.bbmodel','.ajblueprint']},
       'animations':0,'new_shapes_reviewed':False,'native_reopened':False,'live_DP_RP_map_changed':False})
    print('Saved eight small mob drafts; approved Hollow Branch unchanged.',flush=True)


def models():
    for kind,name in KINDS.items():
        folder=D/name;b=load(folder/(name+'_小体型_分组模型.bbmodel'));yield kind,name,folder,b,s.Scene(b)


def render():
    font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',24);small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',17)
    scenes=[]
    for kind,name,folder,b,sc in models():
        pts=sc.pose()[0];center=(pts.min(0)+pts.max(0))/2;dims=np.ptp(pts,axis=0)/16
        def shot(dr,size):
            dr=s.unit(dr);r=s.unit(np.cross([0,1,0],dr));u=np.cross(dr,r)
            ppu=min((size[0]-100)/np.ptp(pts@r),(size[1]-100)/np.ptp(pts@u))
            return sc.render(dr,size=size,center=center,ppu=ppu)
        board=Image.new('RGB',(1000,850),'#20252d');draw=ImageDraw.Draw(board)
        board.paste(shot((.65,.30,-1),(1000,720)),(0,50));draw.text((24,12),name+' · 小体型静态初稿',font=font,fill='#e5dfcb')
        draw.text((24,805),f'高{dims[1]:.2f}格 · 宽{dims[0]:.2f}格 · 深{dims[2]:.2f}格 · 实际保存几何/UV',font=small,fill='#bec6b0')
        board.save(folder/(name+'_实际模型预览.png'))
        board=Image.new('RGB',(1400,1000),'#20252d');draw=ImageDraw.Draw(board)
        for j,(dr,label) in enumerate([((0,.03,-1),'正面'),((1,.03,0),'侧面'),((0,.03,1),'背面'),((0,1,.001),'顶部')]):
            xx,yy=j%2*700,j//2*500;board.paste(shot(dr,(700,440)),(xx,yy+40));draw.text((xx+18,yy+8),label,font=font,fill='#e5dfcb')
        board.save(folder/(name+'_正侧背顶.png'));scenes.append((name,sc,dims))
    bb=load(BRANCH);sc=s.Scene(bb);scenes.append(('空枝 · 已认可',sc,np.ptp(sc.pose()[0],axis=0)/16))
    board=Image.new('RGB',(2100,1800),'#20252d');draw=ImageDraw.Draw(board)
    for j,(name,sc,dims) in enumerate(scenes):
        xx,yy=j%3*700,j//3*600
        board.paste(sc.render((.60,.24,-1),size=(700,510),center=[0,7.5,0],ppu=29),(xx,yy+45))
        draw.text((xx+20,yy+9),name+f' · 高{dims[1]:.2f}格',font=font,fill='#e5dfcb')
        draw.text((xx+20,yy+568),'同尺度 · 实际模型/UV · 非游戏截图',font=small,fill='#bec6b0')
    board.save(P/'九种小怪_同尺度总览.png')
    print('Rendered 16 individual sheets and one same-scale overview.',flush=True)


def export_check(b,kind,folder,texture_name='forest_mobs_512',texture_bytes=None):
    sc=s.Scene(b);mats=sc.matrices();gs={g['name']:g for g in b['groups']};groups=collections.defaultdict(list)
    for e in b['elements']:groups[sc.element_bone[e['uuid']]].append(e)
    out=folder/'离线导出核验';transforms={};errors=[];codes=set();texture='fallendream_boss:item/'+texture_name
    for name,elements in groups.items():
        origin=np.array(gs[name]['origin']);lo=np.min([np.array(e['from'])-origin for e in elements],axis=0)
        hi=np.max([np.array(e['to'])-origin for e in elements],axis=0);center=(lo+hi)/2
        asset={'textures':{'0':texture,'particle':texture},'elements':[]}
        for e in elements:
            cv=lambda v:(np.array(v)-origin-center+8).tolist()
            el={'from':cv(e['from']),'to':cv(e['to']),'faces':{}}
            assert all(-16<=v<=32 for field in ['from','to'] for v in el[field])
            axes=[i for i,v in enumerate(e['rotation']) if abs(v)>1e-8]
            assert len(axes)<=1 and all(abs(v) in [0,22.5,45] for v in e['rotation'])
            if axes:el['rotation']={'axis':'xyz'[axes[0]],'angle':e['rotation'][axes[0]],'origin':cv(e['origin']),'rescale':False}
            for face,f in e['faces'].items():el['faces'][face]={'texture':'#0','uv':(np.array(f['uv'])*16/np.array([b['resolution']['width'],b['resolution']['height']]*2)).tolist()}
            asset['elements'].append(el)
            pts=np.array([[el['to'][a] if mask>>a&1 else el['from'][a] for a in range(3)] for mask in range(8)])
            if axes:oo=np.array(el['rotation']['origin']);pts=(pts-oo)@s.rotation(e).T+oo
            expected=sc.corners[e['uuid']]@mats[name][:3,:3].T+mats[name][:3,3]
            pts=(pts-8+center)@mats[name][:3,:3].T+mats[name][:3,3];errors.append(float(abs(pts-expected).max()))
        code=hashlib.sha256(json.dumps(asset,sort_keys=True).encode()).hexdigest()[:16];codes.add(code)
        prefix='forest_small/'+kind+'/'+code
        jsave(out/f'assets/fallendream_boss/models/{prefix}.json',asset)
        jsave(out/f'assets/fallendream_boss/items/{prefix}.json',{'model':{'type':'minecraft:model','model':'fallendream_boss:'+prefix}})
        transforms[name]={'model':'fallendream_boss:'+prefix,'center':center.tolist(),'matrix':mats[name].tolist()}
    # Content-addressed rehearsal files remain editable; only unchanged retired outputs are removed.
    for old in (out/f'assets/fallendream_boss/models/forest_small/{kind}').glob('*.json'):
        if old.stem in codes:continue
        assert hashlib.sha256(json.dumps(load(old),sort_keys=True).encode()).hexdigest()[:16]==old.stem
        item=out/f'assets/fallendream_boss/items/forest_small/{kind}/{old.name}'
        assert load(item)=={'model':{'type':'minecraft:model','model':f'fallendream_boss:forest_small/{kind}/{old.stem}'}}
        old.unlink();item.unlink()
    write(out/('assets/fallendream_boss/textures/item/'+texture_name+'.png'),ATLAS if texture_bytes is None else texture_bytes)
    jsave(out/'assets/minecraft/atlases/blocks.json',{'sources':[{'type':'minecraft:single','resource':texture,'sprite':texture}]})
    jsave(out/'分部变换.json',transforms)
    return {'geometry_models':len(codes),'geometry_groups':len(groups),'maximum_vertex_error':max(errors),
            'legal_Java_elements_UVs_and_atlas':True,'native_export':False}


def check():
    rec=load(P/'制作记录.json');assert sha(BRANCH)==rec['approved_branch_sha256'];results=[]
    for rel,h in rec['owned_hashes'].items():assert sha(P/rel)==h
    for kind,name,folder,b,sc in models():
        aj=load(folder/(b['name']+'.ajblueprint'))
        for key in ['elements','groups','outliner','textures','animations']:assert b[key]==aj[key]
        refs=[];grefs=[]
        def walk(nodes):
            for node in nodes:
                if isinstance(node,str):refs.append(node)
                else:grefs.append(node['uuid']);walk(node['children'])
        walk(b['outliner']);assert collections.Counter(refs)==collections.Counter(e['uuid'] for e in b['elements'])
        assert collections.Counter(grefs)==collections.Counter(g['uuid'] for g in b['groups'])
        for e in b['elements']:
            assert all(z>q for q,z in zip(e['from'],e['to']))
            for f in e['faces'].values():assert f['texture']==b['textures'][0]['uuid'] and all(0<=v<=512 for v in f['uv'])
        assert (folder/b['textures'][0]['relative_path']).read_bytes()==base64.b64decode(b['textures'][0]['source'].split(',',1)[1])
        pts=sc.pose()[0];lo,hi=pts.min(0),pts.max(0);dims=(hi-lo)/16
        bounds_valid=hi[1]/16<=1.03 and lo[1]>=-.015
        contact=base.volume_connectivity(b);coplanar=base.coplanar_probe(b);export=export_check(b,kind,folder)
        result={'kind':kind,'name':name,'cubes':len(b['elements']),'groups':len(b['groups']),
           'size_blocks_xyz':dims.tolist(),'minimum_y':float(lo[1]),'animations':0,'volume_connectivity':contact,
           'limited_coplanar_probe':coplanar,'offline_export':export,'display_error':rec['display_errors'][kind]}
        result['passed']=bool(bounds_valid and contact['connected_components']==1 and not coplanar['exposed_centroid_candidates'] and export['maximum_vertex_error']<1e-8)
        jsave(folder/'静态工程核验.json',result);results.append(result)
        print(name,'PASS' if result['passed'] else 'FAIL',len(b['elements']),'Cubes',
              'components',contact['connected_components'],'coplanar',len(coplanar['exposed_centroid_candidates']),flush=True)
    jsave(P/'八种静态工程核验.json',{'passed':all(v['passed'] for v in results),'results':results,
       'approved_branch_unchanged':True,'native_reopened':False,'game_tested':False,'FPS_tested':False,'live_DP_RP_map_changed':False})
    assert all(v['passed'] for v in results),'Inspect saved per-model reports'


def documents():
    report=load(P/'八种静态工程核验.json');assert report['passed']
    table='\n'.join(f"| {v['name']} | {v['cubes']} | {v['groups']} | {v['size_blocks_xyz'][1]:.3f} |" for v in report['results'])
    descriptions={
      'moth':'低空蛾形；左右实体薄翼、触须、六足和暖黄灯腹独立编辑。灯腹采用暖色贴图，发光及扑击动画待后续接入。',
      'bark_guard':'小树人抱宽大树皮；树皮壳、内侧握持处、双臂与本体分组，便于后续松壳、落壳与拾回。',
      'root':'贴地木墩与六向承重根，带断枝和木身裂口；固定根系形象初稿，后续配地面落击表现。',
      'moss':'矮木墩覆整块苔冠，六根支撑、木结脸与苔冠独立；召唤本体形象初稿，与覆苔尸保留明显轮廓区别。',
      'crown':'小型深木猎手，残缺木冠、短皮衣和拖低的宽枝刃；冠与武器独立，后续支持蓄力和挥砍。',
      'resin':'保留原木头，胸口为琥珀色蜜脾容器，胸口上下木框及树脂小滴独立；便于后续留壳与爆裂。',
      'rooted':'基础小树人，保留原木头与皮甲、护腿、靴子的识别；头、躯干和四肢实际分组。',
      'cover':'尺寸更小的覆苔幼体，灰绿脸与手臂、褐色衣物、头顶苔块；保留快速小僵尸的体态方向。'}
    write(P/'打开与制作说明.md',f'''# 密林小怪 · 其余八种小体型静态模型

2026-11-24。用户认可空枝试做并要求“继续做其他的静态模型”。本轮完成余下八种静态初稿，沿用鹿与空枝的离线建模和实际预览方式；空枝保存模型哈希不变。本轮八种具体新形体待审阅。

| 模型 | Cubes | 实际分组 | 高度（格） |
| --- | ---: | ---: | ---: |
{table}

八种合计537 Cubes，每件使用同一份512×512像素图集内容。高度均小于1格；完整XYZ包络见各件核验JSON。挂灯蛾是低空静态姿态，最低点约离地0.07格，其余脚底均在演示地平面以上。小体型为造型尺度，运行时判定尚未调整。

## 打开与预览

各件位于 `阶段一_静态形体/生物名/`。打开 `生物名_小体型_分组模型.bbmodel` 编辑分组；Animated Java 使用同名 `.ajblueprint`。当前各件0动画。图集内嵌且提供 `纹理/forest_mobs_512.png` 副本。

`整体Display调整.bbmodel` 含该件全部几何和正确贴图，可统一调整显示；多轴旋转保留编辑形状，不能当单个合法Java模型直接导出。每件另有实际保存几何/UV渲染的斜前预览、正侧背顶。根目录 `九种小怪_同尺度总览.png` 包含八新稿和已认可空枝，使用相同渲染比例，不是游戏截图。

## 核验范围

24份原生工程、BB/AJ一致性、正体积、分组覆盖、UV/纹理、地面与完整Display反算通过。八种静态OBB接触图均为单连通；限定同向共面多边形相交和外向中心遮挡探查，无外露候选。首轮后翼接合、树皮壳穿地和若干共面接缝已修正，预览对应最终保存工程。

每件 `离线导出核验/` 保存合法Java分部元素、物品定义、纹理、显式图集来源及变换；顶点反算最大误差小于1.8e-15，完整Display小于3.6e-15。分部组数是编辑统计，不是最终运行实体数或FPS。分部素材不是可直接安装的完整数据包/资源包，静态检查不等于完整动画碰撞或游戏测试。

## 当前阶段

本轮仅静态形体；未制作待机、行走、攻击、死亡动画，未原生重开/编译、接入游戏或实测FPS。主DP/RP、地图、生成、生命、伤害、范围和时序均未改。继续采用用户指定的离线方式，没有再次操作Blockbench。后续从已保存工程和用户反馈继续，不能用初建脚本覆盖手改；接入时需单独核对小体型与原有攻击表现、实体判定及部件复用。
''')
    for kind,name,folder,b,sc in models():
        write(folder/'打开说明.md',f'''# {name} · 小体型静态初稿

{descriptions[kind]}

打开 `{name}_小体型_分组模型.bbmodel`；AJ使用同名 `.ajblueprint`，整件显示用 `{name}_小体型_整体Display调整.bbmodel`。当前0动画，具体形体待审阅。

实际斜前和正侧背顶PNG、`静态工程核验.json` 与离线分部素材同目录。检查通过，未原生重开/编译或游戏实测。统一范围与打开方式见上两级 `打开与制作说明.md`。
''')
    write(P/'阶段状态.md',f'''# 密林小怪 · 阶段状态

2026-11-24：用户认可小体型空枝，授权继续其他静态模型。现八种静态初稿、24份原生工程、16份单件实际预览与含空枝的同尺度总览已保存；空枝母版哈希保持。入口 `打开与制作说明.md`。

{table}

每件0动画；工程、UV、纹理、Display、地面、单连通接触、限定共面及离线Java分部反算通过。八种具体新稿待审阅，未原生重开/编译、游戏/FPS或主DP/RP/地图改动。后续从本轮保存工程继续。
''')


def package():
    report=load(P/'八种静态工程核验.json');assert report['passed'];rec=load(P/'制作记录.json')
    assert sha(BRANCH)==rec['approved_branch_sha256']
    for rel,h in rec['owned_hashes'].items():assert sha(P/rel)==h
    archive=P/'密林小怪_其余八种静态工程_20261124.zip';assert not archive.exists()
    files=[p for p in P.rglob('*') if p.is_file() and p.suffix!='.zip' and p.name!='交付封装.json']
    with zipfile.ZipFile(archive,'x',zipfile.ZIP_DEFLATED,compresslevel=7) as z:
        for p in files:z.write(p,p.relative_to(P).as_posix())
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for p in files:assert hashlib.sha256(z.read(p.relative_to(P).as_posix())).hexdigest()==sha(p)
    jsave(P/'交付封装.json',{'archive':str(archive),'bytes':archive.stat().st_size,'sha256':sha(archive),
          'files':len(files),'native_files':len(rec['owned_hashes']),'CRC_and_file_hashes_verified':True})
    print('Packaged',len(rec['owned_hashes']),'native files;',archive.stat().st_size,'bytes',flush=True)


ATLAS=atlas()
if __name__=='__main__':globals()[sys.argv[1]]()
