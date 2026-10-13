"""Return to the supplied thick ring / radial ice-blade reference; static review."""
from pathlib import Path
import json,math,uuid,base64,io,copy,random
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import save_native,export_static,renderer,check

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'模型设计/深海回响_旧稿重建_20261009/阶段一_厚环护手与剑根'
O=BASE.parent/'阶段一_宽剑根连接修订';O.mkdir(parents=True,exist_ok=True)
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:deepsea:oldreference:'+n))
groups={};elements=[]
def group(n,p=None,origin=(0,0,0)):
    g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':True,'export':True,'isOpen':True,'color':len(groups)%8,'children':[]};groups[n]=g
    if p:groups[p]['children'].append(g)
    return n
root=group('00_深海回响_旧稿整体');frame=group('01_厚环护手盘',root)
shell=group('护手盘_厚壁内腔',frame);rim=group('护手盘_前后磨银斜沿',frame);plates=group('护手盘_八处径向扣甲',frame)
supports=group('02_放射刃片_各自独立',root);core=group('03_球形潮核与镶爪',root,(0,0,-.75));gem=group('潮核_立体蓝晶',core);claws=group('潮核_四枚镶爪',core)
chain=group('04_挂环链条与水滴',root,(-2.48,-1.15,0));eye=group('吊坠_护手固定挂环',chain);links=group('吊坠_五节交错链',chain,(-2.55,-1.95,0));drop=group('吊坠_金属盖与水滴晶坠',links,(-2.55,-6.65,0))
blade=group('05_剑根_深蓝脊与双侧冰刃',root);neck=group('06_剑柄连接座',root)
colors={'abyss':(15,25,45),'steel':(38,46,67),'steelfacet':(60,72,98),'shade':(84,99,127),
        'silver':(133,147,175),'silverlit':(169,185,209),'edge':(213,228,241),'silverdark':(99,116,145),
        'ice0':(17,52,125),'ice1':(30,84,180),'ice2':(51,124,218),'ice3':(83,166,239),
        'ice4':(133,201,253),'ice5':(191,228,255),'ice6':(227,247,255),'blueblack':(8,26,72)}
atlas=Image.new('RGBA',(128,128));uv={};rng=random.Random(100909)
for i,(n,c) in enumerate(colors.items()):
    x=i%4*32;y=i//4*32;uv[n]=[x,y,x+32,y+32]
    for yy in range(32):
        for xx in range(32):
            v=rng.choice([-1,0,0,0,1]);atlas.putpixel((x+xx,y+yy),tuple(max(0,min(255,a+v)) for a in c)+(255,))
buf=io.BytesIO();atlas.save(buf,format='PNG')
textures=[{'name':'厚环护手_磨银深钢与冰蓝晶面.png','id':'0','uuid':U('texture'),'width':128,'height':128,'uv_width':128,'uv_height':128,'internal':True,'source':'data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()}]
def cube(g,n,a,b,mat,rotation=None,emission=0):
    a,b=list(a),list(b);a[0],b[0]=-b[0],-a[0]
    e={'name':n,'uuid':U(n+str(len(elements))),'type':'cube','from':a,'to':b,'origin':[(v+w)/2 for v,w in zip(a,b)],'rotation':rotation or [0,0,0],'box_uv':False,'autouv':0,'visibility':True,'export':True,'light_emission':emission,'faces':{f:{'texture':0,'uv':uv[mat].copy()} for f in ['north','south','east','west','up','down']}}
    # Directional material shading belongs to geometry faces, not repeated dark borders.
    if mat in ['silver','silverlit','edge','steelfacet']:
        e['faces']['down']['uv']=uv['shade' if mat!='steelfacet' else 'steel'].copy()
        e['faces']['south']['uv']=uv['silverdark' if mat!='steelfacet' else 'steel'].copy()
    elements.append(e);groups[g]['children'].append(e['uuid']);return e

DX=.20;DY=.20;xs=np.arange(-6.8,6.8,DX);ys=np.arange(-4.6,8.6,DY);X,Y=np.meshgrid(xs+DX/2,ys+DY/2)
def patches(mask,g,n,z0,z1,mat):
    mask=mask.copy();idx=0
    for row in range(mask.shape[0]):
        col=0
        while col<mask.shape[1]:
            if not mask[row,col]:col+=1;continue
            w=1
            while col+w<mask.shape[1] and mask[row,col+w]:w+=1
            h=1
            while row+h<mask.shape[0] and np.all(mask[row+h,col:col+w]):h+=1
            mask[row:row+h,col:col+w]=False
            cube(g,n+'_%03d'%idx,[xs[col],ys[row],z0],[xs[col]+w*DX,ys[row]+h*DY,z1],mat);idx+=1;col+=w

R=np.hypot(X,Y)
# An actual annulus: inner wall remains open behind the four mounting claws.
patches((R<2.38)&(R>1.48),shell,'厚环深钢内壁',-.57,.65,'steel')
patches((R<2.30)&(R>1.56),rim,'前磨银宽斜面',-.73,-.56,'silverdark')
patches((R<2.24)&(R>1.85),rim,'外沿磨银面',-.86,-.725,'silver')
patches((R<2.18)&(R>2.08),rim,'外沿细亮脊',-.91,-.855,'silverlit')
patches((R<1.85)&(R>1.66),rim,'内沿深钢斜面',-.83,-.725,'steelfacet')
patches((R<1.67)&(R>1.48),rim,'镶腔灰蓝斜边',-.91,-.825,'shade')
patches((R<1.61)&(R>1.48),rim,'镶腔细亮边',-.955,-.905,'silver')
patches((R<2.18)&(R>1.69),rim,'后侧磨银环',.65,.80,'silverdark')
patches((R<2.37)&(R>2.24),shell,'环体外周倒角',-.57,.37,'shade')
# Eight discrete plates sit across the annulus; sparse dark joints retain ring clarity.
for j in range(8):
    ang=math.tau*j/8;v=np.array([math.cos(ang),math.sin(ang)]);t=np.array([-v[1],v[0]])
    rad=X*v[0]+Y*v[1];across=abs(X*t[0]+Y*t[1]);m=(rad>1.78)&(rad<2.62)&(across<.27)
    g=group('径向扣甲_'+str(j+1),plates)
    patches(m,g,'暗钢扣甲根',-.98,-.76,'steelfacet')
    patches(m&(rad>2.03),g,'扣甲磨银面',-1.07,-.975,'silver')
    patches(m&(across<.08)&(rad>2.13),g,'扣甲窄亮脊',-1.115,-1.065,'silverlit')

def curve(control,widths):
    pts=[];ww=[]
    for i in range(len(control)-1):
        p0=np.array(control[max(0,i-1)]);p1=np.array(control[i]);p2=np.array(control[i+1]);p3=np.array(control[min(len(control)-1,i+2)])
        for t in np.arange(0,1,.06):
            pts.append(.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t));ww.append(widths[i]*(1-t)+widths[i+1]*t)
    pts=np.array(pts);ww=np.array(ww);dist=np.full(X.shape,np.inf);near=np.zeros(X.shape,dtype=int)
    for i,p in enumerate(pts):
        q=(X-p[0])**2+(Y-p[1])**2;pick=q<dist;dist[pick]=q[pick];near[pick]=i
    tangent=np.gradient(pts,axis=0);normal=np.stack([tangent[:,1],-tangent[:,0]],1);normal/=np.maximum(.001,np.linalg.norm(normal,axis=1)[:,None])
    signed=(X-pts[near,0])*normal[near,0]+(Y-pts[near,1])*normal[near,1]
    return np.sqrt(dist)<ww[near],signed,ww[near],near/(len(pts)-1)
horns=[('上方_高冰角',[[-1.37,1.60],[-2.0,2.40],[-2.35,3.5],[-2.22,4.65],[-1.96,5.8]],[.43,.43,.37,.26,.025]),
       ('上方_低冰角',[[1.38,1.6],[1.9,2.5],[2.20,3.45],[2.1,4.55],[2.3,5.25]],[.43,.41,.33,.24,.025]),
       ('横向_短冰翼',[[-1.86,.66],[-3.1,1.05],[-4.20,.90],[-5.15,.28],[-5.75,.15]],[.45,.49,.40,.23,.02]),
       ('横向_扬冰翼',[[1.8,.45],[3.1,.70],[4.18,1.27],[4.83,2.48],[5.07,3.40]],[.43,.51,.45,.30,.025]),
       ('下方_短冰齿',[[-1.42,-1.45],[-2.3,-2.15],[-3.33,-2.63],[-4.13,-3.15]],[.43,.37,.30,.018]),
       ('下方_长冰齿',[[1.50,-1.43],[2.46,-2.19],[3.1,-3.03],[3.44,-3.88]],[.43,.46,.33,.02])]
for j,(name,control,widths) in enumerate(horns):
    g=group('冰刃_'+name,supports);metal=group('骨架_'+name,g);ice=group('渐蓝晶刃_'+name,g)
    m,s,w,p=curve(control,widths);m&=R>2.00
    # Grey root deliberately transitions to blue crystal; not uniformly cyan tentacles.
    for k,(lo,hi,dep) in enumerate([(0,.30,1),(.30,.54,.84),(.54,.75,.65),(.75,.90,.42),(.9,1.001,.23)]):
        mm=m&(p>=lo)&(p<hi)
        patches(mm,metal,'渐薄深钢厚背'+str(j)+str(k),-.33*dep,.49*dep,'steel')
        patches(mm&(s<.0*w),metal,'渐薄灰蓝切面'+str(j)+str(k),-.55*dep,-.32*dep,'steelfacet')
        if k<3:patches(mm&(s>.42*w),metal,'根部磨银斜沿'+str(j)+str(k),-.69*dep,-.54*dep,'silver')
        if k==0:continue
        patches(mm,ice,'渐薄晶刃蓝段'+str(j)+str(k),-.64*dep,-.31*dep,['steel','ice0','ice1','ice3','ice5'][k])
        patches(mm&(s>.04*w),ice,'晶刃宽亮切面'+str(j)+str(k),-.80*dep,-.63*dep,['silver','ice1','ice2','ice4','ice6'][k])
        patches(mm&(s>.70*w),ice,'晶刃薄亮锋'+str(j)+str(k),-.88*dep,-.795*dep,'ice5' if k<4 else 'ice6')

# Gem terraces encode a real rounded depth and several large deliberate facets.
CS=.20;gx=np.arange(-1.16,1.16,CS);gy=np.arange(-1.16,1.16,CS)
for yy in gy:
    for xx in gx:
        px=xx+CS/2;py=yy+CS/2;rad=px*px+py*py
        if rad>1.12**2:continue
        dep=math.sqrt(max(0,1.12**2-rad));z=-.75-.76*dep
        a=math.atan2(py,px);sector=int((a+math.pi)/(math.pi/4))%8;ring=0 if rad<.36 else 1 if rad<.80 else 2
        level=[[1,1,1,0,1,3,4,2],[1,1,0,0,2,4,5,3],[0,0,0,0,1,3,4,2]][ring][sector]
        e=cube(gem,'潮核圆晶面',[xx,yy,z],[xx+CS,yy+CS/1.0,.20+.42*dep],'ice'+str(level))
        e['faces']['south']['uv']=uv['ice0'].copy();e['faces']['down']['uv']=uv['blueblack'].copy();e['faces']['east']['uv']=uv['ice1'].copy()
cube(gem,'潮核主反光',[-.38,.36,-1.575],[-.12,.58,-1.54],'ice6')
cube(gem,'潮核次反光',[-.08,.57,-1.53],[.10,.69,-1.505],'ice4')
for j in range(4):
    ang=math.tau*j/4;rad=X*math.cos(ang)+Y*math.sin(ang);across=abs(-X*math.sin(ang)+Y*math.cos(ang))
    m=(rad>1.01)&(rad<1.62)&(across<.20)
    patches(m,claws,'四枚实接镶爪'+str(j),-1.13,-.48,'silverdark')
    patches(m&(rad>1.24),claws,'镶爪亮面'+str(j),-1.19,-1.125,'silverlit')

# A connected, beveled sword root allows the next blade stage to grow from this socket.
width=np.interp(Y,[1.65,2.50,3.50,4.5,6.8,8.6],[.78,1.02,1.16,1.10,1.03,.96])
bm=(abs(X)<width)&(Y>1.69)&(Y<8.5)
patches(bm,blade,'剑根深蓝钢体',-.32,.44,'abyss')
patches(bm&(abs(X)<width*.60),blade,'剑根深蓝钢脊',-.52,-.31,'steel')
patches(bm&(X<-.15*width)&(X>-.60*width),blade,'剑根一侧切面',-.59,-.515,'steelfacet')
patches(bm&(abs(X)>width*.61),blade,'剑根磨银主切面',-.46,-.315,'silverdark')
patches(bm&(abs(X)>width*.84),blade,'剑根渐亮冰刃',-.51,-.455,'ice4')
# Two longer, pointed ice fragments break the outline without filling the ring cavity.
for side in [-1,1]:
    p=(Y-4.1)/3.1;mm=(p>=0)&(p<1)&(X*side>width*.77)&(X*side<width+.34*(1-p))
    patches(mm,blade,'剑根冰蓝侧锋'+str(side),-.67,-.30,'ice2')
    patches(mm&(X*side>width+.16*(1-p)),blade,'剑根细白尖沿'+str(side),-.72,-.665,'ice5')

for j in range(5):
    y=-3.45+j*.366;w=.57+j*.042
    cube(neck,'柄座宽肩暗钢轴'+str(j),[-w,y,-.47],[w,y+.366,.47],'steel')
for j,(w,y,h,mat) in enumerate([(.71,-2.23,.18,'silverdark'),(.90,-2.70,.27,'silver'),(.79,-3.04,.15,'silverlit')]):
    cube(neck,'柄座束环_'+str(j),[-w,y,-w*.67],[w,y+h,w*.67],mat)
cube(neck,'握柄接续段',[-.44,-4.00,-.40],[.44,-3.04,.4],'steel')

def link(g,n,x,y,z,w=.44,h=.72,t=.10,side=False):
    if not side:
        cube(g,n+'左',[x-w/2,y-h/2+t,z-t],[x-w/2+t,y+h/2-t,z+t],'silver')
        cube(g,n+'右',[x+w/2-t,y-h/2+t,z-t],[x+w/2,y+h/2-t,z+t],'silverdark')
        cube(g,n+'上',[x-w/2+t,y+h/2-t,z-t],[x+w/2-t,y+h/2,z+t],'silverlit')
        cube(g,n+'下',[x-w/2+t,y-h/2,z-t],[x+w/2-t,y-h/2+t,z+t],'silver')
        for sx in [-1,1]:
            for sy in [-1,1]:cube(g,n+'角',[x+sx*(w/2-t)-t*.38,y+sy*(h/2-t)-t*.38,z-t],[x+sx*(w/2-t)+t*.38,y+sy*(h/2-t)+t*.38,z+t],'silver')
    else:
        cube(g,n+'前',[x-t,y-h/2+t,z-w/2],[x+t,y+h/2-t,z-w/2+t],'silverlit')
        cube(g,n+'后',[x-t,y-h/2+t,z+w/2-t],[x+t,y+h/2-t,z+w/2],'silverdark')
        cube(g,n+'上',[x-t,y+h/2-t,z-w/2],[x+t,y+h/2,z+w/2],'silver')
        cube(g,n+'下',[x-t,y-h/2,z-w/2],[x+t,y-h/2+t,z+w/2],'silver')
ax=-2.55;ay=-1.35
am,_,_,_=curve([[-1.83,-.96],[-2.12,-1.15],[-2.53,-1.50]],[.17,.18,.16])
patches(am,eye,'穿入环体的金属连接舌',-.49,.38,'steelfacet')
patches(am&(Y>-1.33),eye,'连接舌磨银面',-.58,-.48,'silver')
cube(eye,'挂环穿入护手金属爪',[ax-.20,ay-.36,-.24],[ax+.20,ay+.20,.30],'steelfacet')
link(eye,'护手固定挂环',ax,ay-.30,.01,.60,.72,.12,False)
for j in range(5):
    g=group('链节_'+str(j+1),links,(-ax,ay-.86-j*.54,0));link(g,'交错链节'+str(j),ax,ay-.86-j*.54,.01,side=j%2==0)
capY=ay-.86-4*.54-.42
link(drop,'晶坠顶部扣环',ax,capY,.01,.38,.44,.09,False)
for j,(w,y,h,mat) in enumerate([(.30,capY-.34,.16,'silverlit'),(.43,capY-.55,.22,'silver')]):
    cube(drop,'水滴金属封盖'+str(j),[ax-w,y,-w*.58],[ax+w,y+h,w*.58],mat)
top=capY-.50
for j in range(12):
    yy=top-j*.145;w=float(np.interp(j,[0,4,11],[.22,.63,.018]));dep=w*.62
    cube(drop,'水滴中心晶面'+str(j),[ax-w*.48,yy-.145,-dep-.03],[ax+w*.48,yy,dep],'ice2' if j<4 else 'ice1')
    cube(drop,'水滴亮切面'+str(j),[ax-w,yy-.145,-dep*.61],[ax-w*.48,yy,dep*.80],'ice4' if j<7 else 'ice5')
    cube(drop,'水滴暗切面'+str(j),[ax+w*.48,yy-.145,-dep*.61],[ax+w,yy,dep*.80],'ice0')

check(elements,groups,root,textures)
# The approved ring, radial ice blades, gem and chain remain geometrically exact.
before=json.loads((BASE/'深海回响_旧稿厚环护手_分组.bbmodel').read_text(encoding='utf-8'))
def fixed_geometry(els):
    def fixed(e):return not e['name'].startswith(('剑根','柄座','握柄'))
    return sorted(json.dumps({k:v for k,v in e.items() if k!='uuid'},ensure_ascii=False,sort_keys=True) for e in els if fixed(e))
assert fixed_geometry(before['elements'])==fixed_geometry(elements)
display=json.loads((ROOT/'sweetdream_rp_完整版/assets/deepseaecho/models/item/sword.json').read_text(encoding='utf-8'))['display']
native=save_native(O,'深海回响_宽剑根连接_分组',elements,groups,root,textures,display)
master,count=export_static(O,'sword','deepseaecho',elements,groups,root,textures,display,offset=(7.775,2,7.895))
(O/'贴图').mkdir(exist_ok=True);atlas.save(O/'贴图'/textures[0]['name'])
r=renderer(native);im=Image.new('RGB',(1620,1180),r['BG']);d=ImageDraw.Draw(im)
d.text((30,22),'深海回响 · 旧稿重建 / 宽剑根连接修订',font=r['font'],fill='#c0dcf4');d.text((30,68),'实际分组模型 · 加宽剑根与柄座过渡 · 已确认的护手、冰刃和吊坠几何保持 · 尚未部署',font=r['small'],fill='#9cabbc')
im.paste(r['render']((1030,1020),yaw=math.pi+.34,pitch=.11,scale=58,focus=(0,.25,0)),(0,115))
im.paste(r['render']((570,540),yaw=math.pi,pitch=0,scale=33,focus=(0,.38,0)),(1040,110))
im.paste(r['render']((570,370),yaw=math.pi+.92,pitch=.14,scale=66,focus=(0,.10,0)),(1040,675))
d=ImageDraw.Draw(im);d.text((1060,650),'正面：宽剑根嵌入上环',font=r['small'],fill='#a9c9e3');d.text((1060,1060),'斜侧：剑根至柄座的完整过渡',font=r['small'],fill='#a9c9e3');d.text((30,1130),f'{count} 个立方体 · {len(groups)} 个分组 · 护手阶段；完整剑刃继续按旧稿延伸',font=r['small'],fill='#9dabb9');im.save(O/'深海回响_宽剑根连接_实际模型.png')
stats={'cubes':count,'groups':len(groups),'textures':1,'chain_links':5,'static_stage':'widened_blade_root','approved_ring_ice_gem_chain_preserved':True,'user_display_preserved':True,'java_static_checked':True,'deployed':False}
(O/'模型检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)
