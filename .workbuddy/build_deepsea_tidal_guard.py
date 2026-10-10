"""Approved asymmetric tidal guard: layered steel crests, round core, real chain."""
from pathlib import Path
import json, math, uuid, base64, random, collections
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import save_native,export_static,renderer,check

ROOT=Path(__file__).resolve().parents[1]
O=ROOT/'模型设计/深海回响_重设计_20261009/方案二_潮汐卷浪/阶段一_卷浪护手';O.mkdir(parents=True,exist_ok=True)
T=O/'贴图';T.mkdir(exist_ok=True)
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:deepsea:tidal:guard:'+n))
colors={'abyss':(22,38,53),'steel':(42,65,87),'steelblue':(78,109,135),'silver':(164,186,194),'edge':(208,220,218),'shade':(107,133,147),'blue0':(5,23,72),'blue1':(9,40,117),'blue2':(21,65,174),'blue3':(38,100,215),'blue4':(75,152,242),'blue5':(145,212,255),'blue6':(211,244,255)}
atlas=Image.new('RGBA',(128,128));d=ImageDraw.Draw(atlas);uv={};rng=random.Random(1009)
for i,(n,c) in enumerate(colors.items()):
    x=i%4*32;y=i//4*32;uv[n]=[x,y,x+32,y+32]
    for yy in range(32):
        for xx in range(32):
            v=round((15.5-yy)/7)+(1 if xx<3 else 0)
            atlas.putpixel((x+xx,y+yy),tuple(max(0,min(255,a+v)) for a in c)+(255,))
    if n in ['steel','steelblue','silver','shade']:
        for j in range(9):
            xx=x+rng.randrange(32);yy=y+rng.randrange(32);d.line((xx,yy,min(x+31,xx+3),yy),fill=tuple(min(255,a+3) for a in c)+(255,))
atlas.save(T/'潮汐护手_钢与深蓝晶核.png')
textures=[{'name':'潮汐护手_钢与深蓝晶核.png','id':'0','uuid':U('atlas'),'width':128,'height':128,'uv_width':128,'uv_height':128,'internal':True,'source':'data:image/png;base64,'+base64.b64encode((T/'潮汐护手_钢与深蓝晶核.png').read_bytes()).decode()}]
groups={};elements=[]
def group(n,p=None,origin=(0,0,0)):
    g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':True,'export':True,'isOpen':True,'color':len(groups)%8,'children':[]};groups[n]=g
    if p:groups[p]['children'].append(g)
    return n
root=group('00_深海回响_整体与握姿');guard=group('01_不对称卷浪护手',root)
left=group('长卷浪_开放回卷',guard);right=group('短卷浪_上扬浪尖',guard)
mount=group('02_潮核开口镶座',root);core=group('03_球形深蓝潮核',root,(0,0,-.7))
chain=group('04_实接短链与水滴',root,(-4.1,-.7,0));eye=group('护手连接扣眼',chain)
drop=group('水滴晶坠_独立摆动',chain,(-4.1,-4.75,0))
def cube(g,n,a,b,mat,rot=None,origin=None):
    # Mirror X so the front shows the drawing's intended asymmetry.
    a,b=list(a),list(b);a[0],b[0]=-b[0],-a[0]
    e={'name':n,'type':'cube','uuid':U(n+str(len(elements))),'from':a,'to':b,'origin':list(origin) if origin else [(x+y)/2 for x,y in zip(a,b)],'rotation':rot or [0,0,0],'visibility':True,'export':True,'box_uv':False,'autouv':0,'faces':{f:{'texture':0,'uv':uv[mat].copy()} for f in ['north','south','east','west','up','down']}}
    elements.append(e);groups[g]['children'].append(e['uuid']);return e
CELL=.16;xs=np.arange(-6.8,6.8,CELL);ys=np.arange(-3.2,3.2,CELL);X,Y=np.meshgrid(xs+CELL/2,ys+CELL/2)
def patches(mask,g,n,z0,z1,mat):
    m=mask.copy();idx=0
    for row in range(m.shape[0]):
        col=0
        while col<m.shape[1]:
            if not m[row,col]:col+=1;continue
            width=1
            while col+width<m.shape[1] and m[row,col+width]:width+=1
            h=1
            while row+h<m.shape[0] and np.all(m[row+h,col:col+width]):h+=1
            m[row:row+h,col:col+width]=False
            cube(g,n+'_%03d'%idx,[xs[col],ys[row],z0],[xs[col]+width*CELL,ys[row]+h*CELL,z1],mat);col+=width;idx+=1
def curve(control,widths):
    pts=[];ws=[]
    for i in range(len(control)-1):
        p0=np.array(control[max(0,i-1)]);p1=np.array(control[i]);p2=np.array(control[i+1]);p3=np.array(control[min(len(control)-1,i+2)])
        for t in np.arange(0,1,.09):
            p=.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t)
            pts.append(p);ws.append(widths[i]*(1-t)+widths[i+1]*t)
    pts=np.array(pts);ws=np.array(ws);near=np.zeros(X.shape,dtype=int);dist=np.full(X.shape,np.inf)
    for i,p in enumerate(pts):
        v=(X-p[0])**2+(Y-p[1])**2;take=v<dist;near[take]=i;dist[take]=v[take]
    tangent=np.gradient(pts,axis=0);normal=np.stack([-tangent[:,1],tangent[:,0]],1);normal/=np.linalg.norm(normal,axis=1)[:,None]
    signed=(X-pts[near,0])*normal[near,0]+(Y-pts[near,1])*normal[near,1]
    width=ws[near];progress=near/(len(pts)-1)
    return np.sqrt(dist)<width,signed,width,progress
lc=[[.45,-1.25],[-.6,-1.1],[-1.25,.0],[-1.9,1.45],[-3.2,2.13],[-4.5,1.90],[-5.4,1.12],[-5.6,.14],[-5.23,-.76],[-4.38,-.80],[-4.02,-.12],[-4.28,.43]]
rc=[[-.3,-1.0],[1.25,-1.1],[2.85,-.81],[4.1,-.42],[5.08,.20],[5.47,1.15],[5.12,1.92],[4.53,2.03],[4.13,1.60],[4.43,1.19]]
lm,ls,lw,lp=curve(lc,[.65,.72,.72,.66,.57,.53,.46,.41,.34,.31,.24,.10])
rm,rs,rw,rp=curve(rc,[.57,.65,.62,.58,.49,.39,.31,.25,.19,.08])
rm&=~lm
for g,m,s,w,p in [(left,lm,ls,lw,lp),(right,rm,rs,rw,rp)]:
    # Thick navy underside, blue concave channel and raised silver cutting crest.
    patches(m,g,'深渊钢_曲面骨架',-.30,.43,'abyss')
    patches(m&(abs(s)<w*.90),g,'蓝钢_卷浪表面',-.43,-.26,'steel')
    patches(m&(abs(s)<w*.62),g,'深蓝_凹面层次',-.51,-.40,'steel')
    patches(m&(s>w*.43),g,'银浪_内侧切面',-.67,-.46,'silver')
    patches(m&(s>w*.76),g,'银浪_内沿亮脊',-.76,-.65,'edge')
    patches(m&(s<-w*.25),g,'回卷_外沿银蓝',-.59,-.41,'shade')
    for j in range(7):
        plate=m&(s<-w*.53)&(p>=j/7)&(p<(j+1)/7)
        depth=-.70-(j%3)*.035
        patches(plate,g,'外浪脊_分层银板'+str(j),depth,-.58,'silver' if j%3==1 else 'edge')
    # Tapered plate seams are sparse, not hundreds of tiny ornaments.
    for at in [.15,.31,.48,.64,.79]:
        cut=m&(abs(p-at)<.006)&(abs(s)<w*.48)
        patches(cut,g,'潮汐板片分界',-.525,-.510,'shade')
# The open socket stays narrow; the orb dominates its center.
R=np.sqrt(X*X+(Y-.04)**2)
patches((R<1.26)&(R>.97),mount,'窄潮核镶座',-.79,.30,'steel')
patches((R<1.25)&(R>1.11),mount,'镶座银蓝边缘',-.87,-.77,'silver')
# Small tapered mounting collar between blade, core and grip.
tip=(abs(X)<np.maximum(.06,.56-.32*(Y-1.12)))&(Y>1.12)&(Y<2.6)
patches(tip,mount,'上方浪尖嵌座',-.44,.40,'steel')
patches(tip&(abs(X)<.13),mount,'嵌座中央银线',-.60,-.42,'silver')
foot=(abs(X)<(.3+.35*np.maximum(0,Y+2.05)))&(Y>-2.1)&(Y<-.88)
patches(foot,mount,'握柄连接颈',-.40,.39,'steel')
patches(foot&(abs(X)>.32),mount,'颈部两侧收口',-.55,-.39,'silver')
# Faceted real-volume orb: tapered voxel terraces, bright facets face the upper left.
cs=.16;ox=np.arange(-1.05,1.05,cs);oy=np.arange(-1.05,1.05,cs)
for yy in oy:
    for xx in ox:
        px,py=xx+cs/2,yy+cs/2;rad=px*px+py*py
        if rad>.98**2:continue
        depth=math.sqrt(max(0,.98**2-rad));zfront=-.66-.78*depth;zback=.08+.42*depth
        # Large, deliberate dark-blue facets with a small pale reflected crest.
        ang=math.atan2(py,px);sector=int((ang+math.pi)/(math.pi/4))
        ring=0 if rad<.28 else 1 if rad<.62 else 2
        level=[[1,1,2,3,2,1,0,0],[2,3,4,5,3,1,0,1],[1,2,3,4,2,1,0,0]][ring][sector%8]
        c='blue'+str(level)
        e=cube(core,'潮核_立体晶面',[xx,yy,zfront],[xx+cs,yy+cs,zback],c)
        e['faces']['south']['uv']=uv['blue1'].copy()
        e['faces']['east']['uv']=uv['blue1'].copy();e['faces']['down']['uv']=uv['blue0'].copy()
# Two tiny intentional sparkle facets, not a neon disk.
cube(core,'潮核_细亮面',[-.38,.31,-1.407],[-.16,.51,-1.36],'blue6')
cube(core,'潮核_次亮面',[-.11,.52,-1.363],[.05,.65,-1.33],'blue4')

def link(g,n,x,y,z,w=.44,h=.70,t=.095,side=False):
    # Rounded rectangular opening, alternate links genuinely pass through in depth.
    if not side:
        cube(g,n+'_左',[x-w/2,y-h/2+t,z-t],[x-w/2+t,y+h/2-t,z+t],'silver')
        cube(g,n+'_右',[x+w/2-t,y-h/2+t,z-t],[x+w/2,y+h/2-t,z+t],'silver')
        cube(g,n+'_顶',[x-w/2+t,y+h/2-t,z-t],[x+w/2-t,y+h/2,z+t],'edge')
        cube(g,n+'_底',[x-w/2+t,y-h/2,z-t],[x+w/2-t,y-h/2+t,z+t],'shade')
        for sx in [-1,1]:
            for sy in [-1,1]:cube(g,n+'_圆角',[x+sx*(w/2-t)-t*.4,y+sy*(h/2-t)-t*.4,z-t],[x+sx*(w/2-t)+t*.4,y+sy*(h/2-t)+t*.4,z+t],'silver')
    else:
        cube(g,n+'_前',[x-t,y-h/2+t,z-w/2],[x+t,y+h/2-t,z-w/2+t],'silver')
        cube(g,n+'_后',[x-t,y-h/2+t,z+w/2-t],[x+t,y+h/2-t,z+w/2],'shade')
        cube(g,n+'_顶',[x-t,y+h/2-t,z-w/2],[x+t,y+h/2,z+w/2],'edge')
        cube(g,n+'_底',[x-t,y-h/2,z-w/2],[x+t,y-h/2+t,z+w/2],'silver')
anchorx=3.93;anchory=-.61
# Fixed clasp penetrates the right crest; there is no floating chain start.
cube(eye,'实接浪底扣爪',[anchorx-.17,anchory-.35,-.05],[anchorx+.17,anchory+.15,.31],'steel')
link(eye,'固定扣眼',anchorx,anchory-.29,.08,.44,.57,.10)
for i in range(5):
    g=group('短链_%02d_交错环'%(i+1),chain,(-anchorx,anchory-.69-i*.48,.08))
    link(g,'锁链环',anchorx,anchory-.69-i*.48,.08,side=i%2==0)
dropY=anchory-.69-4*.48-.66
groups[drop]['origin']=[-anchorx,dropY+.35,.08]
link(drop,'晶坠顶环',anchorx,dropY+.32,.08,.28,.35,.08,True)
cube(drop,'水滴银扣',[anchorx-.19,dropY+.13,-.12],[anchorx+.19,dropY+.30,.25],'silver')
# A double-tapered tear with real depth, tapered to a sharp lower tip.
for j in range(12):
    top=dropY+.20-j*.115;bottom=top-.12
    f=j/11;rad=.13+.33*min(1,f/.35) if f<.35 else .46*(1-(f-.35)/.72)
    rad=max(.04,rad);dep=rad*.70
    cube(drop,'水滴晶面_%02d'%j,[anchorx-rad,bottom,.08-dep],[anchorx+rad,top,.08+dep],'blue'+str(2 if j<3 else 3 if j<8 else 4))
    if rad>.10:cube(drop,'水滴侧亮面_%02d'%j,[anchorx-rad*.80,bottom,-dep+.035],[anchorx-rad*.32,top,-dep+.063],'blue5')

display={'gui':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[1]*3},'firstperson_righthand':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[.7]*3},'thirdperson_righthand':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[.6]*3}}
# If the original whole display exists, use its current pose even for the review JSON.
masters=list((ROOT/'sweetdream_rp/assets/deepseaecho/models/item').glob('*.json'))
for p in masters:
    if p.stem in ['deepseaecho','deepsea','sword']:
        q=json.loads(p.read_text(encoding='utf-8'));display=q.get('display',display);break
check(elements,groups,root,textures)
native=save_native(O,'深海回响_卷浪护手_分组',elements,groups,root,textures,display)
master,count=export_static(O,'deepseaecho','deepseaecho',elements,groups,root,textures,display)
r=renderer(native);render=r['render'];font,small=r['font'],r['small'];im=Image.new('RGB',(1580,1110),r['BG']);d=ImageDraw.Draw(im)
d.text((30,23),'深海回响 · 阶段一 / 卷浪护手、潮核与短链水滴',font=font,fill='#bbd8ef');d.text((30,70),'实际分组模型渲染 · 先确认卷浪轮廓和核心比例 · 尚未部署',font=small,fill='#99a8b5')
im.paste(render((970,865),yaw=math.pi+.25,pitch=.13,scale=63,focus=(0,-.65,0)),(0,120))
im.paste(render((590,385),yaw=math.pi,pitch=0,scale=40,focus=(0,-.65,0)),(975,115))
im.paste(render((590,300),yaw=math.pi+.95,pitch=.19,scale=43,focus=(0,-.50,0)),(975,535))
im.paste(render((260,225),yaw=math.pi+.42,pitch=.03,scale=102,focus=(-anchorx,dropY-.4,0)),(960,850))
im.paste(render((340,225),yaw=math.pi+.22,pitch=.12,scale=88,focus=(0,.04,-.5)),(1225,850))
d=ImageDraw.Draw(im);d.text((995,502),'正面 · 不对称开放卷浪',font=small,fill='#afc4d8');d.text((995,828),'斜侧 · 银浪与蓝钢凹面的厚度',font=small,fill='#afc4d8');d.text((30,1040),f'{count} 个立方体 · {len(groups)} 个独立分组 · 剑刃、剑柄及浪刃下一阶段制作',font=small,fill='#9aa6b4')
im.save(O/'深海回响_卷浪护手_实际模型.png')
stats={'cubes':count,'groups':len(groups),'textures':len(textures),'chain_links':5,'attached_chain':True,'java_static_checked':True,'deployed':False}
(O/'模型检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)
