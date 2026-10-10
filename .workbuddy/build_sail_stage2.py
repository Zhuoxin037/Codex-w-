from pathlib import Path
import json,math,uuid,base64,copy,io,random
from PIL import Image,ImageDraw,ImageFont
import numpy as np

S=Path('D:/数据包/模型设计/风帆_阶段一');O=Path('D:/数据包/模型设计/风帆_阶段二');O.mkdir(parents=True,exist_ok=True)
V=Path('C:/Users/qq303/.codex/visualizations/2026/09/30/01a0f228-3178-7672-a739-8812e448354c')
T=O/'贴图';T.mkdir(exist_ok=True)
bb=json.loads((S/'风帆_阶段一_分组.bbmodel').read_text(encoding='utf-8'));els=bb['elements'];G={g['name']:g for g in bb['groups']};tree={}
def register(n):
 tree[n['uuid']]=n
 for c in n['children']:
  if isinstance(c,dict):register(c)
for n in bb['outliner']:register(n)
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:sail:stage2:'+s))
def rename(a,b):
 g=G.pop(a);g['name']=b;G[b]=g;return b
main=rename('06_主帆_下一阶段','06_主帆_五区柔性帆面');rear=rename('07_后帆_下一阶段','07_后帆_错层柔性帆面');spars=rename('08_帆骨_下一阶段','08_帆骨与固定索')
mainzones=[rename('主帆_形变带_%02d'%(i+1),'主帆_形变区_%02d'%(i+1)) for i in range(5)]
rearzones=[rename('后帆_形变带_%02d'%(i+1),'后帆_形变区_%02d'%(i+1)) for i in range(3)]
def group(n,p,origin):
 g={'name':n,'uuid':uid(n),'origin':list(origin),'rotation':[0,0,0],'visibility':True,'export':True,'isOpen':False,'color':len(G)%8};bb['groups'].append(g);G[n]=g
 node={'uuid':g['uuid'],'isOpen':False,'children':[]};tree[g['uuid']]=node;tree[G[p]['uuid']]['children'].append(node);return n
material={'wood':[0,0,16,16],'woodlight':[16,0,32,16],'wooddark':[32,0,48,16],'brass':[48,0,64,16],'edge':[64,0,80,16],'shadow':[80,0,96,16],'ivory':[0,16,16,32],'silver':[16,16,32,32]}
def box(g,n,a,b,mat='ivory'):
 a=list(a);b=list(b);assert all(x<y for x,y in zip(a,b)),n
 e={'name':n,'type':'cube','uuid':uid(n+'_'+str(len(els))),'from':a,'to':b,'origin':[(x+y)/2 for x,y in zip(a,b)],'rotation':[0,0,0],'rescale':False,'box_uv':False,'autouv':0,'visibility':True,'export':True,'faces':{f:{'uv':material[mat].copy(),'texture':0} for f in ['north','south','east','west','up','down']}}
 els.append(e);tree[G[g]['uuid']]['children'].append(e['uuid']);return e
def texture(im,name):
 im.save(T/name);j=len(bb['textures']);bb['textures'].append({'name':name,'id':str(j),'uuid':uid(name),'width':im.width,'height':im.height,'uv_width':im.width,'uv_height':im.height,'internal':True,'source':'data:image/png;base64,'+base64.b64encode((T/name).read_bytes()).decode()});return j
for t in bb['textures']:(T/t['name']).write_bytes(base64.b64decode(t['source'].split(',')[1]))

# Pixel-authored chart fabric. World-coordinate UVs maintain the artwork across all strips.
im=Image.new('RGBA',(128,128),(218,210,189,255));d=ImageDraw.Draw(im);rng=random.Random(830)
for x in range(128):
 for y in range(128):
  if x%16==0 or y%16==0:d.point((x,y),fill=(204,197,177))
for j in range(65):
 x=rng.randrange(128);y=rng.randrange(128);d.line((x,y,min(x+3,127),y),fill=(222,215,195))
ink=(95,124,132);pale=(151,169,168)
for offset in [0,8]:
 pts=[(x,round(99-offset+10*math.sin(x/27+.5))) for x in range(128)]
 d.line(pts,fill=ink if offset==0 else pale,width=2 if offset==0 else 1)
pts=[(x,round(56+12*math.sin(x/30+1.4))) for x in range(128)];d.line(pts,fill=pale)
cx,cy=61,65
circle=[(cx+round(13*math.cos(a*math.pi/4)),cy+round(13*math.sin(a*math.pi/4))) for a in range(9)];d.line(circle,fill=ink,width=1)
for a in range(4):
 r=a*math.pi/2;v=np.array([math.cos(r),math.sin(r)]);p=np.array([-v[1],v[0]]);c=np.array([cx,cy])
 d.polygon([tuple(c+v*19),tuple(c+p*3),tuple(c-v*3),tuple(c-p*3)],fill=ink)
for x,y in [(20,25),(42,43),(78,42),(96,80)]:d.line((x-2,y,x+2,y),fill=ink);d.line((x,y-2,x,y+2),fill=ink)
for x,y in [(20,25),(42,43),(78,42)]:d.line((x,y,x+7,y+4),fill=pale)
cloth=texture(im,'主帆_织布航图.png')
rimtex=Image.new('RGBA',(128,128),(40,68,74,255));rd=ImageDraw.Draw(rimtex)
for y in range(8,128,16):rd.line([(x,y+round(4*math.sin(x/20))) for x in range(128)],fill=(55,86,89),width=2)
for x in range(0,128,8):rd.line((x,0,x,127),fill=(35,60,67))
backtex=texture(rimtex,'后帆_暗青织纹.png')

rig=[]
def main_span(u):return 23.8+2.6*u,37.35-10.95*u
def billow(u,v):return -.48-2.95*math.sin(math.pi*u)*math.sin(math.pi*v)
# Each strip is a bone; physical cuboids change pose, preserving actual curved volume.
for i in range(24):
 u=(i+.5)/24;g=group('主帆_活动帆片_%02d'%(i+1),mainzones[min(4,i*5//24)],(-.90,30,-.48));rig.append((g,u,False))
 left,right=i/24,(i+1)/24;lo,hi=main_span(u);height=hi-lo
 rows=max(1,math.ceil(height/.88))
 for j in range(rows):
  v0=j/rows;v1=(j+1)/rows;v=(v0+v1)/2;x0=-.9-12.25*right;x1=-.9-12.25*left;y0=lo+height*v0;y1=lo+height*v1;z=billow(u,v)
  corners=[billow(uu,vv) for uu in [left,right] for vv in [v0,v1]]
  e=box(g,'主帆织布_%02d_%02d'%(i,j),(x0-.035,y0-.04,min(corners)-.14),(x1+.035,y1+.04,max(corners)+.14))
  faceuv=[left*128,(37.35-y1)/13.55*128,right*128,(37.35-y0)/13.55*128]
  for f in ['north','south']:e['faces'][f]={'texture':cloth,'uv':faceuv}
 # Reinforced outer and lower seams follow the same animated strip.
 for vv,label in [(0,'下缘'),(1,'上缘')]:
  y=lo if vv==0 else hi;z=billow(u,vv)
  e=box(g,'主帆_'+label+'加强缝边',(-.9-12.25*right-.035,y-.11,z-.24),(-.9-12.25*left+.035,y+.11,z+.24),'wooddark')

# Rear counter-sail: triangular, visibly behind the mast, balanced against main sail.
for i in range(11):
 u=(i+.5)/11;g=group('后帆_活动帆片_%02d'%(i+1),rearzones[min(2,i*3//11)],(.6,29,.95));rig.append((g,u,True))
 a=i/11;b=(i+1)/11;x0=.7+5.55*a;x1=.7+5.55*b;lo=24.3+.8*u;hi=35.65-10.5*u;rows=max(1,math.ceil((hi-lo)/1.0))
 for j in range(rows):
  v0=j/rows;v1=(j+1)/rows;v=(v0+v1)/2;z=1.02+1.05*math.sin(math.pi*u)*math.sin(math.pi*v)
  y0=lo+(hi-lo)*v0;y1=lo+(hi-lo)*v1
  corners=[1.02+1.05*math.sin(math.pi*uu)*math.sin(math.pi*vv) for uu in [a,b] for vv in [v0,v1]]
  e=box(g,'后帆织布_%02d_%02d'%(i,j),(x0-.035,y0-.04,min(corners)-.12),(x1+.035,y1+.04,max(corners)+.12),'wooddark')
  for f in ['north','south']:e['faces'][f]={'texture':backtex,'uv':[a*128,(35.65-y1)/11.35*128,b*128,(35.65-y0)/11.35*128]}
 for y in [lo,hi]:box(g,'后帆加强边',(x0-.04,y-.10,.80),(x1+.04,y+.10,1.20),'wooddark')

# Supporting spars are separated from the soft fabric and attached to mast clamps.
def stepped_spar(name,pts,width=.34,depth=.58):
 g=group(name,spars,pts[0]);count=0
 for a,b in zip(pts,pts[1:]):
  length=math.dist(a,b);N=max(1,math.ceil(length/.47))
  for k in range(N):
   p=np.array(a)+(np.array(b)-a)*(k+.5)/N
   half=np.maximum(np.abs(np.array(b)-a)/N/2+.025,[width/2,width/2,depth/2])
   box(g,name+'_%02d'%count,p-half,p+half,'wooddark');count+=1
 return g
stepped_spar('主帆_下桁杆',[(-.45,23.65,.10),(-6.9,24.94,.10),(-13.28,26.42,.10)],.40,.64)
stepped_spar('主帆_上帆骨',[(-.62,37.65,.05),(-3.3,35.1,.05),(-7.4,31.6,.05),(-13.28,26.42,.05)],.34,.56)
stepped_spar('后帆_下桁杆',[(.45,24.0,1.18),(6.44,25.1,1.18)],.30,.48)
# A narrow hanging support line from the upper collar to the rear outer attachment.
stepped_spar('后帆_张紧索',[(.45,36.0,1.32),(6.44,25.1,1.32)],.085,.12)
for x,y,z in [(-.66,37.6,.05),(-13.2,26.45,.05),(-.52,23.65,.1),(.52,35.95,1.25),(6.35,25.1,1.20)]:
 box(spars,'铜制帆角连接扣',(x-.35,y-.36,z-.40),(x+.35,y+.36,z+.40),'brass')
 box(spars,'帆角扣高光',(x-.25,y+.23,z-.46),(x+.25,y+.36,z-.39),'edge')
# Mast lugs are actual contacts; no floating sail corners.
for y,z in [(37.6,.05),(23.7,.10),(35.95,1.25),(24.05,1.20)]:
 box(spars,'桅杆固定榫',(-.73,y-.19,-.1),(.73,y+.19,z+.35),'brass')

def anim(name,length,loop):return {'name':name,'uuid':uid(name),'loop':loop,'override':False,'length':length,'snapping':20,'anim_time_update':'','blend_weight':'','start_delay':'','loop_delay':'','animators':{}}
idle=anim('01_待机_轻风鼓帆',4,'loop');cast=anim('02_施法_阵风鼓帆',4,'once')
def channel(a,g,c,keys):
 q=a['animators'].setdefault(G[g]['uuid'],{'name':g,'type':'bone','keyframes':[]})
 for t,v in keys:q['keyframes'].append({'channel':c,'time':round(float(t),4),'interpolation':'linear','data_points':[dict(zip('xyz',[str(round(x,6)) for x in v]))],'uuid':uid(a['name']+g+c+str(t))})
times=np.arange(0,4.0001,.1)
for g,u,isrear in rig:
 phase=u*1.65+(1.0 if isrear else 0);fall=math.sin(math.pi*u);amp=.44 if isrear else .86
 pos_idle=[];pos_cast=[];scale_idle=[];scale_cast=[];rot_cast=[]
 for t in times:
  gentle=.11*fall*math.sin(t*math.pi/2-phase)
  env=0 if t<=.2 or t>=3.65 else math.sin(math.pi*min(1,(t-.2)/.6)/2)*min(1,(3.65-t)/.6)
  wave=math.sin(2*math.pi*(t-.15)/.92-phase);z=amp*fall*wave*env
  pos_idle.append((t,[0,0,gentle]));pos_cast.append((t,[0,0,z]))
  scale_idle.append((t,[1,1,1+.035*math.sin(t*math.pi/2-phase)]))
  scale_cast.append((t,[1,1,1+env*(.15+.26*wave)]))
  rot_cast.append((t,[0,env*1.1*fall*math.sin(2*math.pi*t/.92-phase+.7),0]))
 channel(idle,g,'position',pos_idle);channel(idle,g,'scale',scale_idle)
 channel(cast,g,'position',pos_cast);channel(cast,g,'scale',scale_cast);channel(cast,g,'rotation',rot_cast)
channel(idle,'罗盘_可转动指针','rotation',[(0,[0,0,-4]),(1,[0,0,5]),(2,[0,0,9]),(3,[0,0,1]),(4,[0,0,-4])])
channel(cast,'罗盘_可转动指针','rotation',[(0,[0,0,0]),(.35,[0,0,12]),(.95,[0,0,100]),(1.55,[0,0,180]),(2.2,[0,0,270]),(3.1,[0,0,350]),(3.8,[0,0,360]),(4,[0,0,360])])
channel(cast,'05_连接环与垂饰','rotation',[(0,[0,0,0]),(.4,[5,0,-5]),(.85,[-8,0,7]),(1.3,[7,0,-6]),(1.85,[-6,0,6]),(2.3,[6,0,-5]),(2.9,[-4,0,4]),(3.6,[0,0,0]),(4,[0,0,0])])
bb['name']='风帆_阶段二_双帆与阵风动画';bb['animations']=[idle,cast];bb['editor_state']={'mode':'edit'}
displaypath=O/'显示调整示例/assets/sweetdream/models/item/sail/display.json';displaypath.parent.mkdir(parents=True,exist_ok=True)
original=S/'显示调整示例/assets/sweetdream/models/item/sail/display.json'
display=json.loads((displaypath if displaypath.exists() else original).read_text(encoding='utf-8'))
bb['display']=display['display'];displaypath.write_text(json.dumps(display,ensure_ascii=False,indent=2),encoding='utf-8')
(O/'风帆_阶段二_分组动画.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')

# Static Java export: no arbitrary angles, common display parent, same source cuboids.
models=displaypath.parent;texdir=O/'显示调整示例/assets/sweetdream/textures/item/sail';texdir.mkdir(parents=True,exist_ok=True)
textures={}
for i,t in enumerate(bb['textures']):
 (texdir/('t%d.png'%i)).write_bytes(base64.b64decode(t['source'].split(',')[1]));textures[str(i)]='sweetdream:item/sail/t%d'%i
textures['particle']=textures['0'];out=[]
for e in els:
 q={'from':[round(v+o,6) for v,o in zip(e['from'],[8,-12,8])],'to':[round(v+o,6) for v,o in zip(e['to'],[8,-12,8])],'faces':{f:{'uv':[round(v/8,6) for v in face['uv']],'texture':'#'+str(face['texture'])} for f,face in e['faces'].items()}}
 if any(e['rotation']):
  assert e['rotation'][0]==e['rotation'][1]==0
  q['rotation']={'axis':'z','angle':e['rotation'][2],'origin':[round(v+o,6) for v,o in zip(e['origin'],[8,-12,8])],'rescale':False}
  assert q['rotation']['angle'] in [-45,-22.5,0,22.5,45]
 assert all(-16<=x<=32 for x in q['from']+q['to'])
 out.append(q)
(models/'stage2.json').write_text(json.dumps({'parent':'sweetdream:item/sail/display','textures':textures,'elements':out},ensure_ascii=False,separators=(',',':')),encoding='utf-8')

# Reuse the exact-model renderer; render animation keyframes from this saved bbmodel.
source=(V/'render_apocalypse_review.py').read_text(encoding='utf-8').split('def board():')[0]
source=source.replace("O=Path('D:/数据包/模型设计/启示录_审阅版')","O=Path('D:/数据包/模型设计/风帆_阶段二')").replace('启示录_分组动画.bbmodel','风帆_阶段二_分组动画.bbmodel')
ns={};exec(compile(source,'sail_stage2_renderer','exec'),ns);render=ns['render'];font=ns['font'];small=ns['small'];BG=ns['BG']
im=Image.new('RGB',(1680,1140),BG);d=ImageDraw.Draw(im);d.text((35,24),'风帆 · 阶段二 / 鼓帆、后帆与帆骨',font=font,fill='#e3d4b9');d.text((35,75),'实际分组模型渲染 · 曲面织布 / 前后错层 / 可编辑阵风关键帧 · 尚未接入游戏',font=small,fill='#a5adb0')
im.paste(render((790,920),t=0,anim=1,yaw=math.pi+.32,pitch=.07,scale=21,focus=(-2.7,20.5,-.8)),(10,130))
im.paste(render((415,670),t=0,anim=1,yaw=math.pi,pitch=0,scale=14.8,focus=(-3.1,21.7,-.8)),(810,130))
im.paste(render((405,670),t=0,anim=1,yaw=math.pi+math.pi/2,pitch=0,scale=14.8,focus=(-3.1,21.7,-.8)),(1245,130))
im.paste(render((790,250),t=.8,anim=1,yaw=math.pi+.55,pitch=.1,scale=17.8,focus=(-3.3,30.7,-.9)),(840,820))
d=ImageDraw.Draw(im);d.text((825,120),'正面 · 整体帆形',font=small,fill='#d3c4a8');d.text((1260,120),'侧面 · 帆腹体积',font=small,fill='#d3c4a8');d.text((845,792),'阵风中间帧 · 帆面几何实际起伏',font=small,fill='#d3c4a8');d.text((35,1080),f'{len(els)} 个立方体 · {len(bb["groups"])} 个分组 · 3 张贴图 · 待机与施法 2 段动画',font=small,fill='#a5adb0');im.save(O/'风帆_阶段二_完整模型.png')
frames=[]
for i,t in enumerate(np.arange(0,4,.1)):
 im=Image.new('RGB',(1100,840),BG);d=ImageDraw.Draw(im);d.text((25,19),'风帆 · 施法阵风起伏（实际模型动画）',font=font,fill='#e3d4b9')
 im.paste(render((680,680),t=float(t),anim=1,yaw=math.pi+.42,pitch=.06,scale=15.3,focus=(-2.8,21.4,-.8)),(0,80))
 im.paste(render((405,550),t=float(t),anim=1,yaw=math.pi+1.35,pitch=.05,scale=20,focus=(-4.6,30.7,-.8)),(688,145))
 d=ImageDraw.Draw(im);d.text((30,782),'帆腹受风鼓起与回落 · 后帆延迟跟随 · 4 秒动作审阅',font=small,fill='#a5adb0');d.text((715,710),'侧面：检查帆面形变',font=small,fill='#d3c4a8');frames.append(im)
 if i%10==0:print('GIF frame',i,flush=True)
frames[0].save(O/'风帆_阶段二_强风起伏.gif',save_all=True,append_images=frames[1:],duration=100,loop=0,disposal=2)
# Structural checks address the previous partial-load bug and protect frame parent inheritance.
eids={e['uuid'] for e in els};gids={g['uuid'] for g in bb['groups']};seen=[];seen_g=[]
def check(n):
 assert n['uuid'] in gids;seen_g.append(n['uuid'])
 for c in n['children']:
  if isinstance(c,dict):check(c)
  else:assert c in eids;seen.append(c)
for n in bb['outliner']:check(n)
assert len(seen)==len(set(seen))==len(eids)==len(els)
assert len(seen_g)==len(set(seen_g))==len(gids)
for e in els:
 assert set(e['faces'])=={'north','south','east','west','up','down'}
 for f in e['faces'].values():assert 0<=int(f['texture'])<len(bb['textures']) and all(0<=v<=128 for v in f['uv'])
for a in bb['animations']:
 assert set(a['animators']).issubset(gids)
 for q in a['animators'].values():assert all(0<=k['time']<=a['length'] for k in q['keyframes'])
stats={'cuboids':len(els),'faces':len(els)*6,'groups':len(bb['groups']),'textures':len(bb['textures']),'animations':[a['name'] for a in bb['animations']],'structure_checked':True,'static_java_export_checked':True,'animation_runtime_baked':False,'gui_verified':False,'deployed':False}
(O/'模型统计与检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False))
