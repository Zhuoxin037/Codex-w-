"""Hand-drawn crossbow sample and state previews. Review only; no pack edits."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '模型设计/原版风_弩像素试绘_20261010'
TEX = OUT / '贴图/幽匿残响'
TEX.mkdir(parents=True, exist_ok=True)

# A fixed wooden stock and two curved limbs. Bowstrings are drawn separately,
# so the stock never changes shape during drawing or when holding ammunition.
ROWS = [
    '...........nn...',
    '........ddnqnd..',
    '...nn..dchccbd..',
    '..n..ddwwwd.....',
    '..m.dbwdd.......',
    '...dbwdcd.......',
    '..dwwcQcd.......',
    '..bdwQhQcd......',
    '.dcc.ddQwcd.....',
    '.dwd..dddwcd....',
    '.nh....dwBwcd...',
    '.nm.....dwwwd...',
    'nn......dwdBdd..',
    '.n.........dwwbd',
    '............ddwd',
    '.............dd.',
]
PAL = {
    'd': '262622', 'b': '393b30', 'w': '665b42', 'B': '94846b',
    'c': '25504e', 'h': '418780', 'Q': '76b8ad', 'q': '172f31',
    'n': 'b8b3a0', 'm': '7c806f',
}
assert len(ROWS) == 16 and all(len(row) == 16 for row in ROWS)


def rgb(key):
    color = PAL[key]
    return tuple(int(color[i:i+2], 16) for i in (0, 2, 4)) + (255,)


BODY = Image.new('RGBA', (16, 16))
for y, row in enumerate(ROWS):
    for x, key in enumerate(row):
        if key != '.':
            BODY.putpixel((x, y), rgb(key))


def draw_state(knot, ammo=None):
    im = Image.new('RGBA', (16, 16))
    pen = ImageDraw.Draw(im)
    pen.line([(12, 3), knot, (3, 12)], fill='#718576', width=1)
    im.alpha_composite(BODY)
    pen = ImageDraw.Draw(im)
    if knot != (7, 8):
        pen.point(knot, fill='#a6b9a2')
    if ammo == 'arrow':
        pen.line([(3, 3), (10, 10)], fill='#867558')
        for p in ((2, 2), (3, 2), (2, 3)):
            pen.point(p, fill='#dddcca')
        for p in ((3, 3), (9, 10), (10, 9)):
            pen.point(p, fill='#a7ada0')
    elif ammo == 'firework':
        pen.line([(3, 3), (10, 10)], fill='#867558')
        for p in ((1, 1), (2, 1), (1, 2), (3, 2), (2, 3), (4, 3), (3, 4)):
            pen.point(p, fill='#a94435')
        for p in ((2, 2), (3, 3), (4, 4)):
            pen.point(p, fill='#e6dcc0')
    return im


SPECS = [
    ('standby', '待机', (7, 8), None),
    ('pulling_0', '拉弦 I', (8, 9), None),
    ('pulling_1', '拉弦 II', (10, 11), None),
    ('pulling_2', '拉弦 III', (12, 12), None),
    ('arrow', '已装填箭矢', (12, 12), 'arrow'),
    ('firework', '已装填烟花', (12, 12), 'firework'),
]
IMAGES = {}
report = []
for state, label, knot, ammo in SPECS:
    im = draw_state(knot, ammo)
    im.save(TEX / (state + '.png'))
    pixels = [im.getpixel((x, y)) for y in range(16) for x in range(16)]
    assert {p[3] for p in pixels} == {0, 255}
    IMAGES[state] = im
    report.append({'state': state, 'label': label, 'size': [16, 16],
                   'file': str(TEX / (state + '.png')),
                   'opaque_pixels': sum(p[3] != 0 for p in pixels),
                   'sha256': hashlib.sha256((TEX / (state + '.png')).read_bytes()).hexdigest()})

FONT = 'C:/Windows/Fonts/msyh.ttc'
TITLE = ImageFont.truetype(FONT, 29)
TEXT = ImageFont.truetype(FONT, 19)
SMALL = ImageFont.truetype(FONT, 16)
board = Image.new('RGB', (1100, 730), '#22252a')
pen = ImageDraw.Draw(board)
pen.text((28, 22), '幽匿残响 · 原版风弩 / 像素试绘', font=TITLE, fill='#e4e0d5')
pen.text((28, 68), '16 × 16 手工像素 · 深木色 / 幽匿青纹 / 克制的骨白包角', font=TEXT, fill='#adb7bb')


def paste_icon(dest, im, xy, side):
    icon = im.resize((side, side), Image.Resampling.NEAREST)
    dest.paste(icon, xy, icon)


def slot(dest, xy, im, side=64):
    x, y = xy
    d = ImageDraw.Draw(dest)
    d.rectangle((x, y, x+side-1, y+side-1), fill='#8b8b8b')
    d.line([(x+side-1, y), (x, y), (x, y+side-1)], fill='#373737', width=2)
    d.line([(x, y+side-1), (x+side-1, y+side-1), (x+side-1, y)], fill='#eeeeee', width=2)
    paste_icon(dest, im, (x+4, y+4), side-8)


ref = Image.open(OUT / '原版参考/crossbow_standby.png').convert('RGBA')
for x, icon, label in [(32, ref, '原版弩'), (342, IMAGES['standby'], '幽匿残响')]:
    pen.rectangle((x, 119, x+280, 399), fill='#30343a')
    paste_icon(board, icon, (x+12, 131), 256)
    pen.text((x+98, 417), label, font=TEXT, fill='#d5d7d0')

pen.text((684, 126), '呼应技能「悲鸣」', font=TEXT, fill='#c4d7ce')
for n, line in enumerate([
    '弩臂内嵌幽匿青纹，中央留回声晶核。',
    '木身与拉弦机构保持原版的朴素感。',
    '骨白只用在包角，避免大片亮色。',
]):
    pen.text((684, 171+n*32), line, font=SMALL, fill='#b2bdbb')
pen.text((684, 299), '物品栏尺寸对照', font=SMALL, fill='#b2bdbb')
slot(board, (687, 332), ref)
slot(board, (775, 332), IMAGES['standby'])
paste_icon(board, IMAGES['standby'], (890, 347), 32)
pen.text((875, 389), '32px', font=SMALL, fill='#929ea3')

pen.text((28, 481), '弩弦逐步向后拉 · 装填后保持张弦 · 发射后回到待机', font=TEXT, fill='#d0d5cd')
for i, (state, label, _, _) in enumerate(SPECS):
    x = 28+i*177
    pen.rectangle((x, 528, x+162, 670), fill='#2d3238')
    paste_icon(board, IMAGES[state], (x+27, 540), 112)
    length = pen.textbbox((0, 0), label, font=SMALL)[2]
    pen.text((x+(163-length)//2, 674), label, font=SMALL, fill='#bfc8c4')
pen.text((28, 708), '贴图与状态示意；尚未替换资源包、寒鸦现有模型或数据包技能。', font=SMALL, fill='#8f9a9f')
board.save(OUT / '幽匿残响_弩像素试绘.png')

frames = []
sequence = [('standby', 500), ('pulling_0', 230), ('pulling_1', 230),
            ('pulling_2', 230), ('arrow', 800), ('standby', 400)]
for state, duration in sequence:
    canvas = Image.new('RGB', (400, 380), '#22252a')
    d = ImageDraw.Draw(canvas)
    d.text((20, 16), '幽匿残响 · 拉弦状态示意', font=TEXT, fill='#d9ded6')
    paste_icon(canvas, IMAGES[state], (80, 65), 240)
    label = next(x[1] for x in SPECS if x[0] == state)
    d.text((20, 324), label, font=TEXT, fill='#acbdb5')
    d.text((20, 354), '节奏示意；实际拉弦由原版弩控制', font=SMALL, fill='#8f9a9f')
    frames.append(canvas)
frames[0].save(OUT / '幽匿残响_拉弦示意.gif', save_all=True, append_images=frames[1:],
               duration=[x[1] for x in sequence], loop=0, disposal=2)

(OUT / '试绘说明.json').write_text(json.dumps({
    'item': 'sculk_echo', 'name': '幽匿残响', 'hand_authored': True,
    'image_generation_used': False, 'game_bound': False, 'review_stage': True,
    'states': report, 'state_timing': '预览节奏；游戏使用原版拉弦与charge_type判定',
}, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
print(OUT / '幽匿残响_弩像素试绘.png')
