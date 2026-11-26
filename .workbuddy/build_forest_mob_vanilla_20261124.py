"""Vanilla-oriented revisions: adult zombie proportions scaled down, native pixel assets.
Preserves every first-stage project and the approved Hollow Branch.
"""
from pathlib import Path
import base64, collections, copy, hashlib, io, json, math, sys, zipfile
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import build_forest_mob_statics_20261124 as old

s=old.s; load,sha,write,jsave=old.load,old.sha,old.write,old.jsave
P=old.P/'阶段二_原版风格修订';D=P/'模型';KINDS={**old.KINDS,'branch':'空枝'}
JAR=Path('D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar')
BLOCKS=['oak_log','oak_log_top','dark_oak_log','dark_oak_log_top','stripped_oak_log','stripped_oak_log_top',
        'moss_block','honeycomb_block','dark_oak_planks','coarse_dirt','mangrove_roots_side','mangrove_roots_top']


def atlas():
    im=Image.new('RGBA',(256,256));slots={};sources=[]
    with zipfile.ZipFile(JAR) as z:
        for name,entry,xy in [('husk','entity/zombie/husk',(0,0)),('zombie','entity/zombie/zombie',(64,0)),
                 ('leather','entity/equipment/humanoid/leather',(128,0)),
                 ('leggings','entity/equipment/humanoid_leggings/leather',(192,0))]:
            path='assets/minecraft/textures/'+entry+'.png';data=z.read(path)
            tile=Image.open(io.BytesIO(data)).convert('RGBA')
            if name in ['leather','leggings']:
                rgba=np.array(tile);rgba[:,:,:3]=(rgba[:,:,:3].astype(float)*[.52,.36,.23]).astype('uint8');tile=Image.fromarray(rgba)
                overlay=Image.open(io.BytesIO(z.read('assets/minecraft/textures/'+entry+'_overlay.png'))).convert('RGBA')
                tile.alpha_composite(overlay)
                # Bake clothing over the matching vanilla skin layout. One cube per
                # limb avoids overlapping armor shells on the small static draft.
                backing=Image.open(io.BytesIO(z.read('assets/minecraft/textures/entity/zombie/husk.png'))).convert('RGBA')
                backing.alpha_composite(tile);tile=backing
            im.paste(tile,xy);slots[name]=(*xy,*tile.size);sources.append({'resource':path,'sha256':hashlib.sha256(data).hexdigest()})
        for i,name in enumerate(BLOCKS):
            path='assets/minecraft/textures/block/'+name+'.png';data=z.read(path)
            tile=Image.open(io.BytesIO(data)).convert('RGBA');assert tile.size==(16,16)
            xy=(i*16,96);im.paste(tile,xy);slots[name]=(*xy,16,16);sources.append({'resource':path,'sha256':hashlib.sha256(data).hexdigest()})
    # Purpose-painted 16px moth surfaces: discrete pixels, no procedural smooth gradients.
    tile=Image.open(io.BytesIO(zipfile.ZipFile(JAR).read('assets/minecraft/textures/block/oak_log.png'))).convert('RGBA').transpose(Image.Transpose.ROTATE_90)
    im.paste(tile,(192,96));slots['oak_log_z']=(192,96,16,16)
    colors={'moth_body':(82,70,54),'moth_head':(106,94,72),'wing':(137,121,91),'lantern':(208,151,54)}
    for i,(name,col) in enumerate(colors.items()):
        tile=Image.new('RGBA',(16,16),col+(255,));draw=ImageDraw.Draw(tile)
        for yy in range(16):
            for xx in range(16):
                delta=[-12,-5,0,6,10][(xx*7+yy*11+(xx//3)*5)%5]
                tile.putpixel((xx,yy),tuple(max(0,min(255,v+delta)) for v in col)+(255,))
        if name=='wing':
            draw.line([(0,0),(6,5),(15,7)],fill=(82,70,53,255),width=1)
            draw.line([(6,5),(8,15)],fill=(90,76,56,255),width=1)
            draw.line([(0,15),(15,15)],fill=(89,76,57,255),width=1)
            draw.rectangle((10,9,12,11),fill=(108,89,62,255))
        if name=='moth_head':
            draw.rectangle((0,5,3,10),fill=(34,28,22,255));draw.rectangle((12,5,15,10),fill=(34,28,22,255))
        if name=='lantern':draw.rectangle((2,3,13,12),fill=(225,176,76,255));draw.line((0,14,15,14),fill=(136,91,28,255))
        xy=(i*16,128);im.paste(tile,xy);slots[name]=(*xy,16,16)
    out=io.BytesIO();im.save(out,format='PNG');return out.getvalue(),slots,sources


class Builder(s.Builder):
    def __init__(self,kind):
        self.kind=kind;self.b={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},
           'name':KINDS[kind]+'_原版风格_分组模型','resolution':{'width':256,'height':256},'ambientocclusion':True,
           'visible_box':[3,2,0],'elements':[],'groups':[],'outliner':[],'textures':[],'animations':[]}
        self.gs={};self.nodes={};self.shell=set();self.links=[];self.chains={};self.tid=s.uid('forest_mobs_vanilla_256')
        self.b['textures']=[{'uuid':self.tid,'id':'0','name':'forest_mobs_vanilla_256.png','width':256,'height':256,
           'uv_width':256,'uv_height':256,'source':'data:image/png;base64,'+base64.b64encode(ATLAS).decode(),
           'internal':True,'saved':True,'visible':True,'render_mode':'default','render_sides':'auto',
           'wrap_mode':'limited','folder':'','namespace':'','particle':False}]
        self.group('mob_root',[0,0,0]);self.group('body',[0,18,0],'mob_root')

    def uv(self,mat,size,name,face):
        xx,yy,ww,hh=SLOTS[mat];return [xx,yy,xx+ww,yy+hh]

    def cube(self,n,c,sz,parent,mat,rot=None):
        return self.box(n,c,sz,parent,mat,rot)

    def skin_cube(self,n,c,sz,parent,mat,uv):
        el=self.cube(n,c,sz,parent,mat);ox,oy,_,_=SLOTS[mat]
        for face,coords in uv.items():el['faces'][face]['uv']=[coords[0]+ox,coords[1]+oy,coords[2]+ox,coords[3]+oy]
        return el


def skin_uv(u,v,w,h,d):
    return {'north':[u+d,v+d,u+d+w,v+d+h],'south':[u+2*d+w,v+d,u+2*d+2*w,v+d+h],
       'west':[u,v+d,u+d,v+d+h],'east':[u+d+w,v+d,u+2*d+w,v+d+h],
       'up':[u+d,v,u+d+w,v+d],'down':[u+d+w,v,u+d+2*w,v+d]}


def log_head(x,kind):
    material='moss_block' if kind=='cover' else 'dark_oak_log' if kind in ['crown','bark_guard'] else 'stripped_oak_log' if kind=='resin' else 'oak_log'
    e=x.cube('block_head',[0,28,0],[8,8,8],'head',material)
    top=material+'_top'
    if top in SLOTS:
        for face in ['up','down']:e['faces'][face]['uv']=x.uv(top,[8,8,8],'block_head',face)


def humanoid(x,kind):
    # Original adult zombie proportions: 8px head, 12px torso, 12px legs.
    skin='zombie' if kind=='cover' else 'husk'
    armored=kind in ['rooted','bark_guard','crown']
    x.skin_cube('torso',[0,18,0],[8,12,4],'body','leather' if armored else skin,skin_uv(16,16,8,12,4))
    x.group('head',[0,24,0],'body');log_head(x,kind)
    for sign,side in [(-1,'left'),(1,'right')]:
        x.group('leg_'+side,[sign*2,12,0],'mob_root')
        x.skin_cube('leg_'+side,[sign*2,6,0],[4,12,4],'leg_'+side,'leggings' if armored else skin,skin_uv(0,16,4,12,4))
        x.group('arm_'+side,[sign*6,24,0],'mob_root')
        x.skin_cube('arm_'+side,[sign*6,18,0],[4,12,4],'arm_'+side,skin,skin_uv(40,16,4,12,4))
    if kind=='resin':
        x.group('resin_chest',[0,18,-.45],'body')
        x.cube('honeycomb_chest',[0,18,-.45],[7.4,9.5,4.6],'resin_chest','honeycomb_block')
    if kind=='bark_guard':
        x.group('bark_shield',[-2.0,15,-4.25],'arm_left')
        x.cube('bark_shield',[-2.0,15,-4.25],[12.4,20,2.0],'bark_shield','dark_oak_log')
        x.cube('shield_inner_grip',[-4.5,16,-2.6],[3.0,2.5,1.6],'bark_shield','dark_oak_planks')
        x.cube('shield_broken_edge',[-5.5,25.75,-4.25],[5.0,1.5,2.0],'bark_shield','dark_oak_log')
    if kind=='crown':
        x.group('broken_crown',[0,31,0],'head')
        for j,(xx,yy,hh) in enumerate([(-3.,33.0,3.0),(-.5,32.4,1.8),(2.5,32.1,1.2)]):
            x.cube('broken_crown_'+str(j),[xx,yy,-2.6],[1.5,hh,2.5],'broken_crown','dark_oak_log')
        x.group('branch_blade',[6,13,-1],'arm_right')
        x.cube('branch_handle',[6,10.1,-1.5],[2,7.0,2],'branch_blade','dark_oak_log')
        x.cube('broad_branch_edge',[6,4.5,-1.5],[3.5,6.4,1.5],'branch_blade','oak_log')
        x.cube('branch_broken_tip',[7.25,1.7,-1.5],[.9,1.6,1.3],'branch_blade','oak_log')
    factor=.44 if kind=='crown' else .32 if kind=='cover' else .46
    old.scale_model(x.b,factor)
    # The support plane is deterministic and does not depend on render camera.
    for g in x.b['groups']:g['origin'][1]+=.08
    for e in x.b['elements']:
        for key in ['from','to','origin']:e[key][1]+=.08


def root_or_moss(x,kind):
    moss=kind=='moss'
    e=x.cube('stump',[0,4,0],[6,7,6],'body','oak_log')
    for face in ['up','down']:e['faces'][face]['uv']=x.uv('oak_log_top',[6,7,6],'stump',face)
    for sign,side in [(-1,'left'),(1,'right')]:
        x.group('root_'+side,[sign*2,2.2,0],'mob_root')
        x.cube('root_'+side+'_base',[sign*4,1.8,0],[4.0,2.8,2.7],'root_'+side,'oak_log')
        x.cube('root_'+side+'_end',[sign*6.5,.7,0],[2.0,1.2,2.1],'root_'+side,'oak_log')
    for sign,side in [(-1,'front'),(1,'rear')]:
        x.group('root_'+side,[0,2,sign*2],'mob_root')
        x.cube('root_'+side+'_base',[0,1.7,sign*4],[2.5,2.6,4.0],'root_'+side,'oak_log')
        x.cube('root_'+side+'_end',[0,.7,sign*6.4],[2.0,1.2,1.9],'root_'+side,'oak_log')
    if moss:
        x.group('moss_growth',[0,5.5,0],'body')
        x.cube('moss_body',[0,5.5,0],[7.8,6.2,7.7],'moss_growth','moss_block')
        x.cube('moss_uneven_top',[-1.42,9.1,.4],[4.8,1.2,5.3],'moss_growth','moss_block')
        x.cube('moss_side_growth',[4.0,4.2,.6],[1.2,3.2,4.7],'moss_growth','moss_block')
    else:
        x.cube('broken_stump',[-1.3,8.8,.5],[2.6,3.2,2.6],'body','oak_log')
        x.cube('short_side_branch',[3.6,5.2,.7],[2.3,1.8,2.0],'body','oak_log')


def moth(x):
    x.cube('thorax',[0,5.6,-1.3],[4,4,5],'body','moth_body')
    x.group('head',[0,6,-4.8],'body');x.cube('head',[0,6,-4.8],[3,3,3],'head','moth_head')
    for sign,side in [(-1,'left'),(1,'right')]:
        x.cube('antenna_'+side,[sign*1.1,8.0,-5.1],[.5,2.0,.5],'head','moth_body')
        x.group('wing_'+side,[sign*1.6,7.2,-.8],'body',[0,0,-sign*8])
        x.cube('forewing_'+side,[sign*4.6,7.2,-1.0],[6.1,.22,6.0],'wing_'+side,'wing')
        x.cube('hindwing_'+side,[sign*3.9,7.05,3.1],[4.8,.22,3.3],'wing_'+side,'wing')
        for j,z in enumerate([-2.5,-.4,1.3]):
            x.group('foot_'+side+str(j),[sign*1.5,4.0,z],'body')
            x.cube('foot_'+side+str(j),[sign*2.2,3.3,z],[1.6,.55,.55],'foot_'+side+str(j),'moth_body',[0,0,-sign*45])
    x.group('lantern_abdomen',[0,5.0,2.4],'body')
    x.cube('lantern_abdomen',[0,5.,3.2],[3.6,3.6,4.5],'lantern_abdomen','lantern')
    x.cube('abdomen_band',[0,5.1,1.2],[3.7,3.7,.5],'lantern_abdomen','moth_body')


def branch(x):
    # A low fallen branch with a real rectangular cavity and no face or toy hands.
    panels=[('top',[0,6.15,0],[8,1.3,10],[0,0,16,3]),
            ('bottom',[0,1.85,0],[8,1.3,10],[0,13,16,16]),
            ('left',[-3.35,4,0],[1.3,3,10],[0,3,3,13]),
            ('right',[3.35,4,0],[1.3,3,10],[13,3,16,13])]
    ox,oy,_,_=SLOTS['oak_log_top']
    for name,c,sz,uv in panels:
        el=x.cube('hollow_'+name,c,sz,'body','oak_log_z')
        for face in ['north','south']:el['faces'][face]['uv']=[ox+uv[0],oy+uv[1],ox+uv[2],oy+uv[3]]
    for sign,side in [(-1,'left'),(1,'right')]:
        for zz,label in [(-3,'front'),(3,'rear')]:
            group='root_'+side+'_'+label;x.group(group,[sign*3,2,zz],'mob_root')
            x.cube(group,[sign*4.2,1.1,zz],[3.2,.9,1.2],group,'oak_log',[0,0,sign*22.5])
        group='branch_arm_'+side;x.group(group,[sign*3.5,4.4,-.5],'mob_root')
        x.cube(group+'_main',[sign*5.1,4.2,-2.0],[3.4,1.4,1.7],group,'oak_log_z')
        x.cube(group+'_tip',[sign*6.15,4.18,-4.1],[1.2,1.2,3.1],group,'oak_log_z')
        x.cube(group+'_fork',[sign*7.2,4.2,-3.7],[1.2,.9,1.5],group,'oak_log')


def build():
    recpath=P/'制作记录.json'
    if recpath.exists():
        assert '--revise' in sys.argv
        for rel,h in load(recpath)['owned_hashes'].items():assert sha(P/rel)==h,'Preserve edited revision: '+rel
    else:assert not any(D.rglob('*.bbmodel'))
    sources={str(p):sha(p) for p in old.D.rglob('*') if p.suffix in ['.bbmodel','.ajblueprint']}
    sources.update({str(p):sha(p) for p in old.base.D.iterdir() if p.suffix in ['.bbmodel','.ajblueprint']});errors={}
    prev=old.ATLAS
    try:
        old.ATLAS=ATLAS
        for kind,name in KINDS.items():
            x=Builder(kind)
            if kind=='moth':moth(x)
            elif kind in ['root','moss']:root_or_moss(x,kind)
            elif kind=='branch':branch(x)
            else:humanoid(x,kind)
            folder=D/name;errors[kind]=old.output_model(x,folder)
            ajfile=folder/(x.b['name']+'.ajblueprint');aj=load(ajfile)
            aj['blueprint_settings']['blueprint_id']+='_vanilla';aj['meta']['last_used_blueprint_id']=aj['blueprint_settings']['blueprint_id'];jsave(ajfile,aj)
    finally:old.ATLAS=prev
    jsave(P/'制作记录.json',{'date':'2026-11-24','request':'小怪建模贴近原版，取消幼儿玩偶风格',
      'source_hashes':sources,'display_errors':errors,'texture_sources':TEXTURE_SOURCES,'vanilla_client_jar':str(JAR),
      'owned_hashes':{p.relative_to(P).as_posix():sha(p) for p in D.rglob('*') if p.suffix in ['.bbmodel','.ajblueprint']},
      'animations':0,'shape_reviewed':False,'native_reopened':False,'game_tested':False})
    print('Saved nine vanilla-oriented revisions; all prior models preserved.',flush=True)


def models():
    for kind,name in KINDS.items():
        folder=D/name;b=load(folder/(name+'_原版风格_分组模型.bbmodel'));yield kind,name,folder,b,s.Scene(b)


def check():
    rec=load(P/'制作记录.json');results=[]
    for rel,h in rec['source_hashes'].items():assert sha(Path(rel))==h
    for rel,h in rec['owned_hashes'].items():assert sha(P/rel)==h
    for kind,name,folder,b,sc in models():
        aj=load(folder/(b['name']+'.ajblueprint'))
        for key in ['elements','groups','outliner','textures','animations']:assert b[key]==aj[key]
        refs=[];groups=[]
        def walk(ns):
            for node in ns:
                if isinstance(node,str):refs.append(node)
                else:groups.append(node['uuid']);walk(node['children'])
        walk(b['outliner']);assert collections.Counter(refs)==collections.Counter(e['uuid'] for e in b['elements'])
        assert collections.Counter(groups)==collections.Counter(g['uuid'] for g in b['groups'])
        for e in b['elements']:
            assert all(z>q for q,z in zip(e['from'],e['to']))
            for f in e['faces'].values():assert f['texture']==b['textures'][0]['uuid'] and all(0<=v<=256 for v in f['uv'])
        assert (folder/b['textures'][0]['relative_path']).read_bytes()==base64.b64decode(b['textures'][0]['source'].split(',',1)[1])
        pts=sc.pose()[0];lo,hi=pts.min(0),pts.max(0)
        contact=old.base.volume_connectivity(b);coplanar=old.base.coplanar_probe(b)
        export=old.export_check(b,'v2_'+kind,folder,'forest_mobs_vanilla_256',ATLAS)
        ratios=None
        if kind not in ['moth','root','moss','branch']:
            es={e['name']:e for e in b['elements']};dims=lambda n:np.array(es[n]['to'])-es[n]['from']
            ratios=[float(dims('block_head')[1]/dims('torso')[1]),float(dims('leg_right')[1]/dims('torso')[1])]
            assert abs(ratios[0]-2/3)<1e-7 and abs(ratios[1]-1)<1e-7
        passed=bool(lo[1]>=-.015 and hi[1]/16<=1.03 and contact['connected_components']==1 and not coplanar['exposed_centroid_candidates'])
        r={'name':name,'kind':kind,'passed':passed,'cubes':len(b['elements']),'groups':len(b['groups']),
           'size_blocks_xyz':((hi-lo)/16).tolist(),'minimum_y':float(lo[1]),'head_to_torso_and_leg_to_torso':ratios,
           'contact':contact,'limited_coplanar':coplanar,'offline_export':export,'display_error':rec['display_errors'][kind]}
        jsave(folder/'静态工程核验.json',r);results.append(r)
        print(name,'PASS' if passed else 'FAIL','components',contact['connected_components'],'coplanar',len(coplanar['exposed_centroid_candidates']),flush=True)
    jsave(P/'原版风格静态核验.json',{'passed':all(v['passed'] for v in results),'results':results,
           'source_models_unchanged':True,'native_reopened':False,'game_tested':False,'FPS_tested':False,'live_pack_map_changed':False})
    assert all(v['passed'] for v in results),'Inspect saved reports'


def render():
    font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',24);small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',17)
    overview=Image.new('RGB',(2100,1800),'#20252d');draw=ImageDraw.Draw(overview)
    for j,(kind,name,folder,b,sc) in enumerate(models()):
        pts=sc.pose()[0];center=(pts.min(0)+pts.max(0))/2;dims=np.ptp(pts,axis=0)/16
        def shot(direction,size):
            dr=s.unit(direction);rr=s.unit(np.cross([0,1,0],dr));up=np.cross(dr,rr)
            return sc.render(dr,size=size,center=center,ppu=min((size[0]-90)/np.ptp(pts@rr),(size[1]-90)/np.ptp(pts@up)))
        hero=Image.new('RGB',(900,850),'#20252d');hd=ImageDraw.Draw(hero)
        hero.paste(shot((.6,.25,-1),(900,720)),(0,50));hd.text((20,10),name+' · 原版风格修订',font=font,fill='#e5dfcb')
        hd.text((20,800),f'高{dims[1]:.2f}格 · 实际保存模型/UV · 离线预览',font=small,fill='#bec6b0');hero.save(folder/(name+'_实际模型预览.png'))
        board=Image.new('RGB',(1400,1000),'#20252d');bd=ImageDraw.Draw(board)
        for k,(direction,label) in enumerate([((0,.02,-1),'正面'),((1,.02,0),'侧面'),((0,.02,1),'背面'),((0,1,.001),'顶部')]):
            xx,yy=k%2*700,k//2*500;board.paste(shot(direction,(700,440)),(xx,yy+40));bd.text((xx+20,yy+8),label,font=font,fill='#e5dfcb')
        board.save(folder/(name+'_正侧背顶.png'))
        xx,yy=j%3*700,j//3*600
        overview.paste(sc.render((.6,.24,-1),size=(700,480),center=[0,7.6,0],ppu=27),(xx,yy+48))
        draw.text((xx+16,yy+10),name+f' · 高{dims[1]:.2f}格',font=font,fill='#e5dfcb')
        draw.text((xx+16,yy+564),'同尺度 · 实际保存几何/UV',font=small,fill='#bec6b0')
    overview.save(P/'九种小怪_原版风格总览.png')
    # Compare old and new rooted-human silhouettes at equal standing height.
    previous=load(old.D/'扎根人/扎根人_小体型_分组模型.bbmodel');new=load(D/'扎根人/扎根人_原版风格_分组模型.bbmodel')
    board=Image.new('RGB',(1500,900),'#20252d');bd=ImageDraw.Draw(board)
    for j,(bb,label) in enumerate([(previous,'旧稿 · 已停用'),(new,'修订 · 原版比例')]):
        sc=s.Scene(bb);pts=sc.pose()[0];center=(pts.min(0)+pts.max(0))/2
        scale=620/np.ptp(pts[:,1]);board.paste(sc.render((0,.03,-1),size=(750,750),center=center,ppu=scale),(j*750,65))
        bd.text((j*750+30,18),label,font=font,fill='#e5dfcb')
    bd.text((30,850),'等身高比较：头/躯干/腿改为原版8:12:12比例；旧模型只用于对照。',font=small,fill='#bec6b0')
    board.save(P/'扎根人_比例修订对照.png')
    print('Rendered revised models, four-side sheets and proportion comparison.',flush=True)


def documents():
    report=load(P/'原版风格静态核验.json');assert report['passed']
    table='\n'.join(f"| {v['name']} | {v['cubes']} | {v['groups']} | {v['size_blocks_xyz'][1]:.3f} |" for v in report['results'])
    write(P/'打开与制作说明.md',f'''# 密林小怪 · 原版风格静态修订

2026-11-24。用户指出上一批“太幼儿”，要求小怪建模都贴近原版。本轮另存九种静态修订：人形采用原版僵尸8像素头、12像素躯干、12像素腿的比例后整体缩小，手臂为原版直方肢；移除玩偶式立体表情、肥大头身比例、独立手掌和大脚底。树根/苔藓改自然方块生长轮廓，蛾体改直接方块与薄翼，空枝保留中空枯枝识别并另给方块风修订。原九件工程原生文件哈希保持。

| 生物 | Cubes | 实际分组 | 高度（格） |
| --- | ---: | ---: | ---: |
{table}

## 材质来源与工程

材质取自本机Minecraft Java 1.21.5客户端的僵尸、尸壳、原木、苔藓、蜜脾与皮革装备PNG，来源路径和SHA256见 `制作记录.json`。皮革染成棕色并在对应原版UV位置合成到基础皮肤；蛾体与翅面为本轮绘制的16×16像素块面。原版素材归原作者，未称为原创贴图。图集256×256，仅打包原像素，没有以平滑大图替代像素细节。

每件在 `模型/生物名/`，有分组模型 `.bbmodel`、同名 `.ajblueprint`、含完整几何的 `整体Display调整.bbmodel`、内嵌及外置纹理、实际斜前和正侧背顶PNG。27份原生文件，各0动画。完整Display保留展开后的多轴旋转供编辑，不能直接作为单个合法Java模型导出。

`九种小怪_原版风格总览.png` 使用同一物理比例；`扎根人_比例修订对照.png` 按同等身高显示旧稿与新稿。所有图来自保存几何和UV，是离线预览，不是游戏截图。此前八种玩偶风静态稿停止作为后续制作基线，文件作为历史保留；本轮九种具体修订仍待审阅。

## 核验和接续

BB/AJ一致、层级/元素覆盖、UV/纹理可达、正体积、地面、完整Display、静态OBB单连通、限定外露共面检查通过。五种人形的头高/躯干高为2/3、腿高/躯干高为1。各件离线Java分部包含合法元素、物品定义、图集与变换；这些是离线素材，不是可直接安装的完整资源包。分部数量不是运行实体或FPS。

保持用户要求的离线流程，未操作Blockbench、未原生重开/编译、动画或游戏/FPS测试；未改主DP/RP、地图或生命、伤害、范围、时序、归属。小体型接入仍需核对实体判定和技能可见范围。后续从本轮保存工程与反馈继续，不以旧初建器覆盖手改。原版风格要求适用于本批密林小怪，不擅自重做Boss。
''')
    write(P/'阶段状态.md','''# 原版风格修订状态

九种小怪静态修订已保存，具体成品待审阅，入口 `打开与制作说明.md`。上一批玩偶风八种稿停止作为制作基线；已认可空枝旧稿保留，另有本轮风格统一候选。27原生文件、18单件预览、九种总览与一份比例对照，0动画。

离线几何/UV/接触/共面/Java分部与人形8:12:12比例检查通过。旧27原生源文件哈希保持，无主包、资源包、地图或战斗规则修改；未原生重开/编译或游戏/FPS测试。
''')


def package():
    report=load(P/'原版风格静态核验.json');assert report['passed'];rec=load(P/'制作记录.json')
    for path,h in rec['source_hashes'].items():assert sha(Path(path))==h
    for rel,h in rec['owned_hashes'].items():assert sha(P/rel)==h
    archive=P/'密林九种小怪_原版风格静态工程_20261124.zip';assert not archive.exists()
    files=[p for p in P.rglob('*') if p.is_file() and p.suffix!='.zip' and p.name not in ['交付封装.json','八种小怪_原版风格总览.png']]
    with zipfile.ZipFile(archive,'x',zipfile.ZIP_DEFLATED,compresslevel=7) as z:
        for p in files:z.write(p,p.relative_to(P).as_posix())
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for p in files:assert hashlib.sha256(z.read(p.relative_to(P).as_posix())).hexdigest()==sha(p)
    jsave(P/'交付封装.json',{'archive':str(archive),'bytes':archive.stat().st_size,'sha256':sha(archive),
       'files':len(files),'native_files':len(rec['owned_hashes']),'CRC_and_all_file_hashes_verified':True})
    print('Packaged',len(rec['owned_hashes']),'native files;',archive.stat().st_size,'bytes',flush=True)


ATLAS,SLOTS,TEXTURE_SOURCES=atlas()
if __name__=='__main__':globals()[sys.argv[1]]()
