"""Stage-one sacred relic. Axis-aligned anatomy and articulated bone plates."""
from pathlib import Path
import math,json,uuid,base64,io,collections
import numpy as np
from PIL import Image,ImageDraw,ImageFont
from model_review_io import save_native,check,renderer

ROOT=Path('D:/数据包');OUT=ROOT/'模型设计/圣骸_建模_20261012/阶段一_骸骨核心与肋刃'
OUT.mkdir(parents=True,exist_ok=True)
if (OUT/'圣骸_阶段一_分组模型.bbmodel').exists():
 raise SystemExit('已有用户认可的 MCP 精修工程；后续从分组模型继续，不得用初稿生成器覆盖。')
SEED=uuid.UUID('5a3f1380-2d35-4c98-b035-a4a8df152d36')
U=lambda s:str(uuid.uuid5(SEED,s))
G={};E=[];S=collections.Counter()
PALETTE=[('骨面','#d8d0bf'),('亮骨','#eee6d5'),('骨沿','#ada292'),('旧骨','#8b8174'),
 ('骨髓','#5d554c'),('深骨','#373733'),('暗金','#a6864f'),('金棱','#c5ab73'),
 ('金影','#6d5633'),('暗铁','#514b42'),('淡魂','#b8d3c8'),('魂心','#e3e8d7'),
 ('魂影','#698982'),('象牙','#efe5ce'),('灰骨','#aa9e8a'),('封骨','#c9b792')]

def group(name,parent=None,origin=(8,18,8)):
 g=dict(name=name,uuid=U('g/'+name),origin=list(origin),rotation=[0,0,0],children=[],visibility=True,export=True,isOpen=True,color=len(G)%8)
 G[name]=g
 if parent:G[parent]['children'].append(g)
 return g

group('总体')
for n in ['骸骨核心','分节肋骨弧刃','旧金纪念轮','锁骨反支','背部脊骨','柄根连接','残魂印']:
 group(n,'总体')
for n in ['颅顶','眉骨与眼窝','颊骨','鼻骨','齿列与下颌','后颅壳']:
 group(n,'骸骨核心')
for i in range(9):group('肋骨段_%02d'%(i+1),'分节肋骨弧刃')
group('弧刃背部支撑','分节肋骨弧刃')

def tile_uv(mat,serial,side,size):
 # Low contrast hand-placed strokes are in a reused material tile. Density is
 # proportional to the physical face dimensions, not one pattern per block.
 i=mat*3+serial%3;x=(i%8)*32;y=(i//8)*32
 axes=(0,1) if side in ('north','south') else (2,1) if side in ('east','west') else (0,2)
 w=max(2,min(28,round(size[axes[0]]*7)));h=max(2,min(28,round(size[axes[1]]*7)))
 sx=2+(serial*3)%max(1,29-w);sy=2+(serial*5)%max(1,29-h)
 return [x+sx,y+sy,x+sx+w,y+sy+h]

def cube(g,label,a,b,mat=0,light=0):
 S[g]+=1;serial=S[g];a=np.array(a,float);b=np.array(b,float)
 assert np.all(b>a),(g,a,b)
 ident=U(g+'/'+label+'/'+str(serial))
 faces={s:dict(texture=0,uv=tile_uv(mat,serial,s,b-a),rotation=0) for s in ['north','south','east','west','up','down']}
 e=dict(name=g+'_'+label+'_%03d'%serial,type='cube',uuid=ident,origin=((a+b)/2).tolist(),rotation=[0,0,0],
        box_uv=False,autouv=0,visibility=True,export=True,from_=a.round(6).tolist(),to=b.round(6).tolist(),faces=faces)
 e['from']=e.pop('from_')
 if light:e['light_emission']=light
 E.append(e);G[g]['children'].append(ident)
 return e

def box(g,label,c,size,mat=0,light=0):
 c=np.array(c,float);size=np.array(size,float)
 return cube(g,label,c-size/2,c+size/2,mat,light)

CELL=.32
xs=np.arange(-2.4,17.2,CELL);ys=np.arange(7.2,31.5,CELL)
X,Y=np.meshgrid(xs+CELL/2,ys+CELL/2)

def polygon(pts):
 m=np.zeros(X.shape,dtype=bool)
 for a,b in zip(pts,pts[1:]+pts[:1]):
  if a[1]==b[1]:continue
  m^=((a[1]>Y)!=(b[1]>Y))&(X<(b[0]-a[0])*(Y-a[1])/(b[1]-a[1])+a[0])
 return m

def erode(m):
 n=m.copy();n[1:]&=m[:-1];n[:-1]&=m[1:];n[:,1:]&=m[:,:-1];n[:,:-1]&=m[:,1:]
 n[0]=n[-1]=False;n[:,0]=n[:,-1]=False
 return n

def patches(mask,g,label,z0,z1,mat,dx=0,dy=0):
 m=mask.copy()
 for j in range(m.shape[0]):
  i=0
  while i<m.shape[1]:
   if not m[j,i]:i+=1;continue
   w=h=1
   while i+w<m.shape[1] and m[j,i+w]:w+=1
   while j+h<m.shape[0] and np.all(m[j+h,i:i+w]):h+=1
   m[j:j+h,i:i+w]=False
   cube(g,label,[xs[i]+dx,ys[j]+dy,z0],[xs[i]+w*CELL+dx,ys[j]+h*CELL+dy,z1],mat)
   i+=w

def radial(r,deg):
 a=math.radians(deg);return (8+r*math.cos(a),18.6+r*math.sin(a))

# Seven-to-nine separately readable ribs with flared end caps, not a solid slab.
for index,angle in enumerate(np.linspace(104,248,9)):
 g='肋骨段_%02d'%(index+1)
 pts=[radial(5.90,angle-5),radial(6.7,angle-6),radial(8.75,angle-7),
      radial(9.15,angle-3),radial(9.15,angle+3),radial(8.75,angle+7),radial(6.7,angle+7),
      radial(5.90,angle+5)]
 m=polygon(pts);inner=erode(m)
 # Deliberate volume taper: end of blade thinner; root remains substantial.
 radius=np.hypot(X-8,Y-18.6)
 patches(m&(radius<6.8),g,'骨段主承力',6.90,9.10,0)
 patches(m&(radius>=6.8),g,'肋刃收薄外缘',7.16,8.84,2)
 patches(inner,g,'骨面前浮雕',6.67+index*.008,7.30,1,dx=.093,dy=.077)
 patches(inner,g,'骨面背浮雕',8.73,9.33-index*.008,0,dx=-.093,dy=-.077)
 # A small actual cap links the bone at the curve, with front/back gold tabs.
 p=radial(6.5,angle);size=(.68,.51,.24)
 box(g,'旧金正扣',(p[0],p[1],6.52),size,6)
 box(g,'旧金背扣',(p[0],p[1],9.47),size,6)
 box(g,'扣钉',(p[0],p[1],6.34),(.22,.22,.16),7)

# An arc of dark load-bearing bone closes the structure behind the blade roots.
R=np.hypot(X-8,Y-18.6);A=np.degrees(np.arctan2(Y-18.6,X-8));A=np.where(A<0,A+360,A)
arc=(R>=5.63)&(R<=6.26)&(A>=101)&(A<=252)
patches(arc,'弧刃背部支撑','曲脊骨承托',8.76,9.72,4,dx=.047,dy=.059)
bone_arch=(R>=5.73)&(R<=6.12)&(A>=101)&(A<=252)
patches(bone_arch,'弧刃背部支撑','前部肋骨连弧',6.53,7.10,2,dx=.077,dy=.103)
# Three load-bearing connections leave a real open cavity between core and blade.
for angle in (112,178,240):
 pts=[radial(1.7,angle-5),radial(6.1,angle-4),radial(6.1,angle+4),radial(1.7,angle+5)]
 m=polygon(pts)
 patches(m,'弧刃背部支撑','三处肋骨承力桥',7.01,9.09,3,dx=-.043,dy=.037)
 patches(erode(m),'弧刃背部支撑','承力桥前骨面',6.81,7.25,0,dx=.113,dy=.087)

# Cranial dome: hollow centre, layered side/rear walls instead of a full box.
for j in range(7):
 y=20.8+j*.39;hw=[2.13,2.06,1.95,1.80,1.58,1.25,.86][j]
 zf=5.91+j*.065;zb=9.50-j*.06
 cube('颅顶','额骨带',[8-hw,y,zf],[8+hw,y+.395,zf+.46],0 if j%3 else 1)
 cube('颅顶','侧颅壳',[8-hw,y,zf+.23],[8-hw+.51,y+.40,zb],2)
 cube('颅顶','侧颅壳',[8+hw-.51,y,zf+.23],[8+hw,y+.40,zb],0)
 cube('后颅壳','枕骨带',[8-hw+.2,y,zb-.41],[8+hw-.2,y+.405,zb+.02],14)

# Central crest modestly proud of the forehead, all axis-aligned.
for j in range(5):
 w=.64-j*.075;y=20.94+j*.54
 box('颅顶','额骨脊',(8,y,5.70+j*.075),(w,.65,.43),1)

# True recessed orbital openings: top ridge, outer wall, inner wall and floor.
for sign in (-1,1):
 cx=8+sign*1.13
 box('眉骨与眼窝','眉弓',(cx,20.46,5.58),(1.67,.48,.88),1)
 box('眉骨与眼窝','眉弓末端',(8+sign*1.95,20.13,5.93),(.65,.54,.67),0)
 box('眉骨与眼窝','外眶缘',(8+sign*2.03,19.38,5.96),(.43,1.04,.90),0)
 box('眉骨与眼窝','内眶缘',(8+sign*.30,19.53,5.53),(.34,1.22,.63),2)
 box('眉骨与眼窝','下眶缘',(cx,18.90,5.70),(1.47,.40,.66),2)
 box('眉骨与眼窝','凹眼窝内衬',(cx,19.69,7.09),(1.40,1.01,.26),5)
 # Orbital roof extends to the skull walls, avoiding an exposed hollow slab.
 box('眉骨与眼窝','眼窝顶壁',(cx,20.24,6.69),(1.45,.30,1.57),3)

# Cheek bones taper around the sockets and articulate into a long narrow muzzle.
for sign in (-1,1):
 for j in range(5):
  y=18.74-j*.44;cx=8+sign*(2.01-j*.10);zf=5.76-j*.09
  box('颊骨','颧骨层',(cx,y,zf),(.61+j*.035,.51,.70),0 if j%2 else 1)
  box('颊骨','侧颊支撑',(cx-sign*.18,y,7.43),(.39,.52,2.23-j*.13),3)
 box('颊骨','颧骨外突',(8+sign*2.44,18.53,6.56),(.50,.46,.66),0)
 # The split nasal ridge leaves a deep opening between it and the cheek.
 for j in range(5):
  y=19.02-j*.47;cx=8+sign*(.43-j*.025)
  box('鼻骨','鼻骨垂脊',(cx,y,5.07-j*.025),(.31,.55,.70),1 if j<2 else 0)
 box('鼻骨','鼻腔暗衬',(8+sign*.24,17.98,6.38),(.42,1.50,.24),5)

# Small teeth are volume, not one noisy square pattern.
box('齿列与下颌','上颌牙床',(8,16.82,5.33),(2.72,.47,.68),0)
for j in range(6):
 box('齿列与下颌','齿列',(6.93+j*.43,16.30,5.28),(.30,.67+(j%2)*.08,.55),13 if j%3 else 1)
for sign in (-1,1):
 box('齿列与下颌','下颌关节',(8+sign*1.52,16.27,6.42),(.57,1.36,.81),2)
 box('齿列与下颌','下颌收口',(8+sign*1.25,15.51,5.99),(.59,.61,1.32),0)
box('齿列与下颌','颏骨',(8,15.22,5.83),(2.54,.50,.79),1)

# Back view: sculpted occiput and actual vertebrae, not a featureless black plane.
for j in range(8):
 y=14.7+j*.75;hw=1.03+min(j,4)*.13
 box('后颅壳','后颅层',(8,y,9.42),(hw*2,.80,.60),14 if j%3 else 0)
 box('后颅壳','枕骨脊',(8,y,9.83),(.46,.80,.34),2)

for j in range(9):
 y=9.08+j*1.28
 box('背部脊骨','脊骨节',(8,y,9.18),(1.26,.81,1.36),3)
 box('背部脊骨','椎棘',(8,y+.17,10.12),(.44,.40,.69),2)
 for sign in (-1,1):box('背部脊骨','椎骨横突',(8+sign*.79,y,9.13),(.58,.43,.62),0)

# Counterbranch, retaining an airy fork instead of another massive blade.
counter=polygon([[9.9,19.4],[11.1,20.0],[12.8,19.9],[13.3,21.3],[13.9,21.6],
 [13.9,20.0],[15.1,19.8],[15.9,20.5],[16.2,20.3],[15.8,19.1],
 [14.7,18.7],[14.1,17.7],[13.5,17.4],[13.6,18.7],[11.7,18.6],[10.0,18.8]])
patches(counter,'锁骨反支','锁骨支架',7.00,8.97,0)
patches(erode(counter),'锁骨反支','锁骨前层',6.71,7.24,1,dx=.105,dy=.081)
patches(erode(counter),'锁骨反支','锁骨后层',8.76,9.21,2,dx=-.105,dy=-.081)
for x,y in [(11.8,19.3),(14.15,19.2)]:
 box('锁骨反支','旧金连接扣',(x,y,6.72),(.63,.72,.35),6)

# Compact attached memorial wheel, with clean stepped arcs, no rotated cubes.
hr=np.hypot(X-8,Y-27.20)
halo=(hr>2.18)&(hr<2.59)
patches(halo,'旧金纪念轮','纪念轮弧',7.63,8.14,6,dx=-.067,dy=-.041)
for angle in (0,90,180,270):
 a=math.radians(angle);cx=8+2.53*math.cos(a);cy=27.20+2.53*math.sin(a)
 horizontal=angle in (0,180)
 box('旧金纪念轮','四向骨金尖饰',(cx,cy,7.71),(1.04 if horizontal else .28,.28 if horizontal else 1.04,.58),7)
 box('旧金纪念轮','尖饰根扣',(cx,cy,7.61),(.42,.42,.26),8)
box('旧金纪念轮','竖仪式脊',(8,27.19,7.80),(.22,5.77,.29),6)
box('旧金纪念轮','横仪式脊',(8,27.20,7.82),(5.73,.22,.30),6)
box('旧金纪念轮','纪念轮魂印',(8,27.2,7.50),(.59,.59,.34),14)
box('旧金纪念轮','印心',(8,27.2,7.28),(.23,.23,.16),11,12)
box('旧金纪念轮','顶端骨尖',(8,30.42,7.9),(.35,.71,.46),13)
box('旧金纪念轮','承接轮杆',(8,24.11,8.06),(.46,1.67,.51),6)

# A sturdy head-to-grip root; shaft / hanging relics belong to stage two.
box('柄根连接','主承力柱',(8,9.83,8.02),(1.21,5.23,1.77),4)
for y in [7.79,9.22,10.64,12.06]:
 box('柄根连接','柄根骨箍',(8,y,7.91),(1.67,.55,2.13),0)
 box('柄根连接','箍前接片',(8,y,6.73),(.67,.35,.28),15)

# Recessed soul seal beneath the jaw, protected by three bone prongs.
box('残魂印','魂印暗座',(8,13.85,6.94),(1.51,1.39,.72),5)
box('残魂印','旧金魂印座',(8,13.85,6.46),(1.24,1.04,.24),8)
box('残魂印','淡魂印',(8,13.87,6.21),(.76,.78,.28),10,12)
box('残魂印','魂心',(8,13.93,5.99),(.35,.45,.16),11,15)
for dx,dy in [(-.70,0),(.70,0),(0,-.68)]:
 box('残魂印','护魂骨瓣',(8+dx,13.83+dy,6.27),(.36,.49,.63),0)

def atlas():
 im=Image.new('RGBA',(256,256),(0,0,0,0));rng=np.random.default_rng(121026)
 for mat,(label,hx) in enumerate(PALETTE):
  rgb=np.array(tuple(bytes.fromhex(hx[1:])),float)
  for variant in range(3):
   i=mat*3+variant;xx0=i%8*32;yy0=i//8*32
   yy,xx=np.mgrid[0:32,0:32]
   broad=rng.uniform(-2,2,(8,8)).repeat(4,0).repeat(4,1)
   shade=(15-yy)*.11+(15-xx)*.06+broad
   if mat in (6,7,8):shade+=(abs(xx-10)<2)*3-(abs(xx-23)<1)*2
   if mat in (10,11,12):shade=(18-np.hypot(xx-15,yy-15))*.18
   arr=np.zeros((32,32,4),np.uint8);arr[:,:,:3]=np.clip(rgb+shade[:,:,None],0,255);arr[:,:,3]=255
   tile=Image.fromarray(arr);d=ImageDraw.Draw(tile)
   if mat in (0,1,2,3,14,15):
    # Two deliberate tiny fractures, low contrast; avoid outlining every cube.
    c=tuple(np.clip(rgb-15,0,255).astype(int))+(255,)
    d.line([(7+variant*4,5),(9+variant*3,10),(8+variant*3,13)],fill=c,width=1)
    d.line([(22,21),(20,24),(21,27)],fill=tuple(np.clip(rgb-8,0,255).astype(int))+(255,),width=1)
   im.paste(tile,(xx0,yy0))
 im.save(OUT/'圣骸_骨质旧金_材质.png');b=io.BytesIO();im.save(b,format='PNG')
 return [dict(uuid=U('tex'),name='圣骸_骨质旧金_材质.png',width=256,height=256,uv_width=256,uv_height=256,
  mode='bitmap',saved=True,relative_path='圣骸_骨质旧金_材质.png',source='data:image/png;base64,'+base64.b64encode(b.getvalue()).decode())]

T=atlas()
# Refine the skull into a slender funerary mask; no group or cube rotations.
skull_ids={c for n in ['颅顶','眉骨与眼窝','颊骨','鼻骨','齿列与下颌','后颅壳'] for c in G[n]['children']}
for e in E:
 if e['uuid'] in skull_ids:
  for key in ('from','to','origin'):
   e[key][0]=round(8+(e[key][0]-8)*.79,6)
   e[key][1]=round(19.8+(e[key][1]-19.8)*1.14,6)

def add_surface_atlas(name,im):
 p=OUT/name;im.save(p);buf=io.BytesIO();im.save(buf,format='PNG')
 ti=len(T);T.append(dict(uuid=U(name),name=name,width=im.width,height=im.height,uv_width=im.width,uv_height=im.height,
  relative_path=name,mode='bitmap',saved=True,source='data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()))
 return ti

def mapped_faces(es,ti,bounds,offset,tile_size):
 x0,y0,x1,y1=bounds;ox,oy=offset;tw,th=tile_size
 for e in es:
  for side in ('north','south'):
   original_uv=e['faces'][side]['uv'];original_tile=(int(original_uv[1])//32)*8+int(original_uv[0])//32
   material=original_tile//3
   if material not in (0,1,2,3,13,14,15):continue
   lo,hi=e['from'],e['to']
   u0=hi[0] if side=='north' else lo[0];u1=lo[0] if side=='north' else hi[0]
   e['faces'][side]={'texture':ti,'rotation':0,'uv':[ox+(u0-x0)/(x1-x0)*tw,oy+(y1-hi[1])/(y1-y0)*th,
     ox+(u1-x0)/(x1-x0)*tw,oy+(y1-lo[1])/(y1-y0)*th]}

# Whole bone surfaces share a continuous painted UV field; merged rectangles
# do not each acquire a separate dark outline or a repeated generic tile.
bone_im=Image.new('RGBA',(256,256),(0,0,0,0));bone_bounds=[]
for j in range(9):
 g='肋骨段_%02d'%(j+1);es=[e for e in E if e['uuid'] in G[g]['children'] and '旧金' not in e['name'] and '扣钉' not in e['name']]
 x0=min(e['from'][0] for e in es)-.03;x1=max(e['to'][0] for e in es)+.03
 y0=min(e['from'][1] for e in es)-.03;y1=max(e['to'][1] for e in es)+.03
 yy,xx=np.mgrid[0:64,0:64];wx=x0+(xx+.5)/64*(x1-x0);wy=y1-(yy+.5)/64*(y1-y0)
 r=np.hypot(wx-8,wy-18.6);theta=np.degrees(np.arctan2(wy-18.6,wx-8));theta=np.where(theta<0,theta+360,theta)
 angle=np.linspace(104,248,9)[j];edge=np.clip(abs(theta-angle)/8,0,1)
 shade=13*(1-edge**1.5)-15*edge**2-7*np.clip((7-r)/2,0,1)
 shade+=np.sin(wx*3.3+wy*1.7)*1.8
 rgb=np.array([212,204,188])+shade[:,:,None]
 arr=np.zeros((64,64,4),np.uint8);arr[:,:,:3]=np.clip(rgb,0,255);arr[:,:,3]=255
 tile=Image.fromarray(arr);dr=ImageDraw.Draw(tile)
 # Restrained erosion and bone-grain strokes, not surface noise.
 dr.line([(22+j%3,10),(24+j%3,17),(23+j%3,21)],fill=(166,158,144,255),width=1)
 dr.line([(41,34),(39,39),(40,42)],fill=(183,175,160,255),width=1)
 ox=(j%4)*64;oy=(j//4)*64;bone_im.paste(tile,(ox,oy));bone_bounds.append((es,(x0,y0,x1,y1),(ox,oy)))
ti=add_surface_atlas('圣骸_分节骨片_刻纹.png',bone_im)
for es,bounds,offset in bone_bounds:mapped_faces(es,ti,bounds,offset,(64,64))

skull_es=[e for e in E if e['uuid'] in skull_ids]
x0=min(e['from'][0] for e in skull_es)-.03;x1=max(e['to'][0] for e in skull_es)+.03
y0=min(e['from'][1] for e in skull_es)-.03;y1=max(e['to'][1] for e in skull_es)+.03
yy,xx=np.mgrid[0:128,0:128];wx=x0+(xx+.5)/128*(x1-x0);wy=y1-(yy+.5)/128*(y1-y0)
nx=abs(wx-8)/(max(8-x0,x1-8));shade=10*np.exp(-nx*nx*4)-13*nx**2
shade-=5*np.clip((17-wy)/4,0,1);shade+=np.sin(wx*5+wy*2)*1.2
arr=np.zeros((128,128,4),np.uint8);arr[:,:,:3]=np.clip(np.array([218,210,194])+shade[:,:,None],0,255);arr[:,:,3]=255
tile=Image.fromarray(arr);dr=ImageDraw.Draw(tile)
for points in [[(51,12),(53,20),(51,28),(54,33)],[(83,42),(80,48),(82,54)],[(25,62),(28,68),(27,73)],[(90,96),(86,101),(87,107)]]:
 dr.line(points,fill=(177,168,153,255),width=1)
im=Image.new('RGBA',(256,256),(0,0,0,0));im.paste(tile,(0,0))
ti=add_surface_atlas('圣骸_骸骨核心_连续骨纹.png',im)
mapped_faces(skull_es,ti,(x0,y0,x1,y1),(0,0),(128,128))
DISPLAY={'gui':{'rotation':[0,0,-15],'translation':[0,-4,0],'scale':[.58,.58,.58]},
 'firstperson_righthand':{'rotation':[0,-60,-8],'translation':[2,1.5,-2.5],'scale':[.6,.6,.6]},
 'thirdperson_righthand':{'rotation':[0,-85,0],'translation':[0,4,0],'scale':[.65,.65,.65]},
 'ground':{'translation':[0,2,0],'scale':[.3,.3,.3]}}
check(E,G,'总体',T)
assert all(all(-16<=v<=32 for v in e['from']+e['to']) for e in E)
native=save_native(OUT,'圣骸_阶段一_离线候选',E,G,'总体',T,DISPLAY)
bb=json.loads(native.read_text(encoding='utf-8'));bb['meta']['model_format']='java_block';bb['resolution']={'width':256,'height':256}
native.write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
# The MCP add_cubes payload is data written by this task, not external code.
spec={'groups':[{k:v for k,v in g.items() if k in ('name','origin','rotation')}|({'parent':p['name']} if (p:=next((p for p in G.values() if g in [c for c in p['children'] if isinstance(c,dict)]),None)) else {}) for g in G.values()],
 'cubes':[{'name':e['name'],'from':e['from'],'to':e['to'],'parent':next(g['name'] for g in G.values() if e['uuid'] in g['children']),
  'origin':e['origin'],'rotation':[0,0,0],'autouv':0,'box_uv':False,'faces':e['faces'],'light_emission':e.get('light_emission',0)} for e in E]}
(OUT/'MCP建模规格.json').write_text(json.dumps(spec,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
counts=collections.Counter(c['parent'] for c in spec['cubes'])
print('Stage-one',len(E),'cubes;',len(G),'groups;',dict(counts),flush=True)
r=renderer(native)
im=Image.new('RGB',(1660,1140),r['BG']);d=ImageDraw.Draw(im)
d.text((25,20),'圣骸 · 阶段一：骸骨核心 / 分节肋刃 / 纪念轮',font=r['font'],fill='#e5d1ad')
d.text((25,65),'实际立方体与贴图渲染 · 全部正交塑形 · 尚未部署',font=r['small'],fill='#a99c88')
for i,(yaw,label) in enumerate([(math.pi,'正面'),(math.pi-.42,'斜侧'),(0,'背面')]):
 im.paste(r['render']((550,940),yaw=yaw,pitch=.035,scale=35,focus=(7.3,19.1,8)),(i*550,120))
 d.text((i*550+210,1052),label,font=r['small'],fill='#d0c0a3')
d.text((25,1098),f'{len(E)} 立方体 · {len(G)} 分组 · 握柄、红布、灯与铭牌将在下一阶段制作',font=r['small'],fill='#a99c88')
im.save(OUT/'圣骸_阶段一_初次实际预览.png')
(OUT/'阶段统计.json').write_text(json.dumps({'cubes':len(E),'groups':len(G),'parts':dict(counts),'rotated_cubes':0,'deployed':False},ensure_ascii=False,indent=2),encoding='utf-8')
