"""Verify the installed assets and exercise the real palette visual commands."""
from pathlib import Path
import json,copy,re,hashlib,math,base64,io
from collections import Counter
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import renderer
from sync_palette_bright_display import rotation

B=Path(__file__).resolve().parents[1];RP=B/'sweetdream_rp_完整版';DP=B/'sweetdream/data/sweetdream'
F=DP/'function/equipment/staff/palette';A=RP/'assets/palette';M=A/'models/item'
O=B/'模型设计/调色盘_明亮木盘_20261009/阶段二_提色施法'
BACK=B/'.workbuddy/backup/palette-bright-source-20261009'
read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
plan=read(B/'.workbuddy/palette_bright_binding.json');table=read(B/'.workbuddy/palette_bright_pose_table.json')
def code(p):return [s.strip() for s in p.read_text(encoding='utf-8-sig').splitlines() if s.strip() and not s.lstrip().startswith('#')]
def path(ref,kind='models',ext='.json'):
    ns,name=ref.split(':',1);return RP/'assets'/ns/kind/(name+ext)
cache={}
def resolve(ref,trail=()):
    if ref in cache:return cache[ref]
    assert ref not in trail
    d=read(path(ref));p=resolve(d['parent'],trail+(ref,)) if 'parent' in d else {}
    q={**p,**d,'textures':{**p.get('textures',{}),**d.get('textures',{})}}
    cache[ref]=q;return q
def choose(d,v,context):
    t=d['type']
    if t=='minecraft:empty':return []
    if t=='minecraft:model':return [d['model']]
    if t=='minecraft:composite':return [r for m in d['models'] for r in choose(m,v,context)]
    if t=='minecraft:select':return choose(next((c['model'] for c in d['cases'] if context in c['when']),d['fallback']),v,context)
    assert t=='minecraft:range_dispatch',t
    value=v[d.get('index',0)] if len(v)>d.get('index',0) else 0
    selected=d['fallback']
    for e in d['entries']:
        if value>=e['threshold']:selected=e['model']
    return choose(selected,v,context)
item=read(A/'items/palette.json');assert item['hand_animation_on_swap'] is False
whole=read(M/'palette.json');assert whole['display']==read(BACK/'sweetdream_rp_完整版/assets/palette/models/item/palette.json')['display']
for rel in plan['source_rp_files']:
    p=RP/rel
    if p.suffix!='.json':continue
    d=read(p)
    if 'parent' in d:assert path(d['parent']).is_file()
    for tex in d.get('textures',{}).values():
        if not tex.startswith('#'):assert path(tex,'textures','.png').is_file(),tex
    for e in d.get('elements',[]):
        assert all(-16<=v<=32 for v in e['from']+e['to'])
        assert all(a<b for a,b in zip(e['from'],e['to']))
        assert e.get('rotation',{}).get('angle',0) in [-45,-22.5,0,22.5,45]
        for face in e['faces'].values():assert len(face['uv'])==4 and all(0<=v<=16 for v in face['uv'])
for rel,digest in plan['immutable_files'].items():assert hashlib.sha256((B/rel).read_bytes()).hexdigest()==digest,rel

tested=0;peak=0
for frame,cnt in plan['state_counts'].items():
    for c1 in range(4):
        for c2 in range(4):
            for c3 in range(4):
                for context in ['firstperson_righthand','firstperson_lefthand','thirdperson_righthand','gui','ground']:
                    vals=[int(frame),c1,c2,c3,int(not c1 and not c2)]
                    refs=choose(item['model'],vals,context);models=[resolve(ref) for ref in refs]
                    actual=sum(len(d['elements']) for d in models)
                    target=cnt if context.startswith(('firstperson','thirdperson')) else plan['state_counts']['0']
                    expected=target['base']+target['fx']+target['orb1']+target['orb2']+sum(target[f'slot{i+1}'] for i,c in enumerate([c1,c2,c3]) if c)+(target['neutral'] if not c1 and not c2 else 0)
                    assert actual==expected,(frame,vals,context,actual,expected)
                    for d in models:
                        for e in d['elements']:
                            for face in e['faces'].values():assert face['texture'][1:] in d['textures']
                    if not c3:peak=max(peak,actual)
                    tested+=1
assert len(whole['elements'])==663
assert len(choose(item['model'],[999,0,0,0,1],'firstperson_righthand'))==1
# Pigment and the hand-model ball must both use the approved RGB tiles.
for color,box in [('red',(0,16,16,32)),('yellow',(16,16,32,32)),('blue',(32,16,48,32))]:
    orb=np.array(Image.open(A/f'textures/item/bright/{color}_orb.png'))
    current=np.array(Image.open(A/'textures/item/t0.png').crop(box))
    assert np.array_equal(orb,current),color

# Gameplay changed only by the visual hand-off hook and a 22-tick gather gate.
old=code(BACK/'sweetdream/data/sweetdream/function/equipment/staff/palette/skill.mcfunction')
new=[s for s in code(F/'skill.mcfunction') if not s.endswith('/visual/color_prepare')]
assert old==new
old=code(BACK/'sweetdream/data/sweetdream/function/equipment/staff/palette/color_tick.mcfunction')
new=[s.replace(' unless score @s zx.pv_wait matches 1..','') for s in code(F/'color_tick.mcfunction') if not s.endswith('/visual/color_wait')]
assert old==new
assert code(F/'visual/color_prepare.mcfunction')==['scoreboard players set @s zx.pv_wait 22','data modify entity @s transformation.scale set value [0.0f,0.0f,0.0f]']
assert code(F/'visual/color_launch.mcfunction')==['data modify entity @s transformation.scale set value [0.70f,0.70f,0.70f]']
assert '/color_body with storage zx:work pc' in '\n'.join(new)

# Read and interpret the real held/begin/apply/modifier commands. This is a small
# deterministic driver test, not a simulation of Minecraft's damage engine.
G={};STORE={};modifier=read(DP/'item_modifier/palette_visual.json')
for s in code(F/'visual/load.mcfunction'):
    m=re.fullmatch(r'scoreboard players set (#\w+) (\S+) (-?\d+)',s)
    if m:G[(m[1],m[2])]=int(m[3])
def player(c1=0,c2=0,off=False):
    item={'floats':[0.,0.,0.,0.,1.,777.],'model':'palette:palette','extra':{'damage':12}}
    return {'scores':{'zx.pal_c1':c1,'zx.pal_c2':c2},'hands':{'mainhand':None if off else copy.deepcopy(item),'offhand':copy.deepcopy(item) if off else None}}
def score(p,who,obj):return p['scores'].get(obj) if who=='@s' else G.get((who,obj))
def put(p,who,obj,v):
    if who=='@s':p['scores'][obj]=v
    else:G[(who,obj)]=v
def matches(v,r):
    if v is None:return False
    if '..' not in r:return v==int(r)
    a,b=r.split('..');return (not a or v>=int(a)) and (not b or v<=int(b))
def function(p,name,args=None):
    for s in code(F/'visual'/(name+'.mcfunction')):
        if s.startswith('$'):
            assert args is not None;s=s[1:]
            for k,v in args.items():s=s.replace('$('+k+')',str(v))
            assert '$(' not in s
        execute(p,s)
def execute(p,s):
    if s.startswith('execute store result storage '):
        m=re.fullmatch(r'execute store result storage zx:work palette_visual\.(\w+) int 1 run scoreboard players get (#\w+) (\S+)',s);assert m,s
        STORE[m[1]]=score(p,m[2],m[3]);return
    if s.startswith('execute '):
        head,tail=s[8:].split(' run ',1)
        while head:
            m=re.match(r'(if|unless) score (@s|#\w+) (\S+) matches (\S+)(?: |$)',head)
            if m:ok=matches(score(p,m[2],m[3]),m[4])
            else:
                m=re.match(r'(if|unless) items entity @s weapon\.(mainhand|offhand) (\S+)(?: |$)',head);assert m,head
                hand=p['hands'][m[2]];ok=hand is not None
                if 'minecraft:item_model=' in m[3] and hand:
                    vals=[float(x.rstrip('f')) for x in re.search(r'floats:\[([^]]+)\]',m[3])[1].split(',')]
                    # NBT list matching without '~' is exact, including length.
                    ok=hand['model']=='palette:palette' and hand['floats']==vals
            if ok!=(m[1]=='if'):return
            head=head[m.end():].strip()
        execute(p,tail);return
    if s.startswith('scoreboard players '):
        parts=s.split();op,who,obj=parts[2:5]
        if op=='operation':
            v=score(p,parts[6],parts[7]);assert v is not None
            if parts[5]=='/=':v=int(score(p,who,obj)/v)
            else:assert parts[5]=='='
        else:v=int(parts[5]) if op=='set' else (score(p,who,obj) or 0)+int(parts[5])
        put(p,who,obj,v);return
    if s.startswith('data modify storage '):STORE.update(frame=0,c1=0,c2=0,empty=0);return
    if s.startswith('function '):
        name=s.split()[1].rsplit('/',1)[-1];function(p,name,STORE if ' with ' in s else None);return
    if s.startswith('item modify '):
        hand=p['hands'][s.split()[4].split('.')[1]]
        hand['model']=modifier[0]['components']['minecraft:item_model'];d=modifier[1]['floats']
        vals=[float(G[(v['target']['name'],v['score'])]) if isinstance(v,dict) else float(v) for v in d['values']]
        assert d['mode']=='replace_section';hand['floats'][d['offset']:d['offset']+d['size']]=vals;return
    raise AssertionError(s)
def tick(p):
    age=p['scores'].get('zx.pv_age')
    if matches(age,'0..31'):p['scores']['zx.pv_age']=age+1
    if any(p['hands'].values()):function(p,'held')
for c1 in range(4):
    for c2 in range(4):
        for off in [False,True]:
            p=player(c1,c2,off);function(p,'begin');p['scores']['zx.pal_c1']=p['scores']['zx.pal_c2']=0
            hand=p['hands']['offhand' if off else 'mainhand'];frames=[hand['floats'][0]]
            for t in range(1,33):tick(p);frames.append(hand['floats'][0])
            assert frames[:32]==list(map(float,range(100,132)))
            assert frames[32] in range(20) and hand['floats'][1:5]==[0.,0.,0.,1.]
            assert hand['floats'][5]==777 and hand['extra']=={'damage':12}
a,b=player(1,3),player(2,2,True);function(a,'begin');function(b,'begin')
for p in [a,b]:p['scores']['zx.pal_c1']=p['scores']['zx.pal_c2']=0
for _ in range(12):tick(a);tick(b)
assert a['hands']['mainhand']['floats'][1:3]==[1.,3.]
assert b['hands']['offhand']['floats'][1:3]==[2.,2.]
p=player(1,2);p['hands']['offhand']=copy.deepcopy(p['hands']['mainhand']);tick(p)
assert p['scores']['zx.pv_idle']==1 and p['hands']['mainhand']['floats']==p['hands']['offhand']['floats']
saved=p['hands']['mainhand'];function(p,'begin');p['scores']['zx.pal_c1']=p['scores']['zx.pal_c2']=0
p['hands']={'mainhand':None,'offhand':None}
for _ in range(40):tick(p)
p['hands']['offhand']=saved;tick(p);assert saved['floats'][0]<20 and saved['floats'][1:5]==[0.,0.,0.,1.]

# Check the one pending entity cannot move/hit before release. Its counter is
# independent from hands and other players; its owner lookup is still original.
wait=code(F/'visual/color_wait.mcfunction')
assert wait[0].startswith('execute unless entity @a[tag=zx.mc_by,distance=0..,limit=1] run return run function')
assert wait[1]=='execute at @a[tag=zx.mc_by,distance=0..,limit=1] anchored eyes positioned ^ ^ ^1.5 run tp @s ~ ~ ~ ~ ~'
assert wait[2]=='scoreboard players remove @s zx.pv_wait 1'
assert wait[3]=='execute if score @s zx.pv_wait matches 0 run function sweetdream:equipment/staff/palette/visual/color_launch'
remaining=22;active=[]
for t in range(1,25):
    if remaining>0:remaining-=1
    active.append(t if remaining==0 else None)
assert active[:21]==[None]*21 and active[21]==22

# Render from actual referenced model JSON + PNG. Recover the baked native
# rigid pose from display relative to the user pose; no preview VFX is added.
native=renderer(O/'调色盘_明亮木盘_提色施法_分组动画.bbmodel');texture_ids={};images=[]
context='firstperson_righthand';base=whole['display'][context];baseR=rotation(base['rotation']);baseS=np.array(base['scale']);baseT=np.array(base['translation'])
def actualscene(vals):
    result=[]
    for ref in choose(item['model'],vals,context):
        d=resolve(ref);pd=d['display'][context];R=baseR.T@rotation(pd['rotation']);shift=(baseR.T@(np.array(pd['translation'])-baseT))/baseS
        name=ref.split(':',1)[1]+'.json';expected=table['parts'][name]
        assert np.max(np.abs(R-np.array(expected['matrix'])))<3e-8
        assert np.max(np.abs(shift-np.array(expected['shift'])))<2e-6
        for e in d['elements']:
            lo=np.array(e['from'])-8;hi=np.array(e['to'])-8
            vertices=np.array([[lo[0] if not j&1 else hi[0],lo[1] if not j&2 else hi[1],lo[2] if not j&4 else hi[2]] for j in range(8)])
            er=np.eye(3)
            if 'rotation' in e:
                r=e['rotation'];er=native['R']('xyz'.index(r['axis']),r['angle']);p=np.array(r['origin'])-8;vertices=(vertices-p)@er.T+p
            q={'faces':{},'light_emission':e.get('light_emission',0)}
            for side,f in e['faces'].items():
                tex=d['textures'][f['texture'][1:]]
                if tex not in texture_ids:
                    texture_ids[tex]=len(images);images.append(np.array(Image.open(path(tex,'textures','.png')).convert('RGBA')))
                ti=texture_ids[tex];height,width=images[ti].shape[:2]
                q['faces'][side]={'texture':ti,'uv':[x*(width if i%2==0 else height)/16 for i,x in enumerate(f['uv'])]}
            result.append((q,vertices@R.T+shift,R@er))
    return result
board=Image.new('RGB',(1600,800),native['BG']);draw=ImageDraw.Draw(board)
draw.text((24,18),'调色盘 · 已接入产物回渲',font=native['font'],fill='#ead4a9')
draw.text((24,65),'读取实际游戏 JSON 与 PNG：黄蓝提色 → 单球飞出 → 空盘收势',font=native['small'],fill='#aaa293')
for j,(frame,label) in enumerate([(0,'明亮木盘 · 黄 + 蓝'),(109,'提色与湿颜料流'),(115,'单枚小球准备飞出'),(128,'空盘收势')]):
    vals=[frame,2,3,0,0];scene=actualscene(vals);native['scene']=lambda t=0,anim=0,s=scene:s;native['textures']=images
    board.paste(native['render']((400,650),yaw=math.pi+.17,pitch=.34,scale=16.5,focus=(0,0,-1)),(j*400,115));ImageDraw.Draw(board).text((j*400+20,108),label,font=native['small'],fill='#ddc49a')
board.save(O/'游戏产物回渲.png')
size=sum((RP/r).stat().st_size for r in plan['source_rp_files'])
result={'color_frame_context_combinations':tested,'hand_cubes_peak_two_slots':peak,'whole_model_cubes':663,'user_display_preserved':True,
        'single_entity_released_tick':22,'cast_frames_0_to_31_delivered':True,'empty_recovery_correct':True,'two_hands_switch_multiplayer_checked':True,
        'projectile_shape_scale_gameplay_preserved':True,'third_slot_reserved':True,'trailing_item_components_preserved':True,'all_references_legal':True,
        'native_local_vertex_max_error':plan['local_vertex_max_error'],'installed_pose_matrix_max_tolerance':3e-8,
        'installed_resources_bytes':size,'game_tested':False}
(B/'.workbuddy/palette_bright_verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False),flush=True)
