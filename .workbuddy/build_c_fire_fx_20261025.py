"""Vanilla-style volumetric crossed fire tongues, not the rejected light rings."""
import math,json,uuid,base64,copy,zipfile
from pathlib import Path
import numpy as np
from PIL import Image
from animate_c_guard_20261025 import D,CLIPS
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'C/fire/fx/20261025/'+s))
atlas=Image.new('RGBA',(512,512));fire=[Image.open(D/('原版_fire_'+str(i)+'.png')).convert('RGBA')for i in [0,1]]
for i in range(16):
 im=fire[i%2].crop((0,(i*2%32)*16,16,(i*2%32+1)*16));im=im.resize((64,128),Image.Resampling.NEAREST);atlas.paste(im,((i%8)*64,(i//8)*128))
jar=Path('D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar')
from io import BytesIO
with zipfile.ZipFile(jar)as z:smoke=Image.open(BytesIO(z.read('assets/minecraft/textures/particle/big_smoke_3.png'))).convert('RGBA')
for i in range(8):
 im=smoke.resize((64,128),Image.Resampling.NEAREST);a=np.array(im);a[:,:,:3]=(np.array([112,91,82])*(.65+.055*i)).astype('uint8');atlas.paste(Image.fromarray(a),((i%8)*64,256))
for i,c in enumerate([(255,237,141,255),(255,146,41,255),(230,65,16,255),(107,39,24,255)]):
 Image.Image.paste(atlas,Image.new('RGBA',(64,128),c),(i*64,384))
path=D/'c_fire_fx_512.png';atlas.save(path);texture={'uuid':uid('texture'),'name':path.name,'id':'0','path':str(path),'relative_path':path.name,'width':512,'height':512,'uv_width':512,'uv_height':512,'internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode()}
groups=[];elements=[];nodes={};outliner=[]
def group(name,parent,origin,rotation=None,actor=None):
 g={'name':name,'uuid':uid(name),'origin':origin,'rotation':rotation or[0,0,0],'visibility':True,'export':True,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}}
 if actor:g['actor_parent_name']=actor
 groups.append(g);node={'uuid':g['uuid'],'children':[],'isOpen':False};nodes[name]=node;(nodes[parent]['children']if parent else outliner).append(node)
def box(name,bone,center,size,tile,plane=None,angle=0,axis='y'):
 r=[0,0,0];r['xyz'.index(axis)]=angle;x=(tile%8)*64;y=(tile//8)*128
 faces={f:{'texture':None,'uv':[0,0,1,1]}for f in ['north','south','east','west','up','down']}
 for f in (['north','south']if plane=='z'else ['east','west']if plane=='x'else faces):faces[f]={'texture':0,'uv':[x+.5,y+.5,x+63.5,y+127.5]}
 e={'name':name,'uuid':uid(name),'type':'cube','from':[center[i]-size[i]/2 for i in range(3)],'to':[center[i]+size[i]/2 for i in range(3)],'origin':center,'rotation':r,'rescale':False,'shade':False,'light_emission':15,'visibility':True,'export':True,'box_uv':False,'faces':faces};elements.append(e);nodes[bone]['children'].append(e['uuid'])
def flame(name,bone,x,y,z,width,height,tile,angle=0):
 box(name+'_front',bone,[x,y+height/2,z],[width,height,.08],tile,'z',angle,'x')
 box(name+'_cross',bone,[x,y+height/2,z],[.08,height,width],(tile+3)%16,'x')
group('fx_root',None,[1.1,0,0])
for name,o in [('fx_fire_wave',[1.1,.4,0]),('fx_fire_blast',[1.1,22,0]),('fx_fire_charge',[1.1,29,-3]),('fx_fire_embers',[1.1,12,0]),('fx_fire_smoke',[1.1,3,0]),('fx_fire_impact',[1.1,34,-7])]:group(name,'fx_root',o)
for side,cx,cz in [('right',8.8,-3.3),('left',-7.0,4.0)]:
 name='fx_arm_fire_'+side;group(name,None,[cx,27.4,cz],actor='forearm_'+side)
 for j,(dx,dz,w,h)in enumerate([(-1.2,-1.0,3.0,7.0),(1.1,.6,3.4,8.8),(0,-1.4,3.0,10.0)]):flame(f'fx_arm_{side}_{j}',name,cx+dx,26.0,cz+dz,w,h,j+(0 if side=='right'else 4))
for j in range(8):
 gn='fx_fire_sector_'+str(j);group(gn,'fx_fire_wave',[1.1,.4,0],[0,j*45,0])
 for k,(x,r,h,w)in enumerate([(-2.2,13,11,4.8),(2.0,16,13.5,4.8),(0,10,8.5,4.0)]):flame(f'fx_wave_{j}_{k}',gn,1.1+x,.2,-r,w,h,(j*2+k)%16,22.5 if k==1 else 0)
for j in range(10):
 a=math.tau*j/10;r=3.5+(j%3)*1.1;flame(f'fx_blast_{j}','fx_fire_blast',1.1+r*math.cos(a),15+(j%2)*2,r*math.sin(a),6.2,20+(j%3)*2.4,j%16)
for j in range(6):
 a=math.tau*j/6;flame(f'fx_charge_{j}','fx_fire_charge',1.1+5.5*math.cos(a),24+(j%2),-3+3.7*math.sin(a),3.8,9.5+(j%3)*1.5,j+8)
for j in range(24):
 a=j*2.39996;r=8+(j%5)*2.1;box('fx_fire_ember_'+str(j),'fx_fire_embers',[1.1+r*math.cos(a),8+(j%6)*3.1,r*math.sin(a)],[.3+.1*(j%3),.6+.15*(j%4),.3],24+j%3,angle=45 if j%2 else 0,axis='z')
for j in range(8):
 a=math.tau*j/8;tile=16+j;x=1.1+12*math.cos(a);z=12*math.sin(a)
 box('fx_smoke_'+str(j)+'_f','fx_fire_smoke',[x,3.8+(j%3),z],[6,7,.08],tile,'z')
 box('fx_smoke_'+str(j)+'_s','fx_fire_smoke',[x,3.8+(j%3),z],[.08,7,6],tile,'x')
flame('fx_fire_hit_left','fx_fire_impact',-.7,32,-8.5,5.5,9.0,1)
flame('fx_fire_hit_right','fx_fire_impact',2.9,32,-8.3,5.5,9.0,4)
def keys(channel,seq):return [{'channel':channel,'time':t,'data_points':[{a:str(z)for a,z in zip('xyz',v if isinstance(v,list)else[v]*3)}],'uuid':str(uuid.uuid4()),'interpolation':ip}for t,v,ip in seq]
animations={}
animated=[g for g in groups if g['name']!='fx_root']
for clip,length,loop in CLIPS:
 tracks={}
 for g in animated:
  name=g['name'];seq=[(0,0,'linear'),(length,0,'linear')];k=[]
  if name.startswith('fx_fire_sector_'):
   # Sector motion flickers flame height; the parent gates visibility.
   phase=int(name.rsplit('_',1)[1])/8;seq=[(round(float(t),6),[1,1+.12*math.sin(math.tau*(4*t+phase)),1],'linear')for t in np.linspace(0,length,round(length*20)+1)]
   if loop=='loop':seq[-1]=(length,seq[0][1],'linear')
  elif name=='fx_fire_charge' or name.startswith('fx_arm_fire_'):
   if clip=='guard_enter':seq=[(0,0,'linear'),(.28,.0,'linear'),(.65,.85,'linear'),(length,1,'linear')]
   if clip in ['guard_hold','guard_absorb']:seq=[(0,1,'linear'),(length*.25,1.10,'linear'),(length*.5,.95,'linear'),(length*.75,1.12,'linear'),(length,1,'linear')]
   if clip=='guard_release':seq=[(0,1,'linear'),(.4,1.4,'linear'),(.65,1.75,'step'),(.80,0,'linear'),(length,0,'linear')]
   if clip=='guard_cancel':seq=[(0,1,'linear'),(.6,.65,'step'),(.85,0,'linear'),(length,0,'linear')]
  elif clip=='guard_absorb' and name=='fx_fire_impact':seq=[(0,0,'linear'),(.06,1.0,'linear'),(.17,1.4,'step'),(.28,0,'linear'),(length,0,'linear')]
  if clip=='guard_release':
   if name=='fx_fire_wave':seq=[(0,0,'step'),(.62,0,'linear'),(.66,[.4,.65,.4],'linear'),(.88,[1.9,1.2,1.9],'linear'),(length,[3.1,1.0,3.1],'linear')]
   if name=='fx_fire_blast':seq=[(0,0,'step'),(.60,0,'linear'),(.65,.8,'linear'),(.76,1.3,'step'),(.95,0,'linear'),(length,0,'linear')]
   if name=='fx_fire_embers':seq=[(0,0,'step'),(.64,0,'linear'),(.68,.6,'linear'),(length,[2.0,1.6,2.0],'linear')]
   if name=='fx_fire_smoke':seq=[(0,0,'step'),(.78,0,'linear'),(.85,.65,'linear'),(length,[1.8,1.2,1.8],'linear')]
  if clip=='guard_recover':
   if name=='fx_fire_wave':seq=[(0,[3.1,1.0,3.1],'linear'),(.25,[3.9,.65,3.9],'step'),(.40,0,'linear'),(length,0,'linear')]
   if name=='fx_fire_embers':seq=[(0,[2,1.6,2],'linear'),(.5,[2.7,2.0,2.7],'step'),(.65,0,'linear'),(length,0,'linear')]
   if name=='fx_fire_smoke':seq=[(0,[1.8,1.2,1.8],'linear'),(.35,[2.4,1.7,2.4],'linear'),(.8,[2.6,1.8,2.6],'step'),(1.0,0,'linear'),(length,0,'linear')]
  k+=keys('scale',seq);tracks[g['uuid']]={'name':name,'type':'bone','keyframes':k}
 animations[clip]=tracks
data={'groups':groups,'elements':elements,'outliner':outliner,'textures':[texture],'animators':animations,'body_cubes':933,'effect_cubes':len(elements),'effect_geometry_groups':15,'visual_theme':'flame blast; replaces rejected pressure lines and light rings','note':'No fire damage or liuhuo state is added by these visual assets.'}
(D/'特效原生导入.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8');print({'fire_effect_cubes':len(elements),'effect_groups':len(groups)},flush=True)
