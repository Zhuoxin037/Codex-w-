"""New approved maple palette; old Greek/live assets are never overwritten."""
from pathlib import Path
import json, math, collections
from PIL import Image,ImageDraw
from model_review_io import save_native,export_static,renderer,check,visible_ids

ROOT=Path(__file__).resolve().parents[1]
O=ROOT/'模型设计/调色盘_明亮木盘_20261009/阶段一_实际模型';O.mkdir(parents=True,exist_ok=True)
s=(ROOT/'.workbuddy/build_palette_stage1.py').read_text(encoding='utf-8').split('# All review model states')[0]
s=s.replace("O=Path('D:/数据包/模型设计/调色盘_阶段一')",'O=Path('+repr(str(O))+')')
s=s.replace('sweetdream:palette:stage1:','sweetdream:palette:maple:')
recolors={'(131,77,48)':'(162,99,47)','(178,115,70)':'(207,144,70)','(91,55,36)':'(139,79,35)','(226,211,178)':'(246,216,156)','(203,180,139)':'(226,181,111)','(139,117,91)':'(190,137,72)','(104,83,59)':'(143,87,38)','(159,120,59)':'(192,148,64)','(186,45,40)':'(218,43,43)','(223,166,40)':'(242,181,32)','(45,94,157)':'(38,81,191)','(238,220,181)':'(255,236,184)'}
for a,b in recolors.items():s=s.replace(a,b)
s=s.replace("'highlight':(255,236,184)","'highlight':(255,236,184),'redlight':(255,114,97),'yellowlight':(255,225,106),'bluelight':(103,164,255)")
s=s.replace("'bluelight':(103,164,255)","'bluelight':(103,164,255),'reddark':(155,18,25),'yellowdark':(186,117,8),'bluedark':(16,38,115),'redmid':(239,57,49),'yellowmid':(255,202,45),'bluemid':(49,104,224)")
s=s.replace('(232,218,186,255)','(244,211,151,255)').replace('(232+delta,218+delta,186+delta,255)','(244+delta,211+delta,151+delta,255)').replace('(232+v,218+v,186+v)','(244+v,211+v,151+v)').replace('wave*2','wave*3')
s=s.replace('盘面_象牙白木纹.png','盘面_明亮枫木纹.png').replace('盘体_陶土色木胎','盘体_琥珀色木胎').replace('盘体_象牙白混色面','盘体_明亮枫木混色面').replace('CELL=.40','CELL=.30')
start=s.index("label=Image.new");end=s.index('textures=[]',start);s=s[:start]+s[end:]
s=s.replace(",'槽位编号_I_II_III.png'",'')
start=s.index("for n in ['04_希腊");end=s.index('def cube',start);s=s[:start]+s[end:]
start=s.index(' # Labels are shallow');end=s.index(' for color,labeln',start);s=s[:start]+s[end:]
s=s.replace('22.5+i*45','11.25+i*22.5').replace('range(8)])','range(16)])')
s=s.replace('(6.75,4.20),(.15,5.05),(-6.2,3.0)','(6.75,4.10),(.15,5.05),(-6.2,3.80)')
s=s.replace("'颜料底层',-.50,-.33","'颜料底层',-.68,-.33").replace("'颜料隆起',-.61,-.50","'颜料隆起',-.92,-.65").replace("'颜料厚涂尖峰',-.69,-.61","'颜料厚涂尖峰',-1.09,-.90")
ns={};exec(compile(s,'maple_geometry','exec'),ns)
elements=ns['elements'];groups=ns['groups'];root=ns['root'];textures=ns['textures'];pigments=ns['pigments'];cube=ns['cube'];patches=ns['patches'];octagon=ns['octagon'];X,Y=ns['X'],ns['Y'];U=ns['U']
# Remove the flat paint disks and replace with an uneven thick-paint heightfield.
paint_ids={c for n in pigments.values() for c in groups[n]['children']}
elements[:]=[e for e in elements if e['uuid'] not in paint_ids]
for n in pigments.values():groups[n]['children']=[]
for i,(x,y) in enumerate(ns['centers']):
    px,py=(X-x)/1.48,(Y-y)/1.48
    theta=ns['np'].arctan2(py,px);rad=ns['np'].sqrt(px*px+py*py)
    edge=1+.035*ns['np'].sin(theta*5)+.025*ns['np'].cos(theta*8)
    fill=rad<edge
    h=.12+.34*ns['np'].maximum(0,1-rad**2)+.21*ns['np'].exp(-((px+.28)**2+(py-.24)**2)/.13)+.14*ns['np'].exp(-((px-.49)**2+(py+.32)**2)/.10)
    h+=.055*ns['np'].sin((px+py*.3)*9)*(1-ns['np'].minimum(rad,1))
    level=ns['np'].floor(h/.085).astype(int)
    for color in ['red','yellow','blue']:
        g=pigments[i,color]
        for k in sorted(set(level[fill].tolist())):
            m=fill&(level==k)
            # Dark outer paint folds, normal mid body, brighter higher knife ridges.
            mat=color+'dark' if k<=2 else color if k<=4 else color+'mid'
            patches(m,g,'厚涂颜料_高度'+str(k),-.69-k*.085,-.36,mat)
        patches(fill&(py>.08)&(py<.32)&(px<-.20)&(px>-.62),g,'颜料刀痕高光',-1.30,-1.22,color+'light')
        patches(fill&(py<-.23)&(py>-.40)&(px>.20)&(px<.57),g,'偏侧湿颜料高光',-1.20,-1.12,color+'light')
# More readable hand-finished maple grain, still low contrast.
texpath=ns['T']/'盘面_明亮枫木纹.png';wood=Image.open(texpath).convert('RGBA');wd=ImageDraw.Draw(wood)
for j in range(220):
    x=ns['rng'].randrange(128);y=ns['rng'].randrange(128);v=ns['rng'].choice([-9,-5,4,7]);wd.rectangle((x,y,min(127,x+ns['rng'].randrange(3,15)),min(127,y+ns['rng'].randrange(1,3))),fill=(244+v,211+v,151+v,255))
wood.save(texpath);textures[1]['source']='data:image/png;base64,'+ns['base64'].b64encode(texpath.read_bytes()).decode()
# Thin brass inner edge, never an outer clasp.
ell=((X-ns['HOLE_X'])/2.10)**2+((Y-ns['HOLE_Y'])/1.92)**2
patches(ns['shape']&(ell<1.18),ns['thumb'],'薄黄铜孔内沿',-.80,-.59,'bronze')
# Default is RGB; each well also has independent hidden color alternatives.
for (i,c),n in pigments.items():groups[n]['visibility']=c==['red','yellow','blue'][i]
display=json.loads((ROOT/'sweetdream_rp_完整版/assets/palette/models/item/palette.json').read_text(encoding='utf-8'))['display']
key_number=0
def key(channel,t,v):
    global key_number
    key_number+=1
    return {'channel':channel,'time':t,'uuid':U('key_'+str(key_number)),'interpolation':'linear','data_points':[dict(zip('xyz',map(str,v)))]}
def animator(name,keys):return {'name':name,'type':'bone','keyframes':keys}
idle={'uuid':U('idle'),'name':'待机_颜料轻颤','loop':'loop','length':4,'animators':{}}
cast={'uuid':U('cast'),'name':'施法_倾盘汇色','loop':'once','length':1.6,'animators':{}}
idle['animators'][groups[root]['uuid']]=animator(root,[key('position',0,[0,0,0]),key('position',2,[0,.04,0]),key('position',4,[0,0,0])])
cast['animators'][groups[root]['uuid']]=animator(root,[key('rotation',0,[0,0,0]),key('rotation',.28,[22.5,0,0]),key('rotation',.9,[22.5,0,0]),key('rotation',1.6,[0,0,0]),key('position',0,[0,0,0]),key('position',.35,[0,.35,0]),key('position',1.6,[0,0,0])])
for n in pigments.values():
    idle['animators'][groups[n]['uuid']]=animator(n,[key('position',0,[0,0,0]),key('position',2,[0,0,-.045]),key('position',4,[0,0,0])])
    cast['animators'][groups[n]['uuid']]=animator(n,[key('position',0,[0,0,0]),key('position',.35,[0,0,-.35]),key('position',.68,[0,0,-.52]),key('position',1.25,[0,0,0]),key('scale',0,[1,1,1]),key('scale',.68,[.93,.93,1.28]),key('scale',1.25,[1,1,1])])
check(elements,groups,root,textures)
keys=[k['uuid'] for a in [idle,cast] for g in a['animators'].values() for k in g['keyframes']]
assert len(keys)==len(set(keys)), 'Animation keyframe UUIDs must be globally unique'
for e in elements:assert not(e['from'][0]<ns['HOLE_X']<e['to'][0] and e['from'][1]<ns['HOLE_Y']<e['to'][1]),e['name']
native=save_native(O,'调色盘_明亮木盘_分组动画',elements,groups,root,textures,display,[idle,cast])
master,visible=export_static(O,'palette','palette',elements,groups,root,textures,display)
r=renderer(native);render=r['render'];bg=r['BG'];font,small=r['font'],r['small'];rg={}
def cache(g):
    rg[g['uuid']]=g
    for c in g['children']:
        if isinstance(c,dict):cache(c)
for g in r['bb']['outliner']:cache(g)
def state(colors):
    for (i,c),n in pigments.items():rg[groups[n]['uuid']]['visibility']=i<len(colors) and c==colors[i]
im=Image.new('RGB',(1640,1060),bg);d=ImageDraw.Draw(im);d.text((32,22),'调色盘 · 明亮枫木 / 三个独立颜料槽',font=font,fill='#efd6a5');d.text((32,70),'实际分组模型渲染 · 保留你的整体握姿 · 尚未部署',font=small,fill='#a99d89')
state(['red','yellow','blue']);im.paste(render((1000,630),yaw=math.pi+.28,pitch=.35,scale=36,focus=(0,0,0)),(0,110));im.paste(render((610,450),yaw=math.pi,pitch=0,scale=23,focus=(0,0,0)),(1010,95));im.paste(render((610,170),yaw=math.pi+.1,pitch=1.32,scale=23,focus=(0,0,0)),(1010,564))
ImageDraw.Draw(im).text((1025,735),'薄盘、贯穿孔和高出槽面的厚颜料',font=small,fill='#d6b98a')
for j,(colors,label) in enumerate([([], '空盘'),(['red','red'],'红 + 红'),(['yellow','blue'],'黄 + 蓝')]):
    state(colors);im.paste(render((540,245),yaw=math.pi+.12,pitch=.18,scale=14.8,focus=(0,0,0)),(5+j*545,786));ImageDraw.Draw(im).text((25+j*545,774),label,font=small,fill='#e5c996')
im.save(O/'调色盘_明亮木盘_实际模型.png')
state(['red','yellow','blue']);frames=[]
for t in [i*.08 for i in range(21)]:
    f=Image.new('RGB',(700,600),bg);f.paste(render((700,515),t=t,anim=1,yaw=math.pi+.22,pitch=.35,scale=25,focus=(0,0,0)),(0,65));ImageDraw.Draw(f).text((20,15),'施法动作草案 · 倾盘与颜料汇聚',font=small,fill='#ecd0a1');frames.append(f)
frames[0].save(O/'调色盘_倾盘汇色_动作草案.gif',save_all=True,append_images=frames[1:],duration=[80]*20+[800],loop=0,disposal=2)
stats={'source_cubes':len(elements),'visible_rgb_cubes':visible,'groups':len(groups),'textures':len(textures),'animations':2,'user_display_preserved':True,'hole_clear':True,'deployed':False}
(O/'模型检查.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(stats,ensure_ascii=False),flush=True)
