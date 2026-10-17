"""New static geometry authoring spec. Never overwrites a reviewed mother model."""
from pathlib import Path
from PIL import Image, ImageDraw
import collections, json, math, random

ROOT=Path('D:/数据包/模型设计/爆裂黎明_建模_20261014')
OUT=ROOT/'阶段一_原版炮身静态形体'
NATIVE=OUT/'爆裂黎明_原版炮身_分组模型.bbmodel'
if NATIVE.exists(): raise SystemExit('已有母版；后续应编辑该工程，禁止从初稿覆盖。')
OUT.mkdir(parents=True,exist_ok=True)
groups=[]; cubes=[]
def group(name,parent='爆裂黎明_整体',origin=(22,6.5,8)):
    groups.append(dict(name=name,parent=parent,origin=list(origin),rotation=[0,0,0]))
groups.append(dict(name='爆裂黎明_整体',origin=[22,6.5,8],rotation=[0,0,0]))
group('01_固定握持座')
group('02_扳机与护圈','01_固定握持座')
group('03_握柄缠带','01_固定握持座')
group('04_炮体后坐总成')
for n in ['05_承力机匣','06_左侧破损外壳','07_右侧破损外壳','08_上背折面装甲',
          '09_下腹折面装甲','10_长炮管与单发射膛','11_外露导轨','12_炮口金属框',
          '13_炮管压箍','14_长刃承力座','15_长尖炮刃','16_银色刃面','17_红黑刃槽',
          '18_刃根叉刺','19_尾部支架与短尖','20_侧面检修板','21_螺栓与销钉',
          '22_导轨滑块','23_握座连接桥']:
    group(n,'04_炮体后坐总成')

mats={
 'core':(0,0,0,(35,39,49)), 'shell':(0,128,0,(54,59,70)),
 'facet':(0,0,128,(87,95,109)), 'dark':(0,128,128,(23,26,34)),
 'silver':(1,0,0,(178,184,193)), 'rail':(1,128,0,(114,124,139)),
 'grip':(1,0,128,(35,32,38)), 'rivet':(1,128,128,(145,151,162)),
 'red':(2,0,0,(149,42,52)), 'red_dim':(2,128,0,(89,34,46)),
 'blue':(2,0,128,(47,54,87)), 'inset':(2,128,128,(39,42,50))}

def cube(name,lo,hi,parent,mat='core',rotation=None,origin=None):
    assert all(a<b for a,b in zip(lo,hi)),name
    ti,tx,ty,col=mats[mat]; faces={}
    for f in ['north','south','east','west','up','down']:
        a,b=(0,1) if f in ('north','south') else ((2,1) if f in ('east','west') else (0,2))
        u=tx+8+(lo[a]+16)*1.9;v=ty+8+(32-hi[b])*1.9
        du=max(.32,(hi[a]-lo[a])*1.9);dv=max(.32,(hi[b]-lo[b])*1.9)
        assert u+du<tx+128 and v+dv<ty+128,(name,mat,u,v,du,dv)
        faces[f]=dict(uv=[round(u,5),round(v,5),round(u+du,5),round(v+dv,5)],texture=ti)
    q=dict(name=f'{name}_{len(cubes):04d}',to=list(hi),parent=parent,faces=faces,box_uv=False)
    q['from']=list(lo)
    if rotation:q['rotation']=rotation;q['origin']=origin
    q['_material']=mat;cubes.append(q)

def inside(x,y,poly):
    hit=False
    for (ax,ay),(bx,by) in zip(poly,poly[1:]+poly[:1]):
        if (ay>y)!=(by>y) and x<(bx-ax)*(y-ay)/(by-ay)+ax:hit=not hit
    return hit

def greedy(raw):
    cells=dict(raw)
    while cells:
        x,y=min(cells,key=lambda p:(p[1],p[0]));code=cells[x,y];w=h=1
        while cells.get((x+w,y))==code:w+=1
        while all(cells.get((a,y+h))==code for a in range(x,x+w)):h+=1
        for yy in range(y,y+h):
            for xx in range(x,x+w):del cells[xx,yy]
        yield x,y,w,h,code

def profile(poly,parent,name,zlo,zhi,mat='shell',step=.25,bevel=False):
    cells={}
    for j in range(math.floor(min(y for x,y in poly)/step),math.ceil(max(y for x,y in poly)/step)):
        for i in range(math.floor(min(x for x,y in poly)/step),math.ceil(max(x for x,y in poly)/step)):
            if inside((i+.5)*step,(j+.5)*step,poly):cells[i,j]=mat
    if bevel:
        for i,j in list(cells):
            if any((i+dx,j+dy) not in cells for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)]):cells[i,j]='facet'
    for i,j,w,h,material in greedy(cells):
        inset=.17 if material=='facet' and bevel else 0
        cube(name,[i*step,j*step,zlo+inset],[(i+w)*step,(j+h)*step,zhi-inset],parent,material)

# The muzzle points toward -X; the blade extends beyond it on the upper side.
# Dense profile geometry gives true thickness and editable broken silhouettes.
receiver=[(8.5,7.0),(11,6.4),(14,4.8),(16,5.1),(17,3.5),(20.8,4.6),(22.3,5.7),
 (26,5.9),(28.2,8.0),(29.2,12.3),(27.3,14.5),(24.5,15.4),(19.6,14.7),
 (16.3,15.2),(14.1,13.5),(11.3,13.1),(9.4,11.4)]
profile(receiver,'05_承力机匣','承力机匣',6.05,9.95,'core',.30,True)
for zlo,zhi,parent,mirror in [(5.30,6.38,'06_左侧破损外壳',False),(9.62,10.70,'07_右侧破损外壳',True)]:
    shell=[(10.4,8.2),(12.0,7.0),(13.8,7.3),(15.3,5.4),(17.7,6.0),(19.1,4.3),
      (21.9,5.9),(24.6,6.1),(27.7,8.5),(28.5,11.7),(26.7,13.9),(22.4,14.7),
      (20.1,13.7),(18.0,14.2),(16.8,12.8),(14.1,12.9),(12.0,11.3)]
    if mirror:shell=[(x,y+(.18 if x>23 else -.12)) for x,y in shell]
    profile(shell,parent,'破损边壳',zlo,zhi,'shell',.25,True)

# Actual chamfer strips angle across the thickness of the receiver.
for z,angle in [(5.9,45),(10.1,-45)]:
    cube('上背斜折面',[15.2,13.8,z-.6],[25.3,14.45,z+.6],'08_上背折面装甲','facet',[angle,0,0],[20,14.1,z])
    cube('下腹斜折面',[16.0,5.0,z-.53],[23.5,5.7,z+.53],'09_下腹折面装甲','facet',[-angle,0,0],[20,5.35,z])
cube('主脊',[12.9,13.8,6.7],[25.7,14.67,9.3],'08_上背折面装甲','shell')
for x in [16.2,18.1,20.0,21.9,23.8]:
    cube('背脊短槽',[x,14.56,7.12],[x+.82,14.86,8.88],'08_上背折面装甲','dark')

# Hollow rectangular firing channel, not a solid painted muzzle or three guns.
cube('单膛上壁',[-5.7,10.0,6.65],[12.6,10.55,9.35],'10_长炮管与单发射膛','dark')
cube('单膛下壁',[-5.7,7.0,6.65],[12.6,7.55,9.35],'10_长炮管与单发射膛','dark')
cube('单膛左壁',[-5.7,7.46,6.62],[12.6,10.10,7.16],'10_长炮管与单发射膛','core')
cube('单膛右壁',[-5.7,7.46,8.84],[12.6,10.10,9.38],'10_长炮管与单发射膛','core')
cube('膛内后壁',[11.7,7.5,7.12],[12.4,10,8.88],'10_长炮管与单发射膛','dark')
for y,z,mat in [(7.05,5.68,'rail'),(10.45,5.68,'rail'),(7.05,9.92,'rail'),(10.45,9.92,'rail')]:
    cube('平行外露导轨',[-5.35,y,z],[13.2,y+.43,z+.40],'11_外露导轨',mat)
    cube('导轨阴面',[-4.9,y-.14,z+.1],[11.8,y+.05,z+.29],'11_外露导轨','dark')
for z in [5.12,10.35]:
    cube('纵向机匣滑槽',[1.3,8.17,z],[18.2,8.70,z+.45],'11_外露导轨','core')
    cube('纵向细银边',[1.6,8.70,z+.05],[17.3,8.86,z+.39],'11_外露导轨','rail')
for x in [-6.2,-5.55]:
    # A real open rectangular collar with four distinct walls.
    cube('炮口框上边',[x,10.5,5.47],[x+.63,11.16,10.53],'12_炮口金属框','shell')
    cube('炮口框下边',[x,6.42,5.47],[x+.63,7.1,10.53],'12_炮口金属框','shell')
    cube('炮口框左边',[x,7.0,5.47],[x+.63,10.6,6.1],'12_炮口金属框','core')
    cube('炮口框右边',[x,7.0,9.90],[x+.63,10.6,10.53],'12_炮口金属框','core')
for x in [1.2,10.5]:
    for z in [5.24,10.17]:cube('抱箍侧壁',[x,6.5,z],[x+.61,11.25,z+.59],'13_炮管压箍','shell')
    cube('抱箍背桥',[x,10.90,5.40],[x+.61,11.50,10.60],'13_炮管压箍','facet')

# Long asymmetric pointed blade. Core and grinding facets are actual geometry.
blade=[(-15.2,14.05),(-10.7,16.05),(8.9,16.05),(11.5,16.9),(15.7,16.4),
 (17.25,15.25),(15.5,13.9),(10.4,13.7),(-10.8,13.7)]
profile(blade,'15_长尖炮刃','长刃钢体',6.78,9.22,'shell',.20)
edge=[(-15.2,14.05),(-10.7,16.05),(9.0,16.05),(11.5,16.9),(15.7,16.4),
 (15.4,16.0),(11.5,16.4),(9.1,15.61),(-10.5,15.61)]
profile(edge,'16_银色刃面','上磨刃',6.64,9.36,'silver',.20)
edge2=[(-15.2,14.05),(-10.8,13.7),(10.4,13.7),(10.4,14.04),(-10.7,14.06)]
profile(edge2,'16_银色刃面','下磨刃',6.59,9.41,'facet',.20)
for z in [6.52,9.26]:
    profile([(-12.5,14.37),(-9.9,15.25),(9.6,15.25),(11.3,15.94),(14.2,15.72),
        (13.6,15.25),(11.5,15.3),(9.6,14.73),(-9.9,14.73)],'17_红黑刃槽','暗红狭长刃槽',z,z+.22,'red',.16)
    profile([(-11.2,14.18),(-9.5,14.53),(8.7,14.53),(8.7,14.30),(-9.7,14.25)],
        '17_红黑刃槽','冷色刃腹',z+.025,z+.18,'blue',.20)
    for x in [-6.6,-1.8,3.0,7.8]:
        cube('刃面嵌接线',[x,13.82,z-.025],[x+.09,15.85,z+.26],'16_银色刃面','facet',[0,0,-22.5],[x,14.8,8])

profile([(10.1,10.8),(11.2,10.9),(14.9,14.3),(17.0,15.0),(17.1,16.5),
    (15.8,17.1),(14.1,16.2),(11.8,13.0)],'14_长刃承力座','连体斜撑',6.08,9.92,'core',.25,True)
for z in [5.95,9.68]:
    profile([(12.5,11.0),(13.7,11.5),(15.3,15.4),(15.1,16.5),(14.2,15.6)],
        '14_长刃承力座','刃座外压板',z,z+.37,'facet',.20)

# Forked, damaged guard with a long silver fin and shorter torn protrusions.
profile([(14.0,15.3),(14.7,18.2),(14.3,23.0),(16.5,20.1),(16.9,17.5),(16.2,15.1)],
    '18_刃根叉刺','竖向长尖',7.3,8.7,'silver',.20,True)
profile([(12.0,16.0),(10.6,18.0),(8.9,18.8),(11.5,18.6),(13.2,17.5),(14.7,17.1)],
    '18_刃根叉刺','前向裂尖',7.0,9.0,'shell',.20,True)
profile([(15.0,15.9),(17.3,18.5),(19.0,18.9),(18.1,17.4),(18.6,16.6),(16.4,15.1)],
    '18_刃根叉刺','后向裂尖',7.06,8.94,'dark',.20)
for z in [6.0,9.55]:
    profile([(26.0,12.4),(27.1,15.5),(30.3,18.1),(29.0,14.3),(29.2,12.0),(27.1,10.9)],
      '19_尾部支架与短尖','后部破片',z,z+.45,'shell',.25,True)

# Pistol grip and a genuinely open trigger guard, connected under the rear body.
profile([(21.0,7.0),(24.5,6.8),(26.4,1.0),(25.0,-.3),(22.8,.2),(22.1,2.5)],
    '01_固定握持座','握柄钢芯',6.65,9.35,'core',.25,True)
for i in range(8):
    y=.4+i*.65;x=23.05-(y-.4)*.17
    cube('握柄缠带',[x,y,6.47],[x+2.17,y+.43,9.53],'03_握柄缠带','grip',[0,0,22.5],[x+1,y+.2,8])
cube('握柄底箍',[22.80,-.32,6.45],[25.55,.35,9.55],'01_固定握持座','facet')
cube('扳机护圈前柱',[18.4,2.7,7.52],[19.0,6.6,8.48],'02_扳机与护圈','rail',[0,0,-22.5],[18.7,4.5,8])
cube('扳机护圈底边',[18.8,2.5,7.52],[22.7,3.05,8.48],'02_扳机与护圈','rail')
cube('扳机',[21.1,4.1,7.68],[21.55,6.7,8.32],'02_扳机与护圈','rivet',[0,0,-22.5],[21.3,6.4,8])
cube('握座连接桥',[20.0,6.25,6.22],[25.6,7.5,9.78],'23_握座连接桥','dark')

# Side panel layers follow the hull rather than flat duplicate slabs.
for z,sgn in [(5.12,-1),(10.49,1)]:
    profile([(14.0,8.1),(15.2,10.9),(19.2,12.6),(24.3,12.6),(26.5,11.5),
      (25.6,9.0),(22.9,7.1),(19.4,7.4),(18.7,6.4),(17.0,7.0)],
      '20_侧面检修板','嵌套检修板',z,z+.39,'core',.25,True)
    profile([(16.8,10.2),(19.6,11.85),(23.8,11.85),(25.0,11.0),(24.6,10.5),(19.7,11.3),(17.0,9.75)],
      '20_侧面检修板','外露银色折线',z-.06 if sgn<0 else z+.30,z+.10 if sgn<0 else z+.46,'rail',.20)
    for i in range(5):
        x=19.2+i*.96
        cube('凹入散热槽',[x,8.4,z-.10],[x+.42,9.65,z+.48],'20_侧面检修板','dark',[0,0,-22.5],[x+.2,9,8])
    for x,y in [(12.7,10.4),(15.1,8.1),(18.3,12.1),(23.7,12.4),(25.8,10.2),(20.6,6.5)]:
        cube('螺钉底座',[x-.26,y-.26,z-.12],[x+.26,y+.26,z+.51],'21_螺栓与销钉','dark')
        cube('银色螺钉',[x-.13,y-.13,z-.22],[x+.13,y+.13,z+.61],'21_螺栓与销钉','rivet')
    # One subdued red status stripe per side, matching the narrow blade accent.
    cube('机匣红色短标',[23.2,7.35,z-.14],[24.7,7.60,z+.52],'20_侧面检修板','red_dim')
for x in [-5.9,1.35,10.65]:
    for y in [7.25,10.10]:
        for z in [5.37,10.38]:cube('压箍铆钉',[x-.18,y-.18,z-.10],[x+.18,y+.18,z+.20],'21_螺栓与销钉','rivet')
for z in [5.02,10.49]:
    cube('后坐滑块',[9.0,8.0,z],[13.5,9.17,z+.49],'22_导轨滑块','shell')
    cube('滑块银边',[9.3,8.85,z-.06],[13.1,9.25,z+.57],'22_导轨滑块','rail')

# Remove wholly buried faces and resolve genuine coplanar overlap without
# changing the visible silhouette. Rotated cuboids need editor-space QA later.
sideinfo={'west':(0,0),'east':(0,1),'down':(1,0),'up':(1,1),'north':(2,0),'south':(2,1)}
for a in cubes:
    if a.get('rotation'):continue
    for side,(axis,end) in sideinfo.items():
        plane=a['to' if end else 'from'][axis];other=[i for i in range(3) if i!=axis]
        for b in cubes:
            if a is b or b.get('rotation'):continue
            if not b['from'][axis]-1e-7<=plane<=b['to'][axis]+1e-7:continue
            # Surface is buried behind the other volume, including equal
            # planes only if the other cube goes farther in the outward dir.
            beyond=b['to'][axis]>plane+1e-5 if end else b['from'][axis]<plane-1e-5
            if beyond and all(b['from'][i]<=a['from'][i]+1e-7 and b['to'][i]>=a['to'][i]-1e-7 for i in other):
                a['faces'][side]['texture']=None;break

rng=random.Random(1035)
for ti in range(3):
    im=Image.new('RGBA',(256,256));pix=im.load()
    for mat,(t,tx,ty,base) in mats.items():
        if t!=ti:continue
        for y in range(128):
            for x in range(128):
                f=.96+.065*(1-y/127)+rng.uniform(-.012,.012)
                col=tuple(max(0,min(255,round(v*f+math.sin(y*.14)*.9))) for v in base)
                pix[tx+x,ty+y]=(*col,255)
        if mat not in ('grip','dark','inset','red','red_dim'):
            dr=ImageDraw.Draw(im)
            for j in range(14):
                x=tx+rng.randrange(10,113);y=ty+rng.randrange(10,113)
                c=tuple(max(0,min(255,v+rng.choice([-10,9]))) for v in base)
                dr.line((x,y,x+rng.randrange(2,7),y),fill=(*c,255))
    im.save(OUT/f'burst_dawn_material_{ti}.png')

summary={'cubes':len(cubes),'groups':len(groups),'textures':3,
 'materials':dict(collections.Counter(c['_material'] for c in cubes)),
 'bounds':{'min':[min(c['from'][i] for c in cubes) for i in range(3)],'max':[max(c['to'][i] for c in cubes) for i in range(3)]}}
(OUT/'构建规格.json').write_text(json.dumps({'groups':groups,'cubes':cubes,'summary':summary},ensure_ascii=False,separators=(',',':')),encoding='utf8')
print(json.dumps(summary,ensure_ascii=False))
