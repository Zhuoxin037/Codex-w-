from pathlib import Path
import json,math,uuid,base64,copy,io
import numpy as np
from PIL import Image,ImageDraw

B=Path('D:/数据包');S=B/'模型设计/调色盘_阶段二';O=B/'模型设计/调色盘_阶段三';O.mkdir(parents=True,exist_ok=True)
V=Path('C:/Users/qq303/.codex/visualizations/2026/09/30/01a0f228-3178-7672-a739-8812e448354c')
bb=json.loads((S/'调色盘_阶段二_分组.bbmodel').read_text(encoding='utf-8'));props=bb['groups'];elements=bb['elements'];textures=bb['textures']
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:palette:stage3:'+n))
byid={g['uuid']:g for g in props};nodes={}
def expand(n):
 g={**copy.deepcopy(byid[n['uuid']]),'children':[expand(c) if isinstance(c,dict) else c for c in n['children']]};nodes[g['uuid']]=g;return g
root=expand(bb['outliner'][0]);G={g['name']:g for g in nodes.values()}
root['origin']=[7.05,-3.15,-.10]
fx=G['07_施法色带与色彩_下一阶段'];fx['name']='07_施法_色带与汇聚';fx['visibility']=True
centers=[(6.75,4.20),(.15,5.05),(-6.2,3.0)];roman=['I','II','III'];labels={'red':'红','yellow':'黄','blue':'蓝'}
coloruv={'red':[0,64,16,80],'yellow':[16,64,32,80],'blue':[32,64,48,80],'white':[48,64,64,80]}
atlas=Image.open(io.BytesIO(base64.b64decode(textures[0]['source'].split(',')[1]))).convert('RGBA');ad=ImageDraw.Draw(atlas)
for color,base in {'red':(237,81,65),'yellow':(253,191,63),'blue':(77,142,215),'white':(250,241,214)}.items():
 x,y,_,_=coloruv[color];ad.rectangle((x,y,x+15,y+15),fill=base+(255,))
 light=tuple(round(v*.65+255*.35) for v in base)
 ad.rectangle((x,y+5,x+15,y+8),fill=light+(255,));ad.line((x+2,y+3,x+10,y+3),fill=light+(255,))
buf=io.BytesIO();atlas.save(buf,format='PNG');textures[0]['source']='data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()
colored_groups={};ribbonrig=[]

def group(n,p,origin=(0,0,.16),visible=True):
 g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':visible,'export':True,'isOpen':False,'color':len(nodes)%8,'children':[]};nodes[g['uuid']]=g;p['children'].append(g);G[n]=g;return g
def cube(g,n,center,size,color,angle=0):
 center=np.array(center);size=np.array(size);e={'name':n,'uuid':U(n+str(len(elements))),'type':'cube','from':(center-size/2).tolist(),'to':(center+size/2).tolist(),'origin':center.tolist(),'rotation':[0,0,angle],'rescale':False,'box_uv':False,'autouv':0,'visibility':True,'export':True,'light_emission':9,'faces':{f:{'texture':0,'uv':coloruv[color].copy()} for f in ['north','south','east','west','up','down']}}
 elements.append(e);g['children'].append(e['uuid']);return e
def bez(p,t):return (1-t)**3*p[0]+3*(1-t)**2*t*p[1]+3*(1-t)*t*t*p[2]+t**3*p[3]
merge=np.array([0,-.45,-2.8])
for i,(x,y) in enumerate(centers):
 parent=group('色带_槽'+roman[i]+'_七段流动',fx,(x,y,.16))
 points=np.array([[x,y,-.65],[x+(1.35 if i==1 else .65),y+.45,-3.1],[x*.10+(1.2 if i==1 else -.40),.60,-3.25],merge])
 for k in range(7):
  a=bez(points,k/7);b=bez(points,(k+1)/7);c=(a+b)/2;delta=b-a
  g=group('色带_槽'+roman[i]+'_段'+str(k+1),parent,(c[0],c[1],.16));ribbonrig.append((g,k,c[2]))
  angle=round(math.degrees(math.atan2(delta[1],delta[0]))/22.5)*22.5
  angle=(angle+180)%180;swap=45<angle<135
  if swap:angle-=90
  elif angle>=135:angle-=180
  length=math.hypot(delta[0],delta[1])+.15;width=.43-.12*k/6
  size=[width,length,max(.12,abs(delta[2])+.13)] if swap else [length,width,max(.12,abs(delta[2])+.13)]
  for col in labels:
   variant=group('色带_槽'+roman[i]+'_段'+str(k+1)+'_'+labels[col],g,(c[0],c[1],.16),False)
   colored_groups.setdefault((i,col),[]).append(variant)
   e=cube(variant,'流动颜料带_'+roman[i]+'_'+str(k+1)+'_'+col,[c[0],c[1],.16],size,col,angle)
   if swap:e['faces']['north']['rotation']=90

# All held colours become facets of ONE shared projectile, not multiple projectiles.
orb=group('08_色彩_单枚汇聚与飞出',fx,(0,-.45,.16))
for i,offset in enumerate([[.24,.11,0],[-.24,-.11,-.07],[0,.29,.04]]):
 for col in labels:
  variant=group('色彩_槽'+roman[i]+'_'+labels[col]+'色镶面',orb,(0,-.45,.16),False);colored_groups.setdefault((i,col),[]).append(variant)
  for k,(pos,dim) in enumerate([([0,0,0],[.47,.44,.40]),([-.13,.17,-.06],[.23,.21,.24]),([.12,-.15,.07],[.24,.23,.22])]):
   cube(variant,'色彩镶面_'+roman[i]+'_'+col+'_'+str(k),np.array([0,-.45,.16])+offset+pos,dim,col)
cube(orb,'色彩中心亮点',[0,-.45,-.085],[.17,.17,.12],'white')
neutral=group('空盘_素白笔触与色彩',fx,(0,-.45,.16),False)
neutralrig=[]
for k in range(6):
 g=group('素白笔触_段'+str(k+1),neutral,(-.80+k*.25,.60-k*.20,.16));neutralrig.append(g)
 cube(g,'素白汇聚笔触_'+str(k),g['origin'],[.36,.16,.20],'white',-45)
neutralorb=group('空盘_色彩晶点',orb,(0,-.45,.16),False)
for k,(pos,size) in enumerate([([0,0,0],[.45,.45,.38]),([0,.28,0],[.20,.19,.20]),([0,-.28,0],[.20,.19,.20])]):cube(neutralorb,'素白色彩_'+str(k),np.array([0,-.45,.16])+pos,size,'white')
sparks=group('09_汇聚_细小亮屑',fx,(0,-.45,.16));spark_rig=[]
for k in range(6):
 angle=2*math.pi*k/6;c=[math.cos(angle)*.65,-.45+math.sin(angle)*.65,.16]
 g=group('亮屑_'+str(k+1),sparks,c);spark_rig.append((g,angle));cube(g,'汇聚小亮屑_'+str(k),c,[.11,.11,.11],'white')

def animation(name,length,loop):return {'name':name,'uuid':U(name),'loop':loop,'override':False,'length':length,'snapping':20,'anim_time_update':'','blend_weight':'','start_delay':'','loop_delay':'','animators':{}}
idle=animation('01_待机_轻柔持盘',4,'loop');cast=animation('02_施法_提色汇聚与飞出',1.6,'once')
def channel(a,g,chan,keys):
 q=a['animators'].setdefault(g['uuid'],{'name':g['name'],'type':'bone','keyframes':[]})
 for t,v in keys:q['keyframes'].append({'channel':chan,'time':round(t,4),'interpolation':'linear','data_points':[dict(zip('xyz',[str(round(float(x),6)) for x in v]))],'uuid':U(a['name']+g['uuid']+chan+str(t))})
channel(idle,root,'rotation',[(0,[0,0,0]),(1,[.4,0,.35]),(2,[0,0,0]),(3,[-.4,0,-.35]),(4,[0,0,0])])
channel(idle,root,'position',[(0,[0,0,0]),(1,[0,.06,0]),(2,[0,0,0]),(3,[0,-.06,0]),(4,[0,0,0])])
channel(idle,fx,'scale',[(0,[0,0,0]),(4,[0,0,0])])
channel(cast,root,'rotation',[(0,[0,0,0]),(.18,[8,0,-3]),(.38,[15,-3,-6]),(.59,[18,-4,-8]),(.78,[5,0,1]),(1.02,[-2,0,2]),(1.35,[0,0,0]),(1.6,[0,0,0])])
channel(cast,root,'position',[(0,[0,0,0]),(.32,[-.35,.38,-.30]),(.59,[-.50,.50,-.60]),(.78,[.05,.15,.15]),(1.35,[0,0,0]),(1.6,[0,0,0])])
channel(cast,fx,'scale',[(0,[1,1,1]),(1.6,[1,1,1])])
for i,(x,y) in enumerate(centers):
 slot=G['颜料槽_'+roman[i]+'_独立'];pigment=next(c for c in slot['children'] if isinstance(c,dict) and c['name']=='颜料填充_颜色可切换')
 channel(cast,pigment,'position',[(0,[0,0,0]),(.18,[0,0,0]),(.34,[0,-.08,-.55]),(.49,[-x*.045,-.14,-1.10]),(.64,[-x*.07,-.26,-1.65]),(1.6,[-x*.07,-.26,-1.65])])
 channel(cast,pigment,'scale',[(0,[1,1,1]),(.27,[1,1,1]),(.40,[.80,.80,1.1]),(.55,[.35,.35,.8]),(.65,[0,0,0]),(1.6,[0,0,0])])
for g,k,z in ribbonrig:
 delay=k*.017
 channel(cast,g,'scale',[(0,[0,0,0]),(.22+delay,[0,0,0]),(.35+delay,[.65,.65,.70]),(.48+delay,[1,1,1]),(.60+k*.013,[1,1,1]),(.70+k*.014,[.40,.40,.45]),(.81+k*.012,[0,0,0]),(1.6,[0,0,0])])
 channel(cast,g,'position',[(0,[0,0,0]),(.22+delay,[0,0,-.70]),(.38+delay,[0,0,z-.16]),(.58+delay,[.06*math.sin(k),.07*math.cos(k),z-.16-.12]),(.82+delay,[0,0,z-.16]),(1.6,[0,0,z-.16])])
for k,g in enumerate(neutralrig):
 channel(cast,g,'scale',[(0,[0,0,0]),(.24+k*.022,[0,0,0]),(.39+k*.022,[1,1,1]),(.62,[1,1,1]),(.78+k*.013,[0,0,0]),(1.6,[0,0,0])])
 channel(cast,g,'position',[(0,[0,0,0]),(.38,[0,0,-1.50-k*.16]),(.64,[.10,-.20,-2.65]),(1.6,[.10,-.20,-2.65])])
channel(cast,orb,'scale',[(0,[0,0,0]),(.48,[0,0,0]),(.62,[1.35,1.35,1.35]),(.70,[2,2,2]),(.86,[2.12,2.12,2.12]),(1.02,[1.1,1.1,1.1]),(1.13,[0,0,0]),(1.6,[0,0,0])])
channel(cast,orb,'position',[(0,[0,0,-2.96]),(.64,[0,0,-2.96]),(.76,[0,.35,-3.40]),(.90,[0,1.25,-6.5]),(1.13,[0,2.4,-11]),(1.6,[0,2.4,-11])])
channel(cast,orb,'rotation',[(0,[0,0,0]),(.64,[0,0,0]),(1.13,[0,0,100]),(1.6,[0,0,100])])
for k,(g,angle) in enumerate(spark_rig):
 channel(cast,g,'scale',[(0,[0,0,0]),(.47,[0,0,0]),(.57+k*.007,[1,1,1]),(.77,[.7,.7,.7]),(.91,[0,0,0]),(1.6,[0,0,0])])
 channel(cast,g,'position',[(0,[0,0,-2.96]),(.51,[0,0,-2.96]),(.88,[.75*math.cos(angle),.75*math.sin(angle),-4.5]),(1.6,[.75*math.cos(angle),.75*math.sin(angle),-4.5])])

def state(colors):
 for i in range(3):
  for col,label in labels.items():
   G['槽'+roman[i]+'_'+label+'色颜料']['visibility']=i<len(colors) and colors[i]==col
   for g in colored_groups[i,col]:g['visibility']=i<len(colors) and colors[i]==col
 neutral['visibility']=not colors;neutralorb['visibility']=not colors
state(['yellow','blue'])
def out(g):return {'uuid':g['uuid'],'isOpen':g.get('isOpen',False),'children':[out(c) if isinstance(c,dict) else c for c in g['children']]}
bb.update(name='调色盘_阶段三_分组与提色施法动画',elements=elements,groups=[{k:v for k,v in g.items() if k!='children'} for g in nodes.values()],outliner=[out(root)],animations=[idle,cast],editor_state={'mode':'animate'})
bbpath=O/'调色盘_分组动画.bbmodel';bbpath.write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
T=O/'贴图';T.mkdir(exist_ok=True)
for t in textures:(T/t['name']).write_bytes(base64.b64decode(t['source'].split(',')[1]))

# The saved animation keyframes and grouped visibility drive all review pictures.
source=(V/'render_apocalypse_review.py').read_text(encoding='utf-8').split('def board():')[0]
source=source.replace("O=Path('D:/数据包/模型设计/启示录_审阅版')","O=Path('D:/数据包/模型设计/调色盘_阶段三')").replace('启示录_分组动画.bbmodel','调色盘_分组动画.bbmodel')
source=source.replace('def walk(g,M,offset):',"def walk(g,M,offset):\n        if not g.get('visibility',True):return").replace("for side,face in e['faces'].items():","for side,face in e['faces'].items():\n            if face.get('texture') is None:continue")
source=source.replace("tu=np.clip((uv[0]+(uv[2]-uv[0])*u)","fu,fv=u,vv\n            angle=face.get('rotation',0)%360\n            if angle==90:fu,fv=vv,1-u\n            elif angle==180:fu,fv=1-u,1-vv\n            elif angle==270:fu,fv=1-vv,u\n            tu=np.clip((uv[0]+(uv[2]-uv[0])*fu)").replace("(uv[3]-uv[1])*vv","(uv[3]-uv[1])*fv")
ns={};exec(compile(source,'palette_animation_renderer','exec'),ns);render=ns['render'];font=ns['font'];small=ns['small'];BG=ns['BG'];rg={}
def cache(g):
 rg[g['uuid']]=g
 for c in g['children']:
  if isinstance(c,dict):cache(c)
cache(ns['bb']['outliner'][0])
def renderstate(colors):
 state(colors)
 for g in nodes.values():rg[g['uuid']]['visibility']=g.get('visibility',True)

board=Image.new('RGB',(1680,990),BG);d=ImageDraw.Draw(board)
d.text((30,20),'调色盘 · 施法动作分镜（交付模型的实际动画）',font=font,fill='#ebd7b7')
d.text((30,70),'盘面前倾 → 两槽颜料提起 → 各色带汇聚为一枚色彩 → 飞出、回空盘 · 尚未实装',font=small,fill='#a7a49b')
renderstate(['yellow','blue'])
for i,(time,title) in enumerate([(0,'起手 · 黄 + 蓝'),(.42,'提色 · 独立色带'),(.67,'汇聚 · 一枚色彩'),(1.35,'收势 · 颜料槽已清空')]):
 board.paste(render((415,490),t=time,anim=1,yaw=math.pi+.27,pitch=.37,scale=15.6,focus=(0,0,-.7)),(i*420,132));ImageDraw.Draw(board).text((i*420+25,120),title,font=small,fill='#dcc6a5')
for i,(colors,title) in enumerate([([],'空盘 · 素白笔触'),(['red','red'],'重复颜色 · 双红汇聚'),(['red','blue','yellow'],'第三槽 · 超限预留示意')]):
 renderstate(colors);board.paste(render((550,310),t=.70,anim=1,yaw=math.pi+.20,pitch=.35,scale=12.4,focus=(0,0,-.7)),(i*560,655));ImageDraw.Draw(board).text((i*560+25,622),title,font=small,fill='#dcc6a5')
board.save(O/'调色盘_施法动作分镜.png')
renderstate(['yellow','blue']);frames=[]
for i,time in enumerate(np.arange(0,1.601,.05)):
 im=Image.new('RGB',(1140,840),BG);d=ImageDraw.Draw(im)
 d.text((24,18),'调色盘 · 提色、汇聚、飞出（实际模型关键帧）',font=font,fill='#ebd7b7')
 im.paste(render((790,650),t=float(time),anim=1,yaw=math.pi+.30,pitch=.38,scale=29,focus=(0,0,-1.0)),(0,100))
 im.paste(render((345,530),t=float(time),anim=1,yaw=math.pi+.9,pitch=.67,scale=22,focus=(0,0,-2)),(790,160))
 label='起手前倾' if time<.22 else '颜料从槽内提起' if time<.43 else '两色笔触向中心汇聚' if time<.67 else '同一枚色彩向前飞出' if time<1.13 else '收势 · 保留空槽'
 d=ImageDraw.Draw(im);d.text((30,774),label,font=small,fill='#dcc6a5');d.text((812,705),'斜侧面 · 立体提色轨迹',font=small,fill='#a7a49b');frames.append(im)
 if i%10==0:print('Animation frame',i,flush=True)
durations=[400]+[50]*(len(frames)-2)+[650]
frames[0].save(O/'调色盘_施法动画.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2)

# Provide a complete Java preview parent, so Blockbench has actual geometry to open.
renderstate([]);preview=ns['scene'](0,0);models=O/'显示调整示例/assets/palette/models/item';models.mkdir(parents=True,exist_ok=True)
texdir=O/'显示调整示例/assets/palette/textures/item';texdir.mkdir(parents=True,exist_ok=True)
texmap={str(i):'palette:item/t'+str(i) for i in range(len(textures))};texmap['particle']=texmap['0']
for i,t in enumerate(textures):(texdir/('t%d.png'%i)).write_bytes(base64.b64decode(t['source'].split(',')[1]))
output=[]
for e,vs,mat in preview:
 q={'from':[round(v+8,6) for v in e['from']],'to':[round(v+8,6) for v in e['to']],'faces':{}}
 if any(e['rotation']):q['rotation']={'axis':'z','angle':e['rotation'][2],'origin':[round(v+8,6) for v in e['origin']],'rescale':False}
 for side,f in e['faces'].items():
  if f['texture'] is None:continue
  tex=textures[int(f['texture'])];q['faces'][side]={'texture':'#'+str(f['texture']),'uv':[round(v*16/(tex['uv_width'] if k%2==0 else tex['uv_height']),6) for k,v in enumerate(f['uv'])]}
 output.append(q)
displaypath=models/'palette.json';display=bb['display']
if displaypath.exists():display=json.loads(displaypath.read_text(encoding='utf-8'))['display']
displaypath.write_text(json.dumps({'credit':'Edit the whole palette DISPLAY here','ambientocclusion':False,'textures':texmap,'elements':output,'display':display},ensure_ascii=False,indent=2),encoding='utf-8')

eids={e['uuid'] for e in elements};gids=set(nodes);seen=[]
def check(g):
 for c in g['children']:check(c) if isinstance(c,dict) else seen.append(c)
check(root);assert len(seen)==len(eids)==len(elements) and set(seen)==eids
assert len(bb['groups'])==len(gids)
for e in elements:
 assert set(e['faces'])=={'north','south','east','west','up','down'} and all(a<b for a,b in zip(e['from'],e['to']))
 for f in e['faces'].values():
  if f['texture'] is None:continue
  tex=textures[int(f['texture'])]
  assert all(0<=v<=(tex['uv_width'] if k%2==0 else tex['uv_height']) for k,v in enumerate(f['uv']))
for a in bb['animations']:
 assert set(a['animators']).issubset(gids)
 for animator in a['animators'].values():
  assert all(0<=k['time']<=a['length'] for k in animator['keyframes'])
  for ch in ['position','rotation','scale']:
   times=[k['time'] for k in animator['keyframes'] if k['channel']==ch];assert len(times)==len(set(times))
stats={'source_cubes':len(elements),'groups':len(bb['groups']),'textures':len(textures),'animations':[a['name'] for a in bb['animations']],'cast_duration_seconds':1.6,'empty_idle_visible_cubes':len(preview),'whole_display_json':str(displaypath),'structure_checked':True,'gameplay_unchanged':True,'game_baked':False,'gui_verified':False,'deployed':False}
for colors,name in [(['yellow','blue'],'two_colors'),(['red','red'],'red_red'),(['red','blue','yellow'],'third_slot_demo')]:
 renderstate(colors);stats[name+'_idle_cubes']=len(ns['scene'](0,0));stats[name+'_cast_peak_cubes']=max(len(ns['scene'](float(t),1)) for t in np.arange(0,1.601,.05))
 # Recovery must return the exact static empty palette, with all paint and FX gone.
 final=ns['scene'](1.6,1);assert len(final)==len(preview)
 before={e['uuid']:vs for e,vs,_ in preview}
 assert all(e['uuid'] in before and np.allclose(vs,before[e['uuid']]) for e,vs,_ in final)
for q in output:
 assert all(-16<=v<=32 for v in q['from']+q['to'])
 assert q.get('rotation',{}).get('angle',0) in [-45,-22.5,0,22.5,45]
stats['cast_recovers_exact_empty_palette']=True
(O/'模型统计与检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=True),flush=True)
