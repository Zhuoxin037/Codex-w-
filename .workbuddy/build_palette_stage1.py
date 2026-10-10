from pathlib import Path
import json,math,uuid,base64,random,copy,collections
import numpy as np
from PIL import Image,ImageDraw

O=Path('D:/数据包/模型设计/调色盘_阶段一');O.mkdir(parents=True,exist_ok=True)
T=O/'贴图';T.mkdir(exist_ok=True)
V=Path('C:/Users/qq303/.codex/visualizations/2026/09/30/01a0f228-3178-7672-a739-8812e448354c')
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:palette:stage1:'+n))
materials={'terracotta':(131,77,48),'edge':(178,115,70),'shadow':(91,55,36),'ivory':(226,211,178),'bevel':(203,180,139),'well':(139,117,91),'wellshadow':(104,83,59),'bronze':(159,120,59),'red':(186,45,40),'yellow':(223,166,40),'blue':(45,94,157),'highlight':(238,220,181)}
atlas=Image.new('RGBA',(128,128));d=ImageDraw.Draw(atlas);uv={};rng=random.Random(1008)
for i,(n,c) in enumerate(materials.items()):
 x=i%8*16;y=i//8*16;uv[n]=[x,y,x+16,y+16];d.rectangle((x,y,x+15,y+15),fill=c+(255,))
 for k in range(12):
  px=x+rng.randrange(16);py=y+rng.randrange(16);v=rng.choice([-7,-4,4,7]);d.line((px,py,min(x+15,px+2),py),fill=tuple(max(0,min(255,a+v)) for a in c))
atlas.save(T/'调色盘_基材与颜料.png')
wood=Image.new('RGBA',(128,128),(232,218,186,255));d=ImageDraw.Draw(wood)
for y in range(128):
 for x in range(128):
  wave=math.sin((y+.8*math.sin(x/18))/2.8)+.65*math.sin(y/8+x/33)
  delta=round(wave*2);wood.putpixel((x,y),(232+delta,218+delta,186+delta,255))
for j in range(48):
 x=rng.randrange(128);y=rng.randrange(128);v=rng.choice([-5,-3,3]);c=(232+v,218+v,186+v);d.line((x,y,min(127,x+rng.randrange(3,12)),y),fill=c)
wood.save(T/'盘面_象牙白木纹.png')
label=Image.new('RGBA',(64,16),(0,0,0,0));d=ImageDraw.Draw(label)
for i in range(3):
 x=16*i+8-i*2
 for j in range(i+1):
  xx=x+j*4;d.line((xx,3,xx,12),fill=(130,96,62),width=2);d.line((xx-1,3,xx+2,3),fill=(130,96,62));d.line((xx-1,12,xx+2,12),fill=(130,96,62))
label.save(T/'槽位编号_I_II_III.png')
textures=[]
for i,name in enumerate(['调色盘_基材与颜料.png','盘面_象牙白木纹.png','槽位编号_I_II_III.png']):
 im=Image.open(T/name);textures.append({'name':name,'id':str(i),'uuid':U(name),'width':im.width,'height':im.height,'uv_width':im.width,'uv_height':im.height,'internal':True,'source':'data:image/png;base64,'+base64.b64encode((T/name).read_bytes()).decode()})
groups={};elements=[]
def group(n,p=None,origin=(0,0,0),visible=True):
 g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':visible,'export':True,'isOpen':p is None,'color':len(groups)%8,'children':[]};groups[n]=g
 if p:groups[p]['children'].append(g)
 return n
root=group('00_调色盘_整体与握持');body=group('01_肾形盘体',root);core=group('盘体_陶土色木胎',body);face=group('盘体_象牙白混色面',body);bevel=group('盘体_边缘倒角',body);thumb=group('02_贯穿拇指孔',root);slots=group('03_三个独立颜料浅槽',root)
for n in ['04_希腊回纹_下一阶段','05_青铜边扣_下一阶段','06_立体橄榄枝_下一阶段','07_施法色带与色彩_下一阶段']:group(n,root)
def cube(g,n,a,b,mat='ivory',front_texture=False):
 a=list(a);b=list(b);assert all(x<y for x,y in zip(a,b))
 e={'name':n,'type':'cube','uuid':U(n+str(len(elements))),'from':a,'to':b,'origin':[(x+y)/2 for x,y in zip(a,b)],'rotation':[0,0,0],'rescale':False,'box_uv':False,'autouv':0,'visibility':True,'export':True,'faces':{f:{'texture':0,'uv':uv[mat].copy()} for f in ['north','south','east','west','up','down']}}
 if front_texture:e['faces']['north']={'texture':1,'uv':[(12-b[0])/24*128,(9-b[1])/18*128,(12-a[0])/24*128,(9-a[1])/18*128]}
 elements.append(e);groups[g]['children'].append(e['uuid']);return e

# Screen-space shape follows the selected concept; x is mirrored in model coordinates.
control=[(-10.4,4.8),(-8.0,7.3),(-4.2,8.15),(.4,7.9),(5.0,6.7),(8.55,4.05),(10.45,.3),(10.1,-3.3),(8.4,-6.2),(4.25,-8.1),(.2,-8.2),(-3.45,-6.7),(-5.3,-5.9),(-8.0,-6.1),(-10.8,-4.1),(-11.4,-.2)]
poly=[]
for i in range(len(control)):
 p0=np.array(control[(i-1)%len(control)]);p1=np.array(control[i]);p2=np.array(control[(i+1)%len(control)]);p3=np.array(control[(i+2)%len(control)])
 for t in np.arange(0,1,.08):
  p=.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t);poly.append([-p[0],p[1]])
CELL=.40;xs=np.arange(-12,12,CELL);ys=np.arange(-9,9,CELL);X,Y=np.meshgrid(xs+CELL/2,ys+CELL/2)
def inside_polygon(points):
 result=np.zeros(X.shape,dtype=bool)
 for a,b in zip(points,points[1:]+points[:1]):
  if abs(a[1]-b[1])<1e-9:continue
  result^=((a[1]>Y)!=(b[1]>Y))&(X<(b[0]-a[0])*(Y-a[1])/(b[1]-a[1])+a[0])
 return result
def erode(m):
 r=m.copy();r[1:]&=m[:-1];r[:-1]&=m[1:];r[:,1:]&=m[:,:-1];r[:,:-1]&=m[:,1:];r[0]=r[-1]=False;r[:,0]=r[:,-1]=False;return r
HOLE_X,HOLE_Y=7.05,-3.15
outline=inside_polygon(poly);hole=((X-HOLE_X)/2.10)**2+((Y-HOLE_Y)/1.92)**2<1
shape=outline&~hole
centers=[(6.75,4.20),(.15,5.05),(-6.2,3.0)]
def octagon(x,y,r):return inside_polygon([[x+r*math.cos(math.radians(22.5+i*45)),y+r*math.sin(math.radians(22.5+i*45))] for i in range(8)])
def patches(mask,g,name,z0,z1,mat,front=False):
 # Greedy rectangles cover each solid region exactly; holes are never filled by a giant slab.
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
   cube(g,name+'_%03d'%n,(xs[col],ys[row],z0),(xs[col]+width*CELL,ys[row]+height*CELL,z1),mat,front);n+=1;col+=width
 return n
patches(shape,core,'木胎连片',-.23,.45,'terracotta')
patches(erode(shape),core,'背面倒角木胎',.45,.62,'shadow')
outer=shape&~erode(shape);thumb_edge=outer&((((X-HOLE_X)/2.10)**2+((Y-HOLE_Y)/1.92)**2)<1.65)
patches(outer&~thumb_edge,bevel,'外缘温色倒角',-.53,-.23,'edge')
patches(thumb_edge,thumb,'拇指孔内壁',-.58,-.23,'edge')
coat=erode(shape);well_outer=[]
for x,y in centers:
 q=octagon(x,y,2.18)&shape;well_outer.append(q);coat&=~q
patches(coat,face,'盘面连续木纹',-.69,-.23,'ivory',True)
patches(erode(shape)&~erode(erode(shape))&~np.logical_or.reduce(well_outer),bevel,'盘面细倒角',-.73,-.53,'bevel')
pigments={};slotgroups=[]
for i,(x,y) in enumerate(centers):
 s=group('颜料槽_'+['I','II','III'][i]+'_独立',slots,(x,y,-.45));slotgroups.append(s)
 bottom=group('槽底_浅凹木面',s,(x,y,-.34));walls=group('槽壁_分层倒角',s,(x,y,-.48));pig=group('颜料填充_颜色可切换',s,(x,y,-.40))
 inner=octagon(x,y,1.66)&shape;outer=well_outer[i];middle=octagon(x,y,1.94)&shape
 patches(inner,bottom,'颜料浅槽底',-.32,-.23,'well')
 patches(middle&~inner,walls,'浅槽内侧暗倒角',-.59,-.28,'wellshadow')
 patches(outer&~middle,walls,'槽缘浅色倒角',-.76,-.42,'bevel')
 patches(outer&~octagon(x,y,2.01),walls,'浅槽外缘亮切面',-.79,-.74,'ivory')
 patches(middle&~octagon(x,y,1.80),walls,'槽缘细亮边',-.71,-.59,'ivory')
 # Labels are shallow textured quads, with explicit disabled-face records for BB compatibility.
 e=cube(s,'槽位编号_'+str(i+1),(x-.35,y-2.75,-.712),(x+.35,y-2.30,-.698))
 for f in e['faces']:e['faces'][f]={'texture':None,'uv':[0,0,0,0]}
 e['faces']['north']={'texture':2,'uv':[i*16,0,i*16+16,16]}
 for color,labeln in [('red','红'),('yellow','黄'),('blue','蓝')]:
  g=group('槽%s_%s色颜料'%(['I','II','III'][i],labeln),pig,(x,y,-.40),False);pigments[i,color]=g
  fill=octagon(x,y,1.43)&inner
  patches(fill,g,'颜料底层',-.50,-.33,color)
  mound=octagon(x-.18,y+.03,.96)&inner
  patches(mound,g,'颜料隆起',-.61,-.50,color)
  crest=octagon(x-.30,y+.16,.53)&inner
  patches(crest,g,'颜料厚涂尖峰',-.69,-.61,color)

# All review model states reuse one display parent; no game binding at this stage.
display_path=O/'显示调整示例/assets/sweetdream/models/item/palette/display.json';display_path.parent.mkdir(parents=True,exist_ok=True)
initial={'gui':{'rotation':[0,180,-8],'translation':[0,0,0],'scale':[.58]*3},'firstperson_righthand':{'rotation':[12,165,-18],'translation':[-1,1,-2],'scale':[.55]*3},'firstperson_lefthand':{'rotation':[12,-165,18],'translation':[-1,1,-2],'scale':[.55]*3},'thirdperson_righthand':{'rotation':[10,180,-12],'translation':[0,2,0],'scale':[.45]*3},'thirdperson_lefthand':{'rotation':[10,-180,12],'translation':[0,2,0],'scale':[.45]*3},'ground':{'rotation':[90,0,0],'translation':[0,2,0],'scale':[.45]*3},'fixed':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[.55]*3}}
display=json.loads(display_path.read_text(encoding='utf-8')) if display_path.exists() else {'display':initial};display_path.write_text(json.dumps(display,ensure_ascii=False,indent=2),encoding='utf-8')
def outliner(g):return {'uuid':g['uuid'],'isOpen':g['isOpen'],'children':[outliner(c) if isinstance(c,dict) else c for c in g['children']]}
bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':'调色盘_阶段一_盘体与三槽','resolution':{'width':128,'height':128},'elements':elements,'groups':[{k:v for k,v in g.items() if k!='children'} for g in groups.values()],'outliner':[outliner(groups[root])],'textures':textures,'animations':[],'display':display['display']}
(O/'调色盘_阶段一_分组.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
hidden={groups[n]['uuid'] for n in pigments.values()}
def selected_ids(colors=()):
 selected={groups[pigments[i,c]]['uuid'] for i,c in enumerate(colors) if c}
 def walk(g):
  if g['uuid'] in hidden and g['uuid'] not in selected:return []
  a=[]
  for c in g['children']:a.extend(walk(c) if isinstance(c,dict) else [c])
  return a
 return set(walk(groups[root]))
emptyids=selected_ids();example=[]
for e in elements:
 if e['uuid'] not in emptyids:continue
 q={'from':[round(v+8,6) for v in e['from']],'to':[round(v+8,6) for v in e['to']],'faces':{}}
 for f,p in e['faces'].items():
  if p['texture'] is None:continue
  t=textures[int(p['texture'])];q['faces'][f]={'texture':'#'+str(p['texture']),'uv':[round(v*16/(t['uv_width'] if j%2==0 else t['uv_height']),6) for j,v in enumerate(p['uv'])]}
 assert all(-16<=v<=32 for v in q['from']+q['to']);example.append(q)
texdir=O/'显示调整示例/assets/sweetdream/textures/item/palette';texdir.mkdir(parents=True,exist_ok=True)
for i,t in enumerate(textures):(texdir/('t%d.png'%i)).write_bytes(base64.b64decode(t['source'].split(',')[1]))
texmap={str(i):'sweetdream:item/palette/t%d'%i for i in range(len(textures))};texmap['particle']=texmap['0']
(display_path.parent/'stage1.json').write_text(json.dumps({'parent':'sweetdream:item/palette/display','textures':texmap,'elements':example},ensure_ascii=False,separators=(',',':')),encoding='utf-8')

# Renderer respects the source's group visibility and disabled faces.
source=(V/'render_apocalypse_review.py').read_text(encoding='utf-8').split('def board():')[0]
source=source.replace("O=Path('D:/数据包/模型设计/启示录_审阅版')","O=Path('D:/数据包/模型设计/调色盘_阶段一')").replace('启示录_分组动画.bbmodel','调色盘_阶段一_分组.bbmodel')
source=source.replace("a=bb['animations'][anim];result=[]","a={'animators':{}};result=[]")
source=source.replace("def walk(g,M,offset):","def walk(g,M,offset):\n        if not g.get('visibility',True):return")
source=source.replace("for side,face in e['faces'].items():","for side,face in e['faces'].items():\n            if face.get('texture') is None:continue")
ns={};exec(compile(source,'palette_stage1_renderer','exec'),ns);render=ns['render'];font=ns['font'];small=ns['small'];BG=ns['BG']
rendergroups={}
def cache(g):
 rendergroups[g['uuid']]=g
 for c in g['children']:
  if isinstance(c,dict):cache(c)
for g in ns['bb']['outliner']:cache(g)
def state(colors):
 for (i,c),n in pigments.items():rendergroups[groups[n]['uuid']]['visibility']=i<len(colors) and colors[i]==c

board=Image.new('RGB',(1680,1150),BG);d=ImageDraw.Draw(board);d.text((35,25),'调色盘 · 阶段一 / 盘体、贯穿拇指孔与三个浅槽',font=font,fill='#ebd7b7');d.text((35,78),'实际模型渲染 · 古希腊回纹、青铜边扣与橄榄枝将在下一阶段添加 · 尚未接入游戏',font=small,fill='#a7a49b')
state([]);board.paste(render((990,650),yaw=math.pi+.33,pitch=.31,scale=34,focus=(0,0,0)),(10,128))
board.paste(render((610,430),yaw=math.pi,pitch=0,scale=23,focus=(0,0,0)),(1040,132));board.paste(render((610,195),yaw=math.pi+.3,pitch=1.36,scale=22,focus=(0,0,0)),(1040,586))
d=ImageDraw.Draw(board);d.text((1050,110),'正面 · 三槽位置与拇指孔',font=small,fill='#dcc6a5');d.text((1050,560),'低侧面 · 薄盘与浅凹结构',font=small,fill='#dcc6a5')
for j,(colors,title) in enumerate([(['red','red'],'重复颜色：红 + 红'),(['yellow','blue'],'双颜色：黄 + 蓝'),(['red','blue','yellow'],'第三槽：超限预留示意')]):
 state(colors);board.paste(render((540,285),yaw=math.pi+.1,pitch=.1,scale=15.9,focus=(0,0,0)),(20+550*j,820));ImageDraw.Draw(board).text((40+550*j,795),title,font=small,fill='#dcc6a5')
state([]);d=ImageDraw.Draw(board);d.text((35,1110),f'空盘 {len(emptyids)} 个可见立方体 · 母版含 {len(elements)} 个立方体（含隐藏颜色备选）· {len(groups)} 个分组',font=small,fill='#a7a49b');board.save(O/'调色盘_阶段一_实际模型.png')

# Checks: all pieces belong to one group, six face records complete, hole is genuinely clear.
assert len({e['uuid'] for e in elements})==len(elements)
seen=[]
def walk(g):
 for c in g['children']:walk(c) if isinstance(c,dict) else seen.append(c)
walk(groups[root]);assert set(seen)=={e['uuid'] for e in elements} and len(seen)==len(elements)
for e in elements:
 assert set(e['faces'])=={'north','south','east','west','up','down'}
 for f in e['faces'].values():
  if f['texture'] is None:continue
  t=textures[int(f['texture'])];assert all(0<=v<=(t['uv_width'] if j%2==0 else t['uv_height']) for j,v in enumerate(f['uv']))
 # Neither hidden pigments nor static structure may bridge the centre of the thumb hole.
 assert not(e['from'][0]<HOLE_X<e['to'][0] and e['from'][1]<HOLE_Y<e['to'][1]),e['name']
# Flood-fill the hole to prove that its wooden rim closes all the way around it.
start=(int(np.argmin(abs(Y[:,0]-HOLE_Y))),int(np.argmin(abs(X[0]-HOLE_X))))
visited={start};q=collections.deque([start])
while q:
 r,c=q.popleft()
 assert r not in [0,shape.shape[0]-1] and c not in [0,shape.shape[1]-1],'Thumb hole opens into outside boundary'
 for rr,cc in [(r+1,c),(r-1,c),(r,c+1),(r,c-1)]:
  if 0<=rr<shape.shape[0] and 0<=cc<shape.shape[1] and not shape[rr,cc] and (rr,cc) not in visited:visited.add((rr,cc));q.append((rr,cc))
stats={'empty_visible_cubes':len(emptyids),'source_cubes':len(elements),'red_red_visible_cubes':len(selected_ids(['red','red'])),'yellow_blue_visible_cubes':len(selected_ids(['yellow','blue'])),'three_slots_visible_cubes':len(selected_ids(['red','blue','yellow'])),'groups':len(groups),'textures':len(textures),'animations':0,'genuine_thumb_hole':True,'structure_checked':True,'java_static_export_checked':True,'gui_verified':False,'deployed':False}
(O/'模型统计与检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False))
