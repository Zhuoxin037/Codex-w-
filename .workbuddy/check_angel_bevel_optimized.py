"""Read-only checks of native vertices, gameplay hashes, and actual RP output."""
from pathlib import Path
import json,math,itertools,hashlib,uuid,base64,io
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import renderer
B=Path(__file__).resolve().parents[1];load=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
M=load(B/'.workbuddy/angel_bevel_optimized_binding.json');O=Path(M['review']);RP=B/'sweetdream_rp';A=RP/'assets/angelcore'
bb=load(O/M['native_name']);approved=load(O.parent/'阶段二_斜面与金边贴合/天使核心_斜面贴合金边_分组动画.bbmodel')
assert len(bb['elements'])==990 and len(bb['groups'])==26
assert bb['animations']==approved['animations']
master=load(A/'models/item/axe.json');body=load(A/'models/item/parts/body.json')
assert master['display']==load(B/'.workbuddy/backup/angel-bevel-optimized-source-20261009/sweetdream_rp/assets/angelcore/models/item/axe.json')['display']
assert all(hashlib.sha256((B/p).read_bytes()).hexdigest()==sha for p,sha in M['immutable_datapack'].items())
def resolve(ref,kind,suffix):
    ns,name=ref.split(':',1);return RP/'assets'/ns/kind/(name+suffix)
for rel in M['source_rp_files']:
    p=RP/rel
    if p.suffix!='.json':continue
    d=load(p)
    if 'parent' in d:assert d['parent']=='angelcore:item/axe' and 'display' not in d
    for ref in d.get('textures',{}).values():assert resolve(ref,'textures','.png').is_file()
    for e in d.get('elements',[]):
        assert all(-16<=v<=32 for v in e['from']+e['to'])
        assert all(a<b for a,b in zip(e['from'],e['to']))
        assert e.get('rotation',{}).get('angle',0) in [-45,-22.5,0,22.5,45]
        for f in e['faces'].values():
            assert f.get('rotation',0) in [0,90,180,270]
            assert len(f['uv'])==4 and all(0<=v<=16 for v in f['uv'])
def turn(p,origin,axis,angle):
    i,j={'x':(1,2),'y':(2,0),'z':(0,1)}[axis];a=math.radians(angle);c,s=math.cos(a),math.sin(a)
    r=[p[k]-origin[k] for k in range(3)];r[i],r[j]=c*r[i]-s*r[j],s*r[i]+c*r[j];return [r[k]+origin[k] for k in range(3)]
max_error=0
assert len(master['elements'])==990
for e,q in zip(bb['elements'],master['elements']):
    native=list(itertools.product(*zip(e['from'],e['to'])));axis=[(axis,v) for axis,v in zip('xyz',e.get('rotation',[0]*3)) if v]
    if axis:native=[turn(p,e['origin'],*axis[0]) for p in native]
    java=list(itertools.product(*zip(q['from'],q['to'])))
    if 'rotation' in q:
        z=q['rotation'];java=[turn(p,z['origin'],z['axis'],z['angle']) for p in java]
    java=[[p[0]-8,p[1],p[2]-8] for p in java]
    for p in native:
        error=min(math.dist(p,z) for z in java);max_error=max(max_error,error);assert error<3e-6,e['name']
frames=[load(A/f'models/item/frames/idle_{j:02d}.json') for j in range(32)]
maximum=max(len(body['elements'])+len(f['elements']) for f in frames);assert maximum==990
assert len({json.dumps(f['elements']) for f in frames})>20
for name in ['stigma_flow','stigma_core']:
    a=load(A/f'textures/item/{name}.png.mcmeta')['animation'];assert a['frametime']*len(a['frames'])/20==3.2
nr=renderer(O/M['native_name']);before=renderer(O.parent/'阶段二_斜面与金边贴合/天使核心_斜面贴合金边_分组动画.bbmodel')
metrics=[]
for yaw in [.29,math.pi+.29,1.03]:
    args=dict(yaw=yaw,pitch=.06,scale=32,focus=(-1.9,17,0))
    old=np.array(before['render']((720,1030),**args)).astype(float);new=np.array(nr['render']((720,1030),**args)).astype(float)
    bg=old[0,0];a=np.any(old!=bg,2);b=np.any(new!=bg,2);u=a|b
    metrics.append({'yaw':round(yaw,4),'silhouette_iou':round(float(np.sum(a&b)/np.sum(u)),6),'mean_rgb_difference_on_object':round(float(np.abs(old-new)[u].mean()),4)})
assert min(m['silhouette_iou'] for m in metrics)>.98,metrics

# Render the actual installed JSON and frame-zero texture crops. Animated strips
# use their .mcmeta tile size, rather than projecting the entire sprite sheet.
textures=[]
for i in range(len(bb['textures'])):
    ref=master['textures'][str(i)];p=resolve(ref,'textures','.png');im=Image.open(p).convert('RGBA');mp=Path(str(p)+'.mcmeta')
    if mp.exists():
        a=load(mp)['animation'];w=a.get('width',im.width);h=a.get('height',w);im=im.crop((0,0,w,h))
    buf=io.BytesIO();im.save(buf,format='PNG')
    textures.append({'uuid':str(uuid.uuid4()),'name':p.name,'width':im.width,'height':im.height,'uv_width':im.width,'uv_height':im.height,'source':'data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()})
board=Image.new('RGB',(1440,1080),nr['BG']);scratch=B/'.workbuddy/texlab_out/angel_refined';scratch.mkdir(parents=True,exist_ok=True)
for j,(frame,yaw,label) in enumerate([(0,.29,'正面'),(0,math.pi+.29,'背面'),(0,1.03,'斜面与包边'),(16,.29,'原循环动画 · 中间帧')]):
    els=[];gid=str(uuid.uuid4())
    for k,e in enumerate(body['elements']+frames[frame]['elements']):
        rot=e.get('rotation',{});angle=[0,0,0]
        if rot:angle['xyz'.index(rot['axis'])]=rot['angle']
        lo=[e['from'][0]-8,e['from'][1],e['from'][2]-8];hi=[e['to'][0]-8,e['to'][1],e['to'][2]-8]
        origin=[rot['origin'][0]-8,rot['origin'][1],rot['origin'][2]-8] if rot else [(a+b)/2 for a,b in zip(lo,hi)]
        faces={}
        for f,p in e['faces'].items():
            ti=int(p['texture'][1:]);t=textures[ti];faces[f]={'texture':ti,'uv':[v*(t['width'] if k%2==0 else t['height'])/16 for k,v in enumerate(p['uv'])],'rotation':p.get('rotation',0)}
        els.append({'name':'actual_'+str(k),'type':'cube','uuid':str(uuid.uuid4()),'from':lo,'to':hi,'origin':origin,'rotation':angle,'faces':faces,'light_emission':e.get('light_emission',0)})
    test={'meta':{'format_version':'5.0','model_format':'free','bone_rig':True},'elements':els,'groups':[{'uuid':gid,'name':'实际游戏资源','origin':[0,0,0],'rotation':[0,0,0]}],'outliner':[{'uuid':gid,'children':[e['uuid'] for e in els]}],'textures':textures,'animations':[]}
    p=scratch/'实际产物.bbmodel';p.write_text(json.dumps(test,ensure_ascii=False),encoding='utf-8');actual=renderer(p)
    board.paste(actual['render']((360,950),yaw=yaw,pitch=.03,scale=18.3,focus=(-1.9,8.3,0)),(j*360,90));ImageDraw.Draw(board).text((j*360+18,61),label,font=nr['small'],fill='#d5c4a2')
ImageDraw.Draw(board).text((23,17),'天使核心 · 游戏资源实际产物回渲',font=nr['font'],fill='#e7d7b6')
ImageDraw.Draw(board).text((23,1040),'读取资源包 JSON / PNG；990 元素，26 分组；无额外泛光 · 游戏帧率仍需实测',font=nr['small'],fill='#afa591')
board.save(O/'游戏产物回渲.png')
result={'native_cubes':990,'fixed_cubes_shared':len(body['elements']),'maximum_game_frame_cubes':maximum,'animations_unchanged':True,
        'native_groups':26,'frames_checked':32,'resource_files_checked':len(M['source_rp_files']),
        'maximum_native_java_vertex_error':max_error,'visual_comparison':metrics,'datapack_byte_identical':True,'display_preserved':True,'game_tested':False}
(B/'.workbuddy/angel_bevel_optimized_verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False),flush=True)
