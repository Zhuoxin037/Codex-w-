"""Approved bright palette: lift viscous paint, gather one existing orb, release."""
from pathlib import Path
import json,copy,math,uuid,base64,io
import numpy as np
from PIL import Image,ImageDraw
from model_review_io import save_native,export_static,renderer,check

ROOT=Path(__file__).resolve().parents[1];S=ROOT/'模型设计/调色盘_明亮木盘_20261009/阶段一_实际模型';O=S.parent/'阶段二_提色施法';O.mkdir(exist_ok=True)
bb=json.loads((S/'调色盘_明亮木盘_分组动画.bbmodel').read_text(encoding='utf-8'));original=copy.deepcopy(bb);byid={g['uuid']:g for g in bb['groups']};groups={}
def expand(n):
    g={**byid[n['uuid']],**n,'children':[expand(c) if isinstance(c,dict) else c for c in n['children']]};groups[g['name']]=g;return g
tree=expand(bb['outliner'][0]);root=tree['name'];tree['origin']=[7.05,-3.15,-.10];elements=bb['elements'];textures=bb['textures'];U=lambda n:str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:palette:maple:cast:'+n))
def group(n,p=root,origin=(0,0,0),visible=True):
    g={'name':n,'uuid':U(n),'origin':list(origin),'rotation':[0,0,0],'visibility':visible,'export':True,'isOpen':False,'color':len(groups)%8,'children':[]};groups[n]=g;groups[p]['children'].append(g);return n
fx=group('07_施法_提色与汇聚');ribbon=group('08_独立槽色流',fx);orb=group('09_单枚色彩_沿用现有颜料球',fx,(0,-.45,-3.05));sparks=group('10_汇聚湿亮碎屑',fx,(0,-.45,-3.05))
atlas=Image.new('RGBA',(128,128));d=ImageDraw.Draw(atlas);uv={}
for i,(n,c) in enumerate({'red':(231,52,46),'yellow':(253,190,41),'blue':(58,117,233),'white':(250,239,212),'redlight':(255,145,120),'yellowlight':(255,235,156),'bluelight':(160,213,255),'whitelight':(255,251,234)}.items()):
    x=i%4*32;y=i//4*32;uv[n]=[x,y,x+32,y+32];d.rectangle((x,y,x+31,y+31),fill=c+(255,));d.rectangle((x,y+12,x+31,y+17),fill=tuple(round(v*.85+255*.15) for v in c)+(255,))
b=io.BytesIO();atlas.save(b,format='PNG');ti=len(textures);textures.append({'name':'提色流带_湿颜料.png','id':str(ti),'uuid':U('flowtex'),'width':128,'height':128,'uv_width':128,'uv_height':128,'internal':True,'source':'data:image/png;base64,'+base64.b64encode(b.getvalue()).decode()})
def cube(g,n,c,size,col,angle=0):
    c=np.array(c);sz=np.array(size);e={'name':n,'uuid':U(n+str(len(elements))),'type':'cube','from':(c-sz/2).tolist(),'to':(c+sz/2).tolist(),'origin':c.tolist(),'rotation':[0,0,angle],'box_uv':False,'autouv':0,'visibility':True,'export':True,'light_emission':8,'faces':{f:{'texture':ti,'uv':uv[col].copy()} for f in ['north','south','east','west','up','down']}}
    elements.append(e);groups[g]['children'].append(e['uuid']);return e
centers=[(6.75,4.10),(.15,5.05),(-6.2,3.80)];roman=['I','II','III'];labels={'red':'红','yellow':'黄','blue':'蓝'};flowgroups={};rig=[]
def bez(p,t):return (1-t)**3*p[0]+3*(1-t)**2*t*p[1]+3*(1-t)*t*t*p[2]+t**3*p[3]
for i,(x,y) in enumerate(centers):
    parent=group('色流_槽'+roman[i]+'_七段',ribbon,(x,y,-.7))
    p=np.array([[x,y,-.82],[x*.85,y+.2,-2.1],[x*.28,.85,-3.3],[0,-.45,-3.05]])
    for k in range(7):
        a=bez(p,k/7);b=bez(p,(k+1)/7);c=(a+b)/2;delta=b-a
        g=group('色流_槽'+roman[i]+'_段'+str(k+1),parent,tuple(c));rig.append((g,k,i))
        angle=math.degrees(math.atan2(delta[1],delta[0]));swap=abs(delta[1])>abs(delta[0])
        if swap:angle-=90
        angle=((angle+90)%180)-90;angle=max(-45,min(45,round(angle/22.5)*22.5))
        length=math.hypot(delta[0],delta[1])+.16;width=.24-.09*k/6
        size=[width,length,max(.13,abs(delta[2])+.12)] if swap else [length,width,max(.13,abs(delta[2])+.12)]
        for col,label in labels.items():
            v=group('色流_槽'+roman[i]+'_段'+str(k+1)+'_'+label,g,tuple(c),False);flowgroups[i,col,k]=v
            e=cube(v,'湿颜料流_'+roman[i]+col+str(k),c,size,col,angle)
            gloss=c.copy();gloss[2]-=size[2]/2+.015;sz=np.array(size)*[.42,.42,1];sz[2]=.037
            q=cube(v,'湿颜料流高光_'+roman[i]+col+str(k),gloss,sz,col+'light',angle);q['origin']=e['origin'].copy()
# Import actual current projectile geometry and texture instead of inventing another orb.
src=ROOT/'sweetdream_rp/assets/palette/models/item/color/crystal_14.json';source_orb=json.loads(src.read_text(encoding='utf-8'))
tex=ROOT/'sweetdream_rp/assets/palette/textures/item/t0.png';im=Image.open(tex);oti=len(textures);textures.append({'name':'现有颜料球_沿用贴图.png','id':str(oti),'uuid':U('orbtex'),'width':im.width,'height':im.height,'uv_width':im.width,'uv_height':im.height,'internal':True,'source':'data:image/png;base64,'+base64.b64encode(tex.read_bytes()).decode()})
orb1=group('色彩_第一槽颜料',orb,(0,-.45,-3.05));orb2=group('色彩_第二槽颜料',orb,(0,-.45,-3.05));white=group('色彩_沿用湿亮面',orb,(0,-.45,-3.05));orb_parts={0:[],1:[]}
for i,e in enumerate(source_orb['elements']):
    face=next(iter(e['faces'].values()));u,v=face['uv'][:2];tile=(int(u*8)//16,int(v*8)//16)
    slot=0 if tile==(1,1) else 1 if tile==(2,1) else None;g=orb1 if slot==0 else orb2 if slot==1 else white
    a=(np.array(e['from'])-8)*.18;b=(np.array(e['to'])-8)*.18;lo=[float(a[0]),float(a[1]-.45),float(-b[2]-3.05)];hi=[float(b[0]),float(b[1]-.45),float(-a[2]-3.05)]
    q={'name':'现有颜料球_%03d'%i,'uuid':U('orb_'+str(i)),'type':'cube','from':lo,'to':hi,'origin':[(x+y)/2 for x,y in zip(lo,hi)],'rotation':[0,0,0],'box_uv':False,'visibility':True,'export':True,'light_emission':e.get('light_emission',4),'faces':{}}
    for side,p in e['faces'].items():
        s={'north':'south','south':'north'}.get(side,side);q['faces'][s]={'texture':oti,'uv':[float(z*8) for z in p['uv']]}
    elements.append(q);groups[g]['children'].append(q['uuid'])
    if slot is not None:orb_parts[slot].append(q)
neutral=group('空盘_素白短笔触',ribbon,(0,.4,-1.5),False);neutralrig=[]
for k in range(5):
    c=[-.65+k*.25,.8-k*.22,-1.4-k*.30];g=group('素白短流_'+str(k),neutral,tuple(c));neutralrig.append(g);cube(g,'素白湿笔触_'+str(k),c,[.39,.13,.18],'white',-22.5)
spark_rig=[]
for k in range(5):
    a=math.tau*k/5;c=[math.cos(a)*.53,-.45+math.sin(a)*.53,-3.05];g=group('湿亮屑_'+str(k),sparks,tuple(c));spark_rig.append((g,a));cube(g,'微小湿亮屑_'+str(k),c,[.09,.09,.09],'whitelight')
def animation(n,length,loop):return {'name':n,'uuid':U(n),'loop':loop,'length':length,'snapping':20,'animators':{}}
idle=animation('01_待机_持盘轻颤',4,'loop');cast=animation('02_施法_提色汇成单球飞出',1.6,'once')
def channel(anim,g,c,keys):
    a=anim['animators'].setdefault(groups[g]['uuid'],{'name':g,'type':'bone','keyframes':[]})
    for t,v in keys:a['keyframes'].append({'uuid':U(anim['name']+g+c+str(t)),'channel':c,'time':round(t,6),'interpolation':'linear','data_points':[dict(zip('xyz',[str(round(float(x),6)) for x in v]))]})
channel(idle,root,'position',[(0,[0,0,0]),(1,[0,.045,0]),(2,[0,0,0]),(3,[0,-.045,0]),(4,[0,0,0])]);channel(idle,fx,'scale',[(0,[0,0,0]),(4,[0,0,0])])
channel(cast,root,'rotation',[(0,[0,0,0]),(.18,[7,0,0]),(.43,[18,0,-3]),(.65,[20,0,-4]),(.83,[4,0,1]),(1.25,[0,0,0]),(1.6,[0,0,0])])
channel(cast,root,'position',[(0,[0,0,0]),(.43,[-.25,.30,-.28]),(.65,[-.34,.38,-.40]),(.83,[0,.05,.10]),(1.25,[0,0,0]),(1.6,[0,0,0])]);channel(cast,fx,'scale',[(0,[1,1,1]),(1.6,[1,1,1])])
for i in range(3):
    for col,label in labels.items():
        n='槽'+roman[i]+'_'+label+'色颜料'
        channel(cast,n,'position',[(0,[0,0,0]),(.2,[0,0,0]),(.36,[0,0,-.4]),(.50,[-centers[i][0]*.025,-.10,-.80]),(.64,[-centers[i][0]*.055,-.22,-1.16]),(1.6,[-centers[i][0]*.055,-.22,-1.16])])
        channel(cast,n,'scale',[(0,[1,1,1]),(.25,[1,1,1]),(.40,[.86,.86,1.25]),(.55,[.35,.35,.94]),(.66,[0,0,0]),(1.6,[0,0,0])])
for g,k,i in rig:
    delay=k*.021
    channel(cast,g,'scale',[(0,[0,0,0]),(.23+delay,[0,0,0]),(.38+delay,[1,1,1]),(.56+delay,[1,1,1]),(.72+delay,[0,0,0]),(1.6,[0,0,0])])
    channel(cast,g,'position',[(0,[0,0,0]),(.38+delay,[0,0,0]),(.59+delay,[.07*math.sin(k),.05*math.cos(k),-.09]),(.83+delay,[0,0,0]),(1.6,[0,0,0])])
for k,g in enumerate(neutralrig):channel(cast,g,'scale',[(0,[0,0,0]),(.25+k*.025,[0,0,0]),(.42+k*.025,[1,1,1]),(.66,[1,1,1]),(.80+k*.012,[0,0,0]),(1.6,[0,0,0])])
channel(cast,orb,'scale',[(0,[0,0,0]),(.48,[0,0,0]),(.64,[1,1,1]),(.76,[1.08,1.08,1.08]),(1.02,[.85,.85,.85]),(1.13,[0,0,0]),(1.6,[0,0,0])])
channel(cast,orb,'position',[(0,[0,0,0]),(.66,[0,0,0]),(.78,[0,.28,-.4]),(.93,[0,1.12,-3.25]),(1.13,[0,2.2,-7.2]),(1.6,[0,2.2,-7.2])])
for g,a in spark_rig:
    channel(cast,g,'scale',[(0,[0,0,0]),(.50,[0,0,0]),(.64,[1,1,1]),(.80,[.7,.7,.7]),(.95,[0,0,0]),(1.6,[0,0,0])])
    channel(cast,g,'position',[(0,[0,0,0]),(.53,[0,0,0]),(.91,[.46*math.cos(a),.46*math.sin(a),-1.30]),(1.6,[.46*math.cos(a),.46*math.sin(a),-1.30])])
def state(colors):
    for i in range(3):
        for col,label in labels.items():
            groups['槽'+roman[i]+'_'+label+'色颜料']['visibility']=i<len(colors) and colors[i]==col
            for k in range(7):groups[flowgroups[i,col,k]]['visibility']=i<len(colors) and colors[i]==col
    groups[neutral]['visibility']=not colors
    for i in range(2):
        col=(colors[i] if i<len(colors) else colors[0] if colors else 'white');x,y={'red':(0,16),'yellow':(16,16),'blue':(32,16),'white':(48,64)}[col]
        for e in orb_parts[i]:
            for p in e['faces'].values():p['uv']=[x+3,y+3,x+12,y+12]
state(['yellow','blue'])
check(elements,groups,root,textures);assert all(next(e for e in elements if e['uuid']==old['uuid'])==old for old in original['elements'])
keys=[k['uuid'] for a in [idle,cast] for g in a['animators'].values() for k in g['keyframes']];assert len(keys)==len(set(keys))
display=json.loads((ROOT/'sweetdream_rp/assets/palette/models/item/palette.json').read_text(encoding='utf-8'))['display']
native=save_native(O,'调色盘_明亮木盘_提色施法_分组动画',elements,groups,root,textures,display,[idle,cast]);groups[fx]['visibility']=False
master,count=export_static(O,'palette','palette',elements,groups,root,textures,display);groups[fx]['visibility']=True
T=O/'贴图';T.mkdir(exist_ok=True)
for t in textures:(T/t['name']).write_bytes(base64.b64decode(t['source'].split(',')[1]))
r=renderer(native);render=r['render'];font,small=r['font'],r['small'];rg={}
def cache(g):
    rg[g['uuid']]=g
    for c in g['children']:
        if isinstance(c,dict):cache(c)
cache(r['bb']['outliner'][0])
def renderstate(colors):
    state(colors)
    for n,g in groups.items():rg[g['uuid']]['visibility']=g.get('visibility',True)
    for elist in orb_parts.values():
        for e in elist:r['elements'][e['uuid']]['faces']=copy.deepcopy(e['faces'])
im=Image.new('RGB',(1650,960),r['BG']);d=ImageDraw.Draw(im);d.text((30,23),'调色盘 · 明亮木盘 / 提色施法',font=font,fill='#ead4a9');d.text((30,70),'实际模型关键帧 · 倾盘提色 → 汇成一枚现有颜料球 → 飞出并回到空盘 · 尚未部署',font=small,fill='#a69e8f')
renderstate(['yellow','blue'])
for j,(t,label) in enumerate([(0,'起手：黄 + 蓝'),(.43,'提色：湿颜料流'),(.68,'汇聚：一枚小球'),(1.36,'收势：空盘')]):
    im.paste(render((410,470),t=t,anim=1,yaw=math.pi+.19,pitch=.32,scale=14.8,focus=(0,0,-1)),(j*412,120));ImageDraw.Draw(im).text((j*412+20,116),label,font=small,fill='#d7c09a')
for j,(colors,label) in enumerate([([],'空盘：素白笔触'),(['red','red'],'双红：保留重复颜色'),(['red','blue','yellow'],'第三槽：超限预留示意')]):
    renderstate(colors);im.paste(render((548,320),t=.58,anim=1,yaw=math.pi+.14,pitch=.29,scale=14.2,focus=(0,0,-1)),(j*550,620));ImageDraw.Draw(im).text((j*550+20,608),label,font=small,fill='#d7c09a')
im.save(O/'调色盘_明亮木盘_施法分镜.png');renderstate(['yellow','blue'])
frames=[]
for t in np.linspace(0,1.6,33):
    f=Image.new('RGB',(1050,790),r['BG']);f.paste(render((1050,690),t=float(t),anim=1,yaw=math.pi+.17,pitch=.37,scale=32,focus=(0,0,-1)),(0,75));ImageDraw.Draw(f).text((22,16),'明亮木盘 · 提色、单球汇聚与释放',font=font,fill='#e8cda0');frames.append(f)
frames[0].save(O/'调色盘_明亮木盘_提色施法.gif',save_all=True,append_images=frames[1:],duration=[50]*32+[600],loop=0,disposal=2)
stats={'whole_json_idle_cubes':count,'source_cubes_including_hidden_colors_and_fx':len(elements),'groups':len(groups),'textures':len(textures),'animations':2,'palette_body_preserved':True,'user_display_preserved':True,'projectile_reused_cubes':len(source_orb['elements']),'runtime_untouched':True,'deployed':False}
(O/'模型检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)
