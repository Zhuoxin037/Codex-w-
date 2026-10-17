"""Plain editable macaque-inspired skull. Writes new review drafts only."""
from pathlib import Path
import argparse, base64, collections, copy, io, json, math, random, sys, uuid
from PIL import Image,ImageDraw,ImageFont
P=argparse.ArgumentParser();P.add_argument('--draft',default='base01');a=P.parse_args()
STAGE=Path('D:/数据包/模型设计/五世恶咒_建模_20261015/阶段一_猴头骨本体')
OUT=STAGE/'过程记录'/a.draft
if OUT.exists():raise SystemExit('Preserve existing draft; choose a new name.')
OUT.mkdir(parents=True);step=.5;elements=[];groups=[]
uid=lambda s:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream/monkey_skull/'+s))
def group(n,p='猴头骨_整体',origin=(8,13,8)):
    groups.append({'name':n,'parent':p,'origin':list(origin),'rotation':[0,0,0],'uuid':uid('g/'+n),'export':True,'visibility':True})
group('猴头骨_整体',None)
for n in ['01_圆颅骨壳','02_眼眶与鼻梁','03_前突吻骨','04_颧弓_left','05_颧弓_right','06_上齿列']:group(n)
group('07_完整下颌',origin=(8,12,10));group('08_下齿列','07_完整下颌',(8,12,10))
palette={'bone':(115,111,101),'edge':(87,82,74),'inside':(49,45,41),'tooth':(163,155,137)}
tiles={k:(i%2*64,i//2*64) for i,k in enumerate(palette)}
atlas=Image.new('RGBA',(128,128));pix=atlas.load();rng=random.Random(1510)
for m,(tx,ty) in tiles.items():
    for y in range(64):
        for x in range(64):
            f=1.025-y*.0005;v=rng.uniform(-1.5,1.5)+math.sin(x*.29+y*.11)*1.5
            pix[x+tx,y+ty]=tuple(max(0,min(255,round(c*f+v))) for c in palette[m])+(255,)
    d=ImageDraw.Draw(atlas)
    for i in range(16):
        x=tx+rng.randrange(2,60);y=ty+rng.randrange(2,60)
        d.line((x,y,x+rng.randrange(1,3),y),fill=tuple(c-5 for c in palette[m])+(255,))

def cube(n,lo,hi,g,m='bone'):
    faces={}
    for f in ['north','south','east','west','up','down']:
        mat=m
        # Deliberately shade cavity-facing surfaces inside the cranial shell.
        if g=='01_圆颅骨壳' and ((f=='north' and lo[2]>11) or (f=='south' and hi[2]<7) or (f=='down' and lo[1]>17)):mat='inside'
        tx,ty=tiles[mat]
        aa,bb=(0,1) if f in ['north','south'] else ((2,1) if f in ['east','west'] else (0,2))
        u=5+lo[aa]*2;v=5+(23-hi[bb])*2 if bb==1 else 5+lo[bb]*2
        du=(hi[aa]-lo[aa])*2;dv=(hi[bb]-lo[bb])*2
        faces[f]={'uv':[tx+u,ty+v,tx+u+du,ty+v+dv],'texture':0}
    e={'name':n+f'_{len(elements):03d}','uuid':uid(a.draft+'/e/'+str(len(elements))),'type':'cube','from':lo,'to':hi,
       'origin':[8,13,8],'box_uv':False,'autouv':0,'faces':faces,'export':True,'_group':g,'_material':m}
    elements.append(e)

def merge(grid):
    grid=dict(grid)
    while grid:
        x,y,z=min(grid,key=lambda p:(p[1],p[2],p[0]));code=grid[x,y,z];w=h=dep=1
        while grid.get((x+w,y,z))==code:w+=1
        while all(grid.get((xx,y+h,z))==code for xx in range(x,x+w)):h+=1
        while all(grid.get((xx,yy,z+dep))==code for xx in range(x,x+w) for yy in range(y,y+h)):dep+=1
        for xx in range(x,x+w):
            for yy in range(y,y+h):
                for zz in range(z,z+dep):del grid[xx,yy,zz]
        g,m=code;cube(g.split('_',1)[-1],[x*step,y*step,z*step],[(x+w)*step,(y+h)*step,(z+dep)*step],g,m)

def dist_segment(q,p0,p1):
    dv=[b-c for b,c in zip(p1,p0)];t=sum((v-c)*d for v,c,d in zip(q,p0,dv))/sum(d*d for d in dv);t=max(0,min(1,t))
    return math.sqrt(sum((v-(c+t*d))**2 for v,c,d in zip(q,p0,dv)))
archleft=[(3.1,12.15,4.9),(2.0,11.9,6.2),(2.0,11.8,8.6),(3.1,12.05,10.6),(4.0,12.35,11.1)]
archright=[(16-x,y,z) for x,y,z in archleft]
grid={}
for iy in range(13,44):
    y=(iy+.5)*step
    for ix in range(2,31):
        x=(ix+.5)*step;dx=x-8
        for iz in range(0,34):
            z=(iz+.5)*step;code=None
            # Rounded braincase: a genuine bone shell around a cranial cavity.
            outer=(dx/5.45)**2+((y-15.65)/5.75)**2+((z-10.4)/5.95)**2<=1
            inner=(dx/4.45)**2+((y-15.65)/4.75)**2+((z-10.4)/4.95)**2<1
            orb=any(((x-cx)/2.05)**2+((y-14.35)/2.12)**2<1 for cx in [4.55,11.45])
            if outer and not inner and not (orb and z<10):code=('01_圆颅骨壳','bone')
            # Complete bony orbital rims, not painted eye patches or eyeballs.
            for cx in [4.55,11.45]:
                oval=((x-cx)/2.83)**2+((y-14.35)/2.86)**2<=1
                hollow=((x-cx)/2.05)**2+((y-14.35)/2.12)**2<1
                front=3.2+.06*(x-8)**2+.05*(y-14.35)**2
                if oval and not hollow and front<z<front+1.55:code=('02_眼眶与鼻梁','bone')
            # Sloping forward maxilla; monkeys have a projecting face, not a flat mask.
            mz=.35+.77*(y-10.5)
            muzzle=(dx/3.22)**2+((y-11.45)/2.05)**2<=1 and y>9.95 and mz<z<6.7
            nasal=(11.45<y<13.2 and abs(dx)<(.33+.50*(y-11.45)))
            if muzzle and not (nasal and z<4.8):code=('03_前突吻骨','bone')
            bridge=abs(dx)<.65 and 13.1<y<16.5 and 3.20<z<6.1
            if bridge:code=('02_眼眶与鼻梁','bone')
            # Palatine plate is thin, with physical mouth clearance underneath.
            if (dx/2.9)**2+((z-3.6)/3.1)**2<1 and 10.0<y<10.5:code=('03_前突吻骨','bone')
            # Open zygomatic bows connect the eye rim to the back of the cranium.
            for path,g in [(archleft,'04_颧弓_left'),(archright,'05_颧弓_right')]:
                if min(dist_segment((x,y,z),p0,p1) for p0,p1 in zip(path,path[1:]))<.58:code=(g,'bone')
            # U-shaped mandible in plan, with both ascending rami joined to it.
            jaw_outer=(dx/3.9)**2+((z-5.1)/4.55)**2<=1
            jaw_inner=(dx/2.85)**2+((z-5.1)/3.45)**2<1
            if jaw_outer and not jaw_inner and z<6.8 and 7.2<y<8.55:code=('07_完整下颌','bone')
            if 2.9<abs(dx)<4.02 and 5.4<z<10.1 and 7.85<y<9.0:code=('07_完整下颌','bone')
            if 2.95<abs(dx)<4.10 and 8.7<z<10.55 and 8.35<y<12.15:code=('07_完整下颌','bone')
            # A raised coronoid process, linked to the posterior jaw rather than floating.
            if 3.0<abs(dx)<3.9 and 7.7<z<9.3 and 8.7<y<11.0+(z-7.7):code=('07_完整下颌','bone')
            if code:grid[ix,iy,iz]=code
merge(grid)

# Separate, recognisable tooth rows. Small incisors, stronger canines and posterior molars.
for i in range(4):
    cx=6.8+i*.80
    cube('上切齿',[cx-.31,9.33,.80],[cx+.31,10.18,1.61],'06_上齿列','tooth')
    cube('下切齿',[cx-.29,8.38,.90],[cx+.29,9.04,1.67],'08_下齿列','tooth')
for sign in [-1,1]:
    cx=8+sign*2.45
    cube('上犬齿根',[cx-.38,9.25,1.65],[cx+.38,10.27,2.45],'06_上齿列','tooth')
    cube('上犬齿尖',[cx-.25,8.68,1.72],[cx+.25,9.36,2.25],'06_上齿列','tooth')
    cube('下犬齿',[cx-.27,8.3,2.55],[cx+.27,9.2,3.22],'08_下齿列','tooth')
    for j in range(4):
        z=3.0+j*1.0;x=8+sign*(2.55+.12*j)
        cube('上臼齿',[x-.37,9.55,z-.37],[x+.37,10.19,z+.37],'06_上齿列','tooth')
        cube('下臼齿',[x-.35,8.50,z-.35],[x+.35,9.20,z+.35],'08_下齿列','tooth')

# Hidden faces are deliberately disabled; every exposed boundary retains valid UVs.
axisfaces={'west':(0,0),'east':(0,1),'down':(1,0),'up':(1,1),'north':(2,0),'south':(2,1)}
removed=0
for e in elements:
    for f,(ax,end) in axisfaces.items():
        p=e['to' if end else 'from'][ax];other=[i for i in range(3) if i!=ax]
        for b in elements:
            if b is e:continue
            cover=(b['from'][ax]<=p+1e-7 and b['to'][ax]>p+1e-6) if end else (b['from'][ax]<p-1e-6 and b['to'][ax]>=p-1e-7)
            if cover and all(b['from'][i]<=e['from'][i]+1e-7 and b['to'][i]>=e['to'][i]-1e-7 for i in other):
                e['faces'][f]['texture']=None;removed+=1;break

def node(g):return {'uuid':g['uuid'],'isOpen':False,'children':[e['uuid'] for e in elements if e['_group']==g['name']]+[node(q) for q in groups if q['parent']==g['name']]}
display={'gui':{'rotation':[10,145,0],'translation':[0,-1,0],'scale':[.78,.78,.78]},
 'thirdperson_righthand':{'rotation':[0,90,0],'translation':[0,2.0,1.4],'scale':[.45,.45,.45]},
 'thirdperson_lefthand':{'rotation':[0,-90,0],'translation':[0,2.0,1.4],'scale':[.45,.45,.45]},
 'firstperson_righthand':{'rotation':[0,-35,0],'translation':[1,1,0],'scale':[.55,.55,.55]},
 'firstperson_lefthand':{'rotation':[0,35,0],'translation':[1,1,0],'scale':[.55,.55,.55]},
 'ground':{'rotation':[0,0,0],'translation':[0,0,0],'scale':[.6,.6,.6]},
 'fixed':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[.8,.8,.8]}}
atlas.save(OUT/'monkey_skull_bone.png');bio=io.BytesIO();atlas.save(bio,format='PNG')
tex={'name':'monkey_skull_bone.png','path':str(OUT/'monkey_skull_bone.png'),'relative_path':'monkey_skull_bone.png',
 'id':'0','uuid':uid('texture'),'width':128,'height':128,'uv_width':128,'uv_height':128,
 'source':'data:image/png;base64,'+base64.b64encode(bio.getvalue()).decode(),'internal':True,'saved':True,'render_mode':'default'}
bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':'猴头骨_基础形体_分组模型',
 'resolution':{'width':128,'height':128},'elements':[{k:v for k,v in e.items() if not k.startswith('_')} for e in elements],
 'groups':[{k:v for k,v in g.items() if k!='parent'} for g in groups],'outliner':[node(groups[0])],'textures':[tex],'animations':[],'display':display}
(OUT/'猴头骨_基础形体_分组模型.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf8')
db=copy.deepcopy(bb);db['meta']['model_format']='java_block';db['name']='猴头骨_整件Display调整'
(OUT/'猴头骨_整件Display调整.bbmodel').write_text(json.dumps(db,ensure_ascii=False,separators=(',',':')),encoding='utf8')
rp=OUT/'审阅资源';mp=rp/'assets/sweetdream/models/item/monkey_skull_base.json';mp.parent.mkdir(parents=True)
tp=rp/'assets/sweetdream/textures/item/monkey_skull_bone.png';tp.parent.mkdir(parents=True);atlas.save(tp)
model={'textures':{'0':'sweetdream:item/monkey_skull_bone','particle':'sweetdream:item/monkey_skull_bone'},
 'elements':[{'from':e['from'],'to':e['to'],'faces':{f:{'uv':[v/8 for v in ff['uv']],'texture':'#0'} for f,ff in e['faces'].items() if ff['texture'] is not None}} for e in elements],
 'display':display,'gui_light':'front'}
mp.write_text(json.dumps(model,separators=(',',':')),encoding='utf8')
ip=rp/'assets/sweetdream/items/monkey_skull_base.json';ip.parent.mkdir(parents=True);ip.write_text(json.dumps({'model':{'type':'minecraft:model','model':'sweetdream:item/monkey_skull_base'}}),encoding='utf8')
(rp/'pack.mcmeta').write_text(json.dumps({'pack':{'pack_format':55,'description':'猴头骨基础形体审阅（未接入）'}},ensure_ascii=False),encoding='utf8')
stats={'elements':len(elements),'groups':len(groups),'textures':1,'texture_size':[128,128],'hidden_faces_removed':removed,
 'group_counts':dict(collections.Counter(e['_group'] for e in elements)),
 'bounds':{'min':[min(e['from'][i] for e in elements) for i in range(3)],'max':[max(e['to'][i] for e in elements) for i in range(3)]}}
(OUT/'结构统计.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf8')
(OUT/'构建规格.json').write_text(json.dumps({'groups':groups,'elements':elements},ensure_ascii=False),encoding='utf8')
print(json.dumps({'output':str(OUT),**stats},ensure_ascii=False),flush=True)

sys.path.insert(0,'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts');import render3d as R
def nearest(self,u,v):return self._px(max(0,min(self.w-1,int(u*self.w/16))),max(0,min(self.h-1,int(v*self.h/16))))
R.Tex.sample=nearest
faces=R.bake(model,R.Repo(str(rp)),ns_hint='sweetdream');images=[]
views=[('斜前',145,15),('正面',180,0),('侧面',90,0),('背面',0,10)]
for name,yaw,pitch in views:
    rows,_=R.render([(faces,1.0)],600,540,yaw=yaw,pitch=pitch,bg=(224,222,215),ambient=.63,pad=.90)
    png=R.encode_png(600,540,rows);(OUT/f'猴头骨_实际模型_{name}.png').write_bytes(png);images.append(Image.open(io.BytesIO(png)).convert('RGB'))
sheet=Image.new('RGB',(1200,1160),(240,238,232));d=ImageDraw.Draw(sheet)
font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22);title=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',28)
d.text((24,14),'猴头骨本体 · 实际保存模型',font=title,fill=(45,41,40))
for i,(im,(name,_,_)) in enumerate(zip(images,views)):
    x=i%2*600;y=65+i//2*545;sheet.paste(im,(x,y));d.text((x+20,y+12),name,font=font,fill=(55,45,40))
sheet.save(OUT/'猴头骨_实际模型四视图.png');print('Saved actual geometry previews.',flush=True)
