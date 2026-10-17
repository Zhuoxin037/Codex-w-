"""Initial editable static weapon. Never use this to overwrite a user-approved revision."""
from pathlib import Path
import sys, json, math, uuid, base64, io, hashlib
import numpy as np
from PIL import Image, ImageDraw
from model_review_io import save_native, check, export_static

BASE=Path('D:/数据包/模型设计/很冰的斧_建模_20261016')
OUT=BASE/'阶段一_原设静态模型'
OUT.mkdir(parents=True,exist_ok=True)
NAME='很冰的斧_刻俄柏原设_分组可编辑'
if (OUT/(NAME+'.bbmodel')).exists() and '--replace-draft' not in sys.argv:
    raise SystemExit('Draft exists. Do not overwrite an approved model. Explicit --replace-draft only during initial modelling.')
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream/ceobe/iceaxe/v1/'+s))
groups={};elements=[]
def group(name,parent=None,origin=(0,-7,0)):
    g={'name':name,'uuid':uid('group/'+name),'origin':list(origin),'rotation':[0,0,0],'visibility':True,'export':True,'children':[]}
    groups[name]=g
    if parent:groups[parent]['children'].append(g)
    return name
ROOT=group('ice_axe｜整件与统一握点')
for n in ['shaft｜八棱长柄','grip｜下握区','pommel｜柄尾帽','handle_plate｜长柄护片','plate_pins｜护片铆钉','neck｜斧颈连接','head｜非对称斧身','edge｜收薄刃缘','hole_rims｜双贯穿孔口','head_bevel｜冠部实斜面']:
    group(n,ROOT)

# Same world-space UV coordinates across adjacent pieces prevent material seams.
W=H=512;atlas=Image.new('RGBA',(W,H),(46,44,39,255));pix=np.array(atlas)
rng=np.random.default_rng(201316)
yy,xx=np.mgrid[:H,:W]
noise=rng.normal(0,1.15,(H,W))+np.sin(xx*.18+yy*.027)*.8
materials={'dark':(56,54,49),'steel':(117,120,115),'edge':(176,172,150),'brass':(152,128,82),'brass_light':(191,166,111),'black':(33,34,32),'plate':(155,153,137),'grip':(65,59,48),'pin':(129,123,100),'cold':(134,175,177)}
tiles={}
for k,(n,col) in enumerate(materials.items()):
    tx=(k%8)*64;ty=288+(k//8)*80;tiles[n]=(tx,ty)
    for ch in range(3):pix[ty:ty+64,tx:tx+64,ch]=np.clip(col[ch]+noise[ty:ty+64,tx:tx+64],0,255)
    pix[ty:ty+64,tx:tx+64,3]=255
atlas=Image.fromarray(pix);draw=ImageDraw.Draw(atlas)
for k in range(22):
    # Restrained worn steel strokes in the material swatches, not glowing ornaments.
    x=int(rng.integers(0,510));y=int(rng.integers(292,344));draw.line((x,y,x+int(rng.integers(2,7)),y-1),fill=(159,150,124,255))

FACES=['north','south','east','west','up','down']
def face_uv(mat,lo,hi,face):
    tx,ty=tiles[mat]
    if face in ('north','south'):a,b=0,1
    elif face in ('east','west'):a,b=2,1
    else:a,b=0,2
    # Different physical surfaces have scaled planar UVs, always within their tile.
    u0=tx+4+(lo[a]*7)%18;v0=ty+4+(lo[b]*5)%18
    return [round(u0,5),round(v0,5),round(u0+max(.35,min(38,(hi[a]-lo[a])*9)),5),round(v0+max(.35,min(38,(hi[b]-lo[b])*9)),5)]
def cube(name,lo,hi,mat,parent,rotation=None,origin=None,head_uv=False):
    i=len(elements);lo=[round(v,6) for v in lo];hi=[round(v,6) for v in hi]
    f={s:{'uv':face_uv(mat,lo,hi,s),'texture':0} for s in FACES}
    if head_uv:
        # Atlas region x=0..310, y=0..240. y points down in the image.
        uv=[(lo[0]+8)*20,(19-hi[1])*20,(hi[0]+8)*20,(19-lo[1])*20]
        f['north']={'uv':[round(v,5) for v in uv],'texture':0}
        f['south']={'uv':[round(v,5) for v in [uv[2],uv[1],uv[0],uv[3]]],'texture':0}
    e={'name':name,'uuid':uid(str(i)+'/'+name),'type':'cube','from':lo,'to':hi,'origin':list(origin or [(a+b)/2 for a,b in zip(lo,hi)]),'rotation':rotation or [0,0,0],'uv_offset':[0,0],'rescale':False,'autouv':0,'color':0,'faces':f,'visibility':True,'export':True}
    elements.append(e);groups[parent]['children'].append(e['uuid']);return e

def inside(x,y,poly):
    c=False
    for (a,b),(d,e) in zip(poly,poly[1:]+poly[:1]):
        if (b>y)!=(e>y) and x<(d-a)*(y-b)/(e-b)+a:c=not c
    return c
def distance(x,y,poly):
    r=1e9
    for (a,b),(c,d) in zip(poly,poly[1:]+poly[:1]):
        dx=c-a;dy=d-b;t=max(0,min(1,((x-a)*dx+(y-b)*dy)/(dx*dx+dy*dy)))
        r=min(r,math.hypot(x-a-t*dx,y-b-t*dy))
    return r
def octagon(cx,cy,r):return [(cx+r*math.cos(math.pi/8+k*math.pi/4),cy+r*math.sin(math.pi/8+k*math.pi/4)) for k in range(8)]

# Outline taken from the axe in the default LM7 artwork, rotated upright for study.
profile=[(-7.35,12.05),(-5.25,13.05),(-3.0,14.0),(-2.02,15.55),(-1.7,15.82),(-.92,15.48),(5.70,18.22),(5.84,16.18),(5.61,13.92),(5.10,11.70),(4.45,9.92),(3.99,10.18),(4.37,12.10),(4.28,13.09),(2.99,13.23),(1.21,12.38),(.79,10.42),(.70,8.68),(-.70,8.68),(-.83,10.74),(-1.17,11.89),(-2.72,12.76),(-3.72,12.72),(-6.85,11.90)]
holes=[octagon(2.09,15.23,.70),octagon(4.11,16.03,.63),[(-2.45,14.10),(-1.90,14.90),(-.95,14.70)]]
STEP=.125;xs=np.arange(-7.5,6.001,STEP);ys=np.arange(8.5,18.376,STEP)
cells={};bins=[.10,.23,.39,.57]
for j,y in enumerate(ys):
 for i,x in enumerate(xs):
    cx=x+STEP/2;cy=y+STEP/2
    if not inside(cx,cy,profile) or any(inside(cx,cy,h) for h in holes):continue
    d=distance(cx,cy,profile);dh=min(distance(cx,cy,h) for h in holes)
    # Blade's outer arc has a real thickness reduction. Internal webs remain substantial.
    blade=cx>3.65 and cy<18.10
    tier=sum(d>q for q in bins) if blade else 4
    thick=[.18,.36,.62,.88,1.14][tier]
    mat=['edge','edge','brass_light','brass','dark'][tier]
    if dh<.16:mat='brass';thick=1.14
    elif d<.23 and not blade:mat='steel';thick=.90
    elif d<.45 and not blade:mat='brass';thick=1.02
    cells[(i,j)]=(thick,mat)

# Build continuous paired face artwork with broad inset planes, not glued-on lines.
for j in range(240):
 for i in range(320):
    x=i/20-8;y=19-j/20
    if not inside(x,y,profile):continue
    d=distance(x,y,profile);dh=min(distance(x,y,h) for h in holes)
    col=np.array(materials['dark'],float)
    if d<.13:col=np.array(materials['edge'],float)
    elif d<.34:col=np.array(materials['brass'],float)
    elif d<.48:col=np.array((89,79,58),float)
    elif x>4.30:col=np.array((75,76,69),float)
    if dh<.20:col=np.array(materials['brass'],float)
    col+=float(noise[j,i])*.8
    atlas.putpixel((i,j),tuple(np.clip(col,0,255).astype(int))+(255,))
draw=ImageDraw.Draw(atlas)
def xy(x,y):return ((x+8)*20,(19-y)*20)
def line(points,col,width=1):draw.line([xy(*v) for v in points],fill=col,width=width,joint='curve')
# Forged inset panels follow the shoulder/web, with sparse worn engraving.
line([(-6.05,12.40),(-2.57,13.78),(-1.73,15.12),(-.92,14.98),(5.15,17.47)],(117,103,73,255),2)
line([(5.23,16.8),(5.15,14.1),(4.80,12.3),(4.36,10.85)],(154,139,102,255),2)
line([(-.47,10.2),(-.20,12.38),(1.23,13.55),(3.15,13.87)],(104,95,75,255),2)
line([(1.10,14.43),(1.52,14.07),(1.72,14.46)],(134,126,98,255),1)
for x,y in [(-.5,14.0),(.13,13.6),(3.47,14.2),(4.73,15.02),(-1.7,13.35)]:
    line([(x,y),(x+.13,y+.10),(x+.27,y+.08)],(151,147,124,255),1)
# A faint cold cast in the working edge; no permanent oversized crystal garnish.
line([(5.59,16.25),(5.38,14.13),(4.89,11.91)],(145,164,158,255),1)

remaining=dict(cells)
while remaining:
    i,j=min(remaining,key=lambda q:(q[1],q[0]));v=remaining[(i,j)];w=1
    while remaining.get((i+w,j))==v:w+=1
    h=1
    while all(remaining.get((ii,j+h))==v for ii in range(i,i+w)):h+=1
    for jj in range(j,j+h):
        for ii in range(i,i+w):del remaining[(ii,jj)]
    thick,mat=v
    cube(('刃缘收薄' if thick<1.1 else '斧首锻体')+f'_{i}_{j}',[xs[i],ys[j],-thick/2],[xs[i]+w*STEP,ys[j]+h*STEP,thick/2],mat,'edge｜收薄刃缘' if thick<1.1 else 'head｜非对称斧身',head_uv=True)

# Eight-sided shaft using a main prism and real diagonal corner volumes.
cube('长柄芯',[-.365,-11.5,-.555],[.365,10.05,.555],'dark','shaft｜八棱长柄')
cube('长柄侧脊',[-.555,-11.5,-.365],[.555,10.05,.365],'steel','shaft｜八棱长柄')
for x,z in [(-.36,-.36),(-.36,.36),(.36,-.36),(.36,.36)]:
    cube('长柄倒角',[x-.183,-11.49,z-.183],[x+.183,10.04,z+.183],'dark','shaft｜八棱长柄',[0,45,0],[x,0,z])

# Distinctive long pale front plate with tapered ends, separated from the shaft.
plate=[(-.38,-6.85),(.38,-6.85),(.66,-6.20),(.54,7.82),(.30,8.73),(-.43,8.66),(-.65,7.90),(-.54,-6.10)]
def extruded_rows(poly,z0,z1,mat,g,step=.20,label='护片'):
    minx=min(v[0] for v in poly);maxx=max(v[0] for v in poly);miny=min(v[1] for v in poly);maxy=max(v[1] for v in poly)
    yy0=miny;n=0
    while yy0<maxy:
        yy1=min(maxy,yy0+step);ym=(yy0+yy1)/2;hits=[]
        for (a,b),(c,d) in zip(poly,poly[1:]+poly[:1]):
            if (b>ym)!=(d>ym):hits.append(a+(ym-b)*(c-a)/(d-b))
        if len(hits)>=2:
            cube(label+str(n),[min(hits),yy0,z0],[max(hits),yy1,z1],mat,g)
        yy0=yy1;n+=1
extruded_rows(plate,-.690,-.558,'plate','handle_plate｜长柄护片',.33)
extruded_rows(plate,.558,.675,'plate','handle_plate｜长柄护片',.33,'背护片')
# Broad continuous inset on the plate, actual bevel edges at its shoulder.
for s in [-1,1]:
    z=s*.705
    cube('护片中央暗面',[-.205,-5.92,min(z,z-s*.07)],[.175,7.65,max(z,z-s*.07)],'steel','handle_plate｜长柄护片')
    for y in [-6.03,7.82]:
        cube('护片嵌入铆座',[-.195,y-.195,min(s*.737,s*.695)],[.195,y+.195,max(s*.737,s*.695)],'dark','plate_pins｜护片铆钉',[0,0,45],[0,y,0])
        cube('低矮铆钉',[-.088,y-.088,min(s*.765,s*.731)],[.088,y+.088,max(s*.765,s*.731)],'pin','plate_pins｜护片铆钉')

# Lower grip has subtle recessed bands, keeping the default straight utilitarian handle.
cube('下握区',[-.58,-10.95,-.58],[.58,-7.08,.58],'grip','grip｜下握区')
for k in range(7):
    y=-10.74+k*.48
    for s in [-1,1]:
        cube('浅握槽'+str(k),[-.49,y,min(s*.588,s*.576)],[.49,y+.065,max(s*.588,s*.576)],'black','grip｜下握区')
for y,w,h in [(-11.45,.72,.32),(-7.05,.64,.22),(8.88,.73,.26),(9.34,.72,.23)]:
    g='pommel｜柄尾帽' if y<-11 else 'neck｜斧颈连接'
    cube('连接箍',[-w,y-h/2,-w],[w,y+h/2,w],'brass' if y<-7 else 'dark',g)
    for s in [-1,1]:cube('箍面金属',[-w+.12,y-h/2+.04,min(s*(w+.024),s*(w-.025))],[w-.12,y+h/2-.04,max(s*(w+.024),s*(w-.025))],'steel',g)
cube('柄尾主体',[-.59,-12.15,-.59],[.59,-11.46,.59],'dark','pommel｜柄尾帽')
cube('柄尾端面',[-.47,-12.26,-.47],[.47,-12.14,.47],'steel','pommel｜柄尾帽')

# Real octagonal rim segments around two open holes, on both sides.
for index,(cx,cy,r) in enumerate([(2.09,15.23,.70),(4.11,16.03,.63)]):
    for s in [-1,1]:
        for k in range(8):
            a=k*math.pi/4;rad=r+.09;px=cx+rad*math.cos(a);py=cy+rad*math.sin(a)
            # Tangential axis can always be represented with -45,0,45 + swapped dimensions.
            ang=math.degrees(a);w=.14;h=2*(r+.09)*math.tan(math.pi/8)+.035
            while ang>45:ang-=90;w,h=h,w
            while ang<-45:ang+=90;w,h=h,w
            zz0,zz1=sorted([s*.565,s*.638])
            cube(f'孔{index+1}_口沿{k}_{s}',[px-w/2,py-h/2,zz0],[px+w/2,py+h/2,zz1],'brass_light' if k in [1,2,3] else 'brass','hole_rims｜双贯穿孔口',[0,0,ang],[px,py,0])

# Crown bevel is one continuous legal 22.5-degree actual slope on each side.
for s in [-1,1]:
    cube('冠脊实体倒角',[-.68,15.40,min(s*.57,s*.72)],[5.47,15.62,max(s*.57,s*.72)],'brass','head_bevel｜冠部实斜面',[0,0,22.5],[-.68,15.51,0])

# Remove exact axis-aligned internal shared faces. Kept exposed thin sides are intentional.
faceaxis={'west':(0,False),'east':(0,True),'down':(1,False),'up':(1,True),'north':(2,False),'south':(2,True)}
disabled=0
for ei,e in enumerate(elements):
    if any(e['rotation']):continue
    for side,(axis,high) in faceaxis.items():
        coord=e['to' if high else 'from'][axis];other=[a for a in range(3) if a!=axis]
        for fj,f in enumerate(elements):
            if ei==fj or any(f['rotation']):continue
            if abs(f['from' if high else 'to'][axis]-coord)>1e-5:continue
            if all(f['from'][a]<=e['from'][a]+1e-6 and f['to'][a]>=e['to'][a]-1e-6 for a in other):
                e['faces'][side]['texture']=None;disabled+=1;break

atlas.save(OUT/'ceobe_ice_axe_512.png')
buf=io.BytesIO();atlas.save(buf,format='PNG')
texture={'name':'ceobe_ice_axe_512.png','id':'0','uuid':uid('texture'),'source':'data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode(),'uv_width':512,'uv_height':512,'width':512,'height':512,'render_mode':'default','visible':True,'saved':True}
display={'thirdperson_righthand':{'rotation':[0,90,0],'translation':[0,4.6,1.2],'scale':[.9,.9,.9]},'thirdperson_lefthand':{'rotation':[0,-90,0],'translation':[0,4.6,1.2],'scale':[.9,.9,.9]},'firstperson_righthand':{'rotation':[0,90,-12],'translation':[2.2,4.1,1.3],'scale':[.68,.68,.68]},'firstperson_lefthand':{'rotation':[0,-90,12],'translation':[2.2,4.1,1.3],'scale':[.68,.68,.68]},'gui':{'rotation':[0,0,-30],'translation':[0,-1.6,0],'scale':[.65,.65,.65]},'ground':{'rotation':[0,0,80],'translation':[0,2,0],'scale':[.5,.5,.5]},'fixed':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[.75,.75,.75]}}
check(elements,groups,ROOT,[texture])
path=save_native(OUT,NAME,elements,groups,ROOT,[texture],display)
bb=json.loads(path.read_text(encoding='utf-8'));bb['resolution']={'width':512,'height':512};path.write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
# Complete static Java model, coordinates kept legal; no integration into the pack.
json_path,count=export_static(OUT,'ceobe_ice_axe','ceobe_review',elements,groups,ROOT,[texture],display,offset=(8,8,8))
java=json.loads(json_path.read_text(encoding='utf-8'))
# A standalone whole Display entrance references the same texture and complete geometry.
display_bb={**bb,'name':'很冰的斧_整体Display调整','meta':{'format_version':'5.0','model_format':'java_block','box_uv':False},'elements':[],'groups':[],'outliner':[]}
for e in elements:
    e=json.loads(json.dumps(e))
    e['from']=[v+8 for v in e['from']];e['to']=[v+8 for v in e['to']];e['origin']=[v+8 for v in e['origin']]
    display_bb['elements'].append(e);display_bb['outliner'].append(e['uuid'])
(OUT/'很冰的斧_整体Display调整.bbmodel').write_text(json.dumps(display_bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
report={'cubes':len(elements),'groups':len(groups),'textures':1,'texture_resolution':[512,512],'java_elements':count,'native_animation_workspace':True,'animations':0,'exact_shared_internal_faces_removed':disabled,'visible_quads':sum(f['texture'] is not None for e in elements for f in e['faces'].values()),'reference':'Default official LM7 artwork, held asymmetrical axe; not the unrelated circular object in module artwork.','scope':'static review only; no game integration, no DP changes','sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
(OUT/'静态模型检查.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,ensure_ascii=False))
