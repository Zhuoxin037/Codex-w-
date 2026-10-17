"""Author a new review draft only; never overwrite an existing saved project."""
from pathlib import Path
import argparse, base64, collections, copy, io, json, math, random, sys, uuid
from PIL import Image, ImageDraw, ImageFont

ROOT = Path('D:/数据包/模型设计/五世恶咒_建模_20261015')
STAGE = ROOT/'阶段一_咒颅静态形体'
ap=argparse.ArgumentParser(); ap.add_argument('--draft', default='draft01'); args=ap.parse_args()
OUT=STAGE/'过程记录'/args.draft
if OUT.exists(): raise SystemExit('Draft already exists. Use a new draft name; preserve saved projects.')
OUT.mkdir(parents=True)
UID=lambda s: str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream/five_curses/'+s))
groups=[]; elems=[]; material={}; STEP=.5

def group(name, parent='五世恶咒_整体', origin=(8,13,8)):
    groups.append(dict(name=name,uuid=UID('g/'+name),parent=parent,origin=list(origin),rotation=[0,0,0],export=True,visibility=True,color=len(groups)%8))
group('五世恶咒_整体',None,(8,10,8))
for n in ['01_黑木后颅','02_骨面与额咒','03_厚眉骨','04_颧骨与颌桥','05_鼻吻与上齿','06_下颌','07_双侧旧铜缀钉','08_后颅束绳','09_咒眼总成','10_布结挂饰']:
    group(n,origin=(8,11,8) if n=='06_下颌' else (8,13,8))
group('咒眼_right','09_咒眼总成',(11.5,15.7,5.3));group('咒眼_left','09_咒眼总成',(4.5,15.7,5.3))
group('挂饰结头','10_布结挂饰',(8,8,10));group('布尾_left','挂饰结头',(7.4,5.2,9.7));group('布尾_right','挂饰结头',(8.6,5.2,9.7))

colors={'bone':(205,188,155),'bone_plain':(202,184,152),'bone_edge':(168,145,110),'wood':(40,35,40),
 'void':(24,18,28),'purple':(73,31,102),'violet':(151,76,192),'cloth':(73,33,58),
 'bronze':(113,88,54),'brass_light':(160,130,80),'cord':(62,29,48),'bead':(204,189,159),
 'socket':(48,32,47),'pink':(191,119,218),'wood_edge':(52,43,49),'crack':(91,71,53)}
TILE=128;SIZE=512;DENSITY=4
for i,k in enumerate(colors):material[k]=(i%4*TILE,i//4*TILE)
atlas=Image.new('RGBA',(SIZE,SIZE));pix=atlas.load();rng=random.Random(501015)
for mat,(tx,ty) in material.items():
    base=colors[mat]
    for y in range(TILE):
        for x in range(TILE):
            # Soft pigment variation, not a dark grid around each cube.
            wave=math.sin(x*.31+y*.17)*1.4+math.cos(y*.53)*.7+rng.uniform(-1.7,1.7)
            light=1.02-.055*y/(TILE-1)
            pix[tx+x,ty+y]=tuple(max(0,min(255,round(v*light+wave))) for v in base)+(255,)
    d=ImageDraw.Draw(atlas)
    if mat in ['wood','wood_edge']:
        for j in range(17):
            x=tx+rng.randrange(3,TILE-4);y=ty+rng.randrange(1,TILE-13)
            d.line((x,y,x+rng.choice([-1,0,1]),min(ty+TILE-2,y+rng.randrange(3,13))),fill=(*tuple(max(0,v-5) for v in base),255))
    if mat in ['bone','bone_plain','bead']:
        for j in range(30):
            x=tx+rng.randrange(2,TILE-3);y=ty+rng.randrange(2,TILE-3)
            d.line((x,y,x+rng.randrange(1,3),y),fill=(*tuple(v+rng.choice([-7,6]) for v in base),255))
    if mat in ['cloth','cord']:
        for y in range(ty+3,ty+TILE-1,5):d.line((tx+1,y,tx+TILE-2,y),fill=(*tuple(v+3 for v in base),255))

# Projected north-face UVs share world coordinates, so the five forehead
# glyphs stay coherent across stepped bone slabs.
def uvxy(x,y):return 8+(16-x)*DENSITY,8+(25-y)*DENSITY
d=ImageDraw.Draw(atlas); runes=[]
for i,(x,y) in enumerate([(3.7,20.1),(5.85,20.9),(8,21.25),(10.15,20.9),(12.3,20.1)]):
    u,v=uvxy(x,y);u=int(u);v=int(v);runes.append([x,y])
    c=(75,26,103,255);l=(113,47,142,255)
    d.line([(u,v-3),(u-2,v),(u,v+2),(u+2,v),(u,v-3)],fill=c,width=1)
    d.line((u,v-4,u,v+4),fill=c,width=1)
    if i%2:d.line((u-3,v+1,u+3,v-1),fill=c)
    else:d.point((u,v),fill=l)

def cube(name,lo,hi,parent,mat,rotation=None,origin=None):
    if not all(b>a for a,b in zip(lo,hi)):raise ValueError((name,lo,hi))
    faces={}
    for f in ['north','south','east','west','up','down']:
        m=mat
        if mat=='bone' and f!='north':m='bone_plain' if f in ['up','south'] else 'bone_edge'
        tx,ty=material[m]
        if f=='north':
            u,v=uvxy(hi[0],hi[1]); du=(hi[0]-lo[0])*DENSITY;dv=(hi[1]-lo[1])*DENSITY
        elif f=='south':
            u=8+lo[0]*DENSITY;v=8+(25-hi[1])*DENSITY;du=(hi[0]-lo[0])*DENSITY;dv=(hi[1]-lo[1])*DENSITY
        elif f in ['east','west']:
            u=8+lo[2]*DENSITY;v=8+(25-hi[1])*DENSITY;du=(hi[2]-lo[2])*DENSITY;dv=(hi[1]-lo[1])*DENSITY
        else:
            u=8+lo[0]*DENSITY;v=8+lo[2]*DENSITY;du=(hi[0]-lo[0])*DENSITY;dv=(hi[2]-lo[2])*DENSITY
        faces[f]={'uv':[round(tx+u,4),round(ty+v,4),round(tx+u+du,4),round(ty+v+dv,4)],'texture':0}
    q={'name':name+f'_{len(elems):04d}','type':'cube','uuid':UID(args.draft+f'/c/{len(elems)}'),'from':list(lo),'to':list(hi),
       'origin':list(origin or [8,13,8]),'box_uv':False,'autouv':0,'faces':faces,'_group':parent,'_mat':mat,'visibility':True,'export':True}
    if rotation:q['rotation']=list(rotation)
    elems.append(q)

def greedy3(cells,step,prefix):
    cells=dict(cells)
    while cells:
        x,y,z=min(cells,key=lambda p:(p[1],p[2],p[0]));code=cells[x,y,z];w=h=dep=1
        while cells.get((x+w,y,z))==code:w+=1
        while all(cells.get((xx,y+h,z))==code for xx in range(x,x+w)):h+=1
        while all(cells.get((xx,yy,z+dep))==code for yy in range(y,y+h) for xx in range(x,x+w)):dep+=1
        for xx in range(x,x+w):
            for yy in range(y,y+h):
                for zz in range(z,z+dep):del cells[xx,yy,zz]
        mat,g=code;cube(prefix,(x*step,y*step,z*step),((x+w)*step,(y+h)*step,(z+dep)*step),g,mat)

cells={}
for iy in range(14,49):
    y=(iy+.5)*STEP
    for ix in range(1,32):
        x=(ix+.5)*STEP;dx=x-8
        for iz in range(0,33):
            z=(iz+.5)*STEP;v=None
            # One continuous 3-D skull volume. Bone front and wood back meet
            # inside the same occupied grid; there is no detached face plate.
            if (dx/6.8)**2+((y-16.5)/7.5)**2+((z-8.8)/6.1)**2<=1:
                v=('wood','01_黑木后颅') if z>=6.65 else ('bone','02_骨面与额咒' if y>17.8 else '04_颧骨与颌桥')
                # Deep eye sockets are excavated out of the full cranial volume.
                eyes=any(((x-cx)/2.0)**2+((y-15.65)/1.65)**2+((z-2.05)/3.65)**2<1 for cx in [4.5,11.5])
                mouth=(abs(dx)<3.55 and 8.6<y<11.4 and z<7.2)
                hand=(y<11.8 and abs(dx)<1.5 and 9.0<z<12.0)
                if eyes or mouth or hand:v=None
            # Blunt muzzle, broad flat upper jaw, and a joined nasal bridge.
            muzzle=(abs(dx)<2.85 and 11.0<y<13.55 and .75+.045*dx*dx<z<5.2)
            bridge=(abs(dx)<1.05 and 13.3<y<17.55 and 1.6<z<5.1)
            cheek=any(((x-cx)/1.12)**2+((y-13.45)/1.6)**2+((z-4.0)/1.8)**2<1 for cx in [2.55,13.45])
            if muzzle or bridge or cheek:v=('bone_plain','05_鼻吻与上齿' if not cheek else '04_颧骨与颌桥')
            nostril=any(((x-cx)/.52)**2+((y-12.75)/.50)**2<1 for cx in [7.0,9.0]) and z<2.9
            if muzzle and nostril:v=None
            # U-shaped connected mandible, open above the chin.
            outer=(dx/5.45)**2+((y-9.15)/2.55)**2<=1 and y<10.45
            inner=abs(dx)<3.65 and y>8.5
            jfront=1.85+.055*dx*dx
            if outer and not inner and jfront<=z<=jfront+2.15:v=('bone_plain','06_下颌')
            # Side jaw rami really join the face, rather than float below it.
            if 4.65<abs(dx)<5.7 and 9.1<y<13.0 and 4.6<z<6.6:v=('bone_edge','06_下颌')
            if v:cells[ix,iy,iz]=v
greedy3(cells,STEP,'咒颅雕体')

# Pronounced angular brow and secondary cheek planes from approved concept 1.
for sign in [-1,1]:
    cx=8+sign*3.10
    cube('厚重眉弓',[cx-2.62,17.15,1.08],[cx+2.62,18.30,3.80],'03_厚眉骨','bone_plain',
         [0,0,sign*22.5],[cx,17.72,2.40])
    cube('眉骨下侧阴面',[cx-2.37,16.99,2.28],[cx+2.37,17.30,3.83],'03_厚眉骨','bone_edge',
         [0,0,sign*22.5],[cx,17.72,2.40])
    cube('眼窝内后壁',[8+sign*3.50-1.65,14.15,5.15],[8+sign*3.50+1.65,17.20,5.55],
         '咒眼_right' if sign>0 else '咒眼_left','socket')
    pg='咒眼_right' if sign>0 else '咒眼_left'
    cx=8+sign*3.5
    cube('深层紫咒眼',[cx-.74,14.98,4.96],[cx+.74,16.28,5.24],pg,'purple')
    cube('紫瞳',[cx-.39,15.23,4.82],[cx+.39,16.01,5.10],pg,'violet')
    cube('咒眼细亮点',[cx-.12,15.59,4.73],[cx+.13,15.86,4.95],pg,'pink')
    nx=8+sign*1.0
    cube('鼻孔内壁',[nx-.47,12.3,2.88],[nx+.47,13.2,3.08],'05_鼻吻与上齿','void')
    # Two short aged bronze clasps run from the bone face into the wood.
    for yy in [13.3,19.0]:
        x=8+sign*5.55
        cube('侧面旧铜压片',[x-.53,yy-.61,5.20],[x+.53,yy+.61,8.08],'07_双侧旧铜缀钉','bronze')
        for z in [5.23,7.62]:
            cube('压片铆钉',[x-.20,yy-.20,z-.11],[x+.20,yy+.20,z+.17],'07_双侧旧铜缀钉','brass_light')

# Separated teeth; gaps look into a real recessed cavity, no black painted rectangle.
for i in range(6):
    x=5.65+i*.79
    cube('上排短齿',[x-.31,10.0+(i%2)*.10,1.30],[x+.31,11.14,2.45],'05_鼻吻与上齿','bone_plain')
for i in range(4):
    x=6.55+i*.95
    cube('下排短齿',[x-.32,8.23,1.55],[x+.32,8.93-(i%2)*.09,2.52],'06_下颌','bone_plain')

# Cords follow the actual rear ellipsoid instead of crossing empty space.
for k in [0,1]:
    previous=None
    for i in range(41):
        t=-math.pi/2+i*math.pi/40
        x=8+6.45*math.sin(t);y=14.9+(1 if k==0 else -1)*1.40*math.sin(t)+(k-.5)*.30
        z=8.8+6.1*math.sqrt(max(.025,1-((x-8)/6.8)**2-((y-16.5)/7.5)**2))+.04
        q=[x,y,z]
        if previous:
            lo=[min(a,b)-.20 for a,b in zip(q,previous)];hi=[max(a,b)+.20 for a,b in zip(q,previous)]
            cube('贴合后颅束绳',lo,hi,'08_后颅束绳','cord')
        previous=q
# Rear bronze keeper; contact with the rear shell is intentional.
cube('背面束绳扣',[7.25,14.12,14.74],[8.75,15.84,15.35],'08_后颅束绳','bronze')
cube('背扣旧铜内圈',[7.56,14.43,15.22],[8.44,15.53,15.52],'08_后颅束绳','brass_light')
cube('背扣暗心',[7.72,14.61,15.43],[8.28,15.35,15.60],'08_后颅束绳','bronze')

# A true attached hanging knot with two individually editable cloth tails.
cube('挂结连颅短绳',[7.63,7.20,9.12],[8.37,10.20,10.12],'挂饰结头','cord')
for yy,ang in [(7.0,45),(6.33,-45)]:
    cube('交织结头',[7.36,yy,9.0],[8.64,yy+.75,10.14],'挂饰结头','cord',[0,0,ang],[8,yy+.375,9.57])
for sign in [-1,1]:
    cx=8+sign*.61;pg='布尾_right' if sign>0 else '布尾_left'
    cube('骨珠套绳',[cx-.15,4.65,9.42],[cx+.15,6.70,9.78],pg,'cord')
    cube('旧骨方珠',[cx-.51,5.1,9.05],[cx+.51,5.98,10.15],pg,'bead')
    # Three attached segments give cloth volume and a torn asymmetric hem.
    rot=sign*22.5;end=1.10 if sign<0 else .35
    cube('布尾上段',[cx-.39,3.42,9.25],[cx+.39,5.28,9.69],pg,'cloth',[0,0,rot],[cx,5.20,9.47])
    cube('布尾下段',[cx-.43,end+.55,9.27],[cx+.43,3.49,9.71],pg,'cloth',[0,0,rot],[cx,5.20,9.47])
    cube('破布尖一',[cx-.43,end,9.28],[cx-.04,end+.69,9.72],pg,'cloth',[0,0,rot],[cx,5.20,9.47])
    cube('破布尖二',[cx+.11,end+.16,9.29],[cx+.43,end+.78,9.73],pg,'cloth',[0,0,rot],[cx,5.20,9.47])

# Drop wholly buried axis-aligned faces (including boundaries at touching volumes).
facespec={'west':(0,0),'east':(0,1),'down':(1,0),'up':(1,1),'north':(2,0),'south':(2,1)}
removed=0
for a in elems:
    if a.get('rotation'):continue
    for side,(axis,end) in facespec.items():
        p=a['to' if end else 'from'][axis];other=[j for j in range(3) if j!=axis]
        for b in elems:
            if a is b or b.get('rotation'):continue
            beyond=(b['from'][axis]<p+1e-7 and b['to'][axis]>p+1e-5) if end else (b['from'][axis]<p-1e-5 and b['to'][axis]>p-1e-7)
            if beyond and all(b['from'][j]<=a['from'][j]+1e-7 and b['to'][j]>=a['to'][j]-1e-7 for j in other):
                a['faces'][side]['texture']=None;removed+=1;break

atlas.save(OUT/'five_curses_atlas.png')
buffer=io.BytesIO();atlas.save(buffer,format='PNG');dataurl='data:image/png;base64,'+base64.b64encode(buffer.getvalue()).decode()
texture={'name':'five_curses_atlas.png','path':str(OUT/'five_curses_atlas.png'),'relative_path':'five_curses_atlas.png',
 'id':'0','uuid':UID('texture'),'width':SIZE,'height':SIZE,'uv_width':SIZE,'uv_height':SIZE,'source':dataurl,
 'internal':True,'saved':True,'render_mode':'default','namespace':'sweetdream','folder':'item'}
byname={g['name']:g for g in groups}
def node(g):
    return {'uuid':g['uuid'],'isOpen':False,'children':[e['uuid'] for e in elems if e['_group']==g['name']]+[node(h) for h in groups if h['parent']==g['name']]}
display={'gui':{'rotation':[12,145,0],'translation':[0,.8,0],'scale':[.65,.65,.65]},
 'thirdperson_righthand':{'rotation':[0,90,0],'translation':[0,3.2,1.0],'scale':[.48,.48,.48]},
 'thirdperson_lefthand':{'rotation':[0,-90,0],'translation':[0,3.2,1.0],'scale':[.48,.48,.48]},
 'firstperson_righthand':{'rotation':[0,-35,0],'translation':[1.1,2.5,0],'scale':[.55,.55,.55]},
 'firstperson_lefthand':{'rotation':[0,35,0],'translation':[1.1,2.5,0],'scale':[.55,.55,.55]},
 'ground':{'rotation':[0,0,0],'translation':[0,2,0],'scale':[.5,.5,.5]},
 'fixed':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[.65,.65,.65]},
 'head':{'rotation':[0,0,0],'translation':[0,7,0],'scale':[.7,.7,.7]}}
clean=[{k:v for k,v in e.items() if not k.startswith('_')} for e in elems]
bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':'五世恶咒_咒颅_分组模型',
 'model_identifier':'five_curses_ritual_skull','resolution':{'width':SIZE,'height':SIZE},'elements':clean,
 'groups':[{k:v for k,v in g.items() if k!='parent'} for g in groups],'outliner':[node(groups[0])],'textures':[texture],'animations':[],'display':display}
(OUT/'五世恶咒_咒颅_分组模型.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf8')
bbd=copy.deepcopy(bb);bbd['meta']['model_format']='java_block';bbd['name']='五世恶咒_整件Display调整'
(OUT/'五世恶咒_整件Display调整.bbmodel').write_text(json.dumps(bbd,ensure_ascii=False,separators=(',',':')),encoding='utf8')

rp=OUT/'审阅资源';mp=rp/'assets/sweetdream/models/item/five_curses_review.json';mp.parent.mkdir(parents=True)
tp=rp/'assets/sweetdream/textures/item/five_curses_atlas.png';tp.parent.mkdir(parents=True);atlas.save(tp)
je=[]
for e in elems:
    f={k:{'uv':[round(v*16/SIZE,7) for v in ff['uv']],'texture':'#0'} for k,ff in e['faces'].items() if ff['texture'] is not None}
    q={'from':e['from'],'to':e['to'],'faces':f}
    if e.get('rotation'):
        axis=next(i for i,v in enumerate(e['rotation']) if v);q['rotation']={'origin':e['origin'],'axis':'xyz'[axis],'angle':e['rotation'][axis]}
    je.append(q)
model={'credit':'Sweetdream original Five Curses; static review only','texture_size':[SIZE,SIZE],'textures':{'0':'sweetdream:item/five_curses_atlas','particle':'sweetdream:item/five_curses_atlas'},'elements':je,'display':display,'gui_light':'front'}
mp.write_text(json.dumps(model,ensure_ascii=False,separators=(',',':')),encoding='utf8')
ip=rp/'assets/sweetdream/items/five_curses_review.json';ip.parent.mkdir(parents=True);ip.write_text(json.dumps({'model':{'type':'minecraft:model','model':'sweetdream:item/five_curses_review'}}),encoding='utf8')
(rp/'pack.mcmeta').write_text(json.dumps({'pack':{'pack_format':55,'description':'五世恶咒静态审阅资产（未接入）'}},ensure_ascii=False),encoding='utf8')
stats={'elements':len(elems),'groups':len(groups),'textures':1,'texture_size':[SIZE,SIZE],'hidden_internal_faces_removed':removed,
 'materials':dict(collections.Counter(e['_mat'] for e in elems)),'group_counts':dict(collections.Counter(e['_group'] for e in elems)),
 'bounds':{'min':[min(e['from'][i] for e in elems) for i in range(3)],'max':[max(e['to'][i] for e in elems) for i in range(3)]},'rune_centers':runes}
(OUT/'构建规格.json').write_text(json.dumps({'groups':groups,'elements':elems,'statistics':stats},ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({'output':str(OUT),**stats},ensure_ascii=False))

# Previews are baked from exactly the exported geometry and saved atlas.
sys.path.insert(0,'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R
def nearest_sample(self,u,v):
    x=max(0,min(self.w-1,int(u*self.w/16)));y=max(0,min(self.h-1,int(v*self.fh/16)+self.cur*self.fh))
    return self._px(x,y)
R.Tex.sample=nearest_sample
faces=R.bake(model,R.Repo(str(rp)),ns_hint='sweetdream')
viewdefs=[('正面',180,0),('斜前',148,12),('侧面',90,0),('背面',0,8)]
images=[]
for label,yaw,pitch in viewdefs:
    rows,fit=R.render([(faces,1.0)],520,620,yaw=yaw,pitch=pitch,bg=(226,222,212),ambient=.70,pad=.91)
    png=R.encode_png(520,620,rows);(OUT/f'实际模型_{label}.png').write_bytes(png);images.append(Image.open(io.BytesIO(png)).convert('RGB'))
sheet=Image.new('RGB',(1040,1320),(240,238,231));draw=ImageDraw.Draw(sheet)
fontpath='C:/Windows/Fonts/msyh.ttc';font=ImageFont.truetype(fontpath,22);title=ImageFont.truetype(fontpath,28)
draw.text((24,15),'五世恶咒 · 已保存静态模型预览',font=title,fill=(48,39,48))
for i,((label,_,_),im) in enumerate(zip(viewdefs,images)):
    x=(i%2)*520;y=65+(i//2)*625;sheet.paste(im,(x,y));draw.text((x+20,y+10),label,font=font,fill=(60,45,62))
sheet.save(OUT/'五世恶咒_实际模型四视图.png')
print('Saved actual-model previews.')
