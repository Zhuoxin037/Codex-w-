"""Continue the approved old-reference guard; broad root, frost blade and grip."""
from pathlib import Path
import json,copy,math,uuid,base64,io,random
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import save_native,export_static,renderer,check
ROOT=Path(__file__).resolve().parents[1]
S=ROOT/'模型设计/深海回响_旧稿重建_20261009/阶段一_宽剑根连接修订'
O=S.parent/'阶段二_旧稿整剑';O.mkdir(exist_ok=True)
bb=json.loads((S/'深海回响_宽剑根连接_分组.bbmodel').read_text(encoding='utf-8'));original=copy.deepcopy(bb)
byid={g['uuid']:g for g in bb['groups']};groups={}
def expand(n):
    g={**byid[n['uuid']],**n,'children':[expand(c) if isinstance(c,dict) else c for c in n['children']]};groups[g['name']]=g;return g
tree=expand(bb['outliner'][0]);root=tree['name'];elements=bb['elements'];textures=bb['textures']
U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:deepsea:oldreference:full:'+n))
names=['abyss','steel','steelfacet','shade','silver','silverlit','edge','silverdark','ice0','ice1','ice2','ice3','ice4','ice5','ice6','blueblack']
uv={n:[i%4*32,i//4*32,i%4*32+32,i//4*32+32] for i,n in enumerate(names)}
atlas=Image.new('RGBA',(64,64));rng=random.Random(1010);uv2={}
for i,(n,c) in enumerate({'leather':(14,31,55),'leatheredge':(29,49,76),'leathershadow':(9,22,39),'thread':(44,66,90)}.items()):
    x=i%2*32;y=i//2*32;uv2[n]=[x,y,x+32,y+32]
    for yy in range(32):
        for xx in range(32):
            v=rng.choice([-1,0,0,1]);atlas.putpixel((x+xx,y+yy),tuple(a+v for a in c)+(255,))
buf=io.BytesIO();atlas.save(buf,format='PNG');textures.append({'name':'深靛握柄_皮革.png','id':'1','uuid':U('leather'),'width':64,'height':64,'uv_width':64,'uv_height':64,'internal':True,'source':'data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()})
def group(n,p=root,origin=(0,0,0)):
    g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':True,'export':True,'isOpen':True,'color':len(groups)%8,'children':[]};groups[n]=g;groups[p]['children'].append(g);return n
def cube(g,n,a,b,mat,rotation=None):
    a,b=list(a),list(b);a[0],b[0]=-b[0],-a[0];ti=1 if mat in uv2 else 0;v=uv2[mat] if ti else uv[mat]
    e={'name':n,'type':'cube','uuid':U(n+str(len(elements))),'from':a,'to':b,'origin':[(x+y)/2 for x,y in zip(a,b)],'rotation':rotation or [0,0,0],'box_uv':False,'autouv':0,'visibility':True,'export':True,'faces':{f:{'texture':ti,'uv':v.copy()} for f in ['north','south','east','west','up','down']}}
    if ti==0 and mat in ['silver','silverlit','edge']:
        e['faces']['down']['uv']=uv['shade'].copy();e['faces']['south']['uv']=uv['silverdark'].copy()
    elements.append(e);groups[g]['children'].append(e['uuid']);return e
blade=group('07_完整剑刃_分层钢体');spine=group('剑刃_深蓝钢脊与斜切面',blade);frost=group('剑刃_双侧长冰刃',blade);tip=group('剑刃_冰白收尖',blade)
DX=.16;DY=.24;xs=np.arange(-1.9,1.9,DX);ys=np.arange(8.36,29.48,DY);X,Y=np.meshgrid(xs+DX/2,ys+DY/2)
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
W=np.interp(Y,[8.36,11,14,18,23,26.5,28.5,29.48],[.96,.98,.96,.85,.66,.40,.18,.008]);rel=X/W;M=abs(rel)<1
for j,(lo,hi,dep) in enumerate([(8.36,17,.48),(17,24,.35),(24,30,.21)]):
    zone=(Y>=lo)&(Y<hi)
    patches(M&zone,spine,'连续钢体'+str(j),-dep*.60,dep*.70,'abyss')
    patches(M&zone&(rel>-.65)&(rel<-.08),spine,'钢脊暗切面'+str(j),-dep,-dep*.60+.015,'steel')
    patches(M&zone&(rel>=-.08)&(rel<.64),spine,'钢脊蓝切面'+str(j),-dep*.95,-dep*.60+.015,'steelfacet')
    patches(M&zone&(abs(rel)<.11),spine,'细高钢脊'+str(j),-dep-.055,-dep*.94,'shade')
    patches(M&zone&(abs(rel)>.66),spine,'磨银主刃面'+str(j),-dep*.72,-dep*.59,'silverdark')
    patches(M&zone&(abs(rel)>.84),spine,'银蓝薄刃口'+str(j),-dep*.79,-dep*.71,'ice4')
# Larger arrow-ended facets, not a grid of little protrusions down the blade.
for j,(base,length) in enumerate([(9.0,4.5),(16.0,4.1),(22.2,3.2)]):
    t=(Y-base)/length;p=M&(t>=0)&(t<1)&(abs(X+.10)<W*.43*(1-t))
    dep=.54-j*.10
    patches(p,spine,'收尖钢片'+str(j),-dep,-dep+.035,'steel')
    patches(p&(X<-.04)&(X>-.14),spine,'收尖钢片浅切线'+str(j),-dep-.018,-dep,'steelfacet')

for side in [-1,1]:
    for j,(base,length) in enumerate([(8.36,5.0),(12.7,5.3),(17.5,4.8),(22.0,4.5),(25.8,3.7)]):
        if side<0 and j in [1,3]:base+=.35
        g=group(('刃侧A' if side<0 else '刃侧B')+'_长冰片_'+str(j+1),frost)
        t=(Y-base)/length;active=(t>=0)&(t<1)
        # Unequal crest placement breaks the mechanical ladder outline.
        ext=np.interp(t,[0,.16,.39,.62,.84,1],[.04,.44+(side>0)*.10,.16,.36,.08,.005])
        if side<0:ext*=.85
        ice=active&(X*side>W*.47)&(X*side<W+ext)
        dep=.50-j*.077
        patches(ice,g,'整片蓝冰'+str(side)+str(j),-dep*.94,dep*.35,'ice1' if j<4 else 'ice2')
        patches(ice&(X*side>W*.68),g,'冰蓝宽切面'+str(side)+str(j),-dep- .015,-dep*.93,'ice3' if j<4 else 'ice4')
        patches(ice&(X*side>W+ext*.47),g,'浅蓝外斜面'+str(side)+str(j),-dep-.043,-dep-.012,'ice4' if j<3 else 'ice5')
        patches(ice&(X*side>W+ext*.82),g,'冰白不规则细锋'+str(side)+str(j),-dep-.067,-dep-.041,'ice5' if j<3 else 'ice6')
patches((Y>27.7)&M,tip,'冰白剑尖',-.15,.12,'ice5')
patches((Y>28.6)&M,tip,'极尖亮面',-.18,-.145,'ice6')

grip=group('08_完整剑柄与尾部');leather=group('握柄_深靛缠革',grip,(0,-7,0));collars=group('握柄_下束环',grip);pommel=group('尾部_小型银蓝晶锋',grip,(0,-11.5,0))
cube(leather,'握柄内轴',[-.44,-10.52,-.4],[.44,-3.8,.4],'leathershadow')
for j in range(10):
    y=-3.9-j*.66
    cube(leather,'皮革缠带'+str(j),[-.45,y-.60,-.44],[.45,y,.44],'leather')
    cube(leather,'缠革斜边'+str(j),[-.46,y-.35,-.466],[.46,y-.255,-.439],'leatheredge',[0,0,-22.5])
for j,(w,y,h,mat) in enumerate([(.69,-10.62,.18,'silverdark'),(.81,-10.91,.26,'silver'),(.70,-11.11,.16,'silverlit')]):
    cube(collars,'尾部束环'+str(j),[-w,y,-w*.66],[w,y+h,w*.66],mat)
for j in range(12):
    yy=-11.11-j*.19;w=float(np.interp(j,[0,3,6,11],[.38,.72,.46,.02]));dep=w*.7
    cube(pommel,'尾端深钢座'+str(j),[-w,yy-.19,-dep],[w,yy,dep],'steelfacet')
    if j<8:
        cube(pommel,'尾端银切面A'+str(j),[-w,yy-.19,-dep-.035],[-w*.48,yy,-dep],'silverlit')
        cube(pommel,'尾端银切面B'+str(j),[w*.48,yy-.19,-dep-.035],[w,yy,-dep],'silver')
    if j>=3:
        wc=w*.48;cube(pommel,'尾端蓝晶嵌面'+str(j),[-wc,yy-.19,-dep-.055],[wc,yy,-dep-.031],'ice1' if j<7 else 'ice4')
check(elements,groups,root,textures)
now={e['uuid']:e for e in elements};assert all(now[e['uuid']]==e for e in original['elements'])
display=json.loads((ROOT/'sweetdream_rp/assets/deepseaecho/models/item/sword.json').read_text(encoding='utf-8'))['display']
native=save_native(O,'深海回响_旧稿整剑_分组',elements,groups,root,textures,display)
master,count=export_static(O,'sword','deepseaecho',elements,groups,root,textures,display,offset=(7.775,2,7.895))
(O/'贴图').mkdir(exist_ok=True)
for t in textures:(O/'贴图'/t['name']).write_bytes(base64.b64decode(t['source'].split(',')[1]))
r=renderer(native);im=Image.new('RGB',(1580,1360),r['BG']);d=ImageDraw.Draw(im)
d.text((30,23),'深海回响 · 按旧稿重建 / 完整静态模型',font=r['font'],fill='#c3dffa');d.text((30,72),'厚环护手与冰蓝刃片已确认 · 宽剑根连接 + 双侧渐薄冰刃 + 深靛握柄 · 尚未部署',font=r['small'],fill='#9baabb')
r['bb']['outliner'][0]['rotation']=[0,0,18]
im.paste(r['render']((820,1110),yaw=math.pi+.36,pitch=.06,scale=24.0,focus=(-7.8*math.sin(math.radians(18)),7.8*math.cos(math.radians(18)),0)),(0,145))
r['bb']['outliner'][0]['rotation']=[0,0,0]
im.paste(r['render']((370,1130),yaw=math.pi,pitch=0,scale=23.4,focus=(0,7.8,0)),(810,140))
im.paste(r['render']((390,1100),yaw=math.pi+.72,pitch=.10,scale=45,focus=(0,17.3,0)),(1180,135))
d=ImageDraw.Draw(im);d.text((826,116),'正面整剑',font=r['small'],fill='#bad4ea');d.text((1190,116),'剑刃斜侧',font=r['small'],fill='#bad4ea');d.text((30,1300),f'{count} 个立方体 · {len(groups)} 个分组 · 当前握姿已保留 · 浪纹动效待外观确认',font=r['small'],fill='#9faebb');im.save(O/'深海回响_旧稿整剑_实际模型.png')
stats={'cubes':count,'groups':len(groups),'textures':len(textures),'approved_guard_and_wide_root_preserved':True,'user_display_preserved':True,'java_static_checked':True,'static_review_only':True,'deployed':False}
(O/'模型检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)
