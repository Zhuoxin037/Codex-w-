"""An independent, volumetric, burning crescent. Does not rebuild the weapon."""
from pathlib import Path
import base64,io,json,math,uuid
import numpy as np
from PIL import Image
O=Path('D:/数据包/模型设计/烈火残躯_技能动效_20261014')
uid=lambda:str(uuid.uuid4());origin=[8,8,8];pixel=.5;size=64
# A curved blade rather than a complete torus: its back frays into tongues.
masks=[]
for layer in range(3):
 grid=np.zeros((size,size),np.uint8)
 for z in range(size):
  for x in range(size):
   px,pz=(x+.5-32)*pixel,(z+.5-32)*pixel;r=math.hypot(px,pz);a=math.atan2(pz,px)
   u=(a-math.radians(-145))/math.radians(185)
   if not 0<u<1:continue
   envelope=math.sin(math.pi*u)**.7
   spine=11.6+.35*math.sin(a*3+.2)
   width=(.15+2.7*envelope)*(1 if layer==0 else .62 if layer==1 else .3)
   if layer>0 and math.sin(a*8+layer*.8)<-.10:continue
   if abs(r-spine)>width*.5:continue
   d=(r-spine)/max(width,.01)
   grid[z,x]=3 if d<-.18 else 2 if d<.22 else 1
 masks.append(grid)
palette=[(247,70,13),(255,156,35),(255,228,153)]
rectangles=[]
for layer,grid in enumerate(masks):
 work=grid.copy()
 for z in range(size):
  for x in range(size):
   color=int(work[z,x])
   if not color:continue
   w=1
   while x+w<size and work[z,x+w]==color:w+=1
   h=1
   while z+h<size and np.all(work[z+h,x:x+w]==color):h+=1
   work[z:z+h,x:x+w]=0;rectangles.append((x,z,w,h,color,layer))
texture_uuid=uid();group_uuid=uid();els=[]
# Per-patch burn phases reveal the leading edge first and crumble the tail last.
patches=[]
for index,(x,z,w,h,color,layer) in enumerate(rectangles):
 tx,ty=index%16,index//16
 theta=math.atan2(z+h/2-32,x+w/2-32);u=(theta-math.radians(-145))/math.radians(185)
 patches.append((tx,ty,palette[color-1],u,(index*37)%7,layer))
 lo=[8+(x-32)*pixel,8+layer*.4,8+(z-32)*pixel]
 hi=[lo[0]+w*pixel,lo[1]+(.4 if layer==0 else .36),lo[2]+h*pixel]
 faces={s:dict(texture=0,uv=[tx*2,ty*2,tx*2+2,ty*2+2]) for s in ['north','east','south','west','up','down']}
 els.append(dict(name=f'焰刃_{layer}_{index:03}',uuid=uid(),type='cube',from_=lo,to=hi,origin=origin,rotation=[0,0,0],faces=faces,box_uv=False,light_emission=15))
 els[-1]['from']=els[-1].pop('from_')
assert len(els)<=256,len(els)
rows=math.ceil(len(els)/16)*2;tex=Image.new('RGBA',(32,rows*13))
for frame in range(13):
 for tx,ty,color,u,seed,layer in patches:
  reveal=frame>=1+int((1-u)*2)
  keep=frame<9 or frame<10+seed%3
  rgba=(*color,255 if reveal and keep else 0)
  for yy in range(2):
   for xx in range(2):tex.putpixel((tx*2+xx,frame*rows+ty*2+yy),rgba)
buff=io.BytesIO();tex.save(buff,format='PNG');tex.save(O/'回旋焰刃_燃烧贴图.png')
bb=dict(meta=dict(format_version='5.0',model_format='free',box_uv=False,bone_rig=True),name='烈火残躯_回旋焰刃_特效',
 resolution=dict(width=32,height=rows),elements=els,groups=[dict(name='回旋焰刃_fx_root',uuid=group_uuid,origin=origin,rotation=[0,0,0],visibility=True)],
 outliner=[dict(uuid=group_uuid,isOpen=True,children=[e['uuid'] for e in els])],
 textures=[dict(uuid=texture_uuid,id='0',name='回旋焰刃_燃烧贴图.png',source='data:image/png;base64,'+base64.b64encode(buff.getvalue()).decode(),
  uv_width=32,uv_height=rows,width=32,height=rows*13,frame_time=1,frame_interpolate=False,render_mode='emissive',render_sides='double',mode='bitmap',saved=True)],animations=[])
path=O/'烈火残躯_回旋焰刃_特效.bbmodel';path.write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
keys=[]
for t,rotation,scale,dy in [(0,0,.55,-.3),(.10,-45,.8,0),(.20,-118,1.0,.2),(.30,-205,1.06,.5),(.40,-290,1.1,.7),(.50,-360,1.1,.9),(.60,-360,1.1,1.1)]:
 for channel,value in [('rotation',[0,rotation,0]),('scale',[scale,1,scale]),('position',[0,dy,0])]:
  keys.append(dict(bone=group_uuid,channel=channel,time=t,value=value,interpolation='linear' if channel=='rotation' else 'catmullrom'))
spec=dict(native=str(path),name='01_强化_回旋焰刃绕身一周',length=.6,keyframes=keys,cubes=len(els),texture_frame_height=rows,world_scale=6.8,start=.78,
  world_center=[0,-4,0],reference='https://www.youtube.com/watch?v=g1Q4jAy9gec',note='受用户指定的莱万汀强化攻击方向启发；独立焰刃旋转，手持剑双斩后收势。')
(O/'回旋焰刃设计.json').write_text(json.dumps(spec,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(dict(native=str(path),vfx_cubes=len(els),weapon_cubes=994,frames=13),ensure_ascii=False))
