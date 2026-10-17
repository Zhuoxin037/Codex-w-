"""Author only the approved fire-axe head; Blockbench MCP creates the actual project."""
import json, math, random
from pathlib import Path
from collections import Counter
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'模型设计/BOSS_GLB重建_20261016/武器_消防斧'
OUT=BASE/'阶段一_斧头与柄座'
OUT.mkdir(parents=True,exist_ok=True)
VERTS={'north':[(1,1,0),(1,0,0),(0,0,0),(0,1,0)],'south':[(0,1,1),(0,0,1),(1,0,1),(1,1,1)],'east':[(1,1,1),(1,0,1),(1,0,0),(1,1,0)],'west':[(0,1,0),(0,0,0),(0,0,1),(0,1,1)],'up':[(0,1,0),(0,1,1),(1,1,1),(1,1,0)],'down':[(0,0,1),(0,0,0),(1,0,0),(1,0,1)]}
NORMAL={'north':(2,-1),'south':(2,1),'east':(0,1),'west':(0,-1),'up':(1,1),'down':(1,-1)}
PARTS=[]

def cube(name,a,b,group,material):
 PARTS.append(dict(name=name,from_=a,to=b,parent=group,material=material,origin=[0,16,0],box_uv=False,faces={}))

def main():
 # Continuous tapered cheek, with actual increasing thickness behind the cutting edge.
 for i in range(24):
  x=-6.65+i*.24;xx=x+.24;t=(x+xx)/2
  top=18.65-(t+6.65)*.155
  bottom=13.30+(t+6.65)*.338
  if i>=17:bottom=15.48
  depth=.20+1.62*min(1,max(0,(t+6.65)/1.45))+.28*max(0,(t+5.2)/4.3)
  cube(f'blade_cheek_{i:02}',[x,bottom,-depth/2],[xx,top,depth/2],'blade','blade')
 # Curving, heavy pick tapering to a real narrow point; no floating teeth.
 for i in range(18):
  x=1.06+i*.285;xx=x+.285;t=(x+xx)/2;u=(t-1.06)/5.13
  center=16.92-.36*u-1.58*u*u
  h=1.42*(1-u)**.75+.13;d=1.95*(1-u)**.65+.10
  cube(f'pick_forging_{i:02}',[x,center-h/2,-d/2],[xx,center+h/2,d/2],'pick','pick')
 # A hollow four-wall socket, eight separate bevel/rim pieces and a real wooden tenon.
 for side,s in [('front',-1),('back',1)]:
  z0,z1=(-1.26,-.86) if s<0 else (.86,1.26)
  cube(f'eye_{side}_main',[-1.01,14.60,z0],[1.01,17.75,z1],'eye','socket_red')
  for k,(y0,y1) in enumerate([(14.30,14.60),(17.75,18.05)]):
   z0,z1=(-1.38,-.86) if s<0 else (.86,1.38)
   cube(f'eye_{side}_rim_{k}',[-1.20,y0,z0],[1.20,y1,z1],'eye','steel_dark')
  for k,(x0,x1) in enumerate([(-1.23,-1.01),(1.01,1.23)]):
   z0,z1=(-1.14,-.86) if s<0 else (.86,1.14)
   cube(f'eye_{side}_bevel_{k}',[x0,14.60,z0],[x1,17.75,z1],'eye','steel_dark')
 cube('eye_wall_blade',[-1.23,14.30,-.86],[-.85,18.05,.86],'eye','steel_dark')
 cube('eye_wall_pick',[.85,14.30,-.86],[1.23,18.05,.86],'eye','steel_dark')
 cube('ashwood_tenon',[-.82,12.45,-.83],[.82,18.43,.83],'tenon','wood')
 cube('steel_wedge',[-.055,18.38,-.67],[.055,18.51,.67],'tenon','steel_bright')
 for side,s in [('front',-1),('back',1)]:
  z0,z1=(-.99,-.81) if s<0 else (.81,.99)
  cube(f'langet_{side}',[-.28,13.38,z0],[.28,14.53,z1],'retainers','steel_dark')
  z0,z1=(-1.075,-.98) if s<0 else (.98,1.075)
  cube(f'pin_{side}',[-.11,13.72,z0],[.11,13.95,z1],'retainers','steel_bright')
 # Cull faces contained in / flush against the union of the remaining boxes.
 # Nine regularly-spaced samples, inset from polygon edges, prevent seam false positives.
 for i,e in enumerate(PARTS):
  lo=np.array(e['from_']);hi=np.array(e['to'])
  for name,v in VERTS.items():
   q=np.array(v)*(hi-lo)+lo;ax,sg=NORMAL[name];pts=[]
   for u in [.05,.5,.95]:
    for v_ in [.05,.5,.95]:pts.append(q[0]*(1-u)*(1-v_)+q[3]*u*(1-v_)+q[1]*(1-u)*v_+q[2]*u*v_)
   pts=np.array(pts);pts[:,ax]+=sg*.0005;inside=np.zeros(9,bool)
   for j,other in enumerate(PARTS):
    if j==i:continue
    inside|=np.all((pts>=np.array(other['from_'])-1e-7)&(pts<=np.array(other['to'])+1e-7),axis=1)
   e['faces'][name]={'texture':None} if np.all(inside) else {}
 # A continuous world-space pixel painting gives neighbouring slabs coherent wear/blood.
 density=12
 fields={}
 for side in ['front','back']:
  rng=random.Random(722 if side=='front' else 723)
  im=Image.new('RGB',(192,120));a=np.array(im)
  for yy in range(120):
   for xx in range(192):
    x=xx/density-8;y=21-yy/density
    coarse=(math.sin(math.floor(x*3)*8.4+math.floor(y*3)*5.7)+math.sin(math.floor(x*7)*1.3-math.floor(y*7)*2.7))*3
    a[yy,xx]=np.clip(np.array([158,44,32])+coarse,0,255)
  im=Image.fromarray(a);dr=ImageDraw.Draw(im)
  # Chipped enamel, concentrated near the profile and socket; connected small islands.
  for _ in range(210):
   x=rng.randint(0,191);y=rng.randint(0,119);w=rng.choice([1,1,2,3]);h=rng.choice([1,1,2,4])
   c=rng.choice(['#6c6057','#625852','#96877a','#b3422f','#c34b32'])
   dr.rectangle((x,y,x+w,y+h),fill=c)
  for _ in range(65):
   x=rng.randint(0,191);y=rng.randint(0,119)
   dr.line((x,y,x+rng.choice([-3,-2,2,4]),y+rng.choice([0,1,2])),fill='#c16a50',width=1)
  fields[side]=np.array(im)
 # Blood is a separate coordinate field, applied to steel and cheek without raised geometry.
 blood={}
 for side in ['front','back']:
  rng=random.Random(420 if side=='front' else 421);im=Image.new('RGBA',(192,120));dr=ImageDraw.Draw(im)
  def splat(x,y,r,col):
   px=(x+8)*density;py=(21-y)*density;dr.ellipse((px-r,py-r*.7,px+r,py+r*.7),fill=col)
  for cx,cy,rad in [(-6.35,14.55,9),(-5.92,15.00,6),(-6.50,15.65,4),(-5.2,14.48,3),(-5.55,16.05,3)]:
   for _ in range(14):
    splat(cx+rng.gauss(0,.25),cy+rng.gauss(0,.3),rng.uniform(1,rad),rng.choice(['#3f1c18','#50201b','#64261d','#702a20']))
  for _ in range(100):splat(rng.uniform(-6.65,-3.65),rng.uniform(13.4,17.6),rng.choice([.5,.6,1,1.4]),rng.choice(['#481b18','#65251d','#7a3023']))
  for _ in range(8):
   x=rng.uniform(-6.5,-5.1);y=rng.uniform(14.4,15.7);px=(x+8)*density;py=(21-y)*density
   dr.line((px,py,px+rng.choice([-1,0,1]),py+rng.randint(2,7)),fill='#5b231b',width=1)
  blood[side]=np.array(im)

 def color(p,material,face):
  x,y,z=p;ix=int(math.floor(x*12));iy=int(math.floor(y*12));iz=int(math.floor(z*12))
  h=math.sin(ix*127.1+iy*311.7+iz*67.4)*43758.5453;noise=(h-math.floor(h)-.5)
  coarse=math.sin(math.floor(x*3)*13+math.floor(y*3)*7+math.floor(z*3)*3)*3
  if material in ['blade','pick','socket_red']:
   side='front' if z<0 else 'back';xx=max(0,min(191,int((x+8)*12)));yy=max(0,min(119,int((21-y)*12)))
   c=fields[side][yy,xx].astype(float)
   # Long bright silver bevel; thickness comes from the geometry, not this paint edge.
   u=max(0,min(1,(x-1.06)/5.13));pick_center=16.92-.36*u-1.58*u*u;pick_h=1.42*(1-u)**.75+.13
   bare=(material=='blade' and x < -5.45 + .11*math.sin(y*3)) or (material=='pick' and (x>5.20 or (face in ['north','south'] and y>pick_center+pick_h/2-.16)))
   if bare:
    grain=math.sin(iy*.75+math.floor(x*24)*1.3)*6
    c=np.array([177,171,158])+coarse+grain+noise*11
    if (ix+3*iy)%43==0:c+=25
   else:c+=noise*5
   if material=='blade' and face in ['north','south','west','down']:
    b=blood[side][yy,xx]
    if b[3]:c=b[:3].astype(float)+noise*5
  elif material=='wood':
   grain=math.sin(ix*2.15+math.floor(y*2)*.35+iz*1.3)*8
   c=np.array([131,93,58])+coarse+grain+noise*7
   if face=='up':c=np.array([158,123,83])+math.sin(math.hypot(x,z)*50)*9+noise*5
  else:
   c=np.array([63,60,55] if material=='steel_dark' else [147,140,127])+coarse+noise*8
   if (abs(x)>.99 or face in ['up','east']) and (ix+iy*3)%11<3:c+=18
  return np.r_[np.clip(c,0,255).astype(np.uint8),255]
 # Shelf packing with one-pixel repeated gutters. Keeps face UVs entirely in-bounds.
 atlas=Image.new('RGBA',(256,256),(0,0,0,0));px=1;py=1;row=0;visible=0
 islands=[]
 for e in PARTS:
  lo=np.array(e['from_']);hi=np.array(e['to'])
  for face,data in e['faces'].items():
   if data.get('texture','visible') is None:continue
   q=np.array(VERTS[face])*(hi-lo)+lo
   w=max(1,int(math.ceil(np.linalg.norm(q[3]-q[0])*10)));h=max(1,int(math.ceil(np.linalg.norm(q[1]-q[0])*10)))
   islands.append((e,face,data,q,w,h))
 for e,face,data,q,w,h in sorted(islands,key=lambda t:(-t[5],-t[4])):
   if px+w+1>256:px=1;py+=row+2;row=0
   if py+h+1>256:raise RuntimeError(f'Atlas full at {e["name"]} {face}: {py+h}')
   tile=np.zeros((h,w,4),np.uint8)
   for v in range(h):
    for u in range(w):
     a=(u+.5)/w;b=(v+.5)/h;p=q[0]*(1-a)*(1-b)+q[3]*a*(1-b)+q[1]*(1-a)*b+q[2]*a*b
     tile[v,u]=color(p,e['material'],face)
   padded=np.pad(tile,((1,1),(1,1),(0,0)),mode='edge');atlas.paste(Image.fromarray(padded),(px-1,py-1))
   data.update(uv=[px,py,px+w,py+h],texture='fireaxe_head');visible+=1;px+=w+2;row=max(row,h)
 atlas.save(OUT/'fireaxe_head_256.png')
 payload=[]
 for e in PARTS:
  d={k:v for k,v in e.items() if k not in ['material','from_']};d['from']=e['from_'];payload.append(d)
 (OUT/'建模参数_初建用.json').write_text(json.dumps({'cubes':payload,'counts':dict(Counter(e['parent'] for e in PARTS))},ensure_ascii=False,indent=2),encoding='utf8')
 # Crop only the accepted concept's orthographic head for the partial-stage silhouette check.
 ref=Image.open(BASE/'概念设计/消防斧_概念图.png').convert('RGBA');ref=ref.crop((731,32,982,164));arr=np.array(ref)
 # Neutral grey backdrop is excluded for measurement only; the original image remains untouched.
 rgb=arr[:,:,:3];fg=(rgb.max(2)-rgb.min(2)>18)|((rgb.mean(2)>100)&(np.indices(rgb.shape[:2])[0]<120));arr[:,:,3]=fg.astype(np.uint8)*255
 Image.fromarray(arr).save(OUT/'参考裁切_斧头.png')
 print(json.dumps({'cubes':len(PARTS),'visible_faces':visible,'disabled_faces':len(PARTS)*6-visible,'groups':dict(Counter(e['parent'] for e in PARTS)),'atlas_used_height':py+row+1,'out':str(OUT)},ensure_ascii=False))

if __name__=='__main__':main()
