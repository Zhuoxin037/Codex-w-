"""Twelve manually authored vanilla-scale staff sprites, based on current lore.

Only review PNGs and their source/manifest are produced. Existing game packs
and datapack commands are deliberately outside this drawing stage.
"""
from pathlib import Path
import hashlib, json
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'模型设计/原版风_法杖像素试绘_20261010'
ICONS=OUT/'贴图';ICONS.mkdir(parents=True,exist_ok=True)
LORE={x['id']:x for x in json.loads((OUT/'技能依据.json').read_text(encoding='utf-8'))}
BINDING_PATH=OUT/'游戏绑定.json'
BINDING=json.loads(BINDING_PATH.read_text(encoding='utf-8')) if BINDING_PATH.exists() else None

WOOD={'d':'33251b','b':'68462c','W':'9d7145'}
METAL={'g':'51412a','G':'ae8b50','B':'d4ba79'}
BASE={**WOOD,**METAL,'o':'193b43','s':'286c7c','m':'38aab2','h':'a3e9de'}

# Each head is an 8x7 pixel grid placed at x=8. The common diagonal handle
# retains the sample's silhouette; wrappings and wood tones vary by weapon.
# No stochastic noise, anti-aliasing, procedural glow, or image generation.
DESIGNS=[
 dict(id='chime',motif='共鸣水晶 · 法术穿透',
      head=['....o...','...oho..','..ohmso.','.gohmso.','.Gomhos.','.gGooGg.','dgBGgd..']),
 dict(id='polarized_light',motif='透光棱晶 · 持续光线',
      head=['....oo..','...oHho.','..oHmho.','..oHhso.','.gohsoG.','.gGoGg..','dgBGgd..'],
      colors={'o':'454951','s':'737e96','m':'a4c3d4','h':'d6e8e3','H':'fbf2d9'},
      bands={9:('g','G')}),
 dict(id='delusion',motif='紫晶沙漏 · 时停',
      head=['..ggGG..','..gHhG..','...gHG..','....h...','...GmG..','..gmsg..','.gGggd..'],
      colors={'d':'2c2330','b':'59445d','W':'866c84','s':'604378','m':'a581c1','h':'d8b7e4','H':'eee2ef'}),
 dict(id='fallen_dream',motif='残月 · 白昼梦与侵蚀',
      head=['....ooo.','..oomo..','.omso...','.om..h..','.ohm.o..','..osoo..','.gGsgd..'],
      colors={'d':'242130','b':'41374e','W':'74647f','g':'3c3146','G':'857893','B':'c3b4d4',
              'o':'35263f','s':'614675','m':'a682bb','h':'e1c5e7'},
      bands={11:('s','m')}),
 dict(id='begonia',motif='卷水涡 · 渊海吸引',
      head=['...oooo.','..oHHmso','.oHm.oSo','.oH.oHso','.osmHmo.','..goso..','dgBGgd..'],
      colors={'o':'1a3049','s':'2b6385','S':'27485d','m':'4a9cb6','H':'b7dfdc',
              'd':'282931','b':'4b555b','W':'819388'},
      bands={10:('g','G')}),
 dict(id='gu_poison',motif='毒囊与倒钩 · 噬心侵蚀',
      head=['...g..g.','..gGooGg','..gohmso','..GmomsG','..gosmo.','...gGg..','.dgBgd..'],
      colors={'g':'34352a','G':'6e7346','B':'aeb780','o':'243626','s':'415f39','m':'80a94a','h':'c8d979'},
      bands={8:('s','m'),12:('s','m')}),
 dict(id='twilight',motif='裂开的护符 · 护甲削弱',
      head=['..go.og.','.gGo.oGg','.Gms.mhG','.gs..hg.','..o.hs..','..gGsg..','.dgBGd..'],
      colors={'d':'302431','b':'584356','W':'8a6c80','g':'483140','G':'9f7761','B':'d2a46e',
              'o':'302331','s':'58405d','m':'967493','h':'d9b083'},
      bands={10:('g','G')}),
 dict(id='final_revelation',motif='圣光日轮 · 大范围光柱',
      head=['....g...','..gGhG..','..GHHHg.','.gHHhHGg','..GHhG..','...GGg..','.gBGgd..'],
      colors={'g':'765038','G':'c99c53','B':'e3c78a','h':'efdaa4','H':'fff2d2',
              'd':'3a2e26','b':'776656','W':'b7a58a'},
      bands={8:('g','G'),12:('g','G')}),
 dict(id='wind_ontheground',motif='枝冠与风晶 · 风声术阵',
      head=['...L....','..lML.o.','.lgohmo.','.Gohmso.','.gomsoL.','..gGoG..','dgBGgd..'],
      colors={'o':'233d35','s':'3d7063','m':'70b296','h':'c6e1b7',
              'l':'35452a','L':'719747','M':'b4cb78'},
      bands={11:('g','G')}),
 dict(id='sail',motif='扬帆与卷风 · 属性记录',
      head=['....g...','...gHh..','..gHHhs.','.gHHhss.','.gHhso..','.Ggoso..','dgBGgd..'],
      colors={'o':'304f52','s':'71978f','h':'c5d3b4','H':'f2ebd0','m':'9ebdb2'},
      bands={9:('g','G')}),
 dict(id='apocalypse',motif='展开书页 · 启示与灾示',
      head=['..gg.gg.','.gHhghHg','.gHhgHHg','.gphgppg','..GhhGG.','..ggGg..','.dgBGd..'],
      colors={'d':'302c39','b':'514a63','W':'81768e','g':'4d392e','G':'9b704b','B':'d2b275',
              'h':'d8c7a6','H':'f3e6c7','p':'a99d8b'},
      bands={10:('g','G')}),
 dict(id='palette',motif='三色颜料 · 色彩追踪',
      head=['...ggg..','.ggWWGg.','gWrWWyGg','gWWdWWcG','.gWWWBgg','..gGGg..','.dgBgd..'],
      colors={'g':'65442c','G':'aa8050','B':'e1c88a','r':'b94439','y':'dec05b','c':'466cb3',
              'W':'d9bb86','d':'453025','b':'987344'},
      bands={11:('g','G')}),
]

def draw_icon(design):
    p={**BASE,**design.get('colors',{})}
    im=Image.new('RGBA',(16,16))
    def pixel(x,y,key):
        if key=='.':return
        v=p[key];im.putpixel((x,y),tuple(int(v[i:i+2],16) for i in (0,2,4))+(255,))
    for y in range(7,15):
        for j,key in enumerate('dWbd'):pixel(15-y+j,y,key)
    for x in (2,3):pixel(x,15,'d')
    assert len(design['head'])==7 and all(len(s)==8 for s in design['head']),design['id']
    for y,row in enumerate(design['head']):
        for x,key in enumerate(row):pixel(x+8,y,key)
    for y,(dark,light) in design.get('bands',{}).items():
        x=15-y;pixel(x+1,y,light);pixel(x+2,y,dark)
    return im

report=[];images={}
for design in DESIGNS:
    key=design['id'];lore=LORE[key];im=draw_icon(design);images[key]=im
    name=lore['name'];path=ICONS/(name+'_16x16.png');im.save(path)
    pixels=sum(c[3]>0 for c in im.getdata())
    colors=len({c for c in im.getdata() if c[3]>0})
    assert im.size==(16,16) and all(c[3] in (0,255) for c in im.getdata())
    assert colors<=16 and pixels<=100,(key,colors,pixels)
    report.append({'id':key,'name':name,'file':str(path),'resolution':[16,16],
                   'opaque_pixels':pixels,'colors':colors,'motif':design['motif'],
                   'skill_lore':lore['lore'],'existing_model':lore['existing_model'],
                   'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})

approved=Image.open(OUT/'共鸣_法杖_16x16.png').convert('RGBA')
assert images['chime'].tobytes()==approved.tobytes(),'The approved chime sample must stay identical.'
assert set(images)==set(LORE),'All twelve staff-category weapons must be covered.'

font_path='C:/Windows/Fonts/msyh.ttc'
TITLE=ImageFont.truetype(font_path,29)
NAME=ImageFont.truetype(font_path,19)
BODY=ImageFont.truetype(font_path,15)
SMALL=ImageFont.truetype(font_path,12)

def slot(draw,board,x,y,im):
    draw.rectangle((x,y,x+59,y+59),fill='#8b8b8b')
    draw.line((x,y,x+59,y),fill='#373737',width=2)
    draw.line((x,y,x,y+59),fill='#373737',width=2)
    draw.line((x,y+59,x+59,y+59),fill='#ffffff',width=2)
    draw.line((x+59,y,x+59,y+59),fill='#ffffff',width=2)
    q=im.resize((48,48),Image.Resampling.NEAREST);board.paste(q,(x+6,y+6),q)

def sheet(rows,cols,selection,path,title):
    w=cols*300+24;h=rows*315+144
    board=Image.new('RGB',(w,h),'#22252a');draw=ImageDraw.Draw(board)
    draw.text((24,18),title,font=TITLE,fill='#e4e0d5')
    draw.text((24,64),'16 × 16 手绘像素 · 按当前技能设计杖头 · 大图与物品栏尺寸对照',font=BODY,fill='#afb7bc')
    for i,design in enumerate(selection):
        x=12+(i%cols)*300;y=106+(i//cols)*315
        draw.rectangle((x,y,x+288,y+303),fill='#2d3238')
        draw.text((x+16,y+12),LORE[design['id']]['name'],font=NAME,fill='#dddcd5')
        im=images[design['id']];q=im.resize((176,176),Image.Resampling.NEAREST)
        board.paste(q,(x+18,y+61),q)
        slot(draw,board,x+211,y+112,im)
        draw.text((x+211,y+181),'物品栏',font=SMALL,fill='#939ea5')
        draw.text((x+15,y+258),design['motif'],font=BODY,fill='#bcc6c9')
    note='贴图原始预览；最终游戏绑定范围见「游戏绑定.json」。' if BINDING else '当前为贴图审阅；已画齐，尚未替换资源包或游戏中的外观。'
    draw.text((24,h-28),note,font=SMALL,fill='#929ea3')
    board.save(path)

sheet(3,4,DESIGNS,OUT/'法杖_12件_像素总览.png','法杖 · 原版风像素贴图 / 十二件')
ordinary=[d for d in DESIGNS if LORE[d['id']]['existing_model'] is None]
sheet(2,4,ordinary,OUT/'普通法杖_8件_像素总览.png','八把普通法杖 · 按技能绘制')
if BINDING:
    bound={x['id']:x['item_model'] for x in BINDING['items']}
    for item in report:
        item['game_bound']=item['id'] in bound
        if item['game_bound']:
            item['item_model']=bound[item['id']]
status={'phase':'%d张法杖贴图已绑定完整版'%len(bound) if BINDING else '全套贴图绘制完成',
 'hand_authored':True,'image_generation_used':False,'game_bound':bool(BINDING),
 'approved_sample_unchanged':True,'items':report}
if BINDING:
    status.update(bound_count=len(bound),excluded_ids=BINDING['excluded_ids'])
(OUT/'贴图清单.json').write_text(json.dumps(status,
 ensure_ascii=False,indent=2),encoding='utf-8')
description='''# 原版风法杖像素贴图

根据用户认可的「共鸣」16×16 试绘风格，已画齐法杖分类的 12 件。
「共鸣」像素与认可版本完全一致。其余按当前技能 lore 设计杖头和配色。

`贴图/` 是透明背景原始 PNG；`法杖_12件_像素总览.png` 是全套放大与物品栏预览。
`普通法杖_8件_像素总览.png` 只列原先仍使用指南针外观的 8 件。
风行、启示录、风帆、调色盘也提供了同风格贴图，但其原有游戏模型尚未替换。
`技能依据.json` 保存读取的当前技能描述；`贴图清单.json` 保存逐张校验与对应关系。

所有贴图为手工布置像素：16×16、纯透明/不透明、最近邻预览，无光晕或模糊。
本阶段只绘图，没有建造 Blockbench 几何，也没有修改数据包技能、资源包入口或存档。
颜色为静态审阅表现，尚未实现调色盘颜料状态、风帆记录或启示录页数的动态显示。
'''
if not BINDING:
    (OUT/'说明.md').write_text(description,encoding='utf-8')
print(json.dumps({'items':len(report),'ordinary_staffs':len(ordinary),
                 'approved_sample_identical':True,'max_colors':max(x['colors'] for x in report),
                 'max_opaque_pixels':max(x['opaque_pixels'] for x in report),
                 'preview':str(OUT/'法杖_12件_像素总览.png')},ensure_ascii=False))
