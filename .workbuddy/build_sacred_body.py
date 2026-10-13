"""Add only the second stage. The approved, MCP-authored head is immutable."""
from pathlib import Path
import base64, collections, copy, hashlib, io, json, math, random, uuid
from PIL import Image, ImageDraw
from model_review_io import renderer

BASE=Path('D:/数据包/模型设计/圣骸_建模_20261012')
SRC=BASE/'阶段一_骸骨核心与肋刃/圣骸_阶段一_分组模型.bbmodel'
OUT=BASE/'阶段二_整件与垂挂圣物';OUT.mkdir(parents=True,exist_ok=True)
bb=json.loads(SRC.read_text(encoding='utf-8'))
assert len(bb['elements'])==541
SEED=uuid.UUID('6f3c12dc-69b1-4781-aab8-f821179361c6')
uid=lambda n:str(uuid.uuid5(SEED,n))
E=[];G=[];counts=collections.Counter()
SIDES=['north','south','east','west','up','down']

# A muted material sheet for leather, cloth, etched brass and the memory tablet.
rng=random.Random(4012)
colors=['#352b27','#473831','#5c4539','#211e1b',
        '#582c2d','#7c3c36','#a2604a','#c6b68f',
        '#9c8052','#baa06b','#6e583b','#c7bb9f',
        '#e0d4bd','#8d8171','#4e5048','#aaa494']
atlas=Image.new('RGB',(256,256),'#423a30');d=ImageDraw.Draw(atlas)
for mat,col in enumerate(colors):
 rgb=tuple(int(col[i:i+2],16) for i in (1,3,5))
 x=(mat%8)*32;y=(mat//8)*32
 for py in range(32):
  for px in range(32):
   shade=rng.choice([-3,-2,-1,0,0,0,1,2,3])
   if mat in [0,1,2,3]:shade+=int(3*math.sin(px*.6))+int(1.8*math.sin(py*.3))
   if mat in [4,5]:shade+=int(3*math.cos(px*.42))
   atlas.putpixel((x+px,y+py),tuple(max(0,min(255,c+shade)) for c in rgb))
 if mat in [0,1,2,3]:
  for px in [7,22]:d.line((x+px,y+3,x+px,y+28),fill=tuple(max(0,c-12) for c in rgb))
 if mat in [4,5]:
  d.line((x+3,y+2,x+3,y+29),fill=colors[6],width=1)
  d.line((x+27,y+2,x+27,y+29),fill='#442423',width=2)

# Four dedicated leather sides: one continuous worn scarlet winding at each height.
for side in range(4):
 x0=side*32
 for py in range(128):
  for px in range(32):
   rgb=(49,39,34);noise=rng.choice([-3,-1,0,0,1,2])
   atlas.putpixel((x0+px,80+py),tuple(c+noise for c in rgb))
  center=(py*.68-side*8)%34
  for px in range(32):
   q=min(abs(px-center),abs(px-center+34),abs(px-center-34))
   if q<1.4:atlas.putpixel((x0+px,80+py),(122,61,48))
   elif q<2.3:atlas.putpixel((x0+px,80+py),(74,34,29))
 for py in range(84,205,10):
  px=x0+rng.randint(3,27)
  d.line((px,py,px+2,py+2),fill='#6a5344')

# Recessed funerary markings on both faces, not an invented title or literal text.
gx,gy=160,96
d.rectangle((gx,gy,gx+63,gy+95),fill='#a39880')
for py in range(96):
 for px in range(64):
  if rng.random()<.10:
   n=rng.choice([-4,3]);atlas.putpixel((gx+px,gy+py),(163+n,152+n,128+n))
ink='#5b5347';shine='#cdc1a7'
d.line((gx+31,gy+10,gx+31,gy+80),fill=ink,width=2)
for a,b in [((16,22),(46,22)),((22,40),(40,40)),((17,58),(45,58))]:
 d.line((gx+a[0],gy+a[1],gx+b[0],gy+b[1]),fill=ink,width=2)
for xx,yy in [(31,12),(18,23),(45,23),(23,39),(39,39),(18,59),(44,59),(31,78)]:
 d.rectangle((gx+xx-2,gy+yy-2,gx+xx+2,gy+yy+2),fill=ink)
 d.point((gx+xx,gy+yy),fill=shine)
d.line((gx+7,gy+8,gx+7,gy+86),fill='#bcb098')
d.line((gx+55,gy+8,gx+55,gy+86),fill='#bcb098')
atlas_path=OUT/'圣骸_皮革红绸与铭纹.png';atlas.save(atlas_path)

lamp=Image.new('RGB',(256,256),'#d9b072');ld=ImageDraw.Draw(lamp)
for y in range(256):
 for x in range(256):
  v=abs(x-128)/128;noise=rng.choice([-4,-1,0,0,1,3])
  lamp.putpixel((x,y),(min(255,int(255-v*37)+noise),min(255,int(237-v*66)+noise),min(255,int(175-v*81)+noise)))
lamp_path=OUT/'圣骸_魂灯暖芯.png';lamp.save(lamp_path)

def group(name,parent='总体',origin=(8,0,8)):
 q=dict(name=name,uuid=uid('g/'+name),parent=parent,origin=list(origin),rotation=[0,0,0])
 G.append(q);return name

for n in ['脊骨与皮革长柄','褪红祭绸','垂挂魂灯','遗骨铭牌']:
 group(n)
for n,p,o in [
 ('上脊骨节','脊骨与皮革长柄',(8,6.5,8)),
 ('皮革握持区','脊骨与皮革长柄',(8,0,8)),
 ('下脊骨节','脊骨与皮革长柄',(8,-10,8)),
 ('遗骨尾锥','脊骨与皮革长柄',(8,-14,8)),
 ('长祭绸与夹扣','褪红祭绸',(4.1,18.5,10)),
 ('短祭绸与夹扣','褪红祭绸',(5.1,18.5,10)),
 ('魂灯头部挂座','垂挂魂灯',(12.43,18.9,6.5)),
 ('魂灯交错链环','垂挂魂灯',(12.43,18.2,6.12)),
 ('旧金灯笼骨架','垂挂魂灯',(12.43,10.7,6.12)),
 ('暖色残魂灯芯','垂挂魂灯',(12.43,10.7,6.12)),
 ('铭牌肋骨挂座','遗骨铭牌',(4.5,13.5,6.5)),
 ('铭牌交错链环','遗骨铭牌',(4.5,13.2,6.1)),
 ('骨框与凹面铭文','遗骨铭牌',(4.5,5.35,6.1))]:group(n,p,o)

def uv(mat,serial,side,size):
 i=mat*3+serial%3;x=(i%8)*32;y=(i//8)*32
 axes=(0,1) if side in ['north','south'] else (2,1) if side in ['east','west'] else (0,2)
 w=max(2,min(27,round(size[axes[0]]*10)));h=max(2,min(27,round(size[axes[1]]*10)))
 return [x+2,y+2,x+2+w,y+2+h]

def add(g,label,a,b,mat=0,tex=0,light=0,face_uv=None):
 counts[g]+=1;serial=counts[g];name=f'{g}_{label}_{serial:03d}'
 a=[round(float(v),5) for v in a];b=[round(float(v),5) for v in b];size=[y-x for x,y in zip(a,b)]
 assert min(size)>0,name
 if tex==0:faces={s:dict(texture=0,uv=uv(mat,serial,s,size),rotation=0) for s in SIDES}
 else:
  x=(mat%8)*32;y=(mat//8)*32
  faces={s:dict(texture=tex,uv=[x+2,y+2,x+27,y+27],rotation=0) for s in SIDES}
 if face_uv:
  for s,v in face_uv.items():faces[s]['uv']=v
 q=dict(name=name,uuid=uid(name),type='cube',parent=g,origin=[round((x+y)/2,5) for x,y in zip(a,b)],
        rotation=[0,0,0],box_uv=False,autouv=0,faces=faces,**{'from':a,'to':b})
 if light:q['light_emission']=light
 E.append(q);return q

def box(g,label,c,size,mat=0,tex=0,light=0,face_uv=None):
 return add(g,label,[v-s/2 for v,s in zip(c,size)],[v+s/2 for v,s in zip(c,size)],mat,tex,light,face_uv)

def collar(g,y,w=1.55):
 # A marrow center with asymmetric transverse processes and a raised front spine.
 box(g,'骨节髓心',(8,y,8.02),(1.04,.63,1.26),4)
 box(g,'前椎骨',(8,y+.047,7.37),(w,.35,.38),0)
 box(g,'后椎骨',(8,y-.019,8.66),(w-.06,.40,.37),2)
 box(g,'左横突',(8-w*.45,y+.06,8.00),(.46,.37,1.16),2)
 box(g,'右横突',(8+w*.45,y-.08,8.04),(.47,.34,1.14),0)
 box(g,'椎骨前脊',(8,y-.10,7.17),(.39,.48,.27),1)
 box(g,'旧金椎扣',(8,y+.025,6.97),(.27,.20,.15),6)

# Upper exposed spine, then a continuous usable grip, then lower vertebrae.
box('上脊骨节','贯通脊骨',(8,5.67,8.02),(.84,4.21,1.20),5)
for y in [6.54,5.10,3.72]:collar('上脊骨节',y,1.43)
for i in range(9):
 y0=3.52-(i+1)*1.12;y1=3.52-i*1.12+.055
 w=1.11+(.055 if i in [2,3,4,5] else .04)
 p=add('皮革握持区','皮革缠握', [8-w/2,y0,7.35],[8+w/2,y1,8.66],0,3)
 for j,s in enumerate(['north','east','south','west']):
  v0=80+(3.52-y1)/10.08*128;v1=80+(3.52-y0)/10.08*128
  p['faces'][s]['uv']=[j*32+1,v0,j*32+30,v1]
for y in [3.43,-6.51]:
 box('皮革握持区','旧金止口',(8,y,8.01),(1.29,.19,1.57),6)
 box('皮革握持区','磨损止口前棱',(8,y-.027,7.21),(.8,.105,.12),7)
box('皮革握持区','红绳结扣',(8.63,2.93,7.41),(.26,.32,.38),5,3)
box('皮革握持区','结绳短垂一',(8.68,2.42,7.52),(.11,.87,.13),4,3)
box('皮革握持区','结绳短垂二',(8.84,2.62,7.67),(.11,.50,.12),5,3)
box('下脊骨节','下柄髓柱',(8,-10.1,8.02),(.84,7.72,1.20),5)
for i,y in enumerate([-7.09,-8.51,-9.97,-11.39,-12.81]):collar('下脊骨节',y,1.49+(i%2)*.08)
for i,(y,w,h,z) in enumerate([(-13.40,1.37,.40,1.61),(-13.88,1.67,.60,1.85),(-14.35,1.28,.54,1.51),(-14.75,.89,.45,1.10),(-15.09,.51,.44,.66),(-15.41,.24,.29,.35)]):
 box('遗骨尾锥','骨锥分层',(8,y,8.02),(w,h,z),0 if i<3 else 2)
for j,x in enumerate([7.27,8.73]):
 box('遗骨尾锥','尾部侧骨',(x,-13.86,8.04),(.31,.87,.68),2)
 box('遗骨尾锥','尾部收尖',(x+( .12 if j==0 else -.12),-14.46,8.03),(.25,.55,.48),0)
for z in [7.17,8.87]:
 box('遗骨尾锥','尾椎铭封',(8,-13.84,z),(.66,.38,.17),6)
 box('遗骨尾锥','铭封浅槽',(8,-13.80,z+(-.09 if z<8 else .09)),(.29,.15,.10),8)

# Two restrained faded cloth strips hang from the actual mid-rib load bridge.
for short,x,width,top,bottom,z in [(False,4.02,1.08,18.59,.40,9.85),(True,5.03,.73,18.59,5.50,10.09)]:
 g='短祭绸与夹扣' if short else '长祭绸与夹扣'
 box(g,'穿骨夹扣',(x,18.53-(.09 if short else 0),9.08),(width+.24,.33,.69),6)
 box(g,'压绸背扣',(x,18.49,9.67),(width+.11,.24,.19),7)
 n=9 if short else 13
 for i in range(n):
  y1=top-(top-bottom)*i/n+.035;y0=top-(top-bottom)*(i+1)/n
  xc=x+math.sin(i*.74)*(.095 if short else .13)
  ww=width*(1-.15*i/n);zz=z+math.sin(i*.59)*.12
  add(g,'褪色绸段',[xc-ww/2,y0,zz-.09],[xc+ww/2,y1,zz+.09],5 if i%3 else 4,3)
  box(g,'深红折痕',(xc-ww*.19,(y1+y0)/2,zz+.105),(.10,(y1-y0)*.92,.08),4,3)
  if i%3==1:box(g,'磨白绸边',(xc+ww*.41,(y1+y0)/2,zz-.11),(.064,(y1-y0)*.61,.08),6,3)
 for k in range(3):
  box(g,'破绸尾须',(x+(k-1)*width*.27,bottom-.30-k*.14,z+.02),(.08,.71+k*.23,.12),4,3)

def ring(g,label,x,y,z,vertical=False,w=.41,h=.69,t=.108):
 # Alternate XY and YZ loops: real holes and penetrating links, no floating rods.
 if not vertical:
  box(g,label+'左',(x-w/2,y,z),(t,h,t),6)
  box(g,label+'右',(x+w/2,y+.016,z), (t,h,t),6)
  box(g,label+'上',(x,y+h/2,z+.024),(w+.025,t,.125),7)
  box(g,label+'下',(x,y-h/2,z-.019),(w+.025,t,.127),8)
 else:
  box(g,label+'前',(x,y,z-w/2),(t,h,t),6)
  box(g,label+'后',(x+.013,y,z+w/2),(t,h,t),8)
  box(g,label+'上',(x+.025,y+h/2,z),(.13,t,w+.025),7)
  box(g,label+'下',(x-.019,y-h/2,z),(.129,t,w+.025),6)

def hanging_mount(g,x,y):
 # Embedded pin crosses the original bone volume. The eye projects forward.
 box(g,'穿骨销',(x,y,7.19),(.15,.31,1.12),8)
 box(g,'钉首',(x,y,6.59),(.41,.43,.18),7)
 box(g,'前伸挂梁',(x,y-.18,6.35),(.20,.22,.61),6)
 ring(g,'承重挂环',x,y-.40,6.10,False,.36,.46,.12)

LX,LY,LZ=12.39,18.94,6.10
hanging_mount('魂灯头部挂座',LX,LY)
for i in range(10):ring('魂灯交错链环','链环%02d'%(i+1),LX,18.25-i*.62,LZ, i%2==0)
ring('旧金灯笼骨架','灯顶提环',LX,12.29,LZ,True,.35,.43,.105)
# Small open cage, with warm stepped candle within. It is a lantern, not a crystal.
for y,w,deep,h in [(12.00,.68,.65,.16),(11.83,1.03,.91,.16),(11.68,1.24,1.07,.17),
                    (9.89,1.19,1.07,.18),(9.72,.90,.78,.15),(9.53,.51,.47,.20)]:
 box('旧金灯笼骨架','灯笼冠座',(LX,y,LZ),(w,h,deep),6)
for dx,dz in [(-.50,-.40),(.50,-.40),(-.50,.40),(.50,.40)]:
 box('旧金灯笼骨架','灯笼立柱',(LX+dx,10.80,LZ+dz),(.14,1.84,.14),8)
 for y in [10.09,11.48]:box('旧金灯笼骨架','立柱铜节',(LX+dx,y,LZ+dz),(.22,.21,.22),7)
for z in [LZ-.43,LZ+.43]:
 for y in [10.18,11.34]:box('旧金灯笼骨架','横护栏',(LX,y,z),(1.03,.105,.11),6)
for x in [LX-.52,LX+.52]:
 for y in [10.20,11.36]:box('旧金灯笼骨架','侧护栏',(x,y,LZ),(.105,.105,.84),6)
box('旧金灯笼骨架','灯底封钉',(LX,9.35,LZ),(.21,.20,.24),7)
box('暖色残魂灯芯','灰骨烛座',(LX,10.10,LZ),(.58,.19,.53),2)
box('暖色残魂灯芯','残烛白蜡',(LX,10.44,LZ),(.32,.58,.31),13)
for y,w,h in [(10.89,.36,.37),(11.14,.27,.24),(11.34,.14,.24)]:
 box('暖色残魂灯芯','温白魂火',(LX,y,LZ),(w,h,w*.83),0,4,14)

TX,TY,TZ=4.46,13.65,6.10
hanging_mount('铭牌肋骨挂座',TX,TY)
for i in range(9):ring('铭牌交错链环','链环%02d'%(i+1),TX,12.96-i*.66,TZ,i%2==0,w=.36,h=.75,t=.10)
ring('骨框与凹面铭文','铭牌顶提环',TX,7.17,TZ,False,.31,.44,.105)
# An ivory bone frame surrounding a recessed etched plate. Both sides are finished.
CY=5.89
box('骨框与凹面铭文','暗髓底板',(TX,CY,TZ),(.93,2.02,.37),4)
for z in [TZ-.265,TZ+.265]:
 box('骨框与凹面铭文','凹面铭纹',(TX,CY,z),(.65,1.62,.12),11,3,
     face_uv={'north':[160,96,224,192],'south':[224,96,160,192]})
 for x in [TX-.48,TX+.48]:box('骨框与凹面铭文','铭牌侧骨',(x,CY,z),(.19,2.15,.24),0)
 for y in [CY-1.04,CY+1.04]:box('骨框与凹面铭文','铭牌横骨',(TX,y,z),(.92,.20,.27),2)
 for x in [TX-.40,TX+.40]:
  for y in [CY-.93,CY+.93]:box('骨框与凹面铭文','铭牌封钉',(x,y,z+(-.15 if z<TZ else .15)),(.19,.22,.10),7)
box('骨框与凹面铭文','底部遗骨榫',(TX,4.61,TZ),(.30,.42,.31),0)
box('骨框与凹面铭文','遗骨榫暗金扣',(TX,4.45,TZ-.18),(.17,.14,.13),6)

assert len(bb['elements'])+len(E)<=1000,(len(bb['elements']),len(E))
for e in E:assert all(-16<=v<=32 for v in e['from']+e['to'])
# Local review candidate only. Dedicated MCP calls perform the actual authoring.
trial=copy.deepcopy(bb);trial['name']='圣骸_阶段二_比例候选';trial['elements']+=copy.deepcopy(E)
old_groups={g['name']:g['uuid'] for g in bb['groups']}
gd={g['name']:g for g in G};nodes={g['name']:{'uuid':g['uuid'],'isOpen':True,'children':[]} for g in G}
for g in G:
 trial['groups'].append({k:v for k,v in g.items() if k!='parent'})
 if g['parent'] in nodes:nodes[g['parent']]['children'].append(nodes[g['name']])
 else:trial['outliner'][0]['children'].append(nodes[g['name']])
for e in trial['elements'][541:]:nodes[e.pop('parent')]['children'].append(e['uuid'])
for name,pth in [('圣骸_皮革红绸与铭纹.png',atlas_path),('圣骸_魂灯暖芯.png',lamp_path)]:
 trial['textures'].append(dict(name=name,uuid=uid(name),mode='bitmap',uv_width=256,uv_height=256,width=256,height=256,
                              source='data:image/png;base64,'+base64.b64encode(pth.read_bytes()).decode(),path=str(pth)))
display={
 'thirdperson_righthand':{'rotation':[0,-85,0],'translation':[0,6.5,0],'scale':[.6]*3},
 'thirdperson_lefthand':{'rotation':[0,85,0],'translation':[0,6.5,0],'scale':[.6]*3},
 'firstperson_righthand':{'rotation':[0,-55,-8],'translation':[2.8,5.7,-2.6],'scale':[.55]*3},
 'firstperson_lefthand':{'rotation':[0,55,8],'translation':[2.8,5.7,-2.6],'scale':[.55]*3},
 'gui':{'rotation':[0,0,-12],'translation':[0,.3,0],'scale':[.33]*3},
 'ground':{'translation':[0,2,0],'scale':[.28]*3},
 'fixed':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[.32]*3}}
trial['display']=display
candidate=OUT/'圣骸_阶段二_比例候选.bbmodel'
candidate.write_text(json.dumps(trial,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
spec={'groups':G,'cubes':E,'textures':[str(atlas_path),str(lamp_path)],'display':display,
      'approved_head_sha256':hashlib.sha256(SRC.read_bytes()).hexdigest(),
      'approved_head_geometry_sha256':hashlib.sha256(json.dumps(bb['elements'],sort_keys=True).encode()).hexdigest()}
(OUT/'MCP新增部件规格.json').write_text(json.dumps(spec,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
r=renderer(candidate)
lo=[min(e['from'][i] for e in trial['elements']) for i in range(3)]
hi=[max(e['to'][i] for e in trial['elements']) for i in range(3)]
focus=tuple((a+b)/2 for a,b in zip(lo,hi))
r['render']((1050,1480),yaw=math.pi-.12,pitch=.035,scale=29,focus=focus).save(OUT/'内部整件比例检查.png')
print(json.dumps({'head':541,'new_cubes':len(E),'total':541+len(E),'groups_total':len(trial['groups']),'parts':dict(counts)},ensure_ascii=False))
