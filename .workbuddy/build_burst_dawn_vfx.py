"""New review stage, based on saved heavy-recoil mothers. Never overwrites them.

Original game reference: official Arknights announcement 926012197632475156,
last GIF, default outfit S3. The new textures are authored here, not copied.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import base64,copy,hashlib,io,json,math,uuid,sys,shutil
import numpy as np
from model_review_io import renderer

BASE=Path('D:/数据包/模型设计/爆裂黎明_建模_20261014')
S=BASE/'阶段三_普通持有与射击动效'
O=BASE/'阶段四_箭矢与技能背效';O.mkdir(exist_ok=True)
AP=O/'爆裂黎明_箭矢与技能背效_分组可编辑动画.bbmodel'
if AP.exists():
 if '--revise-unreviewed' not in sys.argv or (O/'特效核验.json').exists():raise SystemExit('阶段四工程已存在；禁止用初建器覆盖精修。')
 archive=O/'过程记录/首次离线形态检查';archive.mkdir(parents=True,exist_ok=True)
 for f in O.iterdir():
  if f.is_file():shutil.copy2(f,archive/f.name)
def uid():return str(uuid.uuid4())
def load(p):return json.loads(p.read_text(encoding='utf8'))
def save(b,p):p.write_text(json.dumps(b,ensure_ascii=False,separators=(',',':')),encoding='utf8')
def clip(name,dur,loop='once'):
 return dict(uuid=uid(),name=name,length=dur,loop=loop,override=False,snapping=100,selected=False,animators={})
def key(a,g,ch,points):
 an=a['animators'].setdefault(g['uuid'],dict(name=g['name'],type='bone',rotation_global=False,quaternion_interpolation=False,keyframes=[]))
 for t,v in points:
  k=dict(uuid=uid(),channel=ch,time=t,interpolation='linear',color=-1,data_points=[{k:str(round(float(x),6)) for k,x in zip('xyz',v)}])
  prior=next((x for x in an['keyframes'] if x['channel']==ch and x['time']==t),None)
  if prior:assert prior['data_points']==k['data_points']
  else:an['keyframes'].append(k)
def scalar(a,g,ch,pts):key(a,g,ch,[(t,[v]*3) for t,v in pts])
def group(bb,name,origin,parent=None):
 g=dict(uuid=uid(),name=name,origin=list(origin),rotation=[0,0,0],visibility=True,export=True,isOpen=True)
 n=dict(uuid=g['uuid'],isOpen=True,children=[]);bb['groups'].append(g)
 (parent['children'] if parent is not None else bb['outliner']).append(n)
 return g,n

# One 512² atlas: binary alpha, authored ribbon/spark tiles and solid swatches.
atlas=Image.new('RGBA',(512,512));d=ImageDraw.Draw(atlas)
for tile in range(4):
 ox=(tile%2)*128;oy=(tile//2)*96
 for x in range(128):
  t=x/127;cy=44+(11 if tile<2 else 6)*math.sin(t*math.pi*2)+2*math.sin(t*19)*math.sin(t*math.pi)
  width=(23*(1-.25*t)+3*math.sin(t*23)**2) if tile<2 else (14*(1-.35*t)+2)
  for y in range(88):
   a=abs(y-cy)/width
   if a>1:continue
   # Chipped silhouette / holes toward trailing edges.
   if tile==1 and x>48 and ((x*7+y*13)%71<5) and a>.6:continue
   c=(16,17,26,255) if a>.55 else (55,9,21,255) if a>.34 else (130,15,31,255) if a>.16 else (212,30,39,255)
   if tile>=2 and a<.18:c=(255,112,74,255)
   atlas.putpixel((ox+x,oy+y),c)
 # Isolated tapering forks at the ragged end.
 for i in range(3):
  x=91+i*9;y=31+(i%2)*25
  d.polygon([(ox+x,oy+y),(ox+min(127,x+23),oy+y-8),(ox+x+8,oy+y+2)],fill=(31,20,31,255))
swatches=[(17,19,28),(36,41,58),(78,14,29),(153,19,39),(236,39,46),(255,109,68),(255,211,158),(255,244,218)]
for i,c in enumerate(swatches):d.rectangle((i*32,480,i*32+31,511),fill=c+(255,))
# Curling, broken flame tip instead of a solid rod or torch-shaped cap.
tip_shape=[(2,48),(29,40),(42,25),(38,9),(53,21),(69,4),(68,29),(96,14),(88,37),(125,32),(109,49),(87,56),(119,75),(83,69),(65,85),(49,67),(23,72),(34,57)]
d.polygon([(x,y+192) for x,y in tip_shape],fill=(15,17,25,255))
d.polygon([(x,y+192) for x,y in [(8,48),(38,43),(56,30),(62,46),(89,42),(75,54),(96,63),(65,61),(47,55),(26,61)]],fill=(107,13,30,255))
d.polygon([(x,y+192) for x,y in [(11,48),(40,47),(57,39),(56,51),(79,49),(67,57),(47,52),(27,56)]],fill=(224,32,41,255))
bio=io.BytesIO();atlas.save(bio,format='PNG');atlas.save(O/'爆裂黎明_红黑残焰_纹理.png')
texture=dict(uuid=uid(),id='0',name='爆裂黎明_红黑残焰.png',source='data:image/png;base64,'+base64.b64encode(bio.getvalue()).decode(),width=512,height=512,uv_width=512,uv_height=512,mode='bitmap',render_mode='default',visible=True)
def blank(name):return dict(meta={'format_version':'5.0','model_format':'free','box_uv':False,'bone_rig':True},name=name,resolution={'width':512,'height':512},elements=[],groups=[],outliner=[],textures=[copy.deepcopy(texture)],animations=[],display={})
def cube(bb,node,name,lo,hi,material=0,rot=(0,0,0),origin=None,emission=0,card=None,plane='xy'):
 e=dict(name=name,uuid=uid(),type='cube',from_=lo,to=hi,origin=origin or [(a+b)/2 for a,b in zip(lo,hi)],rotation=list(rot),rescale=False,shade=True,visibility=True,export=True,light_emission=emission,faces={})
 e['from']=e.pop('from_')
 for side in ['north','south','east','west','up','down']:
  uv=[material*32+6,488,material*32+25,507];tex=0
  if card is not None:
   uv=[(card%2)*128,(card//2)*96,(card%2)*128+128,(card//2)*96+88]
   if side not in (['north','south'] if plane=='xy' else ['up','down']):tex=None
   if side in ['south','down']:uv=[uv[2],uv[1],uv[0],uv[3]]
  e['faces'][side]={'uv':uv,'texture':tex}
 bb['elements'].append(e);node['children'].append(e['uuid']);return e

# Shoulder-local space matches the approved shoulder attachment. Extra VFX only.
b=blank('爆裂黎明_技能背效_分组可编辑动画')
br,bn=group(b,'技能背效_独立挂点',[0,8,8]);chains={};embers=[]
for sign,label in [(1,'右'),(-1,'左')]:
 gs=[];parent=bn
 for j,(x,y,z,l,w) in enumerate([(7.5,12.3,8.6,6.1,6.8),(12.5,14.2,10.3,6.1,6.3),(17.6,16.1,12.0,6.1,5.9)]):
  g,n=group(b,label+f'_残焰弧段_{j+1}',[sign*x,y,z],parent);gs.append(g);parent=n
  # Broad cutout VFX surfaces with real front/back UV, not rod-shaped ornaments.
  cx=sign*(x+l/2);lo=[cx-l/2,y-w/2,z-.055];hi=[cx+l/2,y+w/2,z+.055]
  e=cube(b,n,label+f'_红黑流焰_{j+1}',lo,hi,rot=[0,0,sign*(22.5 if j<2 else -22.5)],origin=[sign*x,y,z],card=j%2,emission=8)
  if sign<0:
   for f in e['faces'].values():f['uv']=[f['uv'][2],f['uv'][1],f['uv'][0],f['uv'][3]]
  # A second sheet in the depth direction keeps the plume visible from the side.
  cx=sign*(x+l*.38)
  e=cube(b,n,label+f'_深度流焰_{j+1}',[cx-.055,y-w*.45,z-1],[cx+.055,y+w*.45,z+5.2],material=0,rot=[-22.5,0,0],origin=[cx,y,z],emission=8)
  for side,f in e['faces'].items():
   f['texture']=0 if side in ['east','west'] else None;f['uv']=[128,96,0,184] if side=='east' else [0,96,128,184]
 tip,tn=group(b,label+'_黑色裂片焰尖',[sign*21.1,16,15],parent);gs.append(tip)
 loX,hiX=sorted([sign*19.2,sign*23.7])
 e=cube(b,tn,label+'_碎焰卷尖',[loX,12.8,15.35],[hiX,19.1,15.47],card=4,emission=8)
 if sign<0:
  for f in e['faces'].values():f['uv']=[f['uv'][2],f['uv'][1],f['uv'][0],f['uv'][3]]
 e=cube(b,tn,label+'_碎焰卷尖_侧深度',[sign*21.1-.055,13.3,14.3],[sign*21.1+.055,18.6,19.3],emission=8)
 for side,f in e['faces'].items():f['texture']=0 if side in ['east','west'] else None;f['uv']=[128,192,0,280] if side=='east' else [0,192,128,280]
 chains[sign]=gs
 for j in range(4):
  x=sign*(9+j*3.2);y=13+j*1.9;z=15.6+(j%2)*2
  g,n=group(b,label+f'_离散余烬_{j}',[x,y,z],bn);embers.append((g,sign,j))
  cube(b,n,label+f'_余烬暗片_{j}',[x-.48,y-.12,z-.24],[x+.48,y+.82,z+.24],material=2,rot=[0,0,sign*22.5])
  cube(b,n,label+f'_余烬亮芯_{j}',[x-.16,y+.1,z+.26],[x+.16,y+.65,z+.34],material=4,emission=8)

def back_anim(kind,name=None):
 a=clip(name or {'begin':'04_技能开启','idle':'05_技能背效维持','fire':'06_技能射击','end':'07_技能收束'}[kind],{'begin':.8,'idle':4,'fire':.72,'end':.65}[kind], 'loop' if kind=='idle' else 'once')
 for sign,gs in chains.items():
  for j,g in enumerate(gs):
   if kind=='begin':
    t0=j*.07;t1=.30+j*.07
    scalar(a,g,'scale',[(0,0),(t0,0),(t1,.92),(.65,1.06),(.8,1)])
    key(a,g,'rotation',[(0,[0,sign*12,-sign*24]),(t1,[0,sign*4,sign*7]),(.8,[0,0,0])])
   elif kind=='idle':
    key(a,g,'rotation',[(t,[v*.6,sign*v*.7,sign*v]) for t,v in zip([0,1,2,3,4],[0,2.4 if j%2 else -2.4,0,-2.4 if j%2 else 2.4,0])])
   elif kind=='fire':
    key(a,g,'rotation',[(t,[v*1.1,sign*v*.7,-sign*v]) for t,v in [(0,0),(.05,7),(.10,9-j),(.24,-3),(.42,1),(.72,0)]])
    scalar(a,g,'scale',[(0,1),(.05,1.09),(.12,1.17),(.28,1.04),(.48,1),(.72,1)])
   else:
    scalar(a,g,'scale',[(0,1),(.12,1.04),(.24+j*.04,.75),(.65,0)])
    key(a,g,'rotation',[(0,[0,0,0]),(.65,[sign*9,sign*18,-sign*12])])
 for g,sign,j in embers:
  if kind=='begin':
   scalar(a,g,'scale',[(0,0),(.12+j*.05,0),(.30+j*.05,1),(.8,1)])
  elif kind=='idle':
   key(a,g,'position',[(t,[sign*v*.23,v*.5,v*.15]) for t,v in [(0,0),(1,1),(2,0),(3,-1),(4,0)]])
   scalar(a,g,'scale',[(0,1),(1,.5 if j%2 else 1.1),(2,1),(3,1.1 if j%2 else .5),(4,1)])
  elif kind=='fire':
   key(a,g,'position',[(0,[0,0,0]),(.14,[sign*1.6,1.9,2.4]),(.4,[sign*.6,.9,.9]),(.72,[0,0,0])])
   scalar(a,g,'scale',[(0,1),(.12,1.2),(.4,.4),(.72,1)])
  else:scalar(a,g,'scale',[(0,1),(.4,.35),(.65,0)])
 return a
b['animations']=[back_anim(k) for k in ['begin','idle','fire','end']]
save(b,O/(b['name']+'.bbmodel'))

# Every-shot arrow: a distinct red/black energy bolt and visible wake.
p=blank('爆裂黎明_红黑箭矢_分组可编辑动画');pr,pn=group(p,'箭矢_飞行挂点',[0,0,0])
body,bodyn=group(p,'箭矢_实体弹芯',[0,0,0],pn)
cube(p,bodyn,'箭杆_黑钢',[-.32,-.32,-3.8],[.32,.32,3.6],material=1)
cube(p,bodyn,'箭杆_灼红芯',[-.12,-.42,-3.6],[.12,-.34,2.4],material=4,emission=8)
for j,(w,z0,z1) in enumerate([(1.15,-4.3,-2.4),(.77,-5.2,-4.1),(.37,-6.1,-5.1)]):
 cube(p,bodyn,f'穿甲箭尖_{j}',[-w/2,-w/2,z0],[w/2,w/2,z1],material=4+j,emission=8)
for sign in [-1,1]:
 cube(p,bodyn,'暗色倒钩_'+str(sign),[sign*1.05-.4,-.18,-3.1],[sign*1.05+.4,.18,-.1],material=0,rot=[0,sign*22.5,0])
 cube(p,bodyn,'箭尾稳定片_'+str(sign),[sign*.75-.35,-.12,2.1],[sign*.75+.35,.12,4.7],material=3,rot=[0,sign*22.5,0])
tail=[]
for j in range(3):
 z=1.5+j*5.1;g,n=group(p,f'能量尾迹_{j+1}',[0,0,z],pn);tail.append(g)
 # XY texture rotated into XZ/YZ surfaces through per-cube discrete rotations.
 e=cube(p,n,f'水平赤黑尾迹_{j}',[-2.3,.01,z],[2.3,.11,z+7.5],card=2,plane='xz',emission=8)
 for f in e['faces'].values():f['rotation']=90
 # Vertical wake uses the same original tile rotated 90° in UV, legal face data.
 e=cube(p,n,f'垂直赤黑尾迹_{j}',[-.055,-2.1,z],[.055,2.1,z+7],material=3,emission=8)
 for side,f in e['faces'].items():
  f['texture']=0 if side in ['east','west'] else None;f['uv']=[128,96,0,184] if side=='east' else [0,96,128,184]
for j in range(6):
 x=(-1 if j%2 else 1)*(.8+j*.15);y=((j%3)-1)*.65;z=4+j*2.4
 cube(p,pn,f'飞行碎烬_{j}',[x-.16,y-.16,z],[x+.16,y+.16,z+.8],material=4 if j%2 else 2,emission=8)
flight=clip('01_箭矢尾迹循环',1.2,'loop')
for j,g in enumerate(tail):
 key(flight,g,'rotation',[(t,[0,0,v]) for t,v in [(0,0),(.3,5 if j%2 else -5),(.6,0),(.9,-5 if j%2 else 5),(1.2,0)]])
 scalar(flight,g,'scale',[(0,1),(.3,.9 if j%2 else 1.12),(.6,1),(.9,1.12 if j%2 else .9),(1.2,1)])
p['animations']=[flight];save(p,O/(p['name']+'.bbmodel'))

# Muzzle energy burst. This is attached to the actual saved muzzle, not the blade tip.
m=blank('爆裂黎明_枪口轰焰_分组可编辑动画');mr,mn=group(m,'枪口轰焰_挂点',[0,0,0])
for j in range(4):
 z=-2.7-j*.9;w=[2.4,3.4,2.9,1.9][j]
 cube(m,mn,f'枪口轰焰横片_{j}',[-w,-.045,z-1.6],[w,.045,z+1.6],card=2 if j%2 else 3,plane='xz',emission=8)
 e=cube(m,mn,f'枪口轰焰竖片_{j}',[-.045,-w,z-1.6],[.045,w,z+1.6],material=5,emission=8)
 for side,f in e['faces'].items():f['texture']=0 if side in ['east','west'] else None;f['uv']=[256,96,128,184] if side=='east' else [128,96,256,184]
cube(m,mn,'枪口瞬亮芯',[-.65,-.65,-3],[.65,.65,-.8],material=7,emission=8)
ma=clip('01_枪口轰焰',.2);scalar(ma,mr,'scale',[(0,0),(.015,1),(.05,1.4),(.10,.9),(.20,0)]);m['animations']=[ma]
save(m,O/(m['name']+'.bbmodel'))

assembly=load(S/'爆裂黎明_普通持有_分组可编辑动画.bbmodel');original=copy.deepcopy(assembly)
assembly['name']='爆裂黎明_箭矢与技能背效_分组可编辑动画'
def add_asset(src,scale,pivot,target):
 q=copy.deepcopy(src);base=len(assembly['textures'])
 for t in q['textures']:t.update(id=str(base),uuid=uid());assembly['textures'].append(t)
 for e in q['elements']:
  for k in ['from','to','origin']:e[k]=((np.array(e[k])-pivot)*scale+target).tolist()
  for f in e['faces'].values():
   if f.get('texture') is not None:f['texture']+=base
 for g in q['groups']:g['origin']=((np.array(g['origin'])-pivot)*scale+target).tolist()
 for a in q['animations']:
  for an in a['animators'].values():
   for k in an['keyframes']:
    if k['channel']=='position':k['data_points'][0]={axis:str(float(v)*scale) for axis,v in k['data_points'][0].items()}
 assembly['elements']+=q['elements'];assembly['groups']+=q['groups'];return q
bp=add_asset(b,.85,np.array([0,8,8]),np.array([0,21.65,2.75]));assembly['outliner']+=bp['outliner']
# Charged muzzle computed from saved native grip and loaded Z=1.1° pose.
grip=np.array([23.7,2.7,8]);muzzle=np.array([-6.1,8.93,8.05]);a=math.radians(1.1)
rz=np.array([[math.cos(a),-math.sin(a),0],[math.sin(a),math.cos(a),0],[0,0,1]])
ry=np.array([[0,0,-1],[0,1,0],[1,0,0]])
launch=np.array([6,13,-1.3])+ry@(rz@(muzzle-grip)*.72)
pp=add_asset(p,.8,np.zeros(3),launch);pg=next(g for g in pp['groups'] if g['uuid']==pr['uuid']);pg['rotation']=[-1.1,0,0]
next(g for g in assembly['groups'] if g['uuid']==pr['uuid'])['rotation']=[-1.1,0,0]
assembly['outliner']+=pp['outliner']
mp=add_asset(m,.72,np.zeros(3),launch)
# Its geometry faces -Z in player coordinates. Keep independent of recoil after ignition.
assembly['outliner']+=mp['outliner']
for a0 in assembly['animations']:
 scalar(a0,br,'scale',[(0,0)]);scalar(a0,pr,'scale',[(0,0)]);scalar(a0,mr,'scale',[(0,0)])
def shoot_fx(a0):
 a0['animators'].pop(pr['uuid'],None);a0['animators'].pop(mr['uuid'],None)
 scalar(a0,pr,'scale',[(0,0),(.01,0),(.02,1),(.36,1),(.44,0),(.72,0)])
 key(a0,pr,'position',[(t,[0,-dist*math.sin(math.radians(1.1)),-dist*math.cos(math.radians(1.1))]) for t,dist in [(0,0),(.01,0),(.02,3),(.12,17),(.24,34),(.36,52),(.44,65),(.72,65)]])
 scalar(a0,mr,'scale',[(0,0),(.015,1),(.05,1.4),(.10,.9),(.20,0),(.72,0)])
 for j,g in enumerate(tail):key(a0,g,'rotation',[(t,[0,0,v]) for t,v in [(0,0),(.12,17 if j%2 else -17),(.24,-10 if j%2 else 10),(.44,0),(.72,0)]])
shoot_fx(assembly['animations'][2])
idle_template=copy.deepcopy(original['animations'][0]);fire_template=copy.deepcopy(original['animations'][2])
for kind,ba in zip(['begin','idle','fire','end'],bp['animations']):
 template=fire_template if kind=='fire' else idle_template
 q=clip(ba['name'],ba['length'],ba['loop'])
 if kind in ['begin','end']:
  # Weapon and shoulder rest, so activation can splice into ordinary holding.
  for an in template['animators'].values():
   g=next(g for g in assembly['groups'] if g['uuid'] in template['animators'] and g['name']==an['name'])
   for ch in set(k['channel'] for k in an['keyframes']):key(q,g,ch,[(0,[1,1,1] if ch=='scale' else [0,0,0]),(q['length'],[1,1,1] if ch=='scale' else [0,0,0])])
 else:q['animators']=copy.deepcopy(template['animators'])
 q['animators'].update(copy.deepcopy(ba['animators']))
 scalar(q,pr,'scale',[(0,0)]);scalar(q,mr,'scale',[(0,0)])
 if kind=='fire':shoot_fx(q)
 assembly['animations'].append(q)
# All three VFX components share one actual texture in the assembled editor.
unique=[];remap={};by_source={}
for i,t in enumerate(assembly['textures']):
 h=hashlib.sha256(t['source'].encode()).hexdigest()
 if h not in by_source:by_source[h]=len(unique);t['id']=str(len(unique));unique.append(t)
 remap[i]=by_source[h]
for e in assembly['elements']:
 for f in e['faces'].values():
  if f.get('texture') is not None:f['texture']=remap[int(f['texture'])]
assembly['textures']=unique
save(assembly,AP)

# Java-compatible whole Display editors, full geometry and embedded texture.
def display_export(src,slug,name,offset):
 bb=copy.deepcopy(src);bb['meta'].update(model_format='java_block',bone_rig=False);bb['animations']=[];bb['name']=name
 bb['display']={'thirdperson_righthand':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[1,1,1]},'firstperson_righthand':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[1,1,1]},'gui':{'rotation':[10,-25,0],'translation':[0,0,0],'scale':[.65,.65,.65]}}
 for e in bb['elements']:
  for k in ['from','to','origin']:e[k]=[round(v+offset[i],6) for i,v in enumerate(e[k])]
 for g in bb['groups']:g['origin']=[round(v+offset[i],6) for i,v in enumerate(g['origin'])]
 save(bb,O/(name+'.bbmodel'))
 texdir=O/'审阅资源/assets/sweetdream/textures/item/burst_dawn_vfx';texdir.mkdir(parents=True,exist_ok=True)
 (texdir/'redblack.png').write_bytes(bio.getvalue())
 out=O/'审阅资源/assets/sweetdream/models/item/burst_dawn_vfx'/f'{slug}.json';out.parent.mkdir(parents=True,exist_ok=True)
 elements=[]
 for e in bb['elements']:
  el={'from':e['from'],'to':e['to'],'light_emission':e.get('light_emission',0),'faces':{}}
  assert all(-16<=v<=32 for v in el['from']+el['to']),e['name']
  axes=[i for i,v in enumerate(e['rotation']) if abs(v)>1e-8]
  assert len(axes)<=1 and all(e['rotation'][i] in [-45,-22.5,22.5,45] for i in axes)
  if axes:el['rotation']={'axis':'xyz'[axes[0]],'angle':e['rotation'][axes[0]],'origin':e['origin']}
  for s,f in e['faces'].items():
   if f.get('texture') is None:continue
   v={'texture':'#0','uv':[round(v/32,6) for v in f['uv']]}
   if f.get('rotation'):v['rotation']=f['rotation']
   el['faces'][s]=v
  elements.append(el)
 out.write_text(json.dumps({'credit':'阶段四独立审阅资产，未部署','ambientocclusion':False,'textures':{'0':'sweetdream:item/burst_dawn_vfx/redblack','particle':'sweetdream:item/burst_dawn_vfx/redblack'},'elements':elements,'display':bb['display']},ensure_ascii=False,separators=(',',':')),encoding='utf8')
 return str(out)
exports=[display_export(b,'skill_back','爆裂黎明_技能背效_整体Display调整',[8,8,8]),display_export(p,'redblack_arrow','爆裂黎明_红黑箭矢_整体Display调整',[8,8,8]),display_export(m,'muzzle','爆裂黎明_枪口轰焰_整体Display调整',[8,8,8])]
assert assembly['elements'][:len(original['elements'])]==original['elements']
report=dict(approved_geometry_unchanged=True,normal_weapon=552,normal_shoulders=386,preview_mannequin=6,back_vfx_cubes=len(b['elements']),arrow_vfx_cubes=len(p['elements']),muzzle_vfx_cubes=len(m['elements']),assembly_cubes=len(assembly['elements']),launch_world=launch.tolist(),projectile_flight_demo_only=True,ordinary_and_skill_shots_have_fx=True,official_reference='https://t.bilibili.com/926012197632475156',reference_gif='https://i0.hdslb.com/bfs/new_dyn/2eefb3a257fde1acaee6302fd807d95c161775300.gif',exports=exports,game_deployed=False,source_sha256={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in S.glob('*分组可编辑动画.bbmodel')})
(O/'特效统计与来源.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(report,ensure_ascii=False),flush=True)
