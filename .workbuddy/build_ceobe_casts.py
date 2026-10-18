"""Derive throw animation projects from the three saved, editable weapon masters.

Does not regenerate or deploy any weapon geometry. The optional arm is confined
to separate preview projects. All animations are native Blockbench keyframes.
"""
from pathlib import Path
from PIL import Image
import json, copy, math, hashlib, uuid, io, base64
import numpy as np

BASE = Path('D:/数据包/模型设计/很冰的斧_建模_20261016')
OUT = BASE/'阶段二_三形态投掷施法'

def uid(s): return str(uuid.uuid5(uuid.NAMESPACE_URL, 'ceobe/cast/20261018/'+s))
def rx(v):
    a=math.radians(v);return np.array([[1,0,0],[0,math.cos(a),-math.sin(a)],[0,math.sin(a),math.cos(a)]])
def ease(a): return a*a*(3-2*a)
def curve(points,t):
    if t<=points[0][0]:return np.array(points[0][1],float)
    for (ta,a),(tb,b) in zip(points,points[1:]):
        if t<=tb:
            f=ease((t-ta)/(tb-ta));return np.array(a)*(1-f)+np.array(b)*f
    return np.array(points[-1][1],float)

SPECS = [
 dict(code='ice',label='冰斧',name='很冰的斧',
      source=BASE/'阶段一_设定图修订/很冰的斧_设定图修订_分组可编辑.bbmodel',
      release=.19,flight_end=.35,hide=.38,reset=.41,reform=.45,travel=40,spin=-396,
      arm=[(0,[0,0]),(.11,[40,26]),(.13,[42,28]),(.19,[18,-46]),(.23,[-8,-18]),(.29,[-7,-15]),(.5,[0,0])],
      weapon=[(0,[0,0,0]),(.11,[30,0,-14]),(.13,[42,0,-7]),(.19,[-74,0,10])],
      flight_label='翻转掷斧',explanation='提斧后压住一瞬，向前掷出；脱手后绕横轴翻转。'),
 dict(code='knife',label='热刀',name='很热的刀',
      source=BASE/'阶段一_刀枪形态/很热的刀_双刃短剑/很热的刀_双刃短剑_分组可编辑.bbmodel',
      release=.14,flight_end=.29,hide=.32,reset=.38,reform=.43,travel=50,spin=0,
      arm=[(0,[0,0]),(.07,[18,35]),(.09,[20,33]),(.14,[10,-34]),(.18,[-6,-25]),(.24,[-4,-14]),(.5,[0,0])],
      weapon=[(0,[0,0,0]),(.07,[25,0,-34]),(.09,[32,0,-38]),(.14,[-89,0,-15])],
      flight_label='快速甩刀',explanation='短促收腕，斜向甩出；刀尖朝前快速飞行。'),
 dict(code='spear',label='重枪',name='很重的枪',
      source=BASE/'阶段一_刀枪形态/很重的枪_三段折叠长枪/很重的枪_三段折叠长枪_分组可编辑.bbmodel',
      release=.24,flight_end=.39,hide=.42,reset=.44,reform=.47,travel=52,spin=0,
      arm=[(0,[0,0]),(.14,[40,35]),(.19,[46,34]),(.24,[22,-52]),(.28,[-10,-24]),(.35,[-8,-22]),(.5,[0,0])],
      weapon=[(0,[0,0,0]),(.14,[30,0,-3]),(.19,[44,0,-2]),(.24,[-88,0,0])],
      flight_label='蓄势投枪',explanation='较长蓄势和短顿后猛然前送，整枪挺直飞出；各节全程不折叠。'),
]

def arm_pose(spec,t):
    u,l=curve(spec['arm'],t)
    return float(u),float(l)

def hand_position(grip,u,l):
    shoulder=np.array(grip)+[0,-5,11]
    return shoulder+rx(u)@np.array([0,-1,-6])+rx(u+l)@np.array([0,6,-5])

def pose(spec,grip,t):
    rel=spec['release'];u,l=arm_pose(spec,t)
    if t<=rel or t>=spec['reset']:
        pos=hand_position(grip,u,l)-grip
        r=curve(spec['weapon'],t) if t<=rel else np.zeros(3)
    else:
        u0,l0=arm_pose(spec,rel);start=hand_position(grip,u0,l0)-grip
        f=(t-rel)/(spec['flight_end']-rel)
        # Flight remains at constant speed after leaving the hand.
        pos=start+np.array([0, (2.2*4*f*(1-f) if spec['code']=='ice' else .5*f), -spec['travel']*f])
        r=np.array(spec['weapon'][-1][1],float)+[spec['spin']*f,0,0]
    if t<=spec['flight_end']:scale=1.
    elif t<spec['hide']:scale=1-ease((t-spec['flight_end'])/(spec['hide']-spec['flight_end']))
    elif t<spec['reform']:scale=0.
    else:scale=ease((t-spec['reform'])/(.5-spec['reform']))
    return r,pos,np.repeat(scale,3)

def group(code,name,origin):
    return {'name':name,'uuid':uid(code+'/'+name),'origin':list(origin),'rotation':[0,0,0],
            'visibility':True,'export':True,'isOpen':True}

def key(t,ch,v,interpolation='linear'):
    return {'uuid':str(uuid.uuid4()),'channel':ch,'time':round(float(t),5),'color':-1,
            'interpolation':interpolation,'data_points':[{a:str(round(float(b),7)) for a,b in zip('xyz',v)}]}

def add_animation(bb,spec,root,grip,demo=False):
    aid=uid(spec['code']+'/cast_throw'+('/demo' if demo else ''))
    a={'uuid':aid,'name':'cast_throw｜'+spec['flight_label'],'loop':'once','override':False,
       'length':.5,'snapping':100,'anim_time_update':'','blend_weight':'','start_delay':'',
       'loop_delay':'','animators':{root['uuid']:{'name':root['name'],'type':'bone','keyframes':[]}}}
    times=sorted(set([round(i*.01,4) for i in range(51)]+[spec[k] for k in ['release','flight_end','hide','reset','reform']]))
    for t in times:
        for ch,v in zip(['rotation','position','scale'],pose(spec,np.array(grip),t)):
            smooth=ch!='scale' and (t<spec['release']-.011 or t>=spec['reset'])
            a['animators'][root['uuid']]['keyframes'].append(key(t,ch,v,'catmullrom' if smooth else 'linear'))
    if demo:
        for n in ['right_upper_arm','right_lower_arm','right_hand']:
            a['animators'][uid(spec['code']+'/'+n)]={'name':n,'type':'bone','keyframes':[]}
        for t in times:
            u,l=arm_pose(spec,t)
            if t<=spec['release']:wr=curve(spec['weapon'],t)
            else:wr=curve([(spec['release'],spec['weapon'][-1][1]),(.31,[-48,0,0]),(.5,[0,0,0])],t)
            for n,angle in [('right_upper_arm',[u,0,0]),('right_lower_arm',[l,0,0]),('right_hand',[wr[0]-u-l,0,wr[2]])]:
                a['animators'][uid(spec['code']+'/'+n)]['keyframes'].append(key(t,'rotation',angle,'catmullrom'))
    bb['animations']=[a]

def arm_demo(bb,spec,grip):
    d=copy.deepcopy(bb);d['name']=spec['name']+'_投掷持握演示'
    pix=np.empty((16,16,4),dtype=np.uint8);pix[:]=(64,72,83,255);pix[8:]=(187,151,121,255)
    stream=io.BytesIO();Image.fromarray(pix).save(stream,format='PNG')
    d['textures'].append({'name':'仅演示_手臂.png','uuid':uid(spec['code']+'/arm_tex'),'id':'1',
                         'source':'data:image/png;base64,'+base64.b64encode(stream.getvalue()).decode(),
                         'width':16,'height':16,'uv_width':16,'uv_height':16,'render_mode':'default'})
    sh=np.array(grip)+[0,-5,11];el=sh+[0,-1,-6]
    ug=group(spec['code'],'right_upper_arm',sh);lg=group(spec['code'],'right_lower_arm',el);hg=group(spec['code'],'right_hand',grip)
    d['groups'].extend([ug,lg,hg])
    def cube(n,lo,hi,origin,angle,skin=False):
        eid=uid(spec['code']+'/demo_cube/'+n)
        d['elements'].append({'name':'仅演示｜'+n,'type':'cube','uuid':eid,'from':list(lo),'to':list(hi),
                'origin':list(origin),'rotation':[angle,0,0],'visibility':True,'export':True,'autouv':0,
                'faces':{s:{'texture':1,'uv':[1,9 if skin else 1,6,14 if skin else 6]} for s in ['north','south','east','west','up','down']}})
        return eid
    def segment(n,a,b,width):
        a=np.array(a);b=np.array(b);length=float(np.linalg.norm(b-a));angle=math.degrees(math.atan2(b[1]-a[1],a[2]-b[2]))
        return cube(n,a+[-width/2,-width/2,-length],a+[width/2,width/2,0],a,angle)
    upper=segment('上臂',sh,el,3.3);fore=segment('前臂',el,grip,3.0)
    hand=cube('手掌',np.array(grip)+[-1.7,-1.8,-1.55],np.array(grip)+[1.7,1.8,1.55],grip,0,True)
    d['outliner'].append({'uuid':ug['uuid'],'isOpen':True,'children':[upper,{'uuid':lg['uuid'],'isOpen':True,'children':[fore,{'uuid':hg['uuid'],'isOpen':True,'children':[hand]}]}]})
    return d

def fingerprint(bb):
    return hashlib.sha256(json.dumps({'elements':bb['elements'],'groups':bb['groups'],'outliner':bb['outliner'],
        'textures':bb['textures']},ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()

def main():
    if OUT.exists() and list(OUT.rglob('*.bbmodel')):
        raise SystemExit('原生动画母版已存在；后续应从MCP保存工程继续，不重建覆盖。')
    OUT.mkdir(exist_ok=True);plan=[]
    for s in SPECS:
        b=json.loads(s['source'].read_text(encoding='utf-8'));old=copy.deepcopy(b)
        root0=next(g for g in b['groups'] if g['uuid']==b['outliner'][0]['uuid']);grip=np.array(root0['origin'],float)
        folder=OUT/s['name'];folder.mkdir(exist_ok=True)
        root=group(s['code'],'cast_throw_root｜握点与脱手轨迹',grip)
        b['groups'].insert(0,root);b['outliner']=[{'uuid':root['uuid'],'isOpen':True,'children':b['outliner']}]
        b['name']=s['name']+'_投掷施法_原生动画';b.pop('display',None)
        add_animation(b,s,root,grip)
        p=folder/(b['name']+'.bbmodel');p.write_text(json.dumps(b,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
        # User rejected demonstration-only assets. Deliver weapon-only masters.
        # Complete, static Display entry. Same weapon only; the demo arm is excluded.
        display=json.loads((s['source'].parent/'统一Display.json').read_text(encoding='utf-8'))
        db=copy.deepcopy(old);db['meta']['model_format']='java_block';db['name']=s['name']+'_整体Display调整'
        db['animations']=[];db['groups']=[];db['outliner']=[e['uuid'] for e in db['elements']];db['display']=display
        for e in db['elements']:
            for k in ['from','to','origin']:e[k]=[v+8 for v in e[k]]
        disp=folder/(db['name']+'.bbmodel');disp.write_text(json.dumps(db,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
        (folder/'统一Display.json').write_text(json.dumps(display,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        plan.append({'code':s['code'],'label':s['label'],'description':s['explanation'],
            'native':str(p),'display':str(disp),'source':str(s['source']),
            'source_sha256':hashlib.sha256(s['source'].read_bytes()).hexdigest(),
            'source_content_fingerprint':fingerprint(old),'root':root['uuid'],'grip':grip.tolist(),
            'release':s['release'],'length':.5,'flight_end':s['flight_end'],'hide':s['hide'],'reset':s['reset'],'reform':s['reform'],
            'elements':len(old['elements']),'original_groups':len(old['groups']),'native_groups':len(b['groups']),
            'rejected_animations_removed':[a['name'] for a in old.get('animations',[])]})
    (OUT/'工程清单.json').write_text(json.dumps(plan,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(plan,ensure_ascii=False))

if __name__=='__main__':main()
