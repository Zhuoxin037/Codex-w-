"""Continue the approved guard without rebuilding it; grouped blade, grip and waves."""
from pathlib import Path
import json,copy,math,uuid,base64,io
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import save_native,export_static,renderer,check

ROOT=Path(__file__).resolve().parents[1]
S=ROOT/'模型设计/深海回响_重设计_20261009/方案二_潮汐卷浪/阶段一_卷浪护手'
O=S.parent/'阶段二_整剑与潮浪';O.mkdir(exist_ok=True)
bb=json.loads((S/'深海回响_卷浪护手_分组.bbmodel').read_text(encoding='utf-8'));original=copy.deepcopy(bb)
byid={g['uuid']:g for g in bb['groups']};groups={}
def expand(n):
    g={**byid[n['uuid']],**n,'children':[expand(c) if isinstance(c,dict) else c for c in n['children']]};groups[g['name']]=g;return g
tree=expand(bb['outliner'][0]);root=tree['name'];elements=bb['elements'];textures=bb['textures']
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:deepsea:tidal:full:'+n))
mats=['abyss','steel','steelblue','silver','edge','shade','blue0','blue1','blue2','blue3','blue4','blue5','blue6','leather','leatheredge','leathershadow']
uv={n:[i%4*32,i//4*32,i%4*32+32,i//4*32+32] for i,n in enumerate(mats)}
atlas=Image.open(io.BytesIO(base64.b64decode(textures[0]['source'].split(',')[1]))).convert('RGBA')
for n,c in [('leather',(17,51,65)),('leatheredge',(29,71,83)),('leathershadow',(10,31,42))]:
    x,y,_,_=uv[n]
    for yy in range(32):
        for xx in range(32):
            v=2 if ((xx+yy)//8)%2==0 else -1;atlas.putpixel((x+xx,y+yy),tuple(a+v for a in c)+(255,))
buf=io.BytesIO();atlas.save(buf,format='PNG');textures[0]['source']='data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode();textures[0]['name']='潮汐整剑_钢晶与靛青皮革.png'
def group(n,p=root,origin=(0,0,0)):
    g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':True,'export':True,'isOpen':True,'color':len(groups)%8,'children':[]};groups[n]=g;groups[p]['children'].append(g);return n
def cube(g,n,a,b,mat,rotation=None,emission=0):
    a,b=list(a),list(b);a[0],b[0]=-b[0],-a[0]
    e={'name':n,'type':'cube','uuid':U(n+str(len(elements))),'from':a,'to':b,'origin':[(v+w)/2 for v,w in zip(a,b)],'rotation':rotation or [0,0,0],'visibility':True,'export':True,'box_uv':False,'autouv':0,'light_emission':emission,'faces':{f:{'texture':0,'uv':uv[mat].copy()} for f in ['north','south','east','west','up','down']}}
    elements.append(e);groups[g]['children'].append(e['uuid']);return e
blade=group('05_实体浪刃');spine=group('剑刃_深渊钢脊',blade);bevel=group('剑刃_双侧银蓝切面',blade);plates=group('剑刃_三段叠接钢片',blade)
def width(y):return float(np.interp(y,[1.6,4.8,9.8,17.5,24.5,28.5,29.2],[.38,1.43,1.18,.86,.49,.13,.012]))
for j,y in enumerate(np.arange(1.55,29.20,.60)):
    h=min(.60,29.20-y);cy=y+h/2;w=width(cy);dep=.045+.37*(1-(cy-1.55)/27.65)
    edge=min(w*.40,.28)
    for side in [-1,1]:
        a,b=(-w,-w+edge) if side<0 else (w-edge,w)
        cube(bevel,'银蓝刃面_%02d_%d'%(j,side),[a,y,-dep-.08],[b,y+h,dep+.05],'silver' if j%9<7 else 'edge')
    inside=max(.008,w-edge)
    # One strong raised ridge and broad recessed facets, with real thickness.
    if inside>.025:
        for side in [-1,1]:
            a,b=(-inside,0) if side<0 else (0,inside)
            cube(plates,'潮钢切面_%02d_%d'%(j,side),[a,y,-dep-.10],[b,y+h,dep+.075],'steel' if side<0 else 'steelblue')
    if w>.17:
        cube(spine,'中央钢脊_%02d'%j,[-min(.115,w*.18),y,-dep-.16],[min(.115,w*.18),y+h,dep+.12],'steel')
# Three tapered overlay roots read as plates, rather than dozens of decorative spikes.
for j,(y,w) in enumerate([(4.5,.78),(13.1,.57),(21.0,.32)]):
    for k in range(5):
        ww=w*(1-k/5);yy=y+k*.21
        cube(plates,'叠片收尖_%d_%d'%(j,k),[-ww,yy,-.57+j*.08],[ww,yy+.23,-.40+j*.06],'steelblue' if k==0 else 'steel')

grip=group('06_剑柄与双束环');leather=group('剑柄_深靛皮革握段',grip,(0,-6.4,0));collars=group('剑柄_磨银束环',grip)
cube(leather,'握柄深色内轴',[-.45,-10.40,-.43],[.45,-2.1,.43],'leathershadow')
for j in range(10):
    y=-2.20-j*.80
    cube(leather,'皮革主缠带_%02d'%j,[-.46,y-.75,-.45],[.46,y,.45],'leather')
    cube(leather,'前皮革斜缠边_%02d'%j,[-.51,y-.39,-.48],[.51,y-.27,-.445],'leatheredge',[0,0,-22.5])
    cube(leather,'后皮革斜缠边_%02d'%j,[-.51,y-.39,.445],[.51,y-.27,.48],'leatheredge',[0,0,22.5])
for j,y in enumerate([-2.23,-10.45]):
    for k,(half,height,mat) in enumerate([(.67,.18,'shade'),(.76,.20,'silver'),(.69,.12,'edge')]):
        yy=y-.14+k*.17
        cube(collars,'束环_%d_%d'%(j,k),[-half,yy,-half*.73],[half,yy+height,half*.73],mat)
pommel=group('07_潮滴尾锤',grip,(0,-11.3,0))
for j in range(12):
    yy=-10.85-j*.20;w=float(np.interp(j,[0,3,6,11],[.36,.81,.54,.035]))
    cube(pommel,'尾锤钢晶座_%02d'%j,[-w,yy-.20,-w*.70],[w,yy,w*.70],'silver' if j<5 else 'shade')
    if 2<=j<=7:
        ww=w*.42;cube(pommel,'尾锤潮纹_%02d'%j,[-ww,yy-.19,-w*.70-.032],[ww,yy-.012,-w*.70+.016],'blue2' if j<5 else 'blue4')

wave=group('08_单侧卷浪_可编辑流动');segments=[]
controls=np.array([[1.10,3.45],[2.03,5.5],[2.72,7.35],[2.39,9.3],[1.42,10.7],[1.17,12.0],[2.02,13.7],[2.37,15.4],[1.92,17.3],[.90,18.8],[.76,20.1],[1.46,22.1],[1.68,23.45],[.95,25.05],[.53,26.6]])
pts=[]
for i in range(len(controls)-1):
    p0=controls[max(0,i-1)];p1=controls[i];p2=controls[i+1];p3=controls[min(len(controls)-1,i+2)]
    for t in [0,.5]:pts.append(.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t))
pts.append(controls[-1])
for i,(a,b) in enumerate(zip(pts,pts[1:])):
    c=(a+b)/2;g=group('浪刃_流动段_%02d'%i,wave,(-float(c[0]),float(c[1]),-.56));segments.append(g)
    taper=.045+.085*math.sin(math.pi*(i+.5)/(len(pts)-1));x0,x1=sorted([float(a[0]),float(b[0])]);y0,y1=sorted([float(a[1]),float(b[1])])
    length=float(np.linalg.norm(b-a))+.20;cx,cy=map(float,c)
    angle=max(-45,min(45,round(math.degrees(math.atan2(b[0]-a[0],b[1]-a[1]))/22.5)*22.5))
    e=cube(g,'卷浪实体_%02d'%i,[cx-taper,cy-length/2,-.69],[cx+taper,cy+length/2,-.35],'blue4',[0,0,angle])
    q=cube(g,'卷浪亮沿_%02d'%i,[cx-taper*.32,cy-length/2,-.733],[cx+taper*.32,cy+length/2,-.69],'blue5',[0,0,angle]);q['origin']=e['origin'].copy()
    if i%5==2:
        cube(g,'海沫细屑_%02d'%i,[x1+.17,y1-.1,-.56],[x1+.24,y1+.04,-.48],'blue5')

# Keep the fixed eyelet in the guard. Only the linked chain + drop swing below it.
swing=group('09_吊坠_以扣眼为轴摆动','04_实接短链与水滴',(-3.93,-.90,.08))
parent=groups['04_实接短链与水滴'];move=[g for g in parent['children'] if isinstance(g,dict) and (g['name'].startswith('短链_') or g['name']=='水滴晶坠_独立摆动')]
parent['children']=[g for g in parent['children'] if g not in move];groups[swing]['children'].extend(move)
def animation(n,length,loop):return {'name':n,'uuid':U(n),'loop':loop,'length':length,'snapping':20,'animators':{}}
idle=animation('01_待机_潮浪沿刃流过',4,'loop');cast=animation('02_施法_潮核涌动',1.8,'once')
def channel(anim,g,c,keys):
    out=anim['animators'].setdefault(groups[g]['uuid'],{'name':g,'type':'bone','keyframes':[]})
    for t,v in keys:out['keyframes'].append({'uuid':U(anim['name']+g+c+str(t)),'channel':c,'time':round(t,6),'interpolation':'linear','data_points':[dict(zip('xyz',[str(round(float(x),6)) for x in v]))]})
channel(idle,'03_球形深蓝潮核','scale',[(0,[1,1,1]),(2,[1.045]*3),(4,[1,1,1])])
channel(idle,swing,'rotation',[(0,[0,0,0]),(1,[0,0,2.4]),(2,[0,0,0]),(3,[0,0,-2.4]),(4,[0,0,0])])
channel(cast,root,'position',[(0,[0,0,0]),(.3,[0,-.17,.15]),(.65,[0,.15,-.32]),(1.4,[0,0,0]),(1.8,[0,0,0])])
channel(cast,'03_球形深蓝潮核','scale',[(0,[1]*3),(.32,[.94]*3),(.65,[1.13]*3),(1.0,[1.04]*3),(1.8,[1]*3)])
channel(cast,swing,'rotation',[(0,[0,0,0]),(.30,[0,0,-4]),(.65,[0,0,7]),(1.25,[0,0,-2]),(1.8,[0,0,0])])
for i,g in enumerate(segments):
    phase=i/(len(segments)-1)
    keys=[];positions=[]
    for t in np.arange(0,4.001,.125):
        pulse=(1+math.cos(math.tau*(t/4-phase)))/2
        keys.append((float(t),[.70+.35*pulse,1,.85+.18*pulse]));positions.append((float(t),[-.06*pulse,.13*pulse,0]))
    channel(idle,g,'scale',keys);channel(idle,g,'position',positions)
    delay=.19+phase*.55
    channel(cast,g,'scale',[(0,[1,1,1]),(delay,[.75,1,.85]),(delay+.18,[1.65,1.07,1.2]),(delay+.40,[1,1,1]),(1.8,[1,1,1])])
    channel(cast,g,'position',[(0,[0,0,0]),(delay,[0,0,0]),(delay+.18,[-.12,.20,-.09]),(delay+.40,[0,0,0]),(1.8,[0,0,0])])
check(elements,groups,root,textures)
# No edits to the approved guard/core elements; animation is on their groups only.
now={e['uuid']:e for e in elements};assert all(now[e['uuid']]==e for e in original['elements'])
keys=[k['uuid'] for a in [idle,cast] for g in a['animators'].values() for k in g['keyframes']];assert len(keys)==len(set(keys))
display=json.loads((ROOT/'sweetdream_rp/assets/deepseaecho/models/item/sword.json').read_text(encoding='utf-8'))['display']
native=save_native(O,'深海回响_潮汐整剑_分组动画',elements,groups,root,textures,display,[idle,cast])
master,count=export_static(O,'sword','deepseaecho',elements,groups,root,textures,display,offset=(7.775,2,7.895))
T=O/'贴图';T.mkdir(exist_ok=True)
for t in textures:(T/t['name']).write_bytes(base64.b64decode(t['source'].split(',')[1]))
r=renderer(native);render=r['render'];font,small=r['font'],r['small'];im=Image.new('RGB',(1570,1280),r['BG']);d=ImageDraw.Draw(im)
d.text((30,23),'深海回响 · 阶段二 / 潮汐整剑',font=font,fill='#bdd8ec');d.text((30,70),'实际分组模型 · 已确认护手 + 深蓝实体刃 + 皮革剑柄 + 单侧卷浪 · 尚未部署',font=small,fill='#9caaba')
im.paste(render((790,1120),yaw=math.pi+.24,pitch=.035,scale=25,focus=(0,7.8,0)),(0,110));im.paste(render((430,1100),yaw=math.pi,pitch=0,scale=23,focus=(0,7.8,0)),(815,115));im.paste(render((300,1100),yaw=math.pi/2+.07,pitch=0,scale=23,focus=(0,7.8,0)),(1260,115))
d=ImageDraw.Draw(im);d.text((830,116),'正面',font=small,fill='#bfd3e6');d.text((1270,116),'近侧面',font=small,fill='#bfd3e6');d.text((30,1220),f'{count} 个立方体 · {len(groups)} 个分组 · 2 段原生动画 · 整体显示 JSON 沿用你的握姿',font=small,fill='#99a8b5');im.save(O/'深海回响_潮汐整剑_实际模型.png')
for ai,label,length,name in [(0,'待机 · 卷浪逐段起伏',4,'深海回响_待机潮浪.gif'),(1,'施法 · 潮核涌动与单侧浪刃',1.8,'深海回响_施法潮浪.gif')]:
    frames=[]
    for t in np.linspace(0,length,33):
        f=Image.new('RGB',(1010,940),r['BG']);f.paste(render((580,820),t=float(t),anim=ai,yaw=math.pi+.20,pitch=.04,scale=17.5,focus=(0,7.8,0)),(0,65));f.paste(render((425,810),t=float(t),anim=ai,yaw=math.pi+.15,pitch=.05,scale=38,focus=(-1.2,15.7,0)),(580,70));ImageDraw.Draw(f).text((22,17),label,font=small,fill='#b9d7eb');ImageDraw.Draw(f).text((22,904),'交付模型的实际关键帧 · 右侧为浪刃局部',font=small,fill='#99a8b5');frames.append(f)
    frames[0].save(O/name,save_all=True,append_images=frames[1:],duration=round(length*1000/32),loop=0,disposal=2)
stats={'cubes':count,'groups':len(groups),'textures':len(textures),'animations':2,'approved_guard_elements_preserved':True,'user_display_preserved':True,'java_static_checked':True,'deployed':False}
(O/'模型检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)
