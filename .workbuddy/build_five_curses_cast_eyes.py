"""Split the current hand-edited saved skull into empty-eye idle and cast-only light states."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,copy,uuid,base64,io,hashlib,subprocess,sys,math
ROOT=Path('D:/数据包/模型设计/五世恶咒_建模_20261015')
S=ROOT/'阶段五_常态空眼与施法咒光';SOURCE=S/'过程记录/用户当前手改_634.bbmodel'
NATIVE=S/'五世恶咒_施法咒光_分组可编辑动画.bbmodel';IDLE=S/'五世恶咒_常态空眼_分组模型.bbmodel'
if NATIVE.exists() or IDLE.exists():raise SystemExit('Existing saved state projects preserved; edit them instead of rebuilding.')
d=json.loads(SOURCE.read_text(encoding='utf-8-sig'));assert len(d['elements'])==634
eyes=[e for e in d['elements'] if e['name'].startswith(('柔光内嵌座_','无瞳柔紫咒光_'))];assert len(eyes)==12
eyeids={e['uuid'] for e in eyes};body=[e for e in d['elements'] if e['uuid'] not in eyeids];assert len(body)==622
eye_group=next(g['uuid'] for g in d['groups'] if g['name']=='13_世咒刻纹与魂炭')
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:five_curses:cast_eyes:'+s))
def prune(nodes,ids,remove_group=False):
    out=[]
    for n in nodes:
        if isinstance(n,str):
            if n not in ids:out.append(n)
        elif not (remove_group and n['uuid']==eye_group):
            n=copy.deepcopy(n);n['children']=prune(n.get('children',[]),ids,remove_group);out.append(n)
    return out
def walk(nodes):
    for n in nodes:
        if isinstance(n,dict):
            yield n;yield from walk(n.get('children',[]))
im=Image.open(io.BytesIO(base64.b64decode(d['textures'][1]['source'].split(',',1)[1]))).convert('RGBA');original=im.copy()
# Three pigment levels, occupying unused atlas space. They switch at fixed size, never grow eyeballs.
levels=[('微光',.38,0),('柔光',.78,40),('亮起',1.30,80)]
for label,factor,tx in levels:
    for y in range(32):
        for x in range(32):
            c=original.getpixel((132+x,132+y));im.putpixel((tx+x,196+y),tuple(min(255,round(v*factor)) for v in c[:3])+(c[3],))
    # Matching dark seats use separate swatches, so the whole eye assembly fades together.
    c=original.getpixel((140,12));tint=tuple(min(255,round(v*factor)) for v in c[:3])+(255,)
    ImageDraw.Draw(im).rectangle((tx,232,tx+31,255),fill=tint)
buf=io.BytesIO();im.save(buf,format='PNG');d['textures'][1]['source']='data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()
d['textures'][1]['name']='five_curses_cast_eyes.png'
def remap(e,tx):
    e=copy.deepcopy(e)
    for f,ff in e['faces'].items():
        if e['name'].startswith('无瞳') and f=='north':
            u,v,u2,v2=ff['uv'];ff['uv']=[tx+(u-132),196+(v-132),tx+(u2-132),196+(v2-132)]
        else:ff['uv']=[tx+2,234,tx+29,253]
    return e
def static(phase=None):
    q=copy.deepcopy(d);q['elements']=copy.deepcopy(body)
    q['outliner']=prune(q['outliner'],eyeids,phase is None)
    q['animations']=[]
    if phase is None:q['groups']=[g for g in q['groups'] if g['uuid']!=eye_group]
    else:
        es=[remap(e,levels[phase][2]) for e in eyes];q['elements'].extend(es)
        n=next(n for n in walk(q['outliner']) if n['uuid']==eye_group);n['children']=[e['uuid'] for e in es]
    return q
idle=static();idle['name']='五世恶咒_常态空眼';idle['save_path']=str(IDLE)
IDLE.write_text(json.dumps(idle,ensure_ascii=False,separators=(',',':')),encoding='utf8')
states=[static(i) for i in range(3)]
castdir=S/'施法亮眼';castdir.mkdir(exist_ok=True)
castpath=castdir/'五世恶咒_施法亮眼_分组模型.bbmodel';peak=states[2];peak['name']='五世恶咒_施法亮眼';peak['save_path']=str(castpath)
castpath.write_text(json.dumps(peak,ensure_ascii=False,separators=(',',':')),encoding='utf8')
anim=copy.deepcopy(d);anim['elements']=copy.deepcopy(body);anim['outliner']=prune(anim['outliner'],eyeids)
parent=next(n for n in walk(anim['outliner']) if n['uuid']==eye_group)
phaseids=[]
for i,(label,_,tx) in enumerate(levels):
    gu=uid('phase:'+label);phaseids.append(gu)
    anim['groups'].append({'name':'施法眼光_'+label,'uuid':gu,'origin':[8,14.45,6.7],'rotation':[0,0,0],'export':True,'visibility':True,'isOpen':False})
    new=[]
    for e in eyes:
        e=remap(e,tx);e['uuid']=uid(e['uuid']+':'+label);e['name']=label+'_'+e['name'];anim['elements'].append(e);new.append(e['uuid'])
    parent['children'].append({'uuid':gu,'isOpen':False,'children':new})
timeline=[(0,None),(.05,0),(.10,1),(.15,2),(.35,2),(.40,1),(.50,0),(.60,None),(.65,None)]
def animation(name,length,loop,events,selected):
    a={'uuid':uid(name),'name':name,'loop':loop,'override':False,'length':length,'snapping':20,'selected':selected,'animators':{}}
    for phase,gu in enumerate(phaseids):
        keys=[]
        for t,active in events:
            value='1' if active==phase else '0'
            keys.append({'channel':'scale','data_points':[{'x':value,'y':value,'z':value}],'uuid':uid(name+gu+str(t)),'time':t,'color':-1,'interpolation':'step'})
        a['animators'][gu]={'name':'施法眼光_'+levels[phase][0],'type':'bone','rotation_global':False,'keyframes':keys}
    return a
anim['animations']=[animation('01_常态_空眼窝',1.0,'loop',[(0,None),(1.0,None)],True),animation('02_技能_咒光亮起熄灭',.65,'once',timeline,False)]
anim['name']='五世恶咒_施法咒光';anim['save_path']=str(NATIVE)
NATIVE.write_text(json.dumps(anim,ensure_ascii=False,separators=(',',':')),encoding='utf8')
sourcebody={e['uuid']:e for e in body}
for q in [idle,*states,anim]:
    now={e['uuid']:e for e in q['elements']};assert all(now[u]==e for u,e in sourcebody.items())
assert all(not e['name'].startswith('咒光短侧托_') for e in anim['elements'])
assert d['textures'][0]['source']==idle['textures'][0]['source']==anim['textures'][0]['source']
audit={'source':str(SOURCE),'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'source_current_hand_edited_elements':634,
 'idle_visible_elements':622,'cast_peak_visible_elements':634,'animation_editing_elements':658,'animation_groups':len(anim['groups']),
 'animations':2,'eye_elements_per_visible_level':12,'eye_brightness_levels':3,'max_visible_levels':1,
 'all_622_non_eye_elements_identical_to_live_snapshot':True,'removed_user_eye_supports_restored':False,
 'bone_texture_byte_identical':True,'timeline_seconds':timeline,'geometry_scale_during_visibility':[0,1],
 'note':'Scale uses step-only zero/one visibility selection, not growing eyes. Brightness changes via three UV pigment levels. No gameplay code or live pack changed.'}
(S/'时序与主体保护核验.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(audit,ensure_ascii=False),flush=True)
helper=Path('D:/数据包/.workbuddy/finalize_monkey_skull_review.py')
subprocess.run([sys.executable,str(helper),'--stage',str(S),'--native',IDLE.name,'--model-id','five_curses_visual','--prefix','五世恶咒'],check=True)
subprocess.run([sys.executable,str(helper),'--stage',str(castdir),'--native',castpath.name,'--model-id','five_curses_visual','--prefix','五世恶咒_施法亮眼'],check=True)
# State export reuses one skull model, rather than duplicating all 622 static cubes per light level.
rp=S/'状态导出';models=rp/'assets/sweetdream/models/item';items=rp/'assets/sweetdream/items';textures=rp/'assets/sweetdream/textures/item'
for p in (models,items,textures):p.mkdir(parents=True,exist_ok=True)
full_idle=json.loads((S/'审阅资源/assets/sweetdream/models/item/five_curses_visual.json').read_text(encoding='utf8'))
full_peak=json.loads((castdir/'审阅资源/assets/sweetdream/models/item/five_curses_visual.json').read_text(encoding='utf8'))
for t in d['textures']:(textures/t['name']).write_bytes(base64.b64decode(t['source'].split(',',1)[1]))
(models/'five_curses_skull_static.json').write_text(json.dumps(full_idle,separators=(',',':')),encoding='utf8')
(items/'five_curses_idle.json').write_text(json.dumps({'model':{'type':'minecraft:model','model':'sweetdream:item/five_curses_skull_static'}}),encoding='utf8')
for i,(label,_,_) in enumerate(levels):
    overlay=copy.deepcopy(full_peak);overlay['elements']=[]
    for e in states[i]['elements'][len(body):]:
        overlay['elements'].append({'from':e['from'],'to':e['to'],'faces':{f:{'uv':[v/16 for v in ff['uv']],'texture':'#1'} for f,ff in e['faces'].items()}})
    mid=('dim','soft','peak')[i];(models/f'five_curses_eye_{mid}.json').write_text(json.dumps(overlay,separators=(',',':')),encoding='utf8')
    entry={'model':{'type':'minecraft:composite','models':[{'type':'minecraft:model','model':'sweetdream:item/five_curses_skull_static'},{'type':'minecraft:model','model':f'sweetdream:item/five_curses_eye_{mid}'}]}}
    (items/f'five_curses_cast_{mid}.json').write_text(json.dumps(entry,separators=(',',':')),encoding='utf8')
(rp/'pack.mcmeta').write_text(json.dumps({'pack':{'pack_format':55,'description':'五世恶咒：空眼常态与施法眼光状态审阅，未接入'}}),encoding='utf8')
# Actual pose renders use these exact exported models, textures and native step keyframes.
sys.path.insert(0,'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts');import render3d as V
def nearest(self,u,v):return self._px(max(0,min(self.w-1,int(u*self.w/16))),max(0,min(self.h-1,int(v*self.h/16))))
V.Tex.sample=nearest;repo=V.Repo(str(rp));basefaces=V.bake(full_idle,repo,ns_hint='sweetdream');rendered={}
for phase in [None,0,1,2]:
    faces=basefaces[:]
    if phase is not None:
        mid=('dim','soft','peak')[phase];m=json.loads((models/f'five_curses_eye_{mid}.json').read_text(encoding='utf8'));faces+=V.bake(m,repo,ns_hint='sweetdream')
    rows,_=V.render([(faces,1.0)],640,570,yaw=180,pitch=0,bg=(224,222,215),ambient=.66,pad=.90)
    rendered[phase]=Image.open(io.BytesIO(V.encode_png(640,570,rows))).convert('RGB')
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',24);title=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',28)
sheet=Image.new('RGB',(1280,635),(240,238,232));dr=ImageDraw.Draw(sheet)
dr.text((22,12),'五世恶咒 · 实际状态模型',font=title,fill=(46,44,43))
for i,(phase,label) in enumerate([(None,'常态 · 空眼窝'),(2,'技能施放 · 紫光短亮')]):
    sheet.paste(rendered[phase],(i*640,60));dr.text((i*640+22,67),label,font=font,fill=(46,44,43))
sheet.save(S/'五世恶咒_常态与施法对比.png')
frames=[]
for phase in [None,0,1,2]:
    frame=rendered[phase].copy();ImageDraw.Draw(frame).text((20,15),('常态 · 空眼窝' if phase is None else '施法 · '+levels[phase][0]),font=font,fill=(46,44,43));frames.append(frame)
frames[0].save(S/'五世恶咒_施法眼光过渡.gif',save_all=True,append_images=[frames[1],frames[2],frames[3],frames[2],frames[1],frames[0]],duration=[550,50,50,250,100,100,550],loop=0,disposal=2)
print('Saved native animations, shared-body Java state exports and actual-model transition previews.',flush=True)
