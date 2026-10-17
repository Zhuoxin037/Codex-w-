"""Original-default S3 projectile, muzzle and impact review assets.

Start from the saved, now accepted two-tier outfit. Static phase atlas and stepped
native gates allow one-shot effects to start at their event, without relying on a
globally looping animated texture to reset when an arrow hits.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import base64,copy,hashlib,io,json,math,shutil,uuid
import numpy as np
from render_burst_dawn_vfx_v2 import load_renderer
B=Path('D:/数据包/模型设计/爆裂黎明_建模_20261014');S=B/'阶段七_肩背广域残焰';O=B/'阶段八_原作弹道与命中特效'
AP='爆裂黎明_弹道与命中特效_分组可编辑动画.bbmodel'
if (O/AP).exists():raise SystemExit('阶段八保存母版已存在，禁止初建覆盖。')
O.mkdir(exist_ok=True)
def uid():return str(uuid.uuid4())
def load(p):return json.loads(p.read_text(encoding='utf8'))
def save(b,p):p.write_text(json.dumps(b,ensure_ascii=False,separators=(',',':')),encoding='utf8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def layer(w,h):return Image.new('RGBA',(w*3,h*3))
def polygon(d,points,fill):d.polygon([(x*3,y*3) for x,y in points],fill=fill)
def line(d,points,fill,width):d.line([(x*3,y*3) for x,y in points],fill=fill,width=max(1,round(width*3)))
def ellipse(d,box,fill=None,outline=None,width=1):d.ellipse(tuple(v*3 for v in box),fill=fill,outline=outline,width=max(1,round(width*3)))
atlas=Image.new('RGBA',(512,512));palette=[(12,13,23),(42,37,58),(98,18,36),(183,19,38),(250,40,48),(132,57,212),(62,104,229),(236,213,255)]

def flight(k):
 im=layer(128,32);d=ImageDraw.Draw(im);ph=k/8*math.pi*2
 # Red lozenge followed by fine dark-violet, blue and crimson filaments.
 for branch in range(4):
  pts=[]
  for x in np.linspace(7,125-branch*7,110):
   t=x/128;y=16+(2.4+branch*.55)*math.sin(t*11-ph+branch*1.65)*math.sin(t*math.pi)
   pts.append((x,y))
  line(d,pts,(17,14,29,155),5 if branch<2 else 2.2)
  line(d,pts,[(60,91,203,185),(120,51,192,175),(168,22,52,165),(64,45,124,130)][branch],1.1 if branch<2 else .65)
 polygon(d,[(2,16),(14,10),(30,12),(38,16),(25,21),(12,21)],(47,9,27,220))
 polygon(d,[(2,16),(15,12),(29,14),(31,16),(18,19),(8,18)],(250,32,49,245))
 line(d,[(3,16),(14,15),(25,16)],(255,157,180,240),.8)
 for j in range(5):
  x=25+((k*13+j*23)%95);y=16+math.sin(j*2+k*.7)*4
  polygon(d,[(x,y),(x+4,y-.6),(x+1,y+1)],(121,66,208,110))
 return im.resize((128,32),Image.Resampling.LANCZOS)

def muzzle(k):
 im=layer(128,64);d=ImageDraw.Draw(im);strength=[1,.95,1,.8,.55,.35,.16,.05][k];shift=k*.14
 # Early cold pin-flash; then a curved red/black recoil fan with a violet rim.
 if k<2:
  polygon(d,[(2,32),(13,22),(18,9),(23,25),(45,32),(24,37),(19,56),(14,41)],(91,118,245,round(210*strength)))
  polygon(d,[(1,32),(16,27),(20,18),(23,28),(36,32),(23,36),(19,46),(15,37)],(244,226,255,245))
 for j in range(4):
  pts=[]
  for t in np.linspace(0,1,80):
   x=4+103*t;y=32+(j-1.5)*(4+10*math.sin(t*math.pi))+(j%2*2-1)*8*math.sin(t*math.pi+shift)
   pts.append((x,y))
  line(d,pts,(15,10,23,round(180*strength)),7.4)
  line(d,pts,(190,16,37,round(220*strength)),2.8)
  if j in [1,2]:line(d,pts,(124,49,201,round(210*strength)),.8)
 polygon(d,[(2,32),(22,25),(53,29),(69,32),(31,37)],(245,35,46,round(215*strength)))
 return im.resize((128,64),Image.Resampling.LANCZOS)

def pressure(k):
 im=layer(32,32);d=ImageDraw.Draw(im);r=5+k*1.35;a=round(210*(1-k/8))
 ellipse(d,(16-r,16-r,16+r,16+r),outline=(85,92,224,a),width=1.5)
 for j in range(4):
  ang=j*math.pi/2+.25;u=(math.cos(ang),math.sin(ang));v=(-u[1],u[0])
  polygon(d,[(16+u[0]*3,16+u[1]*3),(16+u[0]*r+v[0]*1.5,16+u[1]*r+v[1]*1.5),(16+u[0]*(r+3),16+u[1]*(r+3)),(16+u[0]*r-v[0]*1.5,16+u[1]*r-v[1]*1.5)],(219,26,55,a))
 return im.resize((32,32),Image.Resampling.LANCZOS)

def impact(k):
 im=layer(128,128);d=ImageDraw.Draw(im);r=[5,20,39,53,57,59,59,60][k];a=[255,255,245,235,210,160,95,30][k];phase=k*.19
 if k==0:
  polygon(d,[(64,40),(69,59),(89,64),(69,69),(64,87),(59,69),(40,64),(59,59)],(255,215,238,255))
 else:
  ellipse(d,(64-r,64-r,64+r,64+r),fill=(20,13,31,round(a*.38)))
  # Irregular sharp black petals, concentrated along the pressure wave.
  for j in range(11):
   ang=j*math.tau/11+phase;u=np.array([math.cos(ang),math.sin(ang)]);v=np.array([-u[1],u[0]])
   tip=r*(.9+.16*math.sin(j*3.7));wide=r*(.12+.035*math.sin(j))
   pts=[np.array([64,64])+u*r*.19+v*wide,np.array([64,64])+u*tip+v*wide*.23,np.array([64,64])+u*(tip+7),np.array([64,64])+u*r*.6-v*wide,np.array([64,64])+u*r*.16-v*wide*.45]
   polygon(d,pts,(12,10,20,a))
  # Blue/violet pressure ring, with discontinuities and a red inner fracture.
  for j in range(10):
   points=[]
   for ang in np.linspace(j*math.tau/10+.04,(j+1)*math.tau/10-.05,14):points.append((64+math.cos(ang)*r*.82,64+math.sin(ang)*r*.82))
   line(d,points,(63,83,208,round(a*.8)),3.5)
   line(d,points,(125,54,197,round(a*.58)),1.4)
  for j in range(9):
   ang=j*math.tau/9-phase*.5;u=np.array([math.cos(ang),math.sin(ang)]);v=np.array([-u[1],u[0]])
   pts=[np.array([64,64])+u*r*.35+v*1.6,np.array([64,64])+u*r*.87+v*2,np.array([64,64])+u*r*1.01,np.array([64,64])+u*r*.53-v*1.2]
   polygon(d,pts,(247,33,50,a))
  rr=r*(.35+.04*k);ellipse(d,(64-rr,64-rr,64+rr,64+rr),fill=(14,9,22,round(a*.8)),outline=(205,23,51,a),width=1.6)
  for j in range(3):
   pts=[(64+math.cos(t+phase+j*1.7)*rr*(.6+.1*j),64+math.sin(t+phase+j*1.7)*rr*(.6+.1*j)) for t in np.linspace(0,math.pi*1.5,50)]
   line(d,pts,(225,22,46,round(a*.8)),1)
  if k<3:
   polygon(d,[(64,54),(68,61),(77,64),(68,67),(64,76),(61,67),(52,64),(61,61)],(255,181,219,a))
 return im.resize((128,128),Image.Resampling.LANCZOS)

for i in range(8):
 atlas.paste(impact(i),((i%4)*128,(i//4)*128))
 atlas.paste(flight(i),((i%4)*128,256+(i//4)*32))
 atlas.paste(muzzle(i),((i%4)*128,320+(i//4)*64))
 atlas.paste(pressure(i),(192+i*32,448))
d=ImageDraw.Draw(atlas)
d.polygon([(3,480),(25,454),(52,463),(61,477),(45,494),(20,500)],fill=palette[0]+(255,));d.polygon([(3,480),(28,463),(52,472),(45,481),(18,490)],fill=palette[3]+(255,));d.line([(5,480),(27,474),(43,476)],fill=(255,103,135,255),width=2)
for i,c in enumerate(palette):d.rectangle((64+i*16,448,79+i*16,463),fill=c+(255,))
bio=io.BytesIO();atlas.save(bio,format='PNG');raw=bio.getvalue();(O/'爆裂黎明_原作弹道与轰击_阶段图集.png').write_bytes(raw)
tex=dict(uuid=uid(),id='0',name='爆裂黎明_原作弹道与轰击_阶段图集.png',source='data:image/png;base64,'+base64.b64encode(raw).decode(),width=512,height=512,uv_width=512,uv_height=512,mode='bitmap',render_mode='default',render_sides='auto',force_translucent=True,frame_time=1,frame_order_type='loop',frame_order='',frame_interpolate=False,internal=True,saved=True,visible=True)

def asset(name):return dict(meta={'format_version':'5.0','model_format':'free','box_uv':False,'bone_rig':True},name=name,resolution={'width':512,'height':512},elements=[],groups=[],outliner=[],textures=[copy.deepcopy(tex)],animations=[],display={})
def group(b,name,parent=None,gid=None):
 g=dict(uuid=gid or uid(),name=name,origin=[0,0,0],rotation=[0,0,0],visibility=True,export=True,isOpen=True);n=dict(uuid=g['uuid'],children=[],isOpen=True);b['groups'].append(g);(b['outliner'] if parent is None else parent['children']).append(n);return g,n
def cube(b,n,name,lo,hi,uv,plane=None,reverse=False):
 e=dict(uuid=uid(),name=name,type='cube',to=list(hi),origin=[0,0,0],rotation=[0,0,0],visibility=True,export=True,rescale=False,shade=False,light_emission=12,faces={});e['from']=list(lo)
 u,v,U,V=uv
 for side in ['north','south','east','west','up','down']:
  active=plane is None or side in {'xy':['north','south'],'yz':['east','west'],'xz':['up','down']}[plane]
  f={'texture':0 if active else None,'uv':[u,v,U,V]}
  if plane=='yz':f['uv']=[U,v,u,V] if (side=='east')^reverse else [u,v,U,V]
  elif plane=='xz':f['rotation']=(270 if reverse else 90) if side=='up' else (90 if reverse else 270)
  e['faces'][side]=f
 b['elements'].append(e);n['children'].append(e['uuid']);return e
def anim(name,length,loop='once'):return dict(uuid=uid(),name=name,length=length,loop=loop,override=False,snapping=100,selected=False,animators={})
def keys(a,g,channel,points,step=True):
 an=a['animators'].setdefault(g['uuid'],dict(name=g['name'],type='bone',rotation_global=False,quaternion_interpolation=False,keyframes=[]))
 for t,vec in sorted(points):an['keyframes'].append(dict(uuid=uid(),channel=channel,time=round(t,6),data_points=[{ax:str(float(v)) for ax,v in zip('xyz',vec)}],interpolation='step' if step else 'linear',color=-1))
def gate(a,g,points):keys(a,g,'scale',[(t,[v]*3) for t,v in points])
def phases(a,groups,loop=False):
 for i,g in enumerate(groups):
  pts={0:1 if i==0 else 0,a['length']:1 if loop and i==0 else 0}
  for base in ([0,.4] if loop else [0]):
   if base+i*.05<a['length']:pts[round(base+i*.05,6)]=1
   if base+(i+1)*.05<=a['length']:pts[round(base+(i+1)*.05,6)]=0
  if loop and i==0:pts[a['length']]=1
  gate(a,g,list(pts.items()))

oldarrow=load(S/'爆裂黎明_红黑箭矢_分组可编辑动画.bbmodel');oldmuzzle=load(S/'爆裂黎明_枪口轰焰_分组可编辑动画.bbmodel')
arrow=asset('爆裂黎明_赤红弹头与紫蓝尾流_分组可编辑动画');ar,arn=group(arrow,'箭矢_飞行挂点',gid=oldarrow['groups'][0]['uuid']);core,cn=group(arrow,'箭矢_细弹芯与刃片',arn,gid=oldarrow['groups'][1]['uuid'])
cube(arrow,cn,'黑色细弹芯',[-.16,-.16,-3.6],[.16,.16,3.6],[67,451,75,459]);cube(arrow,cn,'赤红细弹芯',[-.085,-.19,-4.1],[.085,-.16,3.0],[131,451,139,459])
cube(arrow,cn,'赤黑刃形弹头_横',[-1.25,-.035,-7.2],[1.25,.035,-1.1],[0,448,64,512],'xz');cube(arrow,cn,'赤黑刃形弹头_竖',[-.035,-1.25,-7.2],[.035,1.25,-1.1],[0,448,64,512],'yz')
ags=[]
for i in range(8):
 g,n=group(arrow,f'尾流阶段_{i+1:02}',arn);ags.append(g);uv=[(i%4)*128,256+(i//4)*32,(i%4)*128+128,288+(i//4)*32]
 cube(arrow,n,f'紫蓝尾流横片_{i}',[-2.3,-.035,-5.8],[2.3,.035,21.5],uv,'xz');cube(arrow,n,f'紫蓝尾流竖片_{i}',[-.035,-2.3,-5.8],[.035,2.3,21.5],uv,'yz')
ac=anim('01_弹头与尾流循环',.8,'loop');phases(ac,ags,True);arrow['animations']=[ac]

muzzle=asset('爆裂黎明_红黑反冲轰焰_分组可编辑动画');mr,mrn=group(muzzle,'枪口轰焰_挂点',gid=oldmuzzle['groups'][0]['uuid']);mgs=[]
for i in range(8):
 g,n=group(muzzle,f'轰焰阶段_{i+1:02}',mrn);mgs.append(g);uv=[(i%4)*128,320+(i//4)*64,(i%4)*128+128,384+(i//4)*64]
 cube(muzzle,n,f'红黑反冲横片_{i}',[-8,-.035,-16],[8,.035,-.2],uv,'xz',True);cube(muzzle,n,f'红黑反冲竖片_{i}',[-.035,-8,-16],[.035,8,-.2],uv,'yz',True)
 cube(muzzle,n,f'紫蓝枪口压力环_{i}',[-6.4,-6.4,-1.235],[6.4,6.4,-1.165],[192+i*32,448,224+i*32,480],'xy')
mc=anim('01_枪口冷闪与红黑反冲',.4);phases(mc,mgs);muzzle['animations']=[mc]

impact=asset('爆裂黎明_红黑裂爆与紫蓝冲击_分组可编辑动画');ir,irn=group(impact,'命中裂爆_独立触发');igs=[]
for i in range(8):
 g,n=group(impact,f'裂爆阶段_{i+1:02}',irn);igs.append(g);u=(i%4)*128;v=(i//4)*128;uv=[u,v,u+128,v+128]
 cube(impact,n,f'命中裂爆正片_{i}',[-18,-18,-.035],[18,18,.035],uv,'xy')
 cube(impact,n,f'命中裂片侧片_{i}',[-.035,-11,-11],[.035,11,11],[u+25,v+25,u+103,v+103],'yz')
 cube(impact,n,f'命中冲击水平片_{i}',[-18,-.035,-18],[18,.035,18],uv,'xz')
ic=anim('01_命中冷闪_裂爆_余烬',.4);phases(ic,igs);impact['animations']=[ic]
for b in [arrow,muzzle,impact]:save(b,O/(b['name']+'.bbmodel'))

# Replace only the prior arrow and muzzle in the saved complete held rig.
a=load(S/'爆裂黎明_悬片与流动背效_分组可编辑动画.bbmodel');old=copy.deepcopy(a)
eids={e['uuid'] for b in [oldarrow,oldmuzzle] for e in b['elements']};gids={g['uuid'] for b in [oldarrow,oldmuzzle] for g in b['groups']}
old_ar=next(g for g in a['groups'] if g['uuid']==ar['uuid']);old_mr=next(g for g in a['groups'] if g['uuid']==mr['uuid']);launch=np.array(old_ar['origin']);pre=np.array(old_mr['origin'])
a['elements']=[e for e in a['elements'] if e['uuid'] not in eids];a['groups']=[g for g in a['groups'] if g['uuid'] not in gids]
def detach(nodes):
 for n in nodes:
  if isinstance(n,dict):n['children']=[c for c in n['children'] if not isinstance(c,dict) or c['uuid'] not in gids];detach([c for c in n['children'] if isinstance(c,dict)])
a['outliner']=[n for n in a['outliner'] if n['uuid'] not in gids];detach(a['outliner'])
for an in a['animations']:an['animators']={k:v for k,v in an['animators'].items() if k not in gids or k==ar['uuid']}
a['textures'].append(copy.deepcopy(tex));a['textures'][-1]['id']='4';a['name']=AP[:-8]
def map_asset(b,scale,point,rotation=None):
 q=copy.deepcopy(b)
 for e in q['elements']:
  for k in ['from','to','origin']:e[k]=(np.array(e[k])*scale+point).tolist()
  for f in e['faces'].values():
   if f.get('texture') is not None:f['texture']=4
 for g in q['groups']:g['origin']=(np.array(g['origin'])*scale+point).tolist()
 if rotation:q['groups'][0]['rotation']=rotation
 return q
qa=map_asset(arrow,.8,launch,old_ar['rotation']);qm=map_asset(muzzle,.72,pre,old_mr['rotation'])
tip=np.array([0,0,-7.2*.8]);angle=math.radians(-1.1);R=np.array([[1,0,0],[0,math.cos(angle),-math.sin(angle)],[0,math.sin(angle),math.cos(angle)]])
hit=launch+np.array([0,-.998267,-51.990417])+R@tip
qi=map_asset(impact,1,hit)
for q in [qa,qm,qi]:a['elements']+=q['elements'];a['groups']+=q['groups']
a['outliner']+=qa['outliner']+qi['outliner']
frame=next(g for g in a['groups'] if g['name']=='12_炮口金属框')
def attach(nodes):
 for n in nodes:
  if n['uuid']==frame['uuid']:n['children']+=qm['outliner'];return True
  if attach([c for c in n['children'] if isinstance(c,dict)]):return True
 return False
assert attach(a['outliner'])
target,tn=group(a,'审阅靶位_仅命中演示')
target['origin']=hit.tolist();te=cube(a,tn,'灰色演示靶位',(hit+[-4.5,-10,-4]).tolist(),(hit+[4.5,10,0]).tolist(),[81,451,89,459]);
for f in te['faces'].values():f['texture']=4
te['light_emission']=0
def copied_phases(target,source,length,offset=0):
 for gid,an in source['animators'].items():
  q=copy.deepcopy(an);q['keyframes']=[{**k,'time':round(k['time']+offset,6)} for k in q['keyframes'] if k['time']+offset<=length]
  target['animators'][gid]=q
for i,an in enumerate(a['animations']):
 gate(an,ir,[(0,0)]);gate(an,target,[(0,0)])
 if i in [2,5]:
  copied_phases(an,ac,an['length']);copied_phases(an,mc,an['length']);gate(an,mr,[(0,1),(.4,0),(an['length'],0)])
 else:gate(an,mr,[(0,0)])
demo=copy.deepcopy(a['animations'][5]);demo.update(uuid=uid(),name='08_弹道与命中演示',length=1.2)
demo['animators'].pop(ir['uuid']);demo['animators'].pop(target['uuid']);gate(demo,ir,[(0,0),(.36,1),(.76,0),(1.2,0)]);gate(demo,target,[(0,1)])
copied_phases(demo,ic,1.2,.36)
# The separate demonstration hit hides the bolt on contact. No automatic hit in
# ordinary or skill-shot clips; actual runtime hit will trigger the impact asset.
root_anim=demo['animators'][ar['uuid']];root_anim['keyframes']=[k for k in root_anim['keyframes'] if k['channel']!='scale'];gate(demo,ar,[(0,0),(.02,1),(.36,0),(1.2,0)])
a['animations'].append(demo);save(a,O/AP)

# Preserve accepted back sources byte-for-byte, including its Display entry.
for name in ['爆裂黎明_悬片流动背效_分组可编辑动画.bbmodel','爆裂黎明_悬片背效_整体Display调整.bbmodel','爆裂黎明_上下两段残焰_动态材质.png']:shutil.copy2(S/name,O/name)
oldassets=S/'审阅资源/assets/sweetdream';newassets=O/'审阅资源/assets/sweetdream'
for rel in ['models/item/burst_dawn_vfx_v4/back.json','textures/item/burst_dawn_vfx_v4/flow.png','textures/item/burst_dawn_vfx_v4/flow.png.mcmeta']:
 p=newassets/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(oldassets/rel,p)

def export(b,slug,title,phase):
 native=O/(b['name']+'.bbmodel');r=load_renderer(native);visible={e['uuid'] for e,v,m in r['scene'](phase*.05+.001,0)}
 q=copy.deepcopy(b);q.update(name=title,animations=[]);q['meta'].update(model_format='java_block',bone_rig=False);q['elements']=[e for e in q['elements'] if e['uuid'] in visible]
 # Keep all meaningful parent/core groups; drop hidden mutually exclusive phases.
 def trim(n):
  kids=[trim(c) if isinstance(c,dict) else c for c in n['children'] if isinstance(c,dict) or c in visible];return {'uuid':n['uuid'],'isOpen':True,'children':[c for c in kids if not isinstance(c,dict) or c['children']]}
 q['outliner']=[trim(n) for n in q['outliner']];keep=set()
 def collect(n):
  keep.add(n['uuid'])
  for c in n['children']:
   if isinstance(c,dict):collect(c)
 for n in q['outliner']:collect(n)
 q['groups']=[g for g in q['groups'] if g['uuid'] in keep];factor=.75
 q['display']={'gui':{'rotation':[10,-25,0],'translation':[0,0,0],'scale':[.7/factor]*3},'thirdperson_righthand':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[1/factor]*3}}
 for e in q['elements']:
  for k in ['from','to','origin']:e[k]=[round(v*factor+8,6) for v in e[k]]
 for g in q['groups']:g['origin']=[round(v*factor+8,6) for v in g['origin']]
 save(q,O/(title+'.bbmodel'))
 # Export eight legal phase models with static source UVs and shared geometry.
 def model(elements):
  out=[]
  for e in elements:
   z={'from':[round(v*.75+8,6) for v in e['from']],'to':[round(v*.75+8,6) for v in e['to']],'light_emission':e.get('light_emission',0),'faces':{}}
   assert all(-16<=v<=32 for v in z['from']+z['to'])
   assert e['rotation']==[0,0,0]
   for side,f in e['faces'].items():
    if f.get('texture') is None:continue
    z['faces'][side]={'texture':'#0','uv':[v/32 for v in f['uv']]}
    if f.get('rotation'):z['faces'][side]['rotation']=f['rotation']
   out.append(z)
  return {'credit':'阶段八未部署审阅资产','ambientocclusion':False,'textures':{'0':'sweetdream:item/burst_dawn_ballistics_v1/fx','particle':'sweetdream:item/burst_dawn_ballistics_v1/fx'},'elements':out,'display':q['display']}
 md=newassets/'models/item/burst_dawn_ballistics_v1';md.mkdir(parents=True,exist_ok=True)
 for i in range(8):
  ids={e['uuid'] for e,v,m in r['scene'](i*.05+.001,0)};save(model([e for e in b['elements'] if e['uuid'] in ids]),md/f'{slug}_{i:02}.json')
 save(model([e for e in b['elements'] if e['uuid'] in visible]),md/f'{slug}.json')
for b,slug,title in [(arrow,'arrow','爆裂黎明_原作箭矢_整体Display调整'),(muzzle,'muzzle','爆裂黎明_反冲轰焰_整体Display调整'),(impact,'impact','爆裂黎明_命中裂爆_整体Display调整')]:export(b,slug,title,3)
td=newassets/'textures/item/burst_dawn_ballistics_v1';td.mkdir(parents=True,exist_ok=True);(td/'fx.png').write_bytes(raw)
stats={'source_stage':S.name,'source_sha256':sha(S/'爆裂黎明_悬片与流动背效_分组可编辑动画.bbmodel'),'accepted_back_sha256':sha(S/'爆裂黎明_悬片流动背效_分组可编辑动画.bbmodel'),'reference_frames':{'muzzle':[36,38,40],'flight':[40,42,44],'impact':[44,46,48,50,52,54,57,61]},'phase_atlas_size':[512,512],'phases_per_effect':8,'phase_duration':.05,'one_shot_event_phase_reset_via_native_gates':True,'arrow_authoring':len(arrow['elements']),'arrow_visible':6,'muzzle_authoring':24,'muzzle_visible':3,'impact_authoring':24,'impact_visible':3,'assembly_cubes':len(a['elements']),'assembly_groups':len(a['groups']),'assembly_textures':len(a['textures']),'assembly_clips':len(a['animations']),'demo_hit_time':.36,'demo_hit_position':hit.tolist(),'demo_target_only':True,'runtime_damage_and_shot_timing_unchanged':True,'game_deployed':False}
save(stats,O/'弹道轰击统计与来源.json');print(json.dumps(stats,ensure_ascii=False),flush=True)
