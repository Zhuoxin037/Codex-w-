"""Authored closed-volume, flowing flame geometry in the approved flameremnant style."""
import json,math,uuid,base64
from pathlib import Path
import numpy as np
from PIL import Image
from animate_c_guard_20261025 import D,CLIPS
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'C/modeled_fire/20261025/'+s))
groups=[];elements=[];nodes={};tree=[];tiles=[]
def group(name,parent,origin,rotation=None,actor=None):
 g={'name':name,'uuid':uid(name),'origin':origin,'rotation':rotation or[0,0,0],'visibility':True,'export':True,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}}
 if actor:g['actor_parent_name']=actor
 groups.append(g);node={'uuid':g['uuid'],'children':[],'isOpen':False};nodes[name]=node;(nodes[parent]['children']if parent else tree).append(node)
def box(name,bone,lo,hi,role,phase=0,tip=False):
 lo=np.array(lo,float);hi=np.array(hi,float);assert min(hi-lo)>0
 i=len(tiles);tiles.append({'role':role,'phase':phase,'tip':tip});x=(i%32)*4;y=(i//32)*4
 uv=[(x+.3)*4,(y+.3)*4,(x+3.7)*4,(y+3.7)*4]
 e={'name':name,'uuid':uid(name),'type':'cube','from':lo.tolist(),'to':hi.tolist(),'origin':((lo+hi)/2).tolist(),'rotation':[0,0,0],'rescale':False,'shade':False,'light_emission':15,'visibility':True,'export':True,'box_uv':False,'faces':{f:{'texture':0,'uv':uv.copy()}for f in ['north','east','south','west','up','down']}};elements.append(e);nodes[bone]['children'].append(e['uuid'])
def cell(name,bone,center,size,role,phase=0,tip=False):box(name,bone,np.array(center)-np.array(size)/2,np.array(center)+np.array(size)/2,role,phase,tip)
def flame_spine(name,bone,points,widths,phase=0):
 original=np.array(points,float);tt=np.linspace(0,1,7);p=np.stack([np.interp(tt,np.linspace(0,1,len(original)),original[:,a])for a in range(3)],1)
 for i,(a,b)in enumerate(zip(p[:-1],p[1:])):
  u=(i+.5)/(len(p)-1);w=float(np.interp(u,np.linspace(0,1,len(widths)),widths));lo=np.minimum(a,b)-[w/2,.07,w*.23];hi=np.maximum(a,b)+[w/2,.07,w*.23]
  # Adjacent red/orange/white-hot bands expose their surfaces on both
  # sides. No bright core is buried inside an opaque red enclosing cube.
  cuts=lo[0]+(hi[0]-lo[0])*np.array([0,.22,.64,1.0])
  for k,role in enumerate(['red','orange','core']):
   ll=lo.copy();hh=hi.copy();ll[0]=cuts[k];hh[0]=cuts[k+1]
   box(name+'_'+role+'_'+str(i),bone,ll,hh,role,phase+u*1.8,tip=i==len(p)-2)
group('fx_root',None,[1.1,0,0])
# Three broad, asymmetric flame crescents: each has real radial width and
# vertical thickness, three heat layers, and curled upward flame tongues.
for j in range(3):
 gn='fx_modeled_wave_'+str(j);group(gn,'fx_root',[1.1,.6,0],[0,j*120,0])
 angles=np.linspace(-56,56,15)
 for i,(aa,bb)in enumerate(zip(angles[:-1],angles[1:])):
  taper=.35+.65*math.sin(math.pi*(i+.5)/14)**.65
  for layer,(radius,width,y,h,role)in enumerate([(14.7,.8,1.1,.9,'red'),(13.8,.70,1.5,1.5,'orange'),(12.9,.45,1.95,.75,'core')]):
   a,b=map(math.radians,[aa,bb]);p=np.array([[1.1+radius*math.sin(a),y,-radius*math.cos(a)],[1.1+radius*math.sin(b),y,-radius*math.cos(b)]]);lo=p.min(0)-[width*taper,h/2,width*taper];hi=p.max(0)+[width*taper,h/2,width*taper];box(f'fx_wave_{j}_{layer}_{i}',gn,lo,hi,role,i/14*2+j*.13)
 for k,(theta,height)in enumerate([(-34,6.4),(-3,10.0),(31,8.2)]):
  pts=[]
  for u in np.linspace(0,1,6):
   a=math.radians(theta+u*17);radius=14+u*2.8-u*u*5.8;pts.append([1.1+radius*math.sin(a),1.7+height*u,-radius*math.cos(a)])
  flame_spine(f'fx_wave_tongue_{j}_{k}',gn,pts,[1.6,1.55,1.25,.8,.35],j*.17+k*.21)
# Coiling volumetric flames over each bracer; these attach to the forearm.
for side,cx,cz,sg in [('right',8.8,-3.5,1),('left',-7.0,4.0,-1)]:
 gn='fx_arm_fire_'+side;group(gn,None,[cx,27.4,cz],actor='forearm_'+side)
 for k in range(2):
  pts=[]
  for u in np.linspace(0,1,6):
   pts.append([cx+sg*(1.3+k*.4+1.0*math.sin(u*math.pi)),29.2-6.6*u,cz+(-1 if k==0 else 1)*(1.1+1.1*math.sin(u*math.pi))])
  flame_spine(f'fx_bracer_stream_{side}_{k}',gn,pts,[.85,.85,.72,.52,.25],k*.4)
group('fx_charge_stream','fx_root',[1.1,29,0])
for j in range(2):
 pts=[]
 for u in np.linspace(0,1,9):
  a=math.radians(j*180+u*145);r=7.5-u;pts.append([1.1+r*math.cos(a),24+13*u,r*math.sin(a)])
 for i,(a,b)in enumerate(zip(np.array(pts)[:-1],np.array(pts)[1:])):
  lo=np.minimum(a,b)-[.4,.25,.3];hi=np.maximum(a,b)+[.4,.25,.3];mid=(lo[0]+hi[0])/2;hh=hi.copy();hh[0]=mid;ll=lo.copy();ll[0]=mid;box(f'fx_charge_outer_{j}_{i}','fx_charge_stream',lo,hh,'orange',i/8*2+j*.3);box(f'fx_charge_core_{j}_{i}','fx_charge_stream',ll,hi,'core',i/8*2+j*.3)
group('fx_modeled_blast','fx_root',[1.1,23,0])
for j in range(3):
 yaw=math.radians(j*120);aa=np.linspace(-95,65,12)
 for i,(a,b)in enumerate(zip(aa[:-1],aa[1:])):
  for layer,(radius,th,role)in enumerate([(7.6,.40,'red'),(6.8,.38,'orange'),(6.0,.32,'core')]):
   ps=[]
   for angle in [a,b]:
    x=radius*math.sin(math.radians(angle));y=radius*math.cos(math.radians(angle));ps.append([1.1+math.cos(yaw)*x,27+y,-2-math.sin(yaw)*x])
   pp=np.array(ps);box(f'fx_blast_curl_{j}_{layer}_{i}','fx_modeled_blast',pp.min(0)-th,pp.max(0)+th,role,i/11*2+j*.3,tip=i==len(aa)-2)
group('fx_modeled_embers','fx_root',[1.1,12,0]);group('fx_modeled_ash','fx_root',[1.1,3,0])
for j in range(20):
 a=j*2.39996;r=6+(j%5)*2;cell('fx_ember_'+str(j),'fx_modeled_embers',[1.1+r*math.cos(a),5+(j%6)*3,r*math.sin(a)],[.35,.6,.35],'ember',j*.17,True)
for j in range(12):
 a=math.tau*j/12;r=10+(j%3);cell('fx_ash_'+str(j),'fx_modeled_ash',[1.1+r*math.cos(a),1.5+(j%4)*.5,r*math.sin(a)],[.50,.30,.55],'ash',j*.12,True)
# Original 12-frame palette flow. Each physical cube has its own tile and
# phase so heat travels along the arc/spine, as on flameremnant's fire.
F=12;frames=[]
base={'red':np.array([225,48,7.]),'orange':np.array([255,121,12.]),'core':np.array([255,219,116.]),'ember':np.array([255,155,24.]),'ash':np.array([107,68,43.])}
for f in range(F):
 im=Image.new('RGBA',(128,128))
 for i,t in enumerate(tiles):
  h=max(0,math.sin(math.tau*(t['phase']-f/F)))**2;c=base[t['role']].copy();c+=np.array([15,65,50])*h if t['role']!='ash'else np.array([38,18,0])*h;c=np.clip(c,0,255).astype('uint8');alpha=0 if t['tip']and h<.12 else 255
  x=(i%32)*4;y=(i//32)*4;im.paste(tuple(c.tolist()+[alpha]),(x,y,x+4,y+4))
 frames.append(im)
strip=Image.new('RGBA',(128,128*F))
for i,im in enumerate(frames):strip.paste(im,(0,i*128))
path=D/'c_modeled_fire_flow.png';strip.save(path);(D/'c_modeled_fire_flow.png.mcmeta').write_text(json.dumps({'animation':{'frametime':1,'interpolate':False}}),encoding='utf8')
texture={'uuid':uid('texture'),'name':path.name,'id':'0','path':str(path),'relative_path':path.name,'width':128,'height':128*F,'uv_width':512,'uv_height':512,'internal':True,'saved':True,'render_mode':'emissive','render_sides':'double','fps':20,'frame_time':1,'frame_order_type':'loop','frame_order':'','frame_interpolate':False,'source':'data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode()}
def keys(seq):return [{'channel':'scale','time':t,'data_points':[{a:str(z)for a,z in zip('xyz',v if isinstance(v,list)else[v]*3)}],'uuid':str(uuid.uuid4()),'interpolation':ip}for t,v,ip in seq]
animations={}
for clip,length,loop in CLIPS:
 tracks={}
 for gg in groups[1:]:
  name=gg['name'];seq=[(0,0,'linear'),(length,0,'linear')]
  if name.startswith('fx_arm_fire_')or name=='fx_charge_stream':
   if clip=='guard_enter':seq=[(0,0,'linear'),(.25,0,'linear'),(.65,.85,'linear'),(length,1,'linear')]
   if clip in ['guard_hold','guard_absorb']:seq=[(0,1,'linear'),(length*.5,1.08,'linear'),(length,1,'linear')]
   if clip=='guard_release':seq=[(0,1,'linear'),(.4,1.22,'linear'),(.64,1.4,'step'),(.76,0,'linear'),(length,0,'linear')]
   if clip=='guard_cancel':seq=[(0,1,'linear'),(.55,.75,'step'),(.80,0,'linear'),(length,0,'linear')]
  if clip=='guard_release':
   if name.startswith('fx_modeled_wave_'):seq=[(0,0,'step'),(.62,0,'linear'),(.66,[.55,.65,.55],'linear'),(.90,[1.9,1.4,1.9],'linear'),(length,[3.15,1.2,3.15],'linear')]
   if name=='fx_modeled_blast':seq=[(0,0,'step'),(.61,0,'linear'),(.65,.7,'linear'),(.78,1.6,'step'),(.96,0,'linear'),(length,0,'linear')]
   if name=='fx_modeled_embers':seq=[(0,0,'step'),(.64,0,'linear'),(.68,.7,'linear'),(length,[2.0,1.6,2.0],'linear')]
   if name=='fx_modeled_ash':seq=[(0,0,'step'),(.80,0,'linear'),(.85,.7,'linear'),(length,[1.8,1,1.8],'linear')]
  if clip=='guard_recover':
   if name.startswith('fx_modeled_wave_'):seq=[(0,[3.15,1.2,3.15],'linear'),(.25,[4.1,.8,4.1],'step'),(.4,0,'linear'),(length,0,'linear')]
   if name=='fx_modeled_embers':seq=[(0,[2.0,1.6,2.0],'linear'),(.5,[2.8,2.0,2.8],'step'),(.65,0,'linear'),(length,0,'linear')]
   if name=='fx_modeled_ash':seq=[(0,[1.8,1,1.8],'linear'),(.5,[2.6,1.5,2.6],'step'),(.8,0,'linear'),(length,0,'linear')]
  kk=keys(seq)
  if name.startswith('fx_modeled_wave_')and clip in ['guard_release','guard_recover']:
   ss=[(0,0),(.62,-16),(.90,8),(length,22)]if clip=='guard_release'else[(0,22),(.4,45),(length,45)]
   kk +=[{'channel':'rotation','time':t,'data_points':[{'x':'0','y':str(v),'z':'0'}],'uuid':str(uuid.uuid4()),'interpolation':'linear'}for t,v in ss]
  if name=='fx_charge_stream'and clip=='guard_hold':
   kk +=[{'channel':'rotation','time':t,'data_points':[{'x':'0','y':str(v),'z':'0'}],'uuid':str(uuid.uuid4()),'interpolation':'linear'}for t,v in [(0,0),(length,360)]]
  tracks[gg['uuid']]={'name':name,'type':'bone','keyframes':kk}
 animations[clip]=tracks
data={'groups':groups,'elements':elements,'outliner':tree,'textures':[texture],'animators':animations,'body_cubes':933,'effect_cubes':len(elements),'effect_geometry_groups':len(groups)-1,'visual_theme':'authored closed-volume curled flame crescents and coiling bracer fire','texture_frames':F,'flow_placeholder':'preview.texture_frame = math.floor(query.anim_time * 20) - math.floor(query.anim_time * 20 / 12) * 12;','reference':'烈火残躯三层弧形结构、上翻火舌与逐块流火；没有使用原版fire_0/fire_1火片。'}
(D/'特效原生导入.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8');print({'modeled_flame_cubes':len(elements),'groups':len(groups),'texture_size':strip.size,'frames':F},flush=True)
