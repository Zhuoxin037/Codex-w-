"""Replacement: GSC shoulder apparatus, collar thorns and trailing torn strips.
The rejected six-spoke leaf fan is NOT used as a geometric starting point.
"""
# RETIRED_REJECTED_DRAFT: do not regenerate over the refined native mother.
raise SystemExit('旧背饰方案已被否决/替代；请编辑切面精修母版。')
from pathlib import Path
from PIL import Image,ImageDraw
import base64,copy,io,json,math,random,uuid
import numpy as np
from model_review_io import renderer

OUT=Path('D:/数据包/模型设计/爆裂黎明_建模_20261014/阶段二_优化与普通背饰')
P=OUT/'爆裂黎明_手办肩背装置_普通状态.bbmodel'
if P.exists():raise SystemExit('已有新母版，不能覆盖。')
E=[];G=[]
def group(name,parent=None,origin=(0,8,8)):
    g={'name':name,'uuid':str(uuid.uuid4()),'origin':list(origin),'rotation':[0,0,0],'children':[],'visibility':True,'export':True,'isOpen':True};G.append(g)
    if parent:parent['children'].append(g)
    return g
root=group('普通肩背装置_整体挂点')
collar=group('01_贴背领缘与连接座',root)
right=group('02_肩后双尖装置_right',root,(7.2,11,8.5));left=group('03_肩后双尖装置_left',root,(-7.2,11,8.5))
rfeather=group('04_肩下棘片_right',right,(7.5,10,8.5));lfeather=group('05_肩下棘片_left',left,(-7.5,10,8.5))
wires=group('06_肩后弧线与扣件',root)
fins=group('07_腰后黑蓝长棘',root,(0,3,9.5))
cloth=group('08_白灰下垂长片',root,(2.5,11.7,9.8))
clothtop=group('09_下垂上段',cloth,(2.5,11.7,9.8));clothmid=group('10_下垂中段',clothtop,(3.2,3.8,10.4));clothend=group('11_分叉拖尾',clothmid,(3,-4,11.2))
pal={'obsidian':(18,23,34),'blueblack':(27,37,58),'blue':(39,57,94),'edgeblue':(67,88,128),
     'steel':(116,129,151),'silver':(184,187,201),'pale':(222,220,230),'lilac':(173,167,191),
     'shadow':(124,128,150),'red':(143,34,49),'darkred':(89,32,47),'bolt':(142,151,171)}
rects={m:((i%4)*64,(i//4)*64) for i,m in enumerate(pal)}
im=Image.new('RGBA',(512,512),(25,30,43,255));pix=im.load();rng=random.Random(1035)
for m,color in pal.items():
    tx,ty=rects[m]
    for yy in range(64):
        for xx in range(64):
            delta=rng.choice([-1,0,0,0,1])+round(2*(1-xx/64))
            pix[tx+xx,ty+yy]=tuple(max(0,min(255,c+delta)) for c in color)+(255,)
def cube(name,lo,hi,g,mat='blueblack',rotation=(0,0,0),origin=(0,8,8)):
    assert all(a<b for a,b in zip(lo,hi)),(name,lo,hi)
    tx,ty=rects[mat];faces={}
    for side in ['north','east','south','west','up','down']:
        a,c=(0,1) if side in ('north','south') else ((2,1) if side in ('east','west') else (0,2))
        u=tx+5+(lo[a]+24)*.22;v=ty+5+(32-hi[c])*.22
        faces[side]={'texture':0,'uv':[u,v,u+max(.2,(hi[a]-lo[a])*2.2),v+max(.2,(hi[c]-lo[c])*2.2)]}
    e={'name':name,'uuid':str(uuid.uuid4()),'type':'cube','box_uv':False,'from':list(lo),'to':list(hi),'rotation':list(rotation),'origin':list(origin),'faces':faces,'visibility':True,'export':True};E.append(e);g['children'].append(e['uuid']);return e
def lance(name,base,length,width,depth,angle,g,mat='blueblack',tip=None,sign=1,segments=5):
    x,y,z=base
    for i in range(segments):
        a=i/segments;b=(i+1)/segments
        w=max(.12,width*(1-a)**.82)
        ya,yb=sorted([y+sign*length*a,y+sign*length*b])
        material=tip if tip and a>=.48 else mat
        cube(name+f'_{i}',[x-w/2,ya,z-depth/2],[x+w/2,yb,z+depth/2],g,material,(0,0,angle),base)
    # A narrow, raised metal/crystal spine, rather than a large flat leaf.
    if length>5:
        ya,yb=sorted([y+sign*length*.12,y+sign*length*.73])
        cube(name+'_折面脊',[x-width*.12,ya,z-depth*.63],[x+width*.08,yb,z-depth*.42],g,'steel' if tip else 'edgeblue',(0,0,angle),base)
def beam(name,a,b,width,g,mat='obsidian'):
    a=np.array(a,dtype=float);b=np.array(b,dtype=float);v=b-a;c=(a+b)/2
    ang=round(math.degrees(math.atan2(v[1],v[0]))/22.5)*22.5;ang=(ang+90)%180-90
    vertical=abs(ang)>45
    if vertical:ang=ang-90 if ang>0 else ang+90
    length=np.linalg.norm(v[:2])+.34;w,h=(width,length) if vertical else (length,width)
    return cube(name,[c[0]-w/2,c[1]-h/2,c[2]-width/2],[c[0]+w/2,c[1]+h/2,c[2]+width/2],g,mat,(0,0,ang),c.tolist())
def inside(x,y,poly):
    hit=False
    for (ax,ay),(bx,by) in zip(poly,poly[1:]+poly[:1]):
        if (ay>y)!=(by>y) and x<(bx-ax)*(y-ay)/(by-ay)+ax:hit=not hit
    return hit
def profile(name,poly,zlo,zhi,g,mat='pale',step=.45):
    cells=set()
    for j in range(math.floor(min(y for x,y in poly)/step),math.ceil(max(y for x,y in poly)/step)):
        for i in range(math.floor(min(x for x,y in poly)/step),math.ceil(max(x for x,y in poly)/step)):
            if inside((i+.5)*step,(j+.5)*step,poly):cells.add((i,j))
    made=[]
    while cells:
        i,j=min(cells,key=lambda p:(p[1],p[0]));w=h=1
        while(i+w,j)in cells:w+=1
        while all((k,j+h)in cells for k in range(i,i+w)):h+=1
        for yy in range(j,j+h):
            for xx in range(i,i+w):cells.remove((xx,yy))
        made.append(cube(name,[i*step,j*step,zlo],[(i+w)*step,(j+h)*step,zhi],g,mat))
    return made

# Open collar outline: the shoulder masses sit close to the body, never on spokes.
cube('背领横梁',[-6.7,10.4,7.0],[6.7,11.15,8.15],collar,'obsidian')
cube('背领银灰内缘',[-6.45,11.1,7.18],[6.45,11.48,7.77],collar,'steel')
for sign,g in [(1,right),(-1,left)]:
    beam('肩座斜梁',[sign*5.6,10.5,7.8],[sign*8.1,12.5,8.4],1.25,g,'blueblack')
    beam('肩座外叉',[sign*7.0,11.4,8.45],[sign*10.4,14.5,8.45],.72,g,'obsidian')
    cube('肩座嵌银扣',[sign*7.1-.55,11.8,7.75],[sign*7.1+.55,12.45,8.65],g,'silver')
    # Two long, narrow spear tips and the smaller dark prongs clustered at the root.
    lance('肩后高尖', [sign*7.4,12.5,8.7],11.0 if sign==1 else 9.5,1.55,.85,-22.5*sign,g,'blueblack','pale',segments=7)
    lance('肩后外尖',[sign*8.5,12.6,9.25],8.3 if sign==1 else 7.4,1.6,.72,-45*sign,g,'blueblack','silver',segments=6)
    for j,(dx,dy,l,w,ang) in enumerate([(0,.2,3.6,1.35,-45),(1.0,1.2,3.0,1.1,22.5),(-.5,1.1,2.9,1.0,-22.5)]):
        lance('交错根棘',[sign*(7.4+dx),12+dy,8.25+j*.17],l,w,.58,ang*sign,g,'blue','steel' if j==1 else None,segments=3)
    # Layered black-blue feather-like blades hanging from the shoulder rim.
    fg=rfeather if sign==1 else lfeather
    for j in range(4):
        lance('贴肩裂棘',[sign*(5.4+j*1.0),10.7-j*.12,8.18+j*.18],3.0+(j%3)*.8,1.05,.52,(-22.5 if j<2 else 22.5)*sign,fg,'blueblack',sign=-1,segments=3)

# Thin arc-shaped loops behind each fork, with discrete attachment clasps.
for sign in [1,-1]:
    pts=[(sign*8.1,14.2,9.7),(sign*9.1,17.6,9.8),(sign*12.3,18.0,9.9),(sign*14.0,16.4,9.8),(sign*13.7,13.7,9.7),(sign*11.8,12.5,9.6)]
    for i,(a,b) in enumerate(zip(pts,pts[1:])):
        beam('肩后束线弧',a,b,.15,wires)
        if i:
            x,y,z=a;cube('弧线接扣',[x-.18,y-.18,z-.19],[x+.18,y+.18,z+.21],wires,'steel')
    for x,y,z in [pts[0],pts[-1]]:cube('束线根扣',[x-.24,y-.27,8.45],[x+.24,y+.27,z+.15],wires,'obsidian')

# Two dark trailing fins at the waist, considerably thinner than the shoulder unit.
beam('腰后连接脊',[-4.4,4.4,8.8],[4.4,4.4,8.8],.65,fins,'obsidian')
for sign in [1,-1]:
    beam('腰后弯枝',[sign*3.7,4.6,9.0],[sign*7.4,3.2,9.6],.43,fins)
    lance('腰后黑蓝长尖',[sign*6.5,3.9,9.9],11.5,1.45,.62,45*sign,fins,'blueblack',sign=-1,segments=7)
    lance('腰后短叉',[sign*7.8,.4,9.8],4.1,.65,.42,-45*sign,fins,'blue',sign=-1,segments=3)

# A shoulder-hung pale strip snakes downward and tears into two unequal tails.
# Broad silver/lilac surfaces here are fabric-like strips, not six silver wings.
clothparts=[('肩下白灰长片',[(2.1,11.5),(4.3,11.5),(4.4,7.0),(3.8,3.2),(1.7,2.7),(2.3,7.2)],9.45,10.05,clothtop,'pale'),
 ('白灰中垂片',[(1.7,3.6),(3.9,3.9),(5.0,.6),(4.8,-2.9),(2.3,-5.2),(1.8,-3.8),(3.0,-.6)],9.85,10.6,clothmid,'lilac'),
 ('向左拖曳主片',[(2.5,-3.5),(4.8,-2.6),(3.4,-6.4),(.5,-7.7),(-4.0,-7.8),(-8.0,-9.7),(-6.4,-7.7),(-8.4,-7.2),(-2.5,-6.2)],10.3,11.0,clothend,'pale'),
 ('下垂破碎尾片',[(3.0,-3.9),(5.0,-2.7),(6.2,-6.8),(8.4,-9.1),(6.7,-8.2),(6.7,-10.5),(4.7,-8.2),(4.2,-9.1),(4.0,-7.2),(2.3,-6.1)],10.35,11.18,clothend,'shadow')]
for n,(name,poly,z0,z1,g,m) in enumerate(clothparts):
    made=profile(name,poly,z0,z1,g,m,.5)
    x0=min(p[0] for p in poly)-.5;x1=max(p[0] for p in poly)+.5;y0=min(p[1] for p in poly)-.5;y1=max(p[1] for p in poly)+.5
    tx=256+(n%2)*128;ty=(n//2)*192
    tile=Image.new('RGBA',(128,192),pal[m]+(255,));d=ImageDraw.Draw(tile)
    d.polygon([(20,0),(48,0),(80,192),(42,192)],fill=pal['silver']+(255,))
    d.polygon([(100,0),(113,0),(88,192),(68,192)],fill=pal['pale']+(255,))
    for yy in range(12,192,31):d.line([(25,yy),(65,yy+9),(98,yy+4)],fill=pal['lilac']+(255,),width=1)
    if n==2:d.polygon([(0,140),(50,174),(36,192),(0,192)],fill=pal['red']+(255,))
    im.paste(tile,(tx,ty))
    for e in made:
        lo=e['from'];hi=e['to']
        for side in ('north','south'):
            u0,u1=(hi[0]-x0)/(x1-x0),(lo[0]-x0)/(x1-x0) if side=='north' else (0,0)
            if side=='south':u0,u1=(lo[0]-x0)/(x1-x0),(hi[0]-x0)/(x1-x0)
            e['faces'][side]['uv']=[tx+u0*128,ty+(y1-hi[1])/(y1-y0)*192,tx+u1*128,ty+(y1-lo[1])/(y1-y0)*192]
cube('肩下织带扣',[1.85,10.9,8.0],[4.45,11.7,9.82],clothtop,'obsidian')

bio=io.BytesIO();im.save(bio,format='PNG');png=bio.getvalue()
t={'name':'burst_dawn_gsc_back.png','uuid':str(uuid.uuid4()),'id':'0','width':512,'height':512,'uv_width':512,'uv_height':512,'source':'data:image/png;base64,'+base64.b64encode(png).decode(),'path':'','relative_path':'','saved':True,'mode':'bitmap'}
def tree(g):return {'uuid':g['uuid'],'isOpen':True,'children':[tree(c) if isinstance(c,dict) else c for c in g['children']]}
b={'meta':{'format_version':'5.0','model_format':'free','box_uv':False,'bone_rig':True},'name':'爆裂黎明_手办肩背装置_普通状态','resolution':{'width':512,'height':512},
   'elements':E,'groups':[{k:v for k,v in g.items() if k!='children'} for g in G],'outliner':[tree(root)],'textures':[t],'animations':[],'display':{}}
P.write_text(json.dumps(b,ensure_ascii=False,separators=(',',':')),encoding='utf8');(OUT/'burst_dawn_gsc_back.png').write_bytes(png)
print(json.dumps({'cubes':len(E),'groups':len(G),'normal_state_only':True},ensure_ascii=False))
r=renderer(P);r['BG']=(29,32,39)
r['render']((1350,1450),yaw=math.pi-.28,pitch=.10,scale=29,focus=(0,6,9)).save(OUT/'手办肩背装置_首查.png')
