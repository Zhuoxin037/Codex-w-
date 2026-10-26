from pathlib import Path
import math,json,uuid,base64,copy
from PIL import Image,ImageDraw
from animate_c_guard_20261025 import D,CLIPS
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'C/guard/fx/20261025/'+s))
tex=Image.new('RGBA',(512,512));colors=['#fff7df','#edb489','#b64c43','#f2d1b0','#8c7d75','#b2a196','#fffdf5','#e06a48']
for i,c in enumerate(colors):
 x=(i%4)*128;y=(i//4)*256;ImageDraw.Draw(tex).rectangle((x,y,x+127,y+255),fill=c)
path=D/'c_guard_fx_512.png';tex.save(path);t={'uuid':uid('texture'),'name':path.name,'id':'0','path':str(path),'relative_path':path.name,'width':512,'height':512,'uv_width':512,'uv_height':512,'internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode()}
groups=[];els=[];nodes={};tree=[]
def group(name,parent,o):
 g={'name':name,'uuid':uid(name),'origin':o,'rotation':[0,0,0],'visibility':True,'export':True,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}};groups.append(g);node={'uuid':g['uuid'],'children':[],'isOpen':False};nodes[name]=node;(nodes[parent]['children']if parent else tree).append(node)
def cube(name,g,c,sz,color,angle=0,axis='y'):
 lo=[c[i]-sz[i]/2 for i in range(3)];hi=[c[i]+sz[i]/2 for i in range(3)];x=(color%4)*128;y=(color//4)*256;r=[0,0,0];r['xyz'.index(axis)]=angle
 e={'name':name,'uuid':uid(name),'type':'cube','from':lo,'to':hi,'origin':c,'rotation':r,'rescale':False,'shade':False,'light_emission':15,'box_uv':False,'visibility':True,'export':True,'faces':{f:{'uv':[x+.25,y+.25,x+7.75,y+7.75],'texture':0}for f in ['north','east','south','west','up','down']}};els.append(e);nodes[g]['children'].append(e['uuid'])
def segment(g,j,radius,y,width,length,color,label):
 theta=math.tau*j/16;angle=-math.degrees(theta);q=math.floor((angle+45)/90);angle-=90*q;sz=[width,.22,length]
 if q%2:sz[0],sz[2]=sz[2],sz[0]
 cube(f'fx_{label}_{j}',g,[1.1+radius*math.cos(theta),y,radius*math.sin(theta)],sz,color,round(angle,6))
group('fx_root',None,[1.1,0,0])
for name,o in [('fx_wave_white',[1.1,.65,0]),('fx_wave_red',[1.1,.75,0]),('fx_compression',[1.1,29.5,0]),('fx_streaks',[1.1,25,0]),('fx_dust',[1.1,1.5,0]),('fx_absorb',[1.1,35,-8])]:group(name,'fx_root',o)
for j in range(16):
 segment('fx_wave_white',j,16,.65,.60,6.4,0,'wave_core')
 segment('fx_wave_white',j,15.25,.82,.42,5.8,1,'wave_edge')
 segment('fx_wave_red',j,15,.75,.38,5.4,2,'wave_trail')
 segment('fx_compression',j,11.5,29.5,.25,2.7,3 if j%2 else 0,'compression')
for j in range(8):
 name='fx_arc_direction_'+str(j);group(name,'fx_streaks',[1.1,25,0]);groups[-1]['rotation']=[0,j*45,0]
 for k,(radius,height,angle)in enumerate([(4,0,-22.5),(8,2.0,-22.5),(12,4.0,-22.5),(16,5.2,0),(20,5.0,22.5)]):
  cube(f'fx_pressure_arc_{j}_{k}_edge',name,[1.1,25+height,-radius],[.65,.35,4.5],1,angle,'x')
  cube(f'fx_pressure_arc_{j}_{k}_core',name,[1.1,25+height+.22,-radius],[.32,.23,4.35],6,angle,'x')
for j in range(8):
 a=math.tau*j/8
 for k in range(4):cube(f'fx_dust_{j}_{k}','fx_dust',[1.1+(10+k)*math.cos(a),1.4+k*.7,(10+k)*math.sin(a)],[1.0,.6,.8],4+k%2,45 if j%2 else 0,'z')
for j,(x,y,z,sz,angle,axis)in enumerate([(-1.8,0,0,[2.6,.22,.35],-45,'z'),(1.8,0,0,[2.6,.22,.35],45,'z'),(0,1.9,0,[.25,2.2,.3],0,'z'),(0,-1.9,0,[.25,2.2,.3],0,'z'),(-2.3,1.5,-.2,[1.8,.18,.25],45,'z'),(2.3,-1.5,-.2,[1.8,.18,.25],45,'z'),(-2.3,-1.5,-.2,[1.8,.18,.25],-45,'z'),(2.3,1.5,-.2,[1.8,.18,.25],-45,'z')]):cube('fx_absorb_flash_'+str(j),'fx_absorb',[1.1+x,35+y,-8+z],sz,6,angle,axis)
def scale_keys(seq):
 return [{'channel':'scale','time':time,'data_points':[{a:str(v)for a,v in zip('xyz',value if isinstance(value,list)else[value]*3)}],'uuid':uid('key/'+str(uuid.uuid4())),'interpolation':interpolation}for time,value,interpolation in seq]
animations={}
for name,length,loop in CLIPS:
 tracks={}
 for g in groups[1:]:
  if g['name'].startswith('fx_arc_direction_'):continue
  seq=[(0,0,'linear'),(length,0,'linear')];gn=g['name']
  if gn=='fx_compression':
   if name=='guard_enter':seq=[(0,0,'linear'),(.3,0,'linear'),(.7,1.12,'linear'),(.85,1,'linear')]
   if name in ['guard_hold','guard_absorb']:seq=[(0,1,'linear'),(length/2,1.04,'linear'),(length,1,'linear')]
   if name=='guard_release':seq=[(0,1,'linear'),(.4,.48,'linear'),(.60,.24,'step'),(.65,0,'linear'),(length,0,'linear')]
  if gn=='fx_absorb' and name=='guard_absorb':seq=[(0,0,'linear'),(.06,1.5,'linear'),(.14,1.9,'step'),(.23,0,'linear'),(.4,0,'linear')]
  if name=='guard_release':
   if gn=='fx_absorb':seq=[(0,0,'step'),(.62,0,'linear'),(.65,2.5,'linear'),(.70,3.7,'step'),(.77,0,'linear'),(length,0,'linear')]
   if gn=='fx_wave_white':seq=[(0,0,'step'),(.62,0,'linear'),(.66,[.4,1,.4],'linear'),(.95,[2.8,1,2.8],'linear'),(length,[3.7,1,3.7],'linear')]
   if gn=='fx_wave_red':seq=[(0,0,'step'),(.74,0,'linear'),(.78,[.3,1,.3],'linear'),(length,[3.0,1,3.0],'linear')]
   if gn=='fx_streaks':seq=[(0,0,'step'),(.63,0,'linear'),(.66,.6,'linear'),(.88,1.6,'step'),(1.04,0,'linear'),(length,0,'linear')]
   if gn=='fx_dust':seq=[(0,0,'step'),(.70,0,'linear'),(.76,.7,'linear'),(length,[2,1,2],'linear')]
  if name=='guard_recover':
   if gn=='fx_wave_white':seq=[(0,[3.7,1,3.7],'linear'),(.15,[4.1,.6,4.1],'step'),(.25,0,'linear'),(length,0,'linear')]
   if gn=='fx_wave_red':seq=[(0,[3.0,1,3.0],'linear'),(.25,[4.0,.6,4.0],'step'),(.35,0,'linear'),(length,0,'linear')]
   if gn=='fx_dust':seq=[(0,[2,1,2],'linear'),(.3,[2.5,.6,2.5],'linear'),(.55,[2.8,.2,2.8],'step'),(.65,0,'linear'),(length,0,'linear')]
  tracks[g['uuid']]={'name':gn,'type':'bone','keyframes':scale_keys(seq)}
 animations[name]=tracks
data={'groups':groups,'elements':els,'outliner':tree,'textures':[t],'animators':animations,'body_cubes':933,'effect_cubes':len(els),'effect_geometry_groups':13,'note':'Temporary modeled pressure VFX; no game effects/damage integration yet.'}
(D/'特效原生导入.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8');print({'effect_cubes':len(els),'effect_bones':len(groups)},flush=True)
