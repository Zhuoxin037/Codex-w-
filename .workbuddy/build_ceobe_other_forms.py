"""Build the two explicitly requested forms from the user-provided operator sheet."""
from pathlib import Path
from PIL import Image,ImageDraw
from collections import deque
import numpy as np
import json,uuid,math,base64,io,hashlib
BASE=Path('D:/数据包/模型设计/很冰的斧_建模_20261016')
OUT=BASE/'阶段一_刀枪形态';OUT.mkdir(exist_ok=True)
REF=BASE/'参考资料';sheet=Image.open(REF/'用户提供_刻俄柏设定图.jpg').convert('RGB')
ICE=BASE/'阶段一_设定图修订/很冰的斧_设定图修订_分组可编辑.bbmodel'
ice_hash=hashlib.sha256(ICE.read_bytes()).hexdigest()
PAL={'dark':(58,42,42),'blade':(76,54,52),'steel':(121,114,104),'edge':(190,182,168),'copper':(144,111,66),'gold':(184,152,93),'light':(209,204,187),'black':(36,31,31),'pin':(94,82,65)}
FACES=['north','south','east','west','up','down']
def largest(mask):
 seen=np.zeros(mask.shape,bool);best=[]
 for y,x in zip(*np.where(mask)):
  if seen[y,x]:continue
  q=deque([(y,x)]);seen[y,x]=True;c=[]
  while q:
   j,i=q.popleft();c.append((j,i))
   for dy,dx in [(1,0),(-1,0),(0,1),(0,-1)]:
    a,b=j+dy,i+dx
    if 0<=a<mask.shape[0] and 0<=b<mask.shape[1] and mask[a,b] and not seen[a,b]:seen[a,b]=True;q.append((a,b))
  if len(c)>len(best):best=c
 out=np.zeros(mask.shape,bool)
 for j,i in best:out[j,i]=True
 return out
def fill_holes(mask):
 outside=np.zeros(mask.shape,bool);q=deque([(0,0)])
 while q:
  j,i=q.popleft()
  if not(0<=j<mask.shape[0] and 0<=i<mask.shape[1]) or mask[j,i] or outside[j,i]:continue
  outside[j,i]=True;q.extend([(j-1,i),(j+1,i),(j,i-1),(j,i+1)])
 return ~outside
def erosion(m):
 p=np.pad(m,1);return np.logical_and.reduce([p[1+y:1+y+m.shape[0],1+x:1+x+m.shape[1]] for x,y in [(1,0),(-1,0),(0,1),(0,-1)]])
def rects(data):
 data=dict(data)
 while data:
  u,v=min(data,key=lambda x:(x[1],x[0]));key=data[(u,v)];w=1
  while data.get((u+w,v))==key:w+=1
  h=1
  while all(data.get((a,v+h))==key for a in range(u,u+w)):h+=1
  for b in range(v,v+h):
   for a in range(u,u+w):del data[a,b]
  yield u,v,w,h,key
class Model:
 def __init__(self,code,name,grip):
  self.code=code;self.name=name;self.grip=list(grip);self.e=[];self.g={};self.path=OUT/name;self.path.mkdir(exist_ok=True)
  self.img=Image.new('RGBA',(512,512),PAL['dark']+(255,));self.tiles={}
  rng=np.random.default_rng(1018)
  arr=np.array(self.img)
  for i,(n,c) in enumerate(PAL.items()):
   x=256+(i%4)*64;y=(i//4)*72;self.tiles[n]=(x,y);arr[y:y+64,x:x+64,:3]=np.clip(np.array(c)+rng.normal(0,.85,(64,64,1)),0,255)
  self.img=Image.fromarray(arr);self.group('weapon_root',None,grip)
 def uid(self,s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'ceobe/'+self.code+'/'+s))
 def group(self,n,parent='weapon_root',origin=None):
  self.g[n]={'name':n,'uuid':self.uid('group/'+n),'origin':list(origin or self.grip),'rotation':[0,0,0],'children':[],'visibility':True,'export':True}
  if parent:self.g[parent]['children'].append(self.g[n])
  return n
 def cube(self,n,lo,hi,g,mat='dark',rot=None,pivot=None,uv=None):
  n=n+'_'+str(len(self.e));lo=[round(float(x),6) for x in lo];hi=[round(float(x),6) for x in hi]
  tx,ty=self.tiles[mat];faces={s:{'texture':0,'uv':[tx+4,ty+4,tx+29,ty+28]} for s in FACES}
  if uv:
   u=uv(lo,hi);faces['north']['uv']=[u[2],u[1],u[0],u[3]];faces['south']['uv']=u
  e={'name':n,'uuid':self.uid(n),'type':'cube','from':lo,'to':hi,'origin':list(pivot or [(a+b)/2 for a,b in zip(lo,hi)]),'rotation':rot or [0,0,0],'faces':faces,'visibility':True,'export':True,'autouv':0}
  self.e.append(e);self.g[g]['children'].append(e['uuid']);return e
 def octpole(self,n,lo,hi,r,g,mat='gold',cx=0,cz=0):
  d=r*(math.sqrt(2)-1);c=(r+3*d)/4;t=(r-d)/math.sqrt(2);h=(r-d)/(2*math.sqrt(2))
  self.cube(n+'_cross_a',[cx-r,lo,cz-d],[cx+r,hi,cz+d],g,mat)
  self.cube(n+'_cross_b',[cx-d,lo+.031,cz-r],[cx+d,hi-.027,cz+r],g,mat)
  for sx,sz,ang in [(1,1,45),(-1,1,-45),(-1,-1,45),(1,-1,-45)]:
   x=cx+sx*c;z=cz+sz*c
   self.cube(n+'_bevel',[x-t,lo+.045,z-h],[x+t,hi-.041,z+h],g,mat,[0,ang,0],[x,0,z])
 def save(self,display,animations=()):
  def tree(g):return {'uuid':g['uuid'],'isOpen':True,'children':[tree(c) if isinstance(c,dict) else c for c in g['children']]}
  groups=[{k:v for k,v in g.items() if k!='children'} for g in self.g.values() if g['children']]
  # All created groups below are populated. Keep the native hierarchy as constructed.
  b=io.BytesIO();self.img.save(b,format='PNG');self.img.save(self.path/(self.code+'_512.png'))
  tex={'name':self.code+'_512.png','uuid':self.uid('texture'),'id':'0','source':'data:image/png;base64,'+base64.b64encode(b.getvalue()).decode(),'uv_width':512,'uv_height':512,'width':512,'height':512,'render_mode':'default'}
  bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':self.name+'_分组可编辑','resolution':{'width':512,'height':512},'groups':groups,'elements':self.e,'outliner':[tree(self.g['weapon_root'])],'textures':[tex],'animations':list(animations)}
  for e in self.e:
   assert all(a<b for a,b in zip(e['from'],e['to'])),e['name']
   assert all(-24<=v<=24 for v in e['from']+e['to']),e['name']
  p=self.path/(self.name+'_分组可编辑.bbmodel');p.write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
  (self.path/'统一Display.json').write_text(json.dumps(display,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
  print(json.dumps({'name':self.name,'cubes':len(self.e),'groups':len(groups),'path':str(p)},ensure_ascii=False));return bb

def display(scale,grip_y,gui,first=None):
 first=first or scale
 return {'thirdperson_righthand':{'rotation':[0,90,0],'translation':[0,-grip_y*scale,1],'scale':[scale]*3},'thirdperson_lefthand':{'rotation':[0,-90,0],'translation':[0,-grip_y*scale,1],'scale':[scale]*3},'firstperson_righthand':{'rotation':[0,90,-10],'translation':[1.6,-grip_y*first,1.0],'scale':[first]*3},'firstperson_lefthand':{'rotation':[0,-90,10],'translation':[1.6,-grip_y*first,1.0],'scale':[first]*3},'gui':{'rotation':[0,0,-25],'translation':[0,0,0],'scale':[gui]*3},'ground':{'rotation':[0,0,80],'translation':[0,2,0],'scale':[scale*.75]*3},'fixed':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[scale]*3}}

def knife():
 m=Model('hot_knife','很热的刀_双刃短剑',(0,-8.2,0))
 for g in ['blade_body','cutting_edges','central_ridge','ricasso','guard','grip_ferrules','waisted_grip','copper_pommel']:m.group(g)
 im=sheet.crop((102,890,544,940)).rotate(270,expand=True);rgb=np.array(im);mask=fill_holes(largest(rgb.mean(axis=2)<211))
 raw=np.array(im.convert('RGBA'));raw[:,:,3]=mask.astype('uint8')*255;Image.fromarray(raw).save(REF/'热刀_独立透明参考.png')
 arr=np.array(m.img);cells={};S=.0625;AX=25;V=222
 for v in range(mask.shape[0]):
  us=np.where(mask[v])[0]
  if not len(us):continue
  a,b=us.min(),us.max();cen=(a+b)/2;radius=max(.5,(b-a+1)/2)
  for u in us:
   f=abs(u+.5-cen)/radius
   if v<299:
    tier=0 if f>.76 else 1 if f>.35 else 2;t=[.13,.48,.84][tier];g=['cutting_edges','blade_body','central_ridge'][tier];mat=['edge','blade','dark'][tier]
    t*=min(1,.35+v/70)
    # Quantise the pointed taper, so it remains editable and does not duplicate whole frames.
    t=round(t/.025)*.025
   elif v<316:t=.82;g='guard';mat='copper'
   elif v<327:t=.70;g='grip_ferrules';mat='dark'
   elif v<392:t=.52 if f>.68 else .80;g='waisted_grip';mat='light'
   elif v<412:t=.64 if f>.6 else .92;g='grip_ferrules';mat='gold'
   else:t=.72 if f>.65 else 1.06;g='copper_pommel';mat='gold'
   if 288<v<299:g='ricasso';mat='dark'
   cells[u,v]=(t,g,mat)
   c=np.array(PAL[mat],float);c+=math.sin(v*.055)*1.4
   arr[v+4,u*2+4:u*2+6,:3]=np.clip(c,0,255)
 m.img=Image.fromarray(arr)
 def uv(lo,hi):return [(lo[0]/S+AX)*2+4,(V-hi[1]/S)+4,(hi[0]/S+AX)*2+4,(V-lo[1]/S)+4]
 for u,v,w,h,(t,g,mat) in rects(cells):m.cube('knife_'+g,[(u-AX)*S,(V-v-h)*S,-t/2],[(u+w-AX)*S,(V-v)*S,t/2],g,mat,uv=uv)
 # Three real shoulder bevels in the guard, including separate metal ferrules.
 m.octpole('guard_neck',-6.28,-5.95,.41,'grip_ferrules','copper')
 return m.save(display(.53,-8.2,.49,.58))

def spear():
 m=Model('heavy_spear','很重的枪_三段折叠长枪',(0,-5,0))
 for g in ['spear_blade','blade_edges','head_slots','barb','bronze_socket']:m.group(g)
 m.group('shaft_upper',origin=[0,11.8,0]);m.group('shaft_middle','shaft_upper',[0,.8,0]);m.group('shaft_lower','shaft_middle',[0,-10.2,0])
 m.group('hinge_upper','shaft_upper',[0,.8,0]);m.group('hinge_lower','shaft_middle',[0,-10.2,0]);m.group('butt_cap','shaft_lower',[0,-21.2,0])
 im=sheet.crop((586,814,793,858)).rotate(270,expand=True);rgb=np.array(im);mask=largest(rgb.mean(axis=2)<211)
 raw=np.array(im.convert('RGBA'));raw[:,:,3]=mask.astype('uint8')*255;Image.fromarray(raw).save(REF/'重枪_枪头透明参考.png')
 dist=np.zeros(mask.shape,int);z=mask.copy()
 for _ in range(20):dist+=z;z=erosion(z)
 arr=np.array(m.img);cells={};S=.05;AX=27;TOP=22.4
 for v,u in zip(*np.where(mask)):
  d=int(dist[v,u]);t=.15 if d==1 else .48 if d<=3 else .84
  g='blade_edges' if d<=2 else 'spear_blade';mat='edge' if d==1 else 'steel' if d<=3 else 'dark'
  if v>136 and u<17:g='barb';mat='dark';t=.65
  elif 110<v<170 and d<=2:g='head_slots';mat='steel'
  cells[u,v]=(t,g,mat)
  c=np.array(PAL[mat],float)+math.sin(v*.025)*2;arr[v*2:v*2+2,u*3:u*3+3,:3]=np.clip(c,0,255)
 m.img=Image.fromarray(arr)
 def uv(lo,hi):return [(lo[0]/S+AX)*3,(TOP-hi[1])/S*2,(hi[0]/S+AX)*3,(TOP-lo[1])/S*2]
 for u,v,w,h,(t,g,mat) in rects(cells):m.cube('spear_'+g,[(u-AX)*S,TOP-(v+h)*S,-t/2],[(u+w-AX)*S,TOP-v*S,t/2],g,mat,uv=uv)
 # Real octagonal metal stock and flared socket, with shared axes and substantial joints.
 m.octpole('socket_back',11.65,12.55,.38,'bronze_socket','copper')
 m.octpole('socket_body',12.54,14.32,.32,'bronze_socket','gold')
 m.octpole('socket_taper',14.30,15.54,.245,'bronze_socket','gold')
 m.octpole('socket_nose',15.51,16.25,.17,'bronze_socket','copper')
 for a,b,g in [(0.8,11.8,'shaft_upper'),(-10.2,.8,'shaft_middle'),(-21.2,-10.2,'shaft_lower')]:
  m.octpole('pole_segment',a+.08,b-.08,.275,g,'gold')
  for y in [a+.20,b-.20]:m.octpole('sleeve',y-.12,y+.12,.325,g,'copper')
 # Alternating parallel hinge axes permit the three sections to form a compact stack.
 for y,g,sign in [(.8,'hinge_upper',1),(-10.2,'hinge_lower',-1)]:
  m.octpole('joint_body',y-.28,y+.28,.345,g,'dark')
  for side in [-1,1]:
   m.cube('hinge_cheek',[-.37,y-.30,side*.30-.055],[.37,y+.30,side*.30+.055],g,'copper')
   m.cube('hinge_pin',[-.125,y-.125,min(side*.351,side*.435)],[.125,y+.125,max(side*.351,side*.435)],g,'steel',[0,0,45],[0,y,0])
 m.octpole('end_socket',-21.32,-20.96,.34,'butt_cap','copper')
 m.octpole('end_taper',-21.65,-21.28,.24,'butt_cap','gold')
 # Save a genuine native folding demonstration; no claim that vanilla plays this file.
 def frame(t,channel,v):return {'uuid':m.uid(f'key/{t}/{channel}/{v}'),'channel':channel,'time':t,'data_points':[dict(zip('xyz',map(str,v)))],'interpolation':'linear'}
 animators={}
 for gn,sign in [('shaft_middle',1),('shaft_lower',1)]:
  gid=m.g[gn]['uuid'];ks=[]
  for t,r,x in [(0,0,0),(.18,0,0),(.60,95,.22),(1.05,180,.78),(1.35,180,.78),(1.95,0,0),(2.15,0,0)]:
   ks.append(frame(t,'rotation',[0,0,r]));ks.append(frame(t,'position',[-x if gn=='shaft_middle' else x,0,0]))
  animators[gid]={'name':gn,'type':'bone','keyframes':ks}
 anim={'name':'fold_and_extend｜三段折叠演示','uuid':m.uid('animation/fold'),'loop':'once','length':2.15,'snapping':20,'animators':animators}
 return m.save(display(.65,-5,.29,.56),[anim])

for name,fn in [('很热的刀_双刃短剑',knife),('很重的枪_三段折叠长枪',spear)]:
 path=OUT/name/(name+'_分组可编辑.bbmodel')
 if path.exists():raise SystemExit('Existing draft: continue from the saved model, do not regenerate '+str(path))
 fn()
assert hashlib.sha256(ICE.read_bytes()).hexdigest()==ice_hash
(OUT/'冰斧母版保护.json').write_text(json.dumps({'ice_master':str(ICE),'sha256_before_after':ice_hash,'unchanged':True},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
