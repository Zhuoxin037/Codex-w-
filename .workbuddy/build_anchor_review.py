"""Author a grouped anchor silhouette for live Blockbench construction.

Only writes the new review folder; does not alter either runtime pack.
"""
from pathlib import Path
import collections, json, math, random
from PIL import Image, ImageDraw

ROOT=Path('D:/数据包/模型设计/沉锚_建模_20261014')
OUT=ROOT/'阶段一_完整静态形体'
if (OUT/'沉锚_四向锚爪_分组模型.bbmodel').exists():
    raise SystemExit('已有MCP精修母版；请继续编辑母版，不重建初稿或覆盖材质。')
OUT.mkdir(parents=True,exist_ok=True)
groups=[]; cubes=[]
def group(name,parent='沉锚_整体',origin=(8,18,8)):
    groups.append(dict(name=name,parent=parent,origin=list(origin),rotation=[0,0,0]))
groups.append(dict(name='沉锚_整体',origin=[8,18,8],rotation=[0,0,0]))
for n in ['01_左月刃锚爪','02_右月刃锚爪','03_中央锚冠与尖脊','04_锚颈与加强座',
          '05_长柄钢芯','06_握柄缠带','07_横挡与端刺','08_链条挂耳',
          '09_正面装甲与铆钉','10_背面装甲与铆钉','11_链条整体']:
    group(n)

material={
 'forged':(0,0,0), 'dark':(0,128,0), 'facet':(0,0,128), 'edge':(0,128,128),
 'panel':(1,0,0), 'grip':(1,128,0), 'strap':(1,0,128), 'rivet':(1,128,128),
 'chain':(2,0,0),'chain_side':(2,128,0),'polished':(2,0,128),'inset':(2,128,128)}
colors={'forged':(54,63,77),'dark':(30,36,47),'facet':(108,119,137),'edge':(185,195,211),
 'panel':(39,46,59),'grip':(27,30,38),'strap':(59,65,77),'rivet':(150,160,177),
 'chain':(78,89,108),'chain_side':(45,54,70),'polished':(134,145,164),'inset':(22,29,39)}

def cube(name,lo,hi,parent,mat='forged',rotation=None,origin=None):
    assert all(a<b for a,b in zip(lo,hi)),name
    t,tx,ty=material[mat]
    faces={}
    for face in ['north','south','east','west','up','down']:
        # World-linked mapping keeps contiguous strips from becoming a checkerboard.
        axes=(0,1) if face in ('north','south') else ((2,1) if face in ('east','west') else (0,2))
        a,b=axes
        u=tx+12+(lo[a]+16)*2.1; v=ty+12+(32-hi[b])*2.1
        du=(hi[a]-lo[a])*2.1;dv=(hi[b]-lo[b])*2.1
        if u+du>tx+127:u=tx+4
        if v+dv>ty+127:v=ty+4
        faces[face]=dict(uv=[round(u,4),round(v,4),round(u+max(.28,du),4),round(v+max(.28,dv),4)],texture=t)
    q=dict(name=f'{name}_{len(cubes):04d}',from_=list(lo),to=list(hi),parent=parent,faces=faces,box_uv=False)
    q['from']=q.pop('from_')
    if rotation:q['rotation']=rotation;q['origin']=origin
    q['_material']=mat
    cubes.append(q)

def greedy(grid):
    cells=dict(grid)
    while cells:
        x,y=min(cells,key=lambda p:(p[1],p[0]));code=cells[x,y]
        w=1
        while cells.get((x+w,y))==code:w+=1
        h=1
        while all(cells.get((a,y+h))==code for a in range(x,x+w)):h+=1
        for b in range(y,y+h):
            for a in range(x,x+w):del cells[a,b]
        yield x,y,w,h,code

def point_in_poly(x,y,poly):
    inside=False
    for (ax,ay),(bx,by) in zip(poly,poly[1:]+poly[:1]):
        if (ay>y)!=(by>y) and x<(bx-ax)*(y-ay)/(by-ay)+ax:inside=not inside
    return inside

def profile(poly,parent,prefix,step=.32,style='blade',zcenter=8):
    x0=math.floor(min(x for x,y in poly)/step);x1=math.ceil(max(x for x,y in poly)/step)
    y0=math.floor(min(y for x,y in poly)/step);y1=math.ceil(max(y for x,y in poly)/step)
    raw={(i,j) for j in range(y0,y1) for i in range(x0,x1) if point_in_poly((i+.5)*step,(j+.5)*step,poly)}
    rows=collections.defaultdict(list)
    for i,j in raw:rows[j].append(i)
    grid={}
    for j,xx in rows.items():
        xl,xr=min(xx),max(xx)
        for i in xx:
            f=(i-xl+.5)/(xr-xl+1)
            if style=='blade':
                # Convex outer blade has a real thin edge and stepped grinding facets.
                outer=f if sum(x for x,y in poly)<0 else 1-f
                if outer<.15:code=('edge',.24)
                elif outer<.36:code=('facet',.55)
                elif outer<.72:code=('forged',.92)
                elif outer<.90:code=('dark',.70)
                else:code=('facet',.38)
            elif style=='spine':
                center=abs(f-.5)*2
                code=('facet',1.46) if center<.35 else (('forged',1.20) if center<.72 else ('dark',.90))
            else:code=(style,.15)
            grid[i,j]=code
    for x,y,w,h,(mat,thick) in greedy(grid):
        cube(prefix,[8+x*step,y*step,zcenter-thick],[8+(x+w)*step,(y+h)*step,zcenter+thick],parent,mat)

left=[(0,-2.5),(-3.6,-2.2),(-7.2,-.3),(-10.7,3),(-12.8,7.7),(-13.2,13.9),(-12.1,17.3),
      (-11.55,13.1),(-10.6,8.8),(-8.9,5.4),(-6.1,3.5),(-2.3,2.3),(0,2.2)]
right=[(0,-2.5),(3.8,-1.8),(7.7,.5),(10.8,3.9),(13,8.7),(13.1,14.2),(12.4,16.8),
       (11.85,12.4),(10.2,8.3),(8,5.7),(5.2,3.4),(2.1,2.4),(0,2.2)]
profile(left,'01_左月刃锚爪','左月刃')
profile(right,'02_右月刃锚爪','右月刃')
spine=[(-.7,10),( .7,10),(1.5,6),(2.25,1.8),(2.1,-2.5),(.9,-6.2),(0,-8.8),(-.9,-6.2),(-2.1,-2.5),(-2.25,1.8),(-1.5,6)]
profile(spine,'03_中央锚冠与尖脊','中央尖脊',step=.28,style='spine')

# Paired lower fangs preserve the aggressive crown seen in the supplied art.
for sign in [-1,1]:
    fang=[(sign*1,-1.4),(sign*3.5,-2.4),(sign*4.8,-5.8),(sign*2.4,-4.5),(sign*1,-4)]
    profile(fang,'03_中央锚冠与尖脊','下叉尖',step=.28,style='blade')

# Tapered steel shank: all joins penetrate slightly; no unsupported floaters.
for y,h,half,depth in [(5.8,4.3,.93,.94),(10,4.7,.76,.73),(14.6,4.4,.69,.68),(18.9,4.7,.63,.63),(23.5,3.3,.70,.70),(26.7,3,.56,.56)]:
    cube('长柄钢芯',[8-half,y,8-depth],[8+half,y+h,8+depth],'05_长柄钢芯','forged')
for y,half,depth in [(8.2,1.14,1.04),(13.7,.93,.91),(25.7,1.10,.93),(28.8,.82,.78)]:
    cube('柄箍',[8-half,y,8-depth],[8+half,y+.60,8+depth],'04_锚颈与加强座','facet')

# Narrow faceted shoulders joining the crown, not a giant rectangular plate.
neck=[(-1.0,10.3),(-1.45,7.5),(-1.8,4),(-1.3,3.3),(1.3,3.3),(1.8,4),(1.45,7.5),(1,10.3)]
profile(neck,'04_锚颈与加强座','加强颈',step=.28,style='spine')

# Matte grip bands with separated edges; axis-legal slanted straps on both faces.
for i in range(16):
    y=15.2+i*.56
    cube('缠带',[7.23,y,7.20],[8.77,y+.41,8.80],'06_握柄缠带','grip' if i%4 else 'strap')
for sign in [-1,1]:
    for i in range(7):
        y=16.0+i*1.12
        z=7.13 if sign<0 else 8.79
        cube('缠带接缝',[7.20,y,z],[8.80,y+.18,z+.09],'06_握柄缠带','strap',rotation=[0,0,-22.5],origin=[8,y+.09,8])

# Cross stock with pointed ends, a distinctive feature of the operator's weapon.
stock=[(-5.7,26.4),(-3.9,26.0),(-1.0,26.3),(1,26.3),(3.9,26.0),(5.7,26.4),
       (4.4,27.15),(1,27.35),(-1,27.35),(-4.4,27.15)]
profile(stock,'07_横挡与端刺','横挡',step=.24,style='spine')
for sign in [-1,1]:
    profile([(sign*.35,29.1),(sign*.72,30.4),(0,31.8),(-sign*.18,30.4)],'07_横挡与端刺','上端尖',step=.20,style='blade')

# Raised plates on BOTH sides. No blue crystal or ornate rune invented for this design.
panel=[(-.45,8.5),(.45,8.5),(1.24,3.7),(1.3,-1.4),(0,-5.6),(-1.3,-1.4),(-1.24,3.7)]
for z,parent in [(6.44,'09_正面装甲与铆钉'),(9.56,'10_背面装甲与铆钉')]:
    profile(panel,parent,'锚冠装甲',step=.24,style='panel',zcenter=z)
    for x,y in [(0,6.6),(-.73,2.0),(.73,2.0),(0,-1.4)]:
        cube('铆钉',[8+x-.19,y-.19,z-.23],[8+x+.19,y+.19,z+.23],parent,'rivet')
    for sign in [-1,1]:
        for x,y in [(3.15,-.55),(5.65,.50),(8.65,3.25)]:
            # Slightly proud of the surface, both sides use the same structural fastening.
            rz=7.01 if z<8 else 8.99
            cube('刃根铆钉',[8+sign*x-.15,y-.15,rz-.10],[8+sign*x+.15,y+.15,rz+.10],parent,'rivet')

def ring(cx,cy,cz,plane,parent,name,a=.60,b=1.10,wire=.20,step=.18,angle=0):
    grid={}
    for j in range(-math.ceil(b/step),math.ceil(b/step)):
        for i in range(-math.ceil(a/step),math.ceil(a/step)):
            x,y=(i+.5)*step,(j+.5)*step
            if (x/a)**2+(y/b)**2<=1 and (x/(a-wire))**2+(y/(b-wire))**2>=1:
                grid[i,j]=('chain',.16)
    for x,y,w,h,(mat,t) in greedy(grid):
        if plane=='xy':lo=[cx+x*step,cy+y*step,cz-t];hi=[cx+(x+w)*step,cy+(y+h)*step,cz+t]
        else:lo=[cx-t,cy+y*step,cz+x*step];hi=[cx+t,cy+(y+h)*step,cz+(x+w)*step]
        cube(name,lo,hi,parent,mat,rotation=[0,0,angle] if angle else None,origin=[cx,cy,cz] if angle else None)

# The first ring is physically inside the cross-stock attachment eye.
cube('挂耳支座',[3.75,25.80,7.30],[4.85,26.57,8.70],'08_链条挂耳','dark')
ring(4.26,25.65,8,'xy','08_链条挂耳','上挂耳',a=.48,b=.68,wire=.20)
chain=[(-4.1,24.65),(-4.6,23.10),(-5.0,21.55),(-5.15,20),(-5.0,18.45),(-4.70,16.90),
       (-4.25,15.35),(-3.70,13.80),(-3.10,12.25),(-2.55,10.70),(-2.10,9.15),(-1.75,7.60)]
previous='11_链条整体'
for i,(x,y) in enumerate(chain):
    n=f'链节_{i+1:02d}'
    group(n,parent=previous,origin=(8+x,y+1,8))
    angle=-22.5 if i<3 else (22.5 if i>5 else 0)
    ring(8+x,y,8,'xy' if i%2==0 else 'yz',n,'实心环壁',angle=angle)
    previous=n
ring(6.50,6.55,8,'yz','08_链条挂耳','下挂耳',a=.53,b=.66,wire=.21)
cube('下挂耳支座',[6.28,6.05,7.45],[7.20,7.20,8.55],'08_链条挂耳','dark')

# Material atlas: quiet brushed metal, not noisy pixels or luminous neon.
rng=random.Random(4145)
for ti in range(3):
    image=Image.new('RGBA',(256,256))
    pix=image.load()
    for mat,(t,tx,ty) in material.items():
        if ti!=t:continue
        base=colors[mat]
        for y in range(128):
            stripe=math.sin(y*.19)*1.6
            for x in range(128):
                shade=.95+.07*(1-y/127)+rng.uniform(-.014,.014)
                col=tuple(max(0,min(255,round(v*shade+stripe))) for v in base)
                pix[tx+x,ty+y]=(*col,255)
        dr=ImageDraw.Draw(image)
        if mat not in ('grip','inset'):
            for _ in range(13):
                x,y=tx+rng.randrange(12,112),ty+rng.randrange(12,112)
                delta=rng.choice([-13,10]);c=tuple(max(0,min(255,v+delta)) for v in base)
                dr.line([(x,y),(x+rng.randrange(2,8),y-1)],fill=(*c,255),width=1)
    image.save(OUT/f'anchor_material_{ti}.png')

summary=dict(cubes=len(cubes),groups=len(groups),materials=collections.Counter(q['_material'] for q in cubes),
             bounds=dict(min=[min(c['from'][i] for c in cubes) for i in range(3)],max=[max(c['to'][i] for c in cubes) for i in range(3)]))
(OUT/'构建规格.json').write_text(json.dumps(dict(groups=groups,cubes=cubes,summary=summary),ensure_ascii=False,separators=(',',':')),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False))
