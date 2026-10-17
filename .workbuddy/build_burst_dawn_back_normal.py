"""Normal-state thorn/shard back ornament. No skill effects or runtime logic."""
# RETIRED_REJECTED_DRAFT: do not regenerate over the refined native mother.
raise SystemExit('旧背饰方案已被否决/替代；请编辑切面精修母版。')
from pathlib import Path
from PIL import Image,ImageDraw
import base64,copy,io,json,math,random,uuid
import numpy as np
from model_review_io import renderer

OUT=Path('D:/数据包/模型设计/爆裂黎明_建模_20261014/阶段二_优化与普通背饰')
P=OUT/'爆裂黎明_普通背饰_分组模型.bbmodel'
if P.exists():raise SystemExit('背饰母版已存在，请继续编辑该工程。')
groups=[];elements=[]
def group(name,parent=None,origin=(8,8,8)):
    g={'name':name,'uuid':str(uuid.uuid4()),'origin':list(origin),'rotation':[0,0,0],'children':[],'visibility':True,'export':True,'isOpen':True}
    groups.append(g)
    if parent:parent['children'].append(g)
    return g
root=group('普通背饰_整体挂点')
mount=group('01_背部支座',root)
spines=group('02_黑棘骨架',root)
right=group('03_棘枝_right',root,(11,11,8));left=group('04_棘枝_left',root,(5,11,8))
rshards=group('05_碎翼_right',root,(13,12,9));lshards=group('06_碎翼_left',root,(3,12,9))
lower=group('07_下垂裂片',root,(8,4,9));wires=group('08_断环与束线',root)
colors={'black':(27,32,42),'blue':(44,52,73),'silver':(178,181,192),'edge':(111,124,145),'white':(210,211,219),'dim':(70,75,91),'bolt':(132,141,158),'mannequin':(67,80,96)}
matorder=list(colors);rects={m:((i%4)*64,(i//4)*64) for i,m in enumerate(matorder)}
tex=Image.new('RGBA',(512,512),(28,31,40,255));pix=tex.load();rng=random.Random(1035)
for m,(r,g,b) in colors.items():
    tx,ty=rects[m]
    for y in range(64):
        for x in range(64):
            q=rng.choice([-2,-1,0,0,0,1,2])
            # Broad clean steel tones with sparse directional grain.
            lift=1 if m in ('silver','white','edge') and (x+2*y)%31==0 else 0
            pix[tx+x,ty+y]=(max(0,min(255,r+q+lift)),max(0,min(255,g+q+lift)),max(0,min(255,b+q+lift)),255)
def cube(name,lo,hi,parent,mat='black',rotation=(0,0,0),origin=(8,8,8)):
    assert all(a<b for a,b in zip(lo,hi)),(name,lo,hi)
    tx,ty=rects[mat];faces={}
    for s in ['north','east','south','west','up','down']:
        a,c=(0,1) if s in ('north','south') else ((2,1) if s in ('east','west') else (0,2))
        w=max(.4,(hi[a]-lo[a])*2);h=max(.4,(hi[c]-lo[c])*2)
        u=tx+5+(lo[a]+16)*.28;v=ty+5+(32-hi[c])*.28
        faces[s]={'texture':0,'uv':[u,v,u+w,v+h]}
    e={'name':name,'uuid':str(uuid.uuid4()),'type':'cube','box_uv':False,'from':list(lo),'to':list(hi),'origin':list(origin),'rotation':list(rotation),'faces':faces,'visibility':True,'export':True}
    elements.append(e);parent['children'].append(e['uuid']);return e
def inside(x,y,poly):
    hit=False
    for (ax,ay),(bx,by) in zip(poly,poly[1:]+poly[:1]):
        if (ay>y)!=(by>y) and x<(bx-ax)*(y-ay)/(by-ay)+ax:hit=not hit
    return hit
def profile(name,poly,z,thick,parent,mat='silver',step=.65):
    cells=set()
    for j in range(math.floor(min(y for x,y in poly)/step),math.ceil(max(y for x,y in poly)/step)):
        for i in range(math.floor(min(x for x,y in poly)/step),math.ceil(max(x for x,y in poly)/step)):
            if inside((i+.5)*step,(j+.5)*step,poly):cells.add((i,j))
    while cells:
        i,j=min(cells,key=lambda p:(p[1],p[0]));w=h=1
        while (i+w,j) in cells:w+=1
        while all((k,j+h) in cells for k in range(i,i+w)):h+=1
        for yy in range(j,j+h):
            for xx in range(i,i+w):cells.remove((xx,yy))
        cube(name,[i*step,j*step,z],[(i+w)*step,(j+h)*step,z+thick],parent,mat)
def stem(name,a,b,width,parent,mat='black',z=8.4):
    # Original 22.5-degree bends become legal rotated cuboids with real overlap.
    a=np.array(a,dtype=float);b=np.array(b,dtype=float);v=b-a
    angle=round(math.degrees(math.atan2(v[1],v[0]))/22.5)*22.5
    angle=(angle+90)%180-90
    # Long-axis X supports the Java allowed angle range by swapping axes.
    vertical=abs(angle)>45
    if vertical:angle=angle-90 if angle>0 else angle+90
    assert angle in (-45,-22.5,0,22.5,45)
    c=(a+b)/2;length=float(np.linalg.norm(v))+.45
    w,h=(width,length) if vertical else (length,width)
    cube(name,[c[0]-w/2,c[1]-h/2,z],[c[0]+w/2,c[1]+h/2,z+width],parent,mat,(0,0,angle),(c[0],c[1],z+width/2))

# An actual mounting bridge against the upper back, framed around a narrow spine.
cube('上背贴合座',[5.4,6.8,6.0],[10.6,12.8,7.15],mount,'black')
cube('背座折面',[6.2,7.4,7.1],[9.8,12.3,7.8],mount,'dim')
cube('中脊暗骨',[7.25,1.0,7.4],[8.75,14.3,8.7],spines,'black')
cube('脊部银扣',[6.65,8.6,7.7],[9.35,9.5,9.0],mount,'edge')
cube('下束片',[6.8,2.4,7.7],[9.2,3.2,8.95],mount,'dim')
for x in [6.1,9.45]:cube('背座铆钉',[x,10.7,7.75],[x+.45,11.15,8.15],mount,'bolt')

# Broken, unequal branch fans: shoulder spear, outboard spear and trailing thorn.
stems=[('right',[(8,10),(13,15),(16.5,22.5)],right),
       ('right',[(9,9),(16,12),(24,15.5)],right),
       ('right',[(9,6),(15,6),(21,2)],right),
       ('left',[(8,10),(3.5,16),(.5,24)],left),
       ('left',[(7,9),(0,12),(-6,15)],left),
       ('left',[(7,6),(1.5,5),(-6,-.5)],left)]
for n,(side,points,g) in enumerate(stems):
    for i,(a,b) in enumerate(zip(points,points[1:])):stem('棘枝_'+side,a,b,.78 if i==0 else .58,g,z=8.25+n*.13)

# Spear-like fragments at the tips, with angular chipped notches.
shards=[('右上主裂片',[(12.5,16),(14.8,21.0),(17.6,27.8),(18.2,23.2),(16.9,19.5),(17.2,18.2),(15,17)],9.05,.65,rshards),
        ('右外主裂片',[(17.2,12.4),(21.4,15.8),(28.4,17.0),(25.2,14.5),(26,13.6),(22,13.4),(20,11.5)],9.55,.7,rshards),
        ('左上主裂片',[(1.3,17),(-.2,21.5),(-2.8,28),(-3.6,23.8),(-2.2,20.5),(-3.1,19.6),(-.5,17.1)],9.25,.65,lshards),
        ('左外主裂片',[(-1,12.2),(-5.5,16.2),(-12,17.5),(-9.2,14.5),(-10.4,13.6),(-5.6,13.1),(-3.3,11.6)],9.75,.7,lshards),
        ('右下拖裂片',[(12.1,5.6),(17.2,4.9),(24,-1),(19.3,0),(18.9,-1.8),(15.9,1.7),(13.5,2)],9.25,.62,lower),
        ('左下拖裂片',[(3.3,5.7),(-1.5,4.5),(-8.1,-3.0),(-3.5,-.7),(-3.7,-2.2),(-.2,1.3),(2.8,1.8)],9.5,.62,lower)]
for n,(name,poly,z,thick,g) in enumerate(shards):
    # Coarse but exact solid silhouette, bounded element count; each shard is solid.
    profile(name,poly,z,thick,g,'silver',.4)
    # A separate dark root and narrow split facet give depth to both visible sides.
    center=np.array(poly[:2]).mean(0);end=np.array(poly[2]);v=end-center
    tip=center+v*.72;middle=center+v*.29;per=np.array([-v[1],v[0]]);per=per/np.linalg.norm(per)*.48
    profile(name+'_黑棘脉',[tuple(center-per),tuple(middle+per),tuple(tip),tuple(middle-per)],z-.22,.3,g,'blue',.65)
    profile(name+'_背面暗骨',[tuple(center-per*.7),tuple(middle+per*.7),tuple(tip)],z+thick-.04,.2,g,'dim',.8)
    # Each solid shard gets its own projected faceted steel tile; this adds no cubes.
    x0=min(p[0] for p in poly)-.4;x1=max(p[0] for p in poly)+.4
    y0=min(p[1] for p in poly)-.4;y1=max(p[1] for p in poly)+.4
    tx=256+(n%2)*128;ty=(n//2)*128
    tile=Image.new('RGBA',(128,128),(149,155,173,255));d=ImageDraw.Draw(tile)
    def uv(p):return ((p[0]-x0)/(x1-x0)*128,(y1-p[1])/(y1-y0)*128)
    tip0=np.array(poly[2]);root0=np.array(poly[0]);edge0=np.array(poly[1])
    d.polygon([uv(root0),uv(edge0),uv(tip0)],fill=(202,205,217,255))
    d.polygon([uv(root0),uv(np.array(poly[-1])),uv(tip0*.70+root0*.30)],fill=(100,114,139,255))
    d.line([uv(root0),uv(tip0)],fill=(223,224,229,255),width=2)
    # Sparse fractures drawn inside the body, with a subdued dark-blue seam.
    for f in [.24,.52,.69]:
        q=root0*(1-f)+tip0*f
        d.line([uv(q),uv(q+np.array([(-1 if n%2 else 1)*.65,-.65]))],fill=(75,86,112,255),width=1)
    tex.paste(tile,(tx,ty))
    for e in elements:
        if e['name']!=name:continue
        for side in ('north','south'):
            lo=e['from'];hi=e['to']
            if side=='north':u0,u1=(x1-hi[0])/(x1-x0),(x1-lo[0])/(x1-x0)
            else:u0,u1=(lo[0]-x0)/(x1-x0),(hi[0]-x0)/(x1-x0)
            # Mirror the tile for the north face so world-space facets agree.
            if side=='north':u0,u1=1-u0,1-u1
            e['faces'][side]['uv']=[tx+u0*128,ty+(y1-hi[1])/(y1-y0)*128,tx+u1*128,ty+(y1-lo[1])/(y1-y0)*128]

# Open thorn forks, never a continuous bat membrane.
for n,(a,b,g) in enumerate([((15,18),(12.1,20.2),right),((20.4,13.5),(23.4,10.7),right),
                           ((.6,19.2),(3.6,21),left),((-4.9,13.7),(-7.2,10.9),left),
                           ((16,4),(17.8,7),right),((-.4,3.7),(-2.6,6.5),left)]):
    stem('分叉棘尖',a,b,.36,g,z=9.35+n*.1)

# Two partial angular wire loops. Gaps are intentional broken ends.
for n,(points,z) in enumerate([([(13.5,18),(15,22.2),(19.1,22.5),(21,19),(19,16.3)],10.25),
                               ([(1.7,18),(-.7,21.2),(-5.2,20.5),(-6.5,17.1),(-4.6,14.2)],10.6)]):
    for a,b in zip(points,points[1:]):stem('开放束线环',a,b,.20,wires,'black',z=z)
    cube('束线固定扣',[points[0][0]-.4,points[0][1]-.2,z-.14],[points[0][0]+.4,points[0][1]+.2,z+.5],wires,'bolt')

bio=io.BytesIO();tex.save(bio,format='PNG');png=bio.getvalue()
t={'name':'burst_dawn_back_normal.png','uuid':str(uuid.uuid4()),'id':'0','width':512,'height':512,'uv_width':512,'uv_height':512,'source':'data:image/png;base64,'+base64.b64encode(png).decode(),'path':'','relative_path':'','saved':True,'mode':'bitmap'}
def tree(g):return {'uuid':g['uuid'],'isOpen':True,'children':[tree(c) if isinstance(c,dict) else c for c in g['children']]}
b={'meta':{'format_version':'5.0','model_format':'free','box_uv':False,'bone_rig':True},'name':'爆裂黎明_普通背饰_分组模型','resolution':{'width':512,'height':512},
   'elements':elements,'groups':[{k:v for k,v in g.items() if k!='children'} for g in groups],
   'outliner':[tree(root)],'textures':[t],'animations':[],'display':{}}
P.write_text(json.dumps(b,ensure_ascii=False,separators=(',',':')),encoding='utf8');(OUT/'burst_dawn_back_normal.png').write_bytes(png)
print(json.dumps({'cubes':len(elements),'groups':len(groups),'normal_only':True,'source':'Default outfit shards + GSC licensed figure back view, Minecraft adaptation; no official orthographic blueprint'},ensure_ascii=False))
r=renderer(P)
r['render']((1400,1200),yaw=math.pi-.28,pitch=.12,scale=29,focus=(8,12,9)).save(OUT/'普通背饰_初查.png')
