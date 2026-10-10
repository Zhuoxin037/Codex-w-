from pathlib import Path
import json, math, uuid, base64, io, copy, random
import numpy as np
from PIL import Image, ImageDraw

S=Path('D:/数据包/模型设计/调色盘_阶段一')
O=Path('D:/数据包/模型设计/调色盘_阶段二');O.mkdir(parents=True,exist_ok=True)
T=O/'贴图';T.mkdir(exist_ok=True)
V=Path('C:/Users/qq303/.codex/visualizations/2026/09/30/01a0f228-3178-7672-a739-8812e448354c')
bb=json.loads((S/'调色盘_阶段一_分组.bbmodel').read_text(encoding='utf-8'))
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:palette:stage2:'+n))
oldprops={g['uuid']:g for g in bb['groups']};props=[]

# Give every nested group a distinct identity, including repeated slot subgroups.
def expand(node,path='',parent_origin=None):
 g=copy.deepcopy(oldprops[node['uuid']]);path=path+'/'+g['name'];g['uuid']=U(path)
 if g['name'] in ['槽底_浅凹木面','槽壁_分层倒角','颜料填充_颜色可切换']:
  g['origin'][:2]=parent_origin[:2]
 g['children']=[expand(c,path,g['origin']) if isinstance(c,dict) else c for c in node['children']]
 props.append(g);return g
root=expand(bb['outliner'][0]);groups={g['name']:g for g in props};elements=bb['elements'];textures=bb['textures']
for g in props:g['name']=g['name'].replace('_下一阶段','') if g['name'].startswith(('04_','05_','06_')) else g['name']
groups={g['name']:g for g in props}

def group(n,p,origin=(0,0,0),visible=True):
 g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':visible,'export':True,'isOpen':False,'color':len(props)%8,'children':[]}
 props.append(g);groups[n]=g;p['children'].append(g);return g

atlas=Image.open(io.BytesIO(base64.b64decode(textures[0]['source'].split(',')[1]))).convert('RGBA')
materials={'bronze':(159,120,59),'bronze_light':(203,165,94),'bronze_dark':(113,80,42),'olive':(104,109,60),'olive_light':(136,141,82),'olive_dark':(72,81,44),'stem':(127,98,55),'stem_light':(170,137,74),'olive_fruit':(117,104,60),'fruit_light':(158,143,84),'greek_blue':(59,92,135),'paint_red_light':(222,78,65),'paint_yellow_light':(249,198,78),'paint_blue_light':(89,139,193)}
uv={'bronze':[112,0,128,16]};rng=random.Random(102)
d=ImageDraw.Draw(atlas)
for i,(n,c) in enumerate(list(materials.items())[1:],12):
 x=i%8*16;y=i//8*16;uv[n]=[x,y,x+16,y+16];d.rectangle((x,y,x+15,y+15),fill=c+(255,))
 for k in range(10):
  px=x+rng.randrange(16);py=y+rng.randrange(16);v=rng.choice([-4,3]);d.line((px,py,min(x+15,px+2),py),fill=tuple(a+v for a in c)+(255,))

def encode(im):
 f=io.BytesIO();im.save(f,format='PNG');return 'data:image/png;base64,'+base64.b64encode(f.getvalue()).decode()
textures[0]['source']=encode(atlas)

def cube(g,n,a,b,mat='bronze',rotation=0):
 e={'name':n,'uuid':U(n+str(len(elements))),'type':'cube','from':list(a),'to':list(b),'origin':[(x+y)/2 for x,y in zip(a,b)],'rotation':[0,0,rotation],'rescale':False,'box_uv':False,'autouv':0,'visibility':True,'export':True,'faces':{f:{'texture':0,'uv':uv[mat].copy()} for f in ['north','south','east','west','up','down']}}
 elements.append(e);g['children'].append(e['uuid']);return e

def bar(g,n,p,q,width,z0,z1,mat):
 # Step short cuboids along the segment, avoiding unsupported Java rotations.
 p=np.array(p);q=np.array(q);count=max(1,int(np.linalg.norm(q-p)/.12))
 for i in range(count):
  a=p+(q-p)*i/count;b=p+(q-p)*(i+1)/count;lo=np.minimum(a,b)-width/2;hi=np.maximum(a,b)+width/2
  cube(g,n+'_'+str(i),(lo[0],lo[1],z0),(hi[0],hi[1],z1),mat)

def patches(mask,xs,ys,cell,g,name,z0,z1,mat='bronze',front=None):
 m=mask.copy();n=0
 for row in range(m.shape[0]):
  col=0
  while col<m.shape[1]:
   if not m[row,col]:col+=1;continue
   width=1
   while col+width<m.shape[1] and m[row,col+width]:width+=1
   height=1
   while row+height<m.shape[0] and np.all(m[row+height,col:col+width]):height+=1
   m[row:row+height,col:col+width]=False
   e=cube(g,name+'_'+str(n),(float(xs[col]),float(ys[row]),z0),(float(xs[col]+width*cell),float(ys[row]+height*cell),z1),mat)
   if front is not None:
    e['faces']['north']={'texture':front,'uv':[(12-e['to'][0])/24*512,(9-e['to'][1])/18*512,(12-e['from'][0])/24*512,(9-e['from'][1])/18*512]}
   n+=1;col+=width
 return n

# Curved Greek-key inlay follows the approved kidney-shaped boundary.
control=[(-10.4,4.8),(-8,7.3),(-4.2,8.15),(.4,7.9),(5,6.7),(8.55,4.05),(10.45,.3),(10.1,-3.3),(8.4,-6.2),(4.25,-8.1),(.2,-8.2),(-3.45,-6.7),(-5.3,-5.9),(-8,-6.1),(-10.8,-4.1),(-11.4,-.2)]
curve=[]
for i in range(1,10):
 p0,p1,p2,p3=[np.array(control[j%len(control)]) for j in [i-1,i,i+1,i+2]]
 for t in np.arange(0,1,.035):
  p=.5*(2*p1+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t);curve.append(np.array([-p[0],p[1]]))
path=[]
for i,p in enumerate(curve):
 tangent=curve[min(i+1,len(curve)-1)]-curve[max(0,i-1)];tangent/=np.linalg.norm(tangent);normal=np.array([-tangent[1],tangent[0]])
 if np.dot(normal,-p)<0:normal=-normal
 path.append(p+normal*.60)
path=np.array(path);lengths=np.r_[0,np.cumsum(np.linalg.norm(np.diff(path,axis=0),axis=1))]

def closest(X,Y):
 best=np.full(X.shape,np.inf);along=np.zeros(X.shape);cross=np.zeros(X.shape)
 for i,(p,q) in enumerate(zip(path,path[1:])):
  v=q-p;ll=float(v@v);t=np.clip(((X-p[0])*v[0]+(Y-p[1])*v[1])/ll,0,1);dx=X-(p[0]+t*v[0]);dy=Y-(p[1]+t*v[1]);ds=dx*dx+dy*dy;take=ds<best
  best[take]=ds[take];along[take]=lengths[i]+t[take]*math.sqrt(ll);cross[take]=(v[0]*dy[take]-v[1]*dx[take])/math.sqrt(ll)
 return np.sqrt(best),along,cross

px=12-(np.arange(512)+.5)/512*24;py=9-(np.arange(512)+.5)/512*18;XX,YY=np.meshgrid(px,py)
dist,along,cross=closest(XX,YY);im=np.zeros((512,512,4),dtype=np.uint8);im[:]=[229,214,183,255]
u=(along%1.12)/1.12;v=(cross+.38)/.76
key=[(0,.12),(.85,.12),(.85,.86),(.16,.86),(.16,.37),(.58,.37),(.58,.63)]
ink=np.zeros(u.shape,dtype=bool)
for p,q in zip(key,key[1:]):
 if p[0]==q[0]:ink|=(abs(u-p[0])<.052)&(v>=min(p[1],q[1])-.075)&(v<=max(p[1],q[1])+.075)
 else:ink|=(abs(v-p[1])<.085)&(u>=min(p[0],q[0])-.05)&(u<=max(p[0],q[0])+.05)
im[ink]=[61,93,135,255];im[dist>.43]=[218,198,160,255]
decor=Image.fromarray(im);textures.append({'name':'希腊回纹_曲面镶嵌.png','id':'3','uuid':U('greek_texture'),'width':512,'height':512,'uv_width':512,'uv_height':512,'internal':True,'source':encode(decor)})
cell=.20;xs=np.arange(-12,12,cell);ys=np.arange(-9,9,cell);X,Y=np.meshgrid(xs+cell/2,ys+cell/2);dd,aa,cc=closest(X,Y)
mask=(dd<.41)&(aa>.30)&(aa<lengths[-1]-.65)
border=groups['04_希腊回纹'];patches(mask,xs,ys,cell,border,'随曲面铺设的蓝色回纹',-.792,-.730,'bronze_light',3)
# Short blue rim accents on the left edge and at the lower end of the inlay.
accent=group('回纹_蓝色边缘短线',border)
for c in [(9.0,5.7),(9.5,5.3),(10,4.7),(-3.8,-7.7),(-4.4,-7.5)]:
 cube(accent,'边缘蓝色短线',(c[0]-.32,c[1]-.10,-.76),(c[0]+.32,c[1]+.10,-.59),'greek_blue')

# Small bronze clips wrap over the front, edge and back; no floating decoration.
clips=groups['05_青铜边扣']
for i,(x,y,angle) in enumerate([(10.55,2.50,-22.5),(-9.05,-4.20,22.5),(7.05,-5.28,0)]):
 g=group('青铜扣_'+str(i+1)+'_包边与铆钉',clips,(x,y,0))
 cube(g,'扣面_古铜',(x-.48,y-.68,-.87),(x+.48,y+.68,-.71),'bronze',angle)
 cube(g,'扣面亮边',(x-.38,y-.55,-.91),(x+.38,y+.55,-.87),'bronze_light',angle)
 cube(g,'扣背',(x-.45,y-.65,.47),(x+.45,y+.65,.70),'bronze_dark',angle)
 cube(g,'扣侧连接',(x-.50,y-.70,-.72),(x-.32,y+.70,.68),'bronze',angle)
 for yy in [-.40,.40]:cube(g,'扣面铆钉',(x-.09,y+yy-.09,-.99),(x+.09,y+yy+.09,-.91),'bronze_light')

# Raised olive sprig: screen-right lower corner, with pointed leaves and paired fruit.
olive=groups['06_立体橄榄枝'];stem=group('橄榄枝_主干与侧枝',olive)
main=[(-3.45,-6.85),(-3.62,-5.80),(-4.20,-4.65),(-5.06,-3.52),(-6.15,-2.28),(-7.46,-.90)]
for i,(p,q) in enumerate(zip(main,main[1:])):bar(stem,'枝干_'+str(i),p,q,.10,-.93,-.75,'stem')
leafdefs=[((-3.65,-5.90),(-1.95,-5.15)),((-4.12,-4.90),(-3.30,-3.10)),((-4.55,-4.20),(-6.20,-4.02)),((-5.03,-3.55),(-4.85,-1.55)),((-5.64,-2.80),(-7.27,-2.43)),((-6.17,-2.28),(-6.30,-.52)),((-6.73,-1.64),(-8.18,-1.0)),((-7.12,-1.22),(-7.60,.20))]
for i,(base,tip) in enumerate(leafdefs):
 g=group('橄榄叶_'+str(i+1)+'_叶肉与叶脉',olive,(*base,-.90));p=np.array(base);q=np.array(tip);vv=q-p;ll=np.linalg.norm(vv);normal=np.array([-vv[1],vv[0]])/ll
 # Rasterized lanceolate leaf, broad through its middle and tapered at both ends.
 xmin=min(p[0],q[0])-.5;xmax=max(p[0],q[0])+.5;ymin=min(p[1],q[1])-.5;ymax=max(p[1],q[1])+.5
 lx=np.arange(xmin,xmax,.16);ly=np.arange(ymin,ymax,.16);LX,LY=np.meshgrid(lx+.08,ly+.08)
 t=((LX-p[0])*vv[0]+(LY-p[1])*vv[1])/(ll*ll);c=(LX-p[0])*normal[0]+(LY-p[1])*normal[1];w=.27*np.sin(np.clip(t,0,1)*math.pi)**.75
 leaf=(t>=.09)&(t<=.96)&(abs(c)<w)
 patches(leaf,lx,ly,.16,g,'橄榄叶肉',-1.065,-.84,'olive')
 patches(leaf&(c>-.05)&(c<.10),lx,ly,.16,g,'叶脉浅棱',-1.13,-1.065,'olive_light')
 patches(leaf&(c<-.10),lx,ly,.16,g,'叶背暗棱',-1.09,-1.065,'olive_dark')
fruit=group('双橄榄_果实与短梗',olive)
for i,(x,y) in enumerate([(-5.45,-5.55),(-6.60,-4.68)]):
 bar(fruit,'果梗'+str(i),(-4.65,-4.15),(x,y+.28),.10,-.98,-.76,'stem')
 cube(fruit,'橄榄果腰部',(x-.29,y-.21,-1.20),(x+.29,y+.21,-.81),'olive_fruit')
 cube(fruit,'橄榄果圆弧',(x-.24,y-.33,-1.24),(x+.24,y+.33,-.84),'olive_fruit')
 cube(fruit,'橄榄果两端',(x-.14,y-.42,-1.15),(x+.14,y+.42,-.88),'olive_fruit')
 cube(fruit,'橄榄果高光',(x-.14,y-.16,-1.29),(x+.05,y+.16,-1.24),'fruit_light')

# Two small paint ridges give filled wells a moist, thick-pigment surface.
for i,(x,y) in enumerate([(6.75,4.20),(.15,5.05),(-6.2,3.0)]):
 for c,label in [('red','红'),('yellow','黄'),('blue','蓝')]:
  g=groups['槽'+['I','II','III'][i]+'_'+label+'色颜料']
  cube(g,'颜料厚涂弧光',(x-.59,y+.09,-.729),(x-.24,y+.23,-.69),'paint_'+c+'_light')
  cube(g,'颜料次级笔触',(x-.14,y-.30,-.655),(x+.20,y-.19,-.61),'paint_'+c+'_light')

def flat(g):return {k:v for k,v in g.items() if k!='children'}
def out(g):return {'uuid':g['uuid'],'isOpen':g['isOpen'],'children':[out(c) if isinstance(c,dict) else c for c in g['children']]}
display_path=O/'显示调整示例/assets/sweetdream/models/item/palette/display.json';display_path.parent.mkdir(parents=True,exist_ok=True)
display=json.loads((display_path if display_path.exists() else S/'显示调整示例/assets/sweetdream/models/item/palette/display.json').read_text(encoding='utf-8'))
display_path.write_text(json.dumps(display,ensure_ascii=False,indent=2),encoding='utf-8')
bb.update(name='调色盘_阶段二_古希腊装饰与三槽',groups=[flat(g) for g in props],outliner=[out(root)],elements=elements,textures=textures,display=display['display'])
bbpath=O/'调色盘_阶段二_分组.bbmodel';bbpath.write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
for t in textures:(T/t['name']).write_bytes(base64.b64decode(t['source'].split(',')[1]))

def selected(colors=()):
 chosen={'槽'+['I','II','III'][i]+'_'+{'red':'红','yellow':'黄','blue':'蓝'}[c]+'色颜料' for i,c in enumerate(colors)}
 def walk(g):
  if not g.get('visibility',True) and g['name'] not in chosen:return []
  result=[]
  for c in g['children']:result.extend(walk(c) if isinstance(c,dict) else [c])
  return result
 return set(walk(root))
example=[]
for e in elements:
 if e['uuid'] not in selected():continue
 q={'from':[round(v+8,6) for v in e['from']],'to':[round(v+8,6) for v in e['to']],'faces':{}}
 if any(e['rotation']):q['rotation']={'origin':[round(v+8,6) for v in e['origin']],'axis':'z','angle':e['rotation'][2],'rescale':False}
 for f,p in e['faces'].items():
  if p['texture'] is None:continue
  t=textures[int(p['texture'])];q['faces'][f]={'texture':'#'+str(p['texture']),'uv':[round(v*16/(t['uv_width'] if j%2==0 else t['uv_height']),6) for j,v in enumerate(p['uv'])]}
 example.append(q)
texdir=O/'显示调整示例/assets/sweetdream/textures/item/palette';texdir.mkdir(parents=True,exist_ok=True)
for i,t in enumerate(textures):(texdir/('t%d.png'%i)).write_bytes(base64.b64decode(t['source'].split(',')[1]))
texmap={str(i):'sweetdream:item/palette/t%d'%i for i in range(len(textures))};texmap['particle']=texmap['0']
(display_path.parent/'stage2.json').write_text(json.dumps({'parent':'sweetdream:item/palette/display','textures':texmap,'elements':example},ensure_ascii=False,separators=(',',':')),encoding='utf-8')

# Structural checks include group IDs as well as the complete BB 5.2 face schema.
assert len({g['uuid'] for g in props})==len(props)
assert len({e['uuid'] for e in elements})==len(elements)
seen=[]
def collect(g):
 for c in g['children']:collect(c) if isinstance(c,dict) else seen.append(c)
collect(root);assert len(seen)==len(elements) and set(seen)=={e['uuid'] for e in elements}
for e in elements:
 assert set(e['faces'])=={'north','south','east','west','up','down'}
 assert all(a<b for a,b in zip(e['from'],e['to']))
 assert e['rotation'][2] in [-45,-22.5,0,22.5,45]
 assert not(e['from'][0]<7.05<e['to'][0] and e['from'][1]<-3.15<e['to'][1]),e['name']
 for f in e['faces'].values():
  if f['texture'] is None:continue
  t=textures[int(f['texture'])];assert all(0<=v<=(t['uv_width'] if j%2==0 else t['uv_height']) for j,v in enumerate(f['uv']))
for q in example:assert all(-16<=v<=32 for v in q['from']+q['to'])
stats={'empty_visible_cubes':len(selected()),'source_cubes':len(elements),'red_red_visible_cubes':len(selected(['red','red'])),'yellow_blue_visible_cubes':len(selected(['yellow','blue'])),'three_slots_visible_cubes':len(selected(['red','blue','yellow'])),'groups':len(props),'textures':len(textures),'animations':len(bb['animations']),'unique_group_ids':True,'structure_checked':True,'java_static_export_checked':True,'gui_verified':False,'deployed':False}
(O/'模型统计与检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)

# Render exactly the saved source geometry, textures and grouped colour visibility.
source=(V/'render_apocalypse_review.py').read_text(encoding='utf-8').split('def board():')[0]
source=source.replace("O=Path('D:/数据包/模型设计/启示录_审阅版')","O=Path('D:/数据包/模型设计/调色盘_阶段二')").replace('启示录_分组动画.bbmodel','调色盘_阶段二_分组.bbmodel')
source=source.replace("a=bb['animations'][anim];result=[]","a={'animators':{}};result=[]").replace('def walk(g,M,offset):',"def walk(g,M,offset):\n        if not g.get('visibility',True):return").replace("for side,face in e['faces'].items():","for side,face in e['faces'].items():\n            if face.get('texture') is None:continue")
ns={};exec(compile(source,'palette_stage2_renderer','exec'),ns);render=ns['render'];font=ns['font'];small=ns['small'];BG=ns['BG'];rg={}
def cache(g):
 rg[g['name']]=g
 for c in g['children']:
  if isinstance(c,dict):cache(c)
cache(ns['bb']['outliner'][0])
def state(colors):
 for i in range(3):
  for c,label in [('red','红'),('yellow','黄'),('blue','蓝')]:rg['槽'+['I','II','III'][i]+'_'+label+'色颜料']['visibility']=i<len(colors) and colors[i]==c

board=Image.new('RGB',(1680,1200),BG);d=ImageDraw.Draw(board)
d.text((35,25),'调色盘 · 阶段二 / 古希腊回纹、青铜包边与立体橄榄枝',font=font,fill='#ebd7b7')
d.text((35,78),'实际模型渲染 · 保留已确认盘形与三槽比例 · 装饰分别建组 · 尚未接入游戏',font=small,fill='#a7a49b')
state([]);board.paste(render((990,660),yaw=math.pi+.30,pitch=.30,scale=35,focus=(0,0,0)),(10,124))
board.paste(render((610,435),yaw=math.pi,pitch=0,scale=23,focus=(0,0,0)),(1040,125))
board.paste(render((610,205),yaw=math.pi+.24,pitch=1.32,scale=23,focus=(0,0,0)),(1040,595))
d=ImageDraw.Draw(board);d.text((1050,112),'正面 · 三个槽位保持独立',font=small,fill='#dcc6a5');d.text((1050,568),'低侧面 · 薄盘、浅槽、凸起枝叶',font=small,fill='#dcc6a5')
for j,(colors,title) in enumerate([(['red','red'],'重复颜色：红 + 红'),(['yellow','blue'],'双颜色：黄 + 蓝'),(['red','blue','yellow'],'第三槽：超限预留示意')]):
 state(colors);board.paste(render((540,285),yaw=math.pi+.10,pitch=.12,scale=15.8,focus=(0,0,0)),(20+550*j,850));ImageDraw.Draw(board).text((40+550*j,821),title,font=small,fill='#dcc6a5')
state([]);ImageDraw.Draw(board).text((35,1154),f"空盘 {stats['empty_visible_cubes']} 个可见立方体 · 母版 {stats['source_cubes']} 个（含隐藏颜色备选）· {len(props)} 个独立分组",font=small,fill='#a7a49b')
board.save(O/'调色盘_阶段二_实际模型.png')
render((900,720),yaw=math.pi+.25,pitch=.22,scale=80,focus=(-5.1,-3.4,-.7)).save(O/'调色盘_橄榄枝与回纹细节.png')
print('Saved actual stage2 render',flush=True)
