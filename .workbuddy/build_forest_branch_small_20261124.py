"""Small Hollow Branch shape trial, using the stag's saved-Cube workflow.

Owns only this new review stage. No live packs, map code or old models change.
"""
from pathlib import Path
import base64, collections, copy, hashlib, io, json, math, sys, zipfile
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import build_forest_stag_static_20261123 as shared
from check_forest_stag_static_20261123 import coplanar_probe, volume_connectivity

P = Path(__file__).resolve().parents[1]/'模型设计/密林小怪_空枝_小体型试做_20261124'
D = P/'阶段一_静态形体'
TITLE = '空枝_小体型_分组模型'
load, sha, write, jsave = shared.load, shared.sha, shared.write, shared.jsave
SIZE = 256
MATS = ['bark', 'pale', 'inner', 'cut', 'old_cut', 'lichen', 'edge', 'crack',
        'root', 'dry', 'mottle', 'dark', 'bark_light', 'cut_light', 'lichen_dark', 'knot']
COLORS = [(108,94,76),(157,145,120),(73,59,44),(177,153,114),(131,107,76),
          (107,116,83),(135,120,96),(47,40,30),(91,79,60),(144,134,110),
          (123,116,92),(59,49,37),(129,114,91),(190,168,129),(80,91,60),(95,76,52)]


def atlas():
    im = Image.new('RGBA', (SIZE,SIZE), (0,0,0,255))
    for i, (name, col) in enumerate(zip(MATS,COLORS)):
        tile = Image.new('RGBA',(64,64)); px = tile.load()
        for y in range(64):
            for x in range(64):
                xx, yy = x//2, y//2
                if name in ['cut','old_cut','cut_light']:
                    radius = math.hypot(x-30, (y-34)*.88)
                    noise = -14 if int(radius/3.5)%4 == 0 else 4*math.sin(radius*.5)
                elif 'lichen' in name:
                    noise = 6*math.sin(xx*.7+yy*.25)+5*math.cos(yy*.8-xx*.4)
                else:
                    v = xx+1.5*math.sin(yy*.12)
                    noise = 7*math.sin(v*.8)+4*math.sin(v*1.9)+2*math.cos(yy*.6)
                    if int(v)%11 == 0: noise -= 13
                px[x,y] = tuple(round(max(0,min(255,c+noise))) for c in col)+(255,)
        draw = ImageDraw.Draw(tile)
        if name in ['bark','pale','edge','root','dry','bark_light']:
            draw.arc((21,15,31,42),35,325,fill=tuple(max(0,v-23) for v in col)+(255,),width=2)
        im.paste(tile,(i%4*64,i//4*64))
    out=io.BytesIO(); im.save(out,format='PNG'); return out.getvalue()


class Builder(shared.Builder):
    def __init__(self):
        self.b={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},
                'name':TITLE,'resolution':{'width':SIZE,'height':SIZE},'ambientocclusion':True,
                'visible_box':[3,2,0],'elements':[],'groups':[],'outliner':[],'textures':[],'animations':[]}
        self.gs={}; self.nodes={}; self.shell=set(); self.links=[]; self.chains={}
        self.tid=shared.uid('forest_branch_small_atlas')
        self.b['textures']=[{'uuid':self.tid,'id':'0','name':'hollow_branch_256.png',
            'width':SIZE,'height':SIZE,'uv_width':SIZE,'uv_height':SIZE,
            'source':'data:image/png;base64,'+base64.b64encode(atlas()).decode(),
            'internal':True,'saved':True,'visible':True,'render_mode':'default','render_sides':'auto',
            'wrap_mode':'limited','folder':'','namespace':'','particle':False}]
        self.group('branch_root',[0,0,0]); self.group('hollow_body',[0,6.6,0],'branch_root')

    def uv(self,mat,size,name,face):
        i=MATS.index(mat); d=list(map(abs,size))
        w,h=([d[0],d[1]] if face in ['north','south'] else [d[2],d[1]] if face in ['east','west'] else [d[0],d[2]])
        w,h=min(54,max(2,w*3)),min(54,max(2,h*3))
        seed=int(hashlib.sha1((name+face).encode()).hexdigest()[:8],16)
        x=3+seed%max(1,int(57-w)); y=3+(seed//131)%max(1,int(57-h))
        return [i%4*64+x,i//4*64+y,i%4*64+x+w,i//4*64+y+h]

    def timber(self,n,a,b,w,d,parent,mat='pale',tip=.68):
        # A connected 3-strip bevel with two taper sections, 6 Cubes per timber.
        a,b=np.array(a,float),np.array(b,float); length=float(np.linalg.norm(b-a))
        g=self.group(n,a,parent,shared.euler(shared.align([0,1,0],b-a)))
        for k in range(2):
            u=(k+.5)/2; fac=1-u*(1-tip)
            for j,(lo,hi,depth) in enumerate([(-.5,-.32,.74),(-.32,.32,1.),(.32,.5,.74)]):
                self.box(n+f'_{k}_{j}',a+[(lo+hi)/2*w*fac,length*(k+.5)/2,0],
                         [(hi-lo)*w*fac,length/2+.08,d*depth*fac],g,mat,
                         skip=(['down'] if k else []))
        return g


def geometry(x):
    # Eight connected wooden staves form an actual open tube, not a black decal.
    for j in range(8):
        angle=j*math.pi/4
        for k,(z,length,rad) in enumerate([(-3.6,3.8,3.38),(.1,3.7,3.4),(3.6,3.4,3.36)]):
            if k==0:
                front=-5.5-.075*j; end=-1.7; z=(front+end)/2; length=end-front
            elif k==2:
                start=1.9; end=5.3+.065*j; z=(start+end)/2; length=end-start
            c=[rad*math.sin(angle),6.6+rad*math.cos(angle),z]
            thickness=1.6; width=3.55
            size=[width,thickness,length] if j in [0,4] or j%2 else [thickness,width,length]
            rot=[0,0,(-45 if j in [1,5] else 45)] if j%2 else None
            e=x.box(f'body_stave_{j}_{k}',c,size,'hollow_body','pale' if j in [0,1,7] else 'bark',rot)
            for face in ['north','south']: e['faces'][face]['uv']=x.uv('cut' if k==0 else 'old_cut',size,e['name'],face)
            # No duplicate coplanar interior end faces between the axial sections.
            if k: e['faces'].pop('north',None)
            if k<2: e['faces'].pop('south',None)
    # Broad weathered bark plates remain attached to the solid tube wall.
    for sign,side in [(-1,'left'),(1,'right')]:
        x.box('flank_bark_'+side,[sign*4.16,6.6,1.3],[.6,2.4,5.7],'hollow_body','edge')
        x.box('front_split_'+side,[sign*2.7,9.3,-5.48],[1.5,1.1,.58],'hollow_body','cut_light',[0,0,sign*22.5])
        x.box('bottom_split_'+side,[sign*2.7,3.8,-5.45],[1.0,.9,.48],'hollow_body','old_cut',[0,0,-sign*22.5])
    x.box('back_top_bark',[.1,10.48,1.7],[3.1,.65,4.6],'hollow_body','dry')
    x.timber('broken_back_knot',[.3,9.8,2.9],[1.0,12.2,3.8],1.8,1.6,'hollow_body','bark',.75)
    x.timber('back_knot_stub',[.8,11.3,3.5],[2.0,11.6,4.1],.95,.9,'hollow_body','cut',.50)
    for i,(pos,sz) in enumerate([([-.9,10.95,1.9],[1.5,.22,1.8]),([.9,10.96,2.2],[1.2,.22,1.3]),
                                ([-4.5,7.0,2.2],[.18,1.1,1.3])]):
        x.box('lichen_patch_'+str(i),pos,sz,'hollow_body','lichen')
    # Four short bearing roots; each chain and sole is independently editable.
    for sign,side in [(-1,'left'),(1,'right')]:
        for zsign,label in [(-1,'front'),(1,'rear')]:
            joint=[sign*2.7,4.2,zsign*2.6]
            name='rootleg_'+side+'_'+label; x.group(name,joint,'branch_root')
            knee=[sign*4.1,2.3,zsign*3.5]; end=[sign*4.9,.7,zsign*4.6]
            x.timber(name+'_upper',joint,knee,1.7,1.7,name,'root',.80)
            x.timber(name+'_lower',knee,end,1.4,1.35,name,'pale',.75)
            x.box(name+'_sole',[sign*4.9,.35,zsign*4.8],[1.8,.5,2.0],name,'old_cut')
            x.timber(name+'_toe',end,[sign*5.7,.45,zsign*5.7],.65,.7,name,'dry',.38)
    # Two folded branched arms support later left/right strikes without a large body.
    for sign,side in [(-1,'left'),(1,'right')]:
        shoulder=[sign*3.35,6.1,-.75]; name='branch_arm_'+side
        x.group(name,shoulder,'branch_root')
        elbow=[sign*5.9,4.9,-2.6]; wrist=[sign*7.0,4.0,-4.6]
        x.timber(name+'_upper',shoulder,elbow,2.2,2.0,name,'bark',.80)
        x.timber(name+'_fore',elbow,wrist,1.75,1.6,name,'pale',.70)
        x.timber(name+'_outer_prong',wrist,[sign*9.5,3.4,-7.0],1.2,1.15,name,'dry',.35)
        x.timber(name+'_raised_prong',[sign*6.8,4.2,-4.3],[sign*8.1,6.4,-5.7],1.1,1.,name,'pale',.38)
        x.timber(name+'_inside_prong',[sign*7.2,3.9,-4.7],[sign*6.8,3.1,-6.8],.8,.75,name,'cut',.35)


def save_model(b):
    for tex in b['textures']:
        path=D/'纹理'/tex['name']; write(path,base64.b64decode(tex['source'].split(',',1)[1]))
        tex.update({'path':str(path),'relative_path':'纹理/'+tex['name']})
    jsave(D/(TITLE+'.bbmodel'),b)
    aj=copy.deepcopy(b); aj['meta']={'format':'animated-java:format/blueprint','format_version':'1.11.0',
        'uuid':shared.uid(TITLE+':aj'),'save_location':str(D/(TITLE+'.ajblueprint')),
        'last_used_blueprint_id':'fallendream_boss:small_hollow_branch'}
    aj['blueprint_settings']={'blueprint_id':'fallendream_boss:small_hollow_branch','auto_render_box':False,
        'render_box':[3,2],'resource_pack_export_mode':'none','data_pack_export_mode':'none','target_minecraft_version':'1.21.5'}
    aj['texture_groups']=[]; aj['variants']={'default':{'name':'default','display_name':'Default',
        'uuid':shared.uid(TITLE+':default'),'slot_textures':{},'excluded_nodes':[],'is_default':True},'list':[]}
    jsave(D/(TITLE+'.ajblueprint'),aj)
    # Use exactly the same flatten-and-verify Display workflow as the stag.
    previous=shared.D
    try: shared.D=D; display_error=shared.display(b,'空枝_小体型_整体Display调整')
    finally: shared.D=previous
    return display_error


def build():
    recpath=D/'制作记录.json'
    if recpath.exists():
        assert '--revise' in sys.argv,'Preserve saved trial'
        for name,digest in load(recpath)['owned_hashes'].items(): assert sha(D/name)==digest,'Preserve external edit: '+name
    else: assert not any(D.glob('*.bbmodel')),'Preserve existing editable model'
    x=Builder(); geometry(x); error=save_model(x.b)
    jsave(recpath,{'date':'2026-11-24','request':'所有候选密林小怪都采用小体型，先试做一个；沿用朽冠鹿的离线建模交付方式',
        'model':'空枝','selected_by_assistant_from_approved_list':True,'shape_reviewed':False,
        'cubes':len(x.b['elements']),'groups':len(x.b['groups']),'animations':0,'display_error':error,
        'native_reopened':False,'native_attempt':'Computer Use was not approved to use Blockbench; user then requested the stag workflow.',
        'game_tested':False,'live_DP_RP_map_changed':False,
        'owned_hashes':{p.name:sha(p) for p in list(D.glob('*.bbmodel'))+list(D.glob('*.ajblueprint'))}})
    print('Saved',len(x.b['elements']),'Cubes;',len(x.b['groups']),'groups',flush=True)


def render():
    b=load(D/(TITLE+'.bbmodel')); sc=shared.Scene(b); pts=sc.pose()[0]; lo,hi=pts.min(0),pts.max(0)
    font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',26); small=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',18)
    center=(lo+hi)/2
    def shot(direction,size,margin=45):
        d=shared.unit(direction); right=shared.unit(np.cross([0,1,0],d)); up=np.cross(d,right)
        scale=min((size[0]-margin*2)/np.ptp(pts@right),(size[1]-margin*2)/np.ptp(pts@up))
        return sc.render(direction,size=size,center=center,ppu=scale)
    board=Image.new('RGB',(1400,1000),'#20252d'); draw=ImageDraw.Draw(board)
    board.paste(shot((.72,.36,-1),(1400,850),100),(0,65))
    draw.text((30,18),'空枝 · 小体型试做 · 实际保存模型',font=font,fill='#e5dfcb')
    dims=(hi-lo)/16
    draw.text((30,938),f'高 {dims[1]:.2f} 格 · 宽 {dims[0]:.2f} 格 · 深 {dims[2]:.2f} 格 · 原生几何与UV · 非游戏截图',font=small,fill='#bec6b0')
    board.save(D/'空枝_实际模型预览.png')
    views=[((0,.04,-1),'正面'),((1,.04,0),'侧面'),((0,.04,1),'背面'),((0,1,.001),'顶部')]
    board=Image.new('RGB',(1600,1100),'#20252d'); draw=ImageDraw.Draw(board)
    for i,(direction,label) in enumerate(views):
        x,y=i%2*800,i//2*550
        board.paste(shot(direction,(800,480)),(x,y+43)); draw.text((x+20,y+10),label,font=font,fill='#e5dfcb')
    board.save(D/'空枝_正侧背顶.png')
    # Physical scale reference in a single orthographic view, 16 units = 1 block.
    board=Image.new('RGB',(1400,1000),'#20252d'); draw=ImageDraw.Draw(board)
    scale=25.; width=780; height=850; center2=[0,14.4,0]
    board.paste(sc.render((0,0,-1),size=(width,height),center=center2,ppu=scale),(20,60))
    ground=60+height/2+14.4*scale; top=ground-28.8*scale
    draw.line((55,ground,1325,ground),fill='#798173',width=2)
    draw.rectangle((980,top,1100,ground),outline='#b0b7aa',width=3)
    draw.line((940,top,940,ground),fill='#b0b7aa',width=2)
    for units in [0,8,16,24,28.8]:
        yy=ground-units*scale; draw.line((930,yy,950,yy),fill='#b0b7aa',width=2)
    draw.text((1118,top+14),'1.8 格高度参照',font=small,fill='#d6dccb')
    draw.text((30,18),'空枝 · 与玩家站立高度同尺度对照',font=font,fill='#e5dfcb')
    draw.text((30,938),'右侧为1.8格标尺示意；左侧是实际保存模型。标尺不是游戏截图或实际判定箱。',font=small,fill='#bec6b0')
    board.save(D/'空枝_小体型尺度对照.png')
    print('Rendered actual geometry/UV: hero, four views, physical scale.',flush=True)


def export_check(b):
    sc=shared.Scene(b); mats=sc.matrices(); gs={g['name']:g for g in b['groups']}; bygroup=collections.defaultdict(list)
    for e in b['elements']: bygroup[sc.element_bone[e['uuid']]].append(e)
    dest=D/'离线导出核验'; library={}; transforms={}; errors=[]
    texture='fallendream_boss:item/hollow_branch_256'
    for name,es in bygroup.items():
        origin=np.array(gs[name]['origin']); low=np.min([np.array(e['from'])-origin for e in es],axis=0)
        high=np.max([np.array(e['to'])-origin for e in es],axis=0); center=(low+high)/2
        asset={'textures':{'0':texture,'particle':texture},'elements':[]}
        for e in es:
            conv=lambda v: ((np.array(v)-origin-center)+8).tolist()
            element={'from':conv(e['from']),'to':conv(e['to']),'faces':{}}
            assert all(-16<=v<=32 for field in ['from','to'] for v in element[field])
            axes=[i for i,v in enumerate(e['rotation']) if abs(v)>1e-8]
            assert len(axes)<=1 and all(abs(v) in [0,22.5,45] for v in e['rotation'])
            if axes: element['rotation']={'axis':'xyz'[axes[0]],'angle':e['rotation'][axes[0]],'origin':conv(e['origin']),'rescale':False}
            for face,f in e['faces'].items(): element['faces'][face]={'texture':'#0','uv':(np.array(f['uv'])*16/SIZE).tolist()}
            asset['elements'].append(element)
            points=np.array([[element['to'][j] if mask>>j&1 else element['from'][j] for j in range(3)] for mask in range(8)])
            if axes:
                o=np.array(element['rotation']['origin']); points=(points-o)@shared.rotation(e).T+o
            points=(points-8+center)@mats[name][:3,:3].T+mats[name][:3,3]
            expected=sc.corners[e['uuid']]@mats[name][:3,:3].T+mats[name][:3,3]
            errors.append(float(abs(points-expected).max()))
        key=hashlib.sha256(json.dumps(asset,sort_keys=True).encode()).hexdigest()[:16]
        library[key]=asset
        transforms[name]={'model':'fallendream_boss:small_hollow_branch/'+key,'center':center.tolist(),'matrix':mats[name].tolist()}
    for code,asset in library.items():
        jsave(dest/f'assets/fallendream_boss/models/small_hollow_branch/{code}.json',asset)
        jsave(dest/f'assets/fallendream_boss/items/small_hollow_branch/{code}.json',{'model':{'type':'minecraft:model','model':'fallendream_boss:small_hollow_branch/'+code}})
    for old in (dest/'assets/fallendream_boss/models/small_hollow_branch').glob('*.json'):
        if old.stem in library: continue
        assert hashlib.sha256(json.dumps(load(old),sort_keys=True).encode()).hexdigest()[:16]==old.stem,'Preserve edited rehearsal asset'
        item=dest/f'assets/fallendream_boss/items/small_hollow_branch/{old.name}'
        assert load(item)=={'model':{'type':'minecraft:model','model':'fallendream_boss:small_hollow_branch/'+old.stem}}
        old.unlink(); item.unlink()
    write(dest/'assets/fallendream_boss/textures/item/hollow_branch_256.png',base64.b64decode(b['textures'][0]['source'].split(',',1)[1]))
    jsave(dest/'assets/minecraft/atlases/blocks.json',{'sources':[{'type':'minecraft:single','resource':texture,'sprite':texture}]})
    jsave(dest/'分部变换.json',transforms)
    return {'geometry_models':len(library),'geometry_groups':len(bygroup),'maximum_vertex_reconstruction_error':max(errors),
            'legal_Java_elements_and_UVs':True,'texture_and_explicit_atlas_reachable':True,'native_AJ_export':False}


def check():
    b=load(D/(TITLE+'.bbmodel')); aj=load(D/(TITLE+'.ajblueprint')); rec=load(D/'制作记录.json')
    for n,digest in rec['owned_hashes'].items(): assert sha(D/n)==digest
    for key in ['elements','groups','outliner','textures','animations']: assert b[key]==aj[key]
    refs=[]; groups=[]
    def walk(nodes):
        for node in nodes:
            if isinstance(node,str): refs.append(node)
            else: groups.append(node['uuid']); walk(node['children'])
    walk(b['outliner'])
    assert collections.Counter(refs)==collections.Counter(e['uuid'] for e in b['elements'])
    assert collections.Counter(groups)==collections.Counter(g['uuid'] for g in b['groups'])
    for e in b['elements']:
        assert all(z>q for q,z in zip(e['from'],e['to']))
        for f in e['faces'].values(): assert f['texture']==b['textures'][0]['uuid'] and all(0<=v<=SIZE for v in f['uv'])
    assert (D/b['textures'][0]['relative_path']).read_bytes()==base64.b64decode(b['textures'][0]['source'].split(',',1)[1])
    sc=shared.Scene(b); pts=sc.pose()[0]; lo,hi=pts.min(0),pts.max(0); dims=(hi-lo)/16
    assert hi[1]/16<1.0 and lo[1]>=-.001
    volumes=volume_connectivity(b); coplanar=coplanar_probe(b); exports=export_check(b)
    result={'passed':volumes['connected_components']==1 and not coplanar['exposed_centroid_candidates'] and exports['maximum_vertex_reconstruction_error']<1e-8,
        'cubes':len(b['elements']),'groups':len(b['groups']),'animations':0,'texture_size':[SIZE,SIZE],
        'world_bounds_units':[lo.tolist(),hi.tolist()],'size_blocks_xyz':dims.tolist(),'standing_player_height_reference_blocks':1.8,
        'actual_hollow_tube':True,'BB_AJ_UVs_texture_hierarchy_checked':True,'volume_connectivity':volumes,
        'limited_coplanar_probe':coplanar,'offline_export':exports,'display_reconstruction_error':rec['display_error'],
        'native_reopened':False,'game_tested':False,'FPS_tested':False,'runtime_hitbox_or_combat_changed':False}
    jsave(D/'静态模型核验.json',result)
    print(json.dumps({k:result[k] for k in ['passed','cubes','groups','size_blocks_xyz','display_reconstruction_error']},ensure_ascii=False),flush=True)
    assert result['passed'],'Inspect saved contact/coplanar report'


def package():
    result=load(D/'静态模型核验.json'); assert result['passed']
    rec=load(D/'制作记录.json')
    for n,digest in rec['owned_hashes'].items(): assert sha(D/n)==digest
    files=[p for p in D.rglob('*') if p.is_file()]+[P/'阶段状态.md']
    archive=P/'空枝_小体型静态试做工程_20261124.zip'; assert not archive.exists()
    with zipfile.ZipFile(archive,'x',zipfile.ZIP_DEFLATED,compresslevel=7) as z:
        for p in files: z.write(p,p.relative_to(P).as_posix())
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
        for p in files: assert hashlib.sha256(z.read(p.relative_to(P).as_posix())).hexdigest()==sha(p)
    jsave(P/'交付封装.json',{'archive':str(archive),'bytes':archive.stat().st_size,'sha256':sha(archive),
                          'files':len(files),'CRC_and_all_file_hashes_verified':True})
    print('Packaged',str(archive),archive.stat().st_size,'bytes',flush=True)


if __name__=='__main__': globals()[sys.argv[1]]()
