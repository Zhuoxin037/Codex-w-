from pathlib import Path
import json, math, uuid, base64, random, shutil
from PIL import Image, ImageDraw

O=Path('D:/数据包/模型设计/风帆_阶段一'); O.mkdir(parents=True,exist_ok=True)
V=Path('C:/Users/qq303/.codex/visualizations/2026/09/30/01a0f228-3178-7672-a739-8812e448354c')
T=O/'贴图'; T.mkdir(exist_ok=True)
colors={'wood':(41,68,72),'woodlight':(61,91,93),'wooddark':(27,44,50),'brass':(154,124,78),'edge':(202,172,119),'shadow':(98,74,47),'leather':(68,49,39),'wrap':(92,65,47),'ivory':(220,211,187),'silver':(154,169,171),'blue':(50,105,160),'dark':(20,28,34),'sea':(27,49,103),'fire':(142,47,39),'dream':(169,99,127),'heart':(27,27,33)}
atlas=Image.new('RGBA',(128,128)); d=ImageDraw.Draw(atlas); uv={}; rng=random.Random(801)
for i,(n,c) in enumerate(colors.items()):
    x=i%8*16;y=i//8*16; uv[n]=[x,y,x+16,y+16]
    d.rectangle((x,y,x+15,y+15),fill=c+(255,))
    for k in range(12):
        xx=x+rng.randrange(16);yy=y+rng.randrange(16);delta=rng.choice([-6,-3,3,6]); cc=tuple(max(0,min(255,a+delta)) for a in c)
        d.line((xx,yy,xx,min(y+15,yy+rng.randrange(2,7))),fill=cc)
    if n in ['brass','edge','shadow']: d.line((x,y,x+15,y),fill=tuple(min(255,a+14) for a in c))
# Four purpose-drawn seal glyphs; front/back map directly to these separate atlas regions.
for i,n in enumerate(['sea','fire','dream','heart']):
    x=i*16;y=48;uv[n+'_glyph']=[x,y,x+16,y+16];c=colors[n]
    d.rectangle((x,y,x+15,y+15),fill=c);ink=(166,184,206) if i==0 else (217,151,119) if i==1 else (233,188,206) if i==2 else (163,156,161)
    d.rectangle((x+1,y+1,x+14,y+14),outline=ink)
    if i==0:
        for yy in [5,9]:d.line([(x+3,y+yy+1),(x+5,y+yy-1),(x+8,y+yy+1),(x+11,y+yy-1),(x+12,y+yy)],fill=ink)
    elif i==1:d.line([(x+8,y+3),(x+6,y+7),(x+9,y+7),(x+5,y+12),(x+11,y+9),(x+11,y+6)],fill=ink,width=1)
    elif i==2:
        d.line([(x+8,y+3),(x+10,y+7),(x+12,y+8),(x+9,y+9),(x+8,y+12),(x+6,y+9),(x+3,y+8),(x+6,y+6),(x+8,y+3)],fill=ink)
    else:d.line([(x+3,y+5),(x+5,y+4),(x+8,y+6),(x+11,y+4),(x+12,y+6),(x+8,y+12),(x+4,y+8),(x+3,y+5)],fill=ink)
atlas.save(T/'风帆_材质.png')
groups={};elements=[]
def uid(n):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:sail:stage1:'+n))
def group(n,p=None,origin=(0,0,0)):
    g={'name':n,'uuid':uid(n),'origin':list(origin),'rotation':[0,0,0],'children':[],'visibility':True,'export':True,'isOpen':p is None,'color':len(groups)%8};groups[n]=g
    if p:groups[p]['children'].append(g)
    return n
root=group('00_风帆_整体');mast=group('01_桅杆',root);grip=group('02_握柄与尾锥',root);comp=group('03_风向罗盘',root,(0,23,-1.45));rim=group('罗盘_镂空铜框',comp);needle=group('罗盘_可转动指针',comp,(0,23,-2));seals=group('04_四象记录槽',root);charm=group('05_连接环与垂饰',root,(2.6,21.2,0))
main=group('06_主帆_下一阶段',root,(0,30,0));rear=group('07_后帆_下一阶段',root,(0,30,1));spars=group('08_帆骨_下一阶段',root);group('09_风效_后续阶段',root)
for i in range(5):group('主帆_形变带_%02d'%(i+1),main,(0,35-i*2.7,0))
for i in range(3):group('后帆_形变带_%02d'%(i+1),rear,(0,31-i*3,1))
def box(g,n,a,b,mat='wood',angle=0,origin=None):
    a=list(a);b=list(b);e={'name':n,'type':'cube','uuid':uid(n+str(len(elements))),'from':a,'to':b,'origin':list(origin or [(a[j]+b[j])/2 for j in range(3)]),'rotation':[0,0,angle],'rescale':False,'box_uv':False,'autouv':0,'visibility':True,'export':True,'faces':{f:{'uv':uv[mat].copy(),'texture':0} for f in ['north','south','east','west','up','down']}}
    assert all(a[j]<b[j] for j in range(3)); elements.append(e);groups[g]['children'].append(e['uuid']);return e
def band(g,y,w,h,mat='brass',z=0):
    return box(g,'分层包箍',(-w/2,y-h/2,z-w/2),(w/2,y+h/2,z+w/2),mat)
def beam(g,n,a,b,width,depth,mat):
    x,y,z=[(a[j]+b[j])/2 for j in range(3)];length=math.hypot(b[0]-a[0],b[1]-a[1]);ang=math.degrees(math.atan2(b[1]-a[1],b[0]-a[0]));ang=(ang+180)%180
    swap=45<ang<135
    ang=ang-90 if swap else ang-180 if ang>=135 else ang
    wh=(width,length) if swap else (length,width)
    return box(g,n,(x-wh[0]/2,y-wh[1]/2,z-depth/2),(x+wh[0]/2,y+wh[1]/2,z+depth/2),mat,round(ang,6),(x,y,z))
# Long coherent timbers, with restrained bevel strips instead of random voxel clutter.
box(mast,'主桅杆_深青木芯',(-.49,2,-.48),(.49,39,.48))
box(mast,'正面纵向切面',(-.33,11.6,-.58),(.33,38.7,-.48),'woodlight')
box(mast,'左侧暗切面',(-.59,2.2,-.31),(-.49,38.8,.31),'wooddark')
box(mast,'背面纵向切面',(-.31,11.6,.48),(.31,38.7,.58),'wooddark')
for y in [11.8,19.5,27,33.6,37.8]:
    band(mast,y,1.44,.55,'brass');band(mast,y+.28,1.50,.13,'edge');band(mast,y-.29,1.42,.12,'shadow')
    for x in [-.42,.42]:box(mast,'包箍铆钉',(x-.10,y-.1,-.79),(x+.1,y+.1,-.72),'edge')
# Hooked finial with a dark void and clear stepped silhouette.
for a,b in [((-.7,38.65,0),(-1.8,39.75,0)),((-1.8,39.75,0),(-.65,40.9,0)),((-.65,40.9,0),(.6,40.9,0)),((.6,40.9,0),(1.35,40.15,0))]:beam(mast,'铜制回风钩',a,b,.52,.86,'brass')
band(mast,38.65,1.6,.45,'edge');box(mast,'顶帽凸榫',(-.36,40.9,-.33),(.25,41.35,.33),'edge')
# Leather grip, overlapping broad wraps plus narrow seams, not beads.
box(grip,'握柄皮革基底',(-.65,3.9,-.64),(.65,11.1,.64),'leather')
for j in range(13):
    y=4.0+j*.53
    box(grip,'皮革绕带_%02d'%j,(-.68,y,-.69),(.68,y+.43,.69),'wrap' if j%3==0 else 'leather')
    box(grip,'绕带接缝',(-.63,y+.39,-.715),(.60,y+.45,-.691),'shadow',-22.5)
for y in [3.7,11.3]:band(grip,y,1.64,.44);band(grip,y+.23,1.72,.13,'edge');band(grip,y-.23,1.62,.11,'shadow')
for y,w,h,m in [(2.9,1.30,1,'brass'),(2.3,1.5,.25,'edge'),(1.7,1.06,1,'brass'),(.95,.73,.5,'edge'),(.50,.44,.4,'brass'),(.18,.20,.24,'edge')]:band(grip,y,w,h,m)
# Back bracket visibly joins compass to mast. Ring is open, no solid backing disk.
box(comp,'罗盘背侧支架',(-.34,22.0,-1.45),(.34,24.0,-.48),'shadow')
box(comp,'罗盘横向支座',(-1.1,22.8,-1.50),(1.1,23.2,-1.05),'brass')
for rad,z,width,depth,mat in [(2.70,-1.25,.52,.60,'shadow'),(2.68,-1.64,.43,.38,'brass'),(2.68,-1.89,.15,.14,'edge')]:
    for i in range(8):
        a=math.radians(22.5+i*45);b=a+math.pi/4
        beam(rim,'八边罗盘框',(rad*math.cos(a),23+rad*math.sin(a),z),(rad*math.cos(b),23+rad*math.sin(b),z),width,depth,mat)
for ang in [0,90,180,270]:
    a=math.radians(ang);x=2.54*math.cos(a);y=23+2.54*math.sin(a)
    box(rim,'方位刻标',(x-.13,y-.13,-2.05),(x+.13,y+.13,-1.94),'ivory')
# Four solid stepped arrowheads, tips remain inside hollow ring.
for arm in range(4):
    for j in range(7):
        length=.27;start=.24+j*length;half=.50*(1-j/7)
        if arm==0:a=(-half,23+start,-2.05);b=(half,23+start+length,-1.79)
        elif arm==2:a=(-half,23-start-length,-2.05);b=(half,23-start,-1.79)
        elif arm==1:a=(start,23-half,-2.05);b=(start+length,23+half,-1.79)
        else:a=(-start-length,23-half,-2.05);b=(-start,23+half,-1.79)
        box(needle,'风向针_%d_%d'%(arm,j),a,b,'ivory' if arm<2 else 'silver')
box(needle,'指针轮毂铜座',(-.53,22.47,-2.11),(.53,23.53,-1.65),'brass')
box(needle,'蓝色轴心',(-.37,22.63,-2.31),(.37,23.37,-2.08),'blue')
box(needle,'轴心切面',(-.23,22.77,-2.40),(.23,23.23,-2.31),'silver')
# Four individually editable relief seal plates on a mounting rail.
box(seals,'记录槽背轨',(-.79,12.9,-.75),(.79,19.02,-.54),'wooddark')
for i,(n,label) in enumerate(zip(['sea','fire','dream','heart'],['渊海','流火','白昼梦','噬心'])):
    y=18.27-i*1.55;g=group('记录槽_'+label,seals,(0,y,-.9))
    box(g,'封印槽底',(-.73,y-.65,-.92),(.73,y+.65,-.71),'shadow')
    for x in [-.70,.58]:box(g,'铜框竖边',(x,y-.65,-1.10),(x+.12,y+.65,-.88),'edge')
    for yy in [y-.65,y+.53]:box(g,'铜框横边',(-.58,yy,-1.10),(.58,yy+.12,-.88),'brass')
    e=box(g,label+'_符印',(-.56,y-.51,-1.04),(.56,y+.51,-.94),n)
    e['faces']['north']['uv']=uv[n+'_glyph'];e['faces']['south']['uv']=uv[n+'_glyph']
# Actual linked open rectangles, then a small suspended nautical plumb.
for j in range(4):
    x=2.48;y=20.7-j*.70;z=-.24
    if j%2==0:
        for xx in [x-.24,x+.14]:box(charm,'链环侧柱',(xx,y-.40,z-.08),(xx+.10,y+.40,z+.08),'brass')
        for yy in [y-.4,y+.3]:box(charm,'链环横梁',(x-.24,yy,z-.08),(x+.24,yy+.1,z+.08),'edge')
    else:
        for zz in [z-.24,z+.14]:box(charm,'交错链环侧柱',(x-.08,y-.40,zz),(x+.08,y+.40,zz+.10),'brass')
        for yy in [y-.4,y+.3]:box(charm,'交错链环横梁',(x-.08,yy,z-.24),(x+.08,yy+.1,z+.24),'edge')
beam(charm,'链根连接臂',(1.75,21.0,-.24),(2.48,21.73,-.24),.20,.30,'brass')
for yy,w,h,mat in [(17.9,.53,.28,'edge'),(17.45,.40,.62,'brass'),(17.0,.25,.28,'edge')]:box(charm,'铜质测风垂饰',(2.48-w/2,yy-h/2,-.24-w/2),(2.48+w/2,yy+h/2,-.24+w/2),mat)

display={'gui':{'rotation':[0,0,-22.5],'translation':[0,0,0],'scale':[.39]*3},'firstperson_righthand':{'rotation':[0,-15,-12],'translation':[1,-2,-2],'scale':[.60]*3},'firstperson_lefthand':{'rotation':[0,15,12],'translation':[1,-2,-2],'scale':[.60]*3},'thirdperson_righthand':{'rotation':[0,0,0],'translation':[0,3,0],'scale':[.55]*3},'thirdperson_lefthand':{'rotation':[0,0,0],'translation':[0,3,0],'scale':[.55]*3},'ground':{'rotation':[0,0,85],'translation':[0,2,0],'scale':[.38]*3},'fixed':{'rotation':[0,180,0],'translation':[0,0,0],'scale':[.40]*3},'head':{'rotation':[0,0,0],'translation':[0,5,0],'scale':[.45]*3}}
def outline(g):return {'uuid':g['uuid'],'isOpen':g['isOpen'],'children':[outline(c) if isinstance(c,dict) else c for c in g['children']]}
bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':'风帆_阶段一_桅杆罗盘握柄','resolution':{'width':128,'height':128},'elements':elements,'groups':[{k:v for k,v in g.items() if k!='children'} for g in groups.values()],'outliner':[outline(groups[root])],'textures':[{'name':'风帆_材质.png','id':'0','uuid':uid('tex'),'width':128,'height':128,'uv_width':128,'uv_height':128,'internal':True,'source':'data:image/png;base64,'+base64.b64encode((T/'风帆_材质.png').read_bytes()).decode()}],'animations':[],'display':display}
(O/'风帆_阶段一_分组.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
modeldir=O/'显示调整示例/assets/sweetdream/models/item/sail';modeldir.mkdir(parents=True,exist_ok=True)
(modeldir/'display.json').write_text(json.dumps({'display':display},ensure_ascii=False,indent=2),encoding='utf-8')
out=[]
for e in elements:
    offset=[8,-12,8];q={'name':e['name'],'from':[round(e['from'][i]+offset[i],6) for i in range(3)],'to':[round(e['to'][i]+offset[i],6) for i in range(3)],'faces':{f:{'uv':[round(v/8,6) for v in face['uv']],'texture':'#0'} for f,face in e['faces'].items()}}
    angle=e['rotation'][2]
    if angle:q['rotation']={'axis':'z','angle':angle,'origin':[round(e['origin'][i]+offset[i],6) for i in range(3)],'rescale':False}
    assert angle in [-45,-22.5,0,22.5,45],angle
    assert all(-16<=v<=32 for v in q['from']+q['to'])
    out.append(q)
(modeldir/'stage1.json').write_text(json.dumps({'parent':'sweetdream:item/sail/display','textures':{'0':'sweetdream:item/sail/materials','particle':'sweetdream:item/sail/materials'},'elements':out},ensure_ascii=False,separators=(',',':')),encoding='utf-8')
texdir=O/'显示调整示例/assets/sweetdream/textures/item/sail';texdir.mkdir(parents=True,exist_ok=True);shutil.copy2(T/'风帆_材质.png',texdir/'materials.png')
stats={'cuboids':len(elements),'faces':6*len(elements),'groups':len(groups),'textures':1,'animations':0,'stage':'仅桅杆、握柄、罗盘、四象槽与垂饰；帆体和动画等待下一阶段','deployed':False}
(O/'模型统计.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8')
# Render the exact saved geometry/texture, using the established z-buffer renderer.
source=(V/'render_apocalypse_review.py').read_text(encoding='utf-8').split('def board():')[0]
source=source.replace("O=Path('D:/数据包/模型设计/启示录_审阅版')","O=Path('D:/数据包/模型设计/风帆_阶段一')").replace("启示录_分组动画.bbmodel","风帆_阶段一_分组.bbmodel")
source=source.replace("a=bb['animations'][anim];result=[]","a={'animators':{}};result=[]")
ns={};exec(compile(source,'sail_renderer','exec'),ns)
render=ns['render'];font=ns['font'];small=ns['small'];BG=ns['BG']
im=Image.new('RGB',(1600,1120),BG);d=ImageDraw.Draw(im)
d.text((35,24),'风帆 · 阶段一 / 桅杆、风向罗盘与握柄',font=font,fill='#e3d4b9')
d.text((35,76),'实际 bbmodel 几何与贴图渲染 · 帆面尚未制作 · 尚未接入游戏',font=small,fill='#a5adb0')
im.paste(render((380,880),yaw=math.pi,pitch=.04,scale=19.3,focus=(0,20.6,0)),(20,125))
im.paste(render((390,880),yaw=math.pi+.65,pitch=.08,scale=19.3,focus=(0,20.6,0)),(400,125))
im.paste(render((740,430),yaw=math.pi+.28,pitch=.10,scale=58,focus=(0,22.8,-1)),(815,153))
im.paste(render((340,350),yaw=math.pi+.15,pitch=.06,scale=47,focus=(0,16.05,-.8)),(823,654))
im.paste(render((350,350),yaw=math.pi+.58,pitch=.08,scale=39,focus=(0,7.5,0)),(1200,654))
d=ImageDraw.Draw(im)
for xy,label in [((40,1020),'正面 · 整体比例'),((420,1020),'斜侧 · 支架与部件厚度'),((840,126),'镂空罗盘 / 独立指针 / 实体连接'),((840,618),'四个独立记录槽'),((1210,618),'皮革绕带与旧铜包箍')]:d.text(xy,label,font=small,fill='#d3c4a8')
d.text((35,1073),f'{len(elements)} 个立方体 · {len(groups)} 个分组 · 已预留主帆与后帆形变分组',font=small,fill='#a5adb0')
im.save(O/'风帆_阶段一_实际模型.png')
print(json.dumps(stats,ensure_ascii=False))
