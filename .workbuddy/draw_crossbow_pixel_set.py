"""Six hand-authored vanilla-scale crossbows; preserve recorded binding scope on redraw."""
from pathlib import Path
import ast
import hashlib
import json
import zipfile
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '模型设计/原版风_弩像素试绘_20261010'
BINDING_FILE = OUT / '游戏绑定.json'
BINDING = json.loads(BINDING_FILE.read_text(encoding='utf-8')) if BINDING_FILE.exists() else {}
BOUND_IDS = set(BINDING.get('bound_ids', []))
assert 'cold_crow' not in BOUND_IDS
SOURCE = ROOT / '.workbuddy/draw_crossbow_pixel_sample.py'
constants = {}
for node in ast.parse(SOURCE.read_text(encoding='utf-8')).body:
    if isinstance(node, ast.Assign):
        for target in node.targets:
            if isinstance(target, ast.Name) and target.id in ('ROWS', 'PAL', 'SPECS'):
                constants[target.id] = ast.literal_eval(node.value)
ROWS, BASE_PALETTE, SPECS = (constants[k] for k in ('ROWS', 'PAL', 'SPECS'))
LORE = {x['id']: x for x in json.loads((OUT / '技能依据.json').read_text(encoding='utf-8'))}

# Colours and individually placed marks are selected from the actual skills.
# All limbs retain readable wood and their fixed anchors; ornaments stay inset.
DESIGNS = [
    {'id': 'sculk_echo', 'motif': '幽匿青纹 / 回声晶核',
     'palette': BASE_PALETTE, 'marks': [], 'string': '718576', 'knot': 'a6b9a2'},
    {'id': 'bone_erode', 'motif': '骨质包角 / 暗红裂纹',
     'palette': {'d':'302928', 'b':'49413a', 'w':'756451', 'B':'a18b6f',
                 'c':'56413d', 'h':'98665b', 'Q':'c68c79', 'q':'322b30',
                 'n':'cfbfa0', 'm':'95876c'},
     'marks': [(8,1,'m'),(9,1,'n'),(9,2,'n'),(2,6,'m'),(2,8,'n'),
               (2,9,'m'),(6,6,'m'),(5,7,'n'),(6,7,'h'),(7,7,'m'),
               (7,8,'c'),(9,10,'n')], 'string':'9a8b76', 'knot':'c2b394'},
    {'id': 'cold_crow', 'motif': '霜蓝弩臂 / 鸦羽木托',
     'palette': {'d':'252b38', 'b':'3a4251', 'w':'596176', 'B':'8391a6',
                 'c':'344e67', 'h':'6c96b5', 'Q':'b2c9d6', 'q':'293b50',
                 'n':'a2b1b8', 'm':'667c8a'},
     'marks': [(11,0,'Q'),(12,0,'n'),(11,1,'h'),(10,2,'Q'),(1,10,'Q'),
               (0,12,'h'),(1,13,'Q'),(7,8,'h'),(8,9,'d'),(9,10,'B'),
               (10,11,'d'),(11,12,'B'),(12,13,'d')],
     'string':'8091a1', 'knot':'c0cbd5'},
    {'id': 'lucid_dream', 'motif': '睁开的梦瞳 / 梦回刻纹',
     'palette': {'d':'303441', 'b':'4b5060', 'w':'8c8c7c', 'B':'b6b4a0',
                 'c':'525875', 'h':'6d9c9b', 'Q':'abe0ce', 'q':'424462',
                 'n':'dad6c1', 'm':'9da9a7'},
     'rows': [
         '...........nn...',
         '.......dmmhnnd..',
         '...nm.dnwQhcmd..',
         '..n..dnnwd......',
         '..m.dbncd.......',
         '...dwmnmd.......',
         '..dwMnnnMd......',
         '..dwncQcnmd.....',
         '.dhc.MnnMwmd....',
         '.dwc..dwwnd.....',
         '.nh....dwmnd....',
         '.nm.....dwmwd...',
         'nn......dwmndd..',
         '.n.........dwmwd',
         '............dmwd',
         '.............dd.',
     ],
     'extra_palette': {'M':'748391'},
     'marks': [(8,9,'m'),(9,10,'n'),(10,11,'m'),(11,12,'n'),(12,13,'m')],
     'string':'8faaa3', 'knot':'d2dece'},
    {'id': 'rainbow', 'motif': '连续五色虹纹 / 合色棱镜',
     'palette': {'d':'302c3b', 'b':'48414f', 'w':'786776', 'B':'a28d91',
                 'c':'5a526f', 'h':'a276ba', 'Q':'86c3cd', 'q':'373446',
                 'n':'c8c6ba', 'm':'8f989e'},
     'rows': [
         '..........dnnd..',
         '.......dRFSPHnd.',
         '...nm.dwwwcmd...',
         '..n..dmwwd......',
         '..m.dbwcd.......',
         '...dHwdcd.......',
         '..dPwcncd.......',
         '..SdwhQhnd......',
         '.dFd.dQQwmd.....',
         '.Rwd..dwwnwd....',
         '.nm....dwnwd....',
         'dnm.....dwmwd...',
         'nn......dwcndd..',
         '.n.........dwmbd',
         '............dnwd',
         '.............dd.',
     ],
     'extra_palette': {'R':'d29556','F':'a15c69','S':'649caf','P':'b39aca','H':'c680a5'},
     'marks': [(6,6,'P'),(6,7,'n'),(5,7,'H'),(7,7,'Q'),(6,8,'Q')],
     'string':'9795ae', 'knot':'d1cee1'},
    {'id': 'arc', 'motif': '铜箍木身 / 折线电纹',
     'palette': {'d':'352d25', 'b':'54422f', 'w':'886342', 'B':'b99b64',
                 'c':'375257', 'h':'608e98', 'Q':'a0c3bf', 'q':'293b41',
                 'n':'bda56e', 'm':'80754f'},
     'marks': [(6,5,'h'),(6,6,'Q'),(7,6,'Q'),(5,7,'c'),(6,7,'Q'),
               (7,7,'c'),(6,8,'Q'),(7,8,'h'),(9,10,'B'),(10,10,'n'),
               (11,12,'B'),(12,12,'n')], 'string':'978c72', 'knot':'c9c1a3'},
]


def color(value):
    return tuple(int(value[i:i+2], 16) for i in (0, 2, 4)) + (255,)


def body(design):
    im = Image.new('RGBA', (16,16))
    rows=design.get('rows',ROWS)
    palette={**design['palette'],**design.get('extra_palette',{})}
    assert len(rows)==16 and all(len(row)==16 for row in rows)
    for y, row in enumerate(rows):
        for x, key in enumerate(row):
            if key != '.':
                im.putpixel((x,y), color(palette[key]))
    for x,y,key in design['marks']:
        assert im.getpixel((x,y))[3], 'Decorations must remain on the existing body.'
        im.putpixel((x,y), color(palette[key]))
    return im


def state_image(design, knot, ammo):
    im = Image.new('RGBA', (16,16))
    d = ImageDraw.Draw(im)
    d.line([(12,3),knot,(3,12)], fill=color(design['string']), width=1)
    im.alpha_composite(body(design))
    d = ImageDraw.Draw(im)
    if knot != (7,8):
        d.point(knot, fill=color(design['knot']))
    if ammo == 'arrow':
        d.line([(3,3),(10,10)], fill='#867558')
        for p in ((2,2),(3,2),(2,3)):
            d.point(p, fill='#dddcca')
        for p in ((3,3),(9,10),(10,9)):
            d.point(p, fill='#a7ada0')
    elif ammo == 'firework':
        d.line([(3,3),(10,10)], fill='#867558')
        for p in ((1,1),(2,1),(1,2),(3,2),(2,3),(4,3),(3,4)):
            d.point(p, fill='#a94435')
        for p in ((2,2),(3,3),(4,4)):
            d.point(p, fill='#e6dcc0')
    return im


images, report = {}, []
approved = json.loads((OUT / '试绘说明.json').read_text(encoding='utf-8'))
approved_hashes = {x['state']:x['sha256'] for x in approved['states']}
for design in DESIGNS:
    cid = design['id']; name = LORE[cid]['name']
    folder = OUT / '贴图' / name
    folder.mkdir(parents=True,exist_ok=True)
    frames, states = {}, []
    for state, label, knot, ammo in SPECS:
        im = state_image(design,knot,ammo)
        path = folder / (state+'.png')
        if cid == 'sculk_echo':
            # The approved sample is a fixed baseline, including its draw states.
            assert path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest() == approved_hashes[state]
            assert Image.open(path).convert('RGBA').tobytes() == im.tobytes()
        else:
            im.save(path)
        assert im.size == (16,16)
        assert {im.getpixel((x,y))[3] for y in range(16) for x in range(16)} == {0,255}
        frames[state] = im
        states.append({'state':state,'label':label,'file':str(path),
                       'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
    assert len({im.tobytes() for im in frames.values()}) == 6
    images[cid] = frames
    report.append({'id':cid,'name':name,'motif':design['motif'],'resolution':[16,16],
                   'skill_lore':LORE[cid]['lore'],'existing_model':LORE[cid]['existing_model'],
                   'game_bound':cid in BOUND_IDS,'excluded_from_binding':cid=='cold_crow','states':states})
assert len({frames['standby'].tobytes() for frames in images.values()}) == 6

FONT = 'C:/Windows/Fonts/msyh.ttc'
TITLE = ImageFont.truetype(FONT,30)
NAME = ImageFont.truetype(FONT,24)
TEXT = ImageFont.truetype(FONT,18)
SMALL = ImageFont.truetype(FONT,15)


def icon(dest,im,xy,size):
    q=im.resize((size,size),Image.Resampling.NEAREST)
    dest.paste(q,xy,q)


def slot(dest,im,xy,size=60):
    x,y=xy; d=ImageDraw.Draw(dest)
    d.rectangle((x,y,x+size-1,y+size-1),fill='#8b8b8b')
    d.line([(x+size-1,y),(x,y),(x,y+size-1)],fill='#373737',width=2)
    d.line([(x,y+size-1),(x+size-1,y+size-1),(x+size-1,y)],fill='#eeeeee',width=2)
    icon(dest,im,(x+4,y+4),size-8)


board=Image.new('RGB',(1208,816),'#22252a'); d=ImageDraw.Draw(board)
d.text((24,18),'弩 · 原版风像素贴图 / 六件',font=TITLE,fill='#e4e0d5')
d.text((24,65),'16 × 16 手工像素 · 沿用认可的弩形 · 按技能区分材料与纹饰',font=TEXT,fill='#b0babc')
for i,design in enumerate(DESIGNS):
    x=20+(i%3)*396; y=110+(i//3)*338
    cid=design['id']; im=images[cid]['standby']
    d.rectangle((x,y,x+375,y+317),fill='#2d3238')
    d.text((x+18,y+15),LORE[cid]['name'],font=NAME,fill='#ddded5')
    icon(board,im,(x+18,y+68),192)
    slot(board,im,(x+266,y+122))
    d.text((x+267,y+191),'物品栏',font=SMALL,fill='#a3afac')
    d.text((x+18,y+276),design['motif'],font=TEXT,fill='#bcc6bf')
d.text((24,788),'五把像素弩已绑定完整版；寒鸦保留原有模型。' if BOUND_IDS else '全套贴图已画齐；尚未替换资源包或游戏外观。',font=SMALL,fill='#929ea3')
board.save(OUT/'弩_6件_像素总览.png')

sheet=Image.new('RGB',(1190,1152),'#22252a'); d=ImageDraw.Draw(sheet)
d.text((24,18),'六把弩 · 待机 / 拉弦 / 装填状态',font=TITLE,fill='#e4e0d5')
for j,(_,label,_,_) in enumerate(SPECS):
    d.text((177+j*165,77),label,font=TEXT,fill='#becbc3')
for i,design in enumerate(DESIGNS):
    y=118+i*165; cid=design['id']
    d.text((20,y+56),LORE[cid]['name'],font=TEXT,fill='#d0d7cb')
    for j,(state,_,_,_) in enumerate(SPECS):
        x=166+j*165
        d.rectangle((x,y,x+145,y+145),fill='#2d3238')
        icon(sheet,images[cid][state],(x+9,y+9),128)
d.text((24,1121),'弩身固定，弦逐步向后拉；箭矢与烟花有独立装填贴图。',font=SMALL,fill='#929ea3')
sheet.save(OUT/'弩_36张_状态总览.png')

sequence=[('standby',500),('pulling_0',230),('pulling_1',230),
          ('pulling_2',230),('arrow',800),('standby',400)]
gif_frames=[]
for state,_ in sequence:
    frame=Image.new('RGB',(972,630),'#22252a'); d=ImageDraw.Draw(frame)
    label=next(x[1] for x in SPECS if x[0]==state)
    d.text((22,16),'六把弩 · '+label,font=NAME,fill='#dfe3d8')
    for i,design in enumerate(DESIGNS):
        x=16+(i%3)*320; y=67+(i//3)*264; cid=design['id']
        d.rectangle((x,y,x+303,y+247),fill='#2d3238')
        d.text((x+16,y+12),LORE[cid]['name'],font=TEXT,fill='#d0d8ce')
        icon(frame,images[cid][state],(x+68,y+57),176)
    d.text((22,608),'状态切换示意；实际装填速度由原版弩及附魔控制。',font=SMALL,fill='#99a8a2')
    gif_frames.append(frame)
gif_frames[0].save(OUT/'弩_6件_拉弦示意.gif',save_all=True,append_images=gif_frames[1:],
                   duration=[t for _,t in sequence],loop=0,disposal=2)

manifest={'phase':'五把像素弩已绑定完整版，寒鸦保留' if BOUND_IDS else '六件全套贴图完成，尚未绑定','hand_authored':True,
          'image_generation_used':False,'game_bound':bool(BOUND_IDS),'item_count':6,'texture_count':36,
          'approved_sample_unchanged':True,'excluded_ids':['cold_crow'],'items':report}
(OUT/'贴图清单.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'接入范围.json').write_text(json.dumps({
    'candidate_ids':['sculk_echo','bone_erode','lucid_dream','rainbow','arc'],
    'excluded_ids':['cold_crow'],'excluded_note':'用户要求寒鸦保留现有游戏模型，不接入这套像素弩',
    'redraw_review_ids':['lucid_dream','rainbow'],'game_bound':bool(BOUND_IDS),
},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'说明.md').write_text('''# 六把原版风弩像素贴图

沿用用户认可的幽匿残响16×16试绘，已完成6把弩、36张透明PNG。
幽匿残响的6张原稿逐字节保留。其余按当前技能设置材料、配色和少量镶纹：
蚀骨（骨质与暗红裂纹）、寒鸦（霜蓝与羽纹）、清醒梦（睁开的梦瞳与梦回刻纹）、虹彩（连续五色虹纹与合色棱镜）、电弧（铜箍与折线电纹）。

用户明确：寒鸦不接入，本套寒鸦PNG仅保留审阅记录，游戏继续使用原有模型。
清醒梦和虹彩已按最新反馈重画，等待审阅。五道梦回刻纹与五色虹纹是静态纹饰，不是新增技能或状态条。

每把6状态：standby、pulling_0、pulling_1、pulling_2、arrow、firework。
弩身与弩臂固定，弦向后拉，装填状态保持张弦；箭矢和烟花分别画出。
GIF仅为状态切换示意，没有修改装填速度、技能、消耗或层数。

贴图/ 为原始PNG；弩_6件_像素总览.png为外观预览；弩_36张_状态总览.png列出全套状态。
技能依据.json保存当前技能描述，贴图清单.json记录每张图的SHA256。
所有纹饰为手工布置像素，无AI生图、模糊、外部光晕或Blockbench立方体。

本次只完成贴图审阅，没有修改资源包、数据包或游戏副本，寒鸦现有模型也未替换。
''',encoding='utf-8')
if BOUND_IDS:
    (OUT/'说明.md').write_text('''# 原版风像素弩 · 已接入

幽匿残响、蚀骨、电弧，以及获批准重画版清醒梦和虹彩，已绑定 sweetdream_rp_完整版 与对应数据包武器。
寒鸦 PNG 仅为审阅记录；游戏保留寒鸦原有三维模型。

每把六状态：standby、pulling_0、pulling_1、pulling_2、arrow、firework。
沿用 Minecraft 1.21.5 原版弩的拉弦、箭矢/烟花判定及握姿；没有修改射速或技能。
旧弩拿在主手或副手约一秒后更新外观；只设置 item_model，不重置附魔、升级或已装填弹药。

贴图/ 保存原始16×16透明PNG。贴图清单.json保存各状态校验值；游戏绑定.json记录接入范围。
使用教程：游戏内按 F3+T 重载完整版资源包，再输入 /reload 重载数据包。
''',encoding='utf-8')
archive=OUT/'弩_6件_36张_16x16贴图.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for item in report:
        for state in item['states']:
            p=Path(state['file']); z.write(p,p.relative_to(OUT).as_posix())
    for name in ['贴图清单.json','技能依据.json','说明.md','弩_6件_像素总览.png','弩_36张_状态总览.png']:
        z.write(OUT/name,name)
print(json.dumps({'items':len(report),'textures':36,'approved_sample_unchanged':True,
                  'game_bound':bool(BOUND_IDS),'preview':str(OUT/'弩_6件_像素总览.png'),
                  'archive':str(archive)},ensure_ascii=False))

# A focused preview of the two redrawn designs, with their actual skill basis.
PAIR=['lucid_dream','rainbow']
NOTES={
    'lucid_dream':['梦瞳表现“清醒”，回环刻纹表现“梦回”。',
                   '薄荷青、象牙白与梦紫，区别于寒鸦的冰蓝。',
                   '白昼梦 / 时停 → 积累梦回 → 消耗并展开术阵。'],
    'rainbow':['五段颜色连成虹纹，汇入中央合色棱镜。',
               '配色呼应流火、夜火、渊海、白昼梦、噬心。',
               '对应“漫彩”消耗多种属性；纹饰为静态设计。'],
}
pair=Image.new('RGB',(1148,774),'#22252a'); d=ImageDraw.Draw(pair)
d.text((24,18),'清醒梦 / 虹彩 · 第二版手绘像素弩',font=TITLE,fill='#e4e0d5')
d.text((24,65),'16 × 16 · 重画结构与纹饰 · 保留原版弩的拉弦逻辑',font=TEXT,fill='#b0babc')
for i,cid in enumerate(PAIR):
    x=20+i*568; y=110
    d.rectangle((x,y,x+547,y+615),fill='#2d3238')
    d.text((x+18,y+15),LORE[cid]['name'],font=NAME,fill='#dde3d9')
    icon(pair,images[cid]['standby'],(x+31,y+65),256)
    slot(pair,images[cid]['standby'],(x+406,y+157),64)
    d.text((x+407,y+232),'物品栏',font=SMALL,fill='#a3afac')
    for j,line in enumerate(NOTES[cid]):
        d.text((x+18,y+344+j*29),line,font=TEXT,fill='#b9c8c2')
    for j,(state,label,_,_) in enumerate(SPECS):
        xx=x+12+j*88; yy=y+455
        d.rectangle((xx,yy,xx+82,yy+99),fill='#343a40')
        icon(pair,images[cid][state],(xx+9,yy+8),64)
        name={'arrow':'箭矢','firework':'烟花'}.get(state,label)
        width=d.textbbox((0,0),name,font=SMALL)[2]
        d.text((xx+(83-width)//2,yy+78),name,font=SMALL,fill='#bcc8c0')
d.text((24,745),'重画版清醒梦、虹彩已接入完整版；寒鸦保留现有模型。' if BOUND_IDS else '寒鸦保留现有模型。这两把尚未接入游戏，先确认新外观。',font=SMALL,fill='#99a5a2')
pair.save(OUT/'清醒梦_虹彩_重画预览.png')
pair_gif=[]
for state,_ in sequence:
    frame=Image.new('RGB',(728,410),'#22252a'); d=ImageDraw.Draw(frame)
    label=next(x[1] for x in SPECS if x[0]==state)
    d.text((20,14),'重画版 · '+label,font=NAME,fill='#dde3d9')
    for i,cid in enumerate(PAIR):
        x=16+i*360
        d.rectangle((x,61,x+342,366),fill='#2d3238')
        d.text((x+17,76),LORE[cid]['name'],font=TEXT,fill='#c2cec8')
        icon(frame,images[cid][state],(x+59,117),224)
    d.text((20,382),'状态切换示意；装填速度与技能未修改。',font=SMALL,fill='#99a5a2')
    pair_gif.append(frame)
pair_gif[0].save(OUT/'清醒梦_虹彩_重画拉弦.gif',save_all=True,append_images=pair_gif[1:],
                 duration=[t for _,t in sequence],loop=0,disposal=2)
with zipfile.ZipFile(OUT/'清醒梦_虹彩_重画_12张贴图.zip','w',zipfile.ZIP_DEFLATED) as z:
    for item in report:
        if item['id'] in PAIR:
            for state in item['states']:
                p=Path(state['file']); z.write(p,p.relative_to(OUT).as_posix())
    for name in ['清醒梦_虹彩_重画预览.png','清醒梦_虹彩_重画拉弦.gif','接入范围.json','说明.md']:
        z.write(OUT/name,name)
