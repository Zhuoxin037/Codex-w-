# -*- coding: utf-8 -*-
"""
build_vanilla_icons.py —— 「原版风」16x16 物品图标生成器（10 件）

两条保证"和原版差不多"的硬约束：
  1) 轮廓：alpha 掩码逐像素照抄原版贴图 —— 形状 100% 一致，不是临摹。
  2) 明暗：读原版每个像素的**亮度**，按区域映射到该武器自己的色阶（ramp）。
     => 原版的描边、受光面、暗面结构原样保留，只换色相/材质。

模板 = 本机 1.21.5 客户端 jar 官方贴图（.workbuddy/_vanilla_ref/）
色阶 = 从 sweetdream_rp 该武器自己的 3D 贴图里采的（见各 RAMP_* 注释）

输出：模型设计/原版风_资源包_20261010/icons/<ns>_<name>.png  (16x16)
"""
from PIL import Image, ImageDraw, ImageFont
import os

REF = r'D:\数据包\.workbuddy\_vanilla_ref'
OUT = r'D:\数据包\模型设计\原版风_资源包_20261010'
ICON = os.path.join(OUT, 'icons')
os.makedirs(ICON, exist_ok=True)
FONT = r'C:\Windows\Fonts\msyh.ttc'


def hx(s):
    s = s.lstrip('#')
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def load(name):
    im = Image.open(os.path.join(REF, name + '.png')).convert('RGBA')
    return im.load(), im.size[0], im.size[1]


def sample_ramp(ramp, t):
    t = 0.0 if t < 0 else (1.0 if t > 1 else t)
    p = t * (len(ramp) - 1)
    i = int(p)
    j = min(i + 1, len(ramp) - 1)
    f = p - i
    a, b = ramp[i], ramp[j]
    return tuple(int(round(a[k] + (b[k] - a[k]) * f)) for k in range(4))


def build(template, region_fn, ramps, overrides=None, carve=None):
    px, W, H = load(template)
    opaque = [[px[x, y][3] > 0 and not (carve and carve(x, y)) for x in range(W)] for y in range(H)]

    # 0) 轮廓边：四邻域里有透明格的像素（原版自己的描边就在这）
    edge = [[False] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            if not opaque[y][x]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if not (0 <= xx < W and 0 <= yy < H) or not opaque[yy][xx]:
                    edge[y][x] = True
                    break

    # 1) 逐区域统计原版亮度范围（区域内的明暗关系原样保留）
    rng = {}
    for y in range(H):
        for x in range(W):
            if not opaque[y][x]:
                continue
            r = region_fn(x, y, px[x, y])
            L = lum(px[x, y])
            lo, hi = rng.get(r, (999.0, -1.0))
            rng[r] = (min(lo, L), max(hi, L))

    out = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    o = out.load()
    for y in range(H):
        for x in range(W):
            if not opaque[y][x]:
                continue
            reg = region_fn(x, y, px[x, y])
            lo, hi = rng.get(reg, (0.0, 255.0))
            t = 1.0 if hi <= lo else (lum(px[x, y]) - lo) / (hi - lo)
            col = sample_ramp(ramps.get(reg, ramps['_default']), t)
            if overrides:
                for pred, color in overrides:
                    if pred(x, y, reg, t, edge[y][x]):
                        col = hx(color)
                        break
            o[x, y] = col
    return out


# ============================================================ 区域划分
def region_sword(x, y, c):
    """原版铁剑 / 钻石剑"""
    if y <= 8:
        return 'blade'
    if y <= 10:
        return 'guard'
    if y <= 13:
        return 'grip' if x <= 4 else 'guard'
    return 'pommel'


def region_sword_neth(x, y, c):
    """原版下界合金剑"""
    if y <= 10:
        return 'blade'
    if y <= 12:
        return 'guard'
    return 'grip'


def region_axe(x, y, c):
    """原版斧"""
    if y <= 7 or (y == 8 and x >= 7):
        return 'head'
    return 'haft'


def region_crossbow(x, y, c):
    """原版弩：按原版自己的**色相**分材质 —— 木=弩身、灰=铁弓/弦"""
    r, g, b, a = c
    if r > g + 10 and g > b + 4:      # 原版是棕木
        return 'wood'
    L = lum(c)
    if L >= 150:
        return 'string'
    if L >= 95:
        return 'steel'
    return 'iron'


def region_hoe(x, y, c):
    """原版锄（当镰用）：上端弯刃 + 斜杆"""
    if y <= 5:
        return 'blade'
    if y == 6:
        return 'collar'
    return 'haft'


def region_rod(x, y, c):
    """原版烈焰棒（当法杖）：顶端 4 行 = 杖头"""
    return 'head' if y <= 4 else 'shaft'


def region_book(x, y, c):
    """原版书：按明度分 书页 / 封面 / 描边"""
    L = lum(c)
    if L >= 140:
        return 'pages'
    if L >= 60:
        return 'face'
    return 'edge'


def region_glass(x, y, c):
    """原版望远镜：物镜口 / 镜筒 / 握把"""
    if y <= 3:
        return 'lens'
    if y <= 8:
        return 'barrel'
    return 'grip'


# ============================================================ 色阶
# —— 深海的回响（已认可）—— 采自 deepsea_blade / core / guard / pendant
RAMP_DEEPSEA = {
    'blade':  [hx('#08111C'), hx('#123055'), hx('#255C99'), hx('#5E9CC8'), hx('#BCE0F2'), hx('#F2FDFF')],
    'guard':  [hx('#081120'), hx('#122438'), hx('#25405A'), hx('#5A87A8'), hx('#9FC4DA')],
    'grip':   [hx('#04191A'), hx('#0B2E30'), hx('#155052'), hx('#22787A')],
    'pommel': [hx('#081322'), hx('#1B3A5C'), hx('#3F7398'), hx('#8FBBD4')],
    '_default': [hx('#0E1B2E'), hx('#2A5C93'), hx('#C8E8F7')],
}
ACC_DEEPSEA = [
    (lambda x, y, r, t, e: r == 'blade' and (x + y) == 14, '#4FCBD8'),
]

# —— 天使核心（已认可）—— 采自 upper_gold / blade_facets_v3 / haft / stigma_core
RAMP_ANGEL = {
    'head':   [hx('#3A3222'), hx('#8C8064'), hx('#DCD3BC'), hx('#F2ECDE'), hx('#FFFCF2'), hx('#FFFFFF')],
    'haft':   [hx('#0D1117'), hx('#1B2029'), hx('#2E3542'), hx('#59616F')],
    'grip':   [hx('#1B1712'), hx('#33291C'), hx('#4E3F28'), hx('#7A6240')],
    '_default': [hx('#3A3222'), hx('#DCD3BC'), hx('#FFFFFF')],
}
ACC_ANGEL = [
    (lambda x, y, r, t, e: r == 'head' and e and x >= 10, '#E8C46A'),
    (lambda x, y, r, t, e: r == 'haft' and y == 9, '#D9AE4E'),
]

# —— 寒鸦 —— 采自 coldcrow raven.png（冰青 / 冷钢 / 墨蓝）
RAMP_CROW = {
    'wood':   [hx('#0A0E14'), hx('#161C26'), hx('#28303C'), hx('#3E4854'), hx('#5E6874')],
    'steel':  [hx('#0E2A38'), hx('#1A4E62'), hx('#3596B4'), hx('#6FC4DA'), hx('#B4E2EE'), hx('#E8F8FC')],
    'iron':   [hx('#070D13'), hx('#0F1A22'), hx('#1C2A34'), hx('#31414C'), hx('#566470')],
    'string': [hx('#8FB0BC'), hx('#C6DEE6'), hx('#EAFBFF')],
    '_default': [hx('#0A0E14'), hx('#28303C'), hx('#B4E2EE')],
}
ACC_CROW = [
    (lambda x, y, r, t, e: r == 'steel' and e, '#081620'),           # 铁弓描边
    (lambda x, y, r, t, e: r == 'wood' and (x + y) == 9, '#3FB6CE'),  # 弩身符文线（冰）
    (lambda x, y, r, t, e: r == 'wood' and e and t > 0.6, '#0E141C'),
]

# —— 引梦镰 —— 采自 dream_scythe / dream_core（银紫刃 / 近黑柄）
RAMP_DREAM = {
    'blade':  [hx('#160D20'), hx('#33204C'), hx('#60489C'), hx('#9C81CC'), hx('#D2C2EE'), hx('#F4EEFF')],
    'guard':  [hx('#0C0714'), hx('#1C1030'), hx('#37205A'), hx('#5E3E90'), hx('#8E72BC')],
    'grip':   [hx('#08070D'), hx('#12101A'), hx('#221D2C'), hx('#3A3444'), hx('#666070')],
    '_default': [hx('#160D20'), hx('#60489C'), hx('#D8CBEE')],
}
ACC_DREAM = [
    (lambda x, y, r, t, e: r == 'blade' and e and t > 0.72, '#EFE6FF'),   # 刃口亮银紫
    (lambda x, y, r, t, e: r == 'blade' and (x + y) == 14, '#B79BE4'),    # 刃中血槽
    (lambda x, y, r, t, e: r == 'guard' and t > 0.85, '#C89CFF'),         # 护手宝石
]

# —— 烈火，残躯 —— 采自 flameremnant body / magma / wave（焦黑→炽橙→金）
RAMP_FLAME = {
    'blade': [hx('#201008'), hx('#451A0C'), hx('#A03A12'), hx('#F0540C'), hx('#FC9030'), hx('#FCCC6C'), hx('#FCE4C0')],
    'guard': [hx('#150A0A'), hx('#2E1A14'), hx('#5A2A16'), hx('#9C5A28'), hx('#C09060')],
    'grip':  [hx('#0A0606'), hx('#181210'), hx('#281C16'), hx('#3C2A20')],
    '_default': [hx('#201008'), hx('#F0540C'), hx('#FCE4C0')],
}
ACC_FLAME = [
    (lambda x, y, r, t, e: r == 'blade' and e and t > 0.75, '#FFD98A'),      # 刃口余火
    (lambda x, y, r, t, e: r == 'blade' and (x + y) == 13 and 4 <= y <= 7, '#240E06'),  # 残躯裂纹
    (lambda x, y, r, t, e: r == 'guard' and t > 0.85, '#FC600C'),            # 护手熔浆点
]

# —— 风行于大地之上 —— 采自 naturewind body / crystal / outer_crown（深橄榄木 + 青玉）
RAMP_WIND = {
    'head':  [hx('#0A3A48'), hx('#0078A8'), hx('#0CCCD8'), hx('#54E4E4'), hx('#B4F2F2'), hx('#EAFEFE')],
    'shaft': [hx('#1A1408'), hx('#33280F'), hx('#5A4A24'), hx('#8A7040'), hx('#B49A62')],
    '_default': [hx('#1A1408'), hx('#0CCCD8'), hx('#EAFEFE')],
}
ACC_WIND = [
    (lambda x, y, r, t, e: r == 'head' and t > 0.95, '#FFFFFF'),
    (lambda x, y, r, t, e: r == 'shaft' and y == 8, '#C08454'),   # 金箍
]

# —— 调色盘 —— 采自 palette pigment / t0（木杆 + 三色颜料头）
RAMP_PALETTE = {
    'head':  [hx('#3A2414'), hx('#604830'), hx('#8A6A44'), hx('#B49066'), hx('#D8CCA8')],
    'shaft': [hx('#241608'), hx('#3E2814'), hx('#604830'), hx('#8A6A44'), hx('#B49066')],
    '_default': [hx('#241608'), hx('#8A6A44'), hx('#D8CCA8')],
}
ACC_PALETTE = [
    (lambda x, y, r, t, e: r == 'head' and y == 1, '#F2EEDC'),   # 白
    (lambda x, y, r, t, e: r == 'head' and y == 2, '#D8483C'),   # 红
    (lambda x, y, r, t, e: r == 'head' and y == 3, '#D89C24'),   # 黄
    (lambda x, y, r, t, e: r == 'head' and y == 4, '#24549C'),   # 蓝
    (lambda x, y, r, t, e: r == 'shaft' and y == 6, '#C09C54'),  # 金箍
]

# —— 风帆 —— 采自 sail t0 / t1 / recorded（木杆 + 帆白）
RAMP_SAIL = {
    'head':  [hx('#8C8574'), hx('#B2AA96'), hx('#D0C6AE'), hx('#E4DAC4'), hx('#F2ECDA'), hx('#FFFCF2')],
    'shaft': [hx('#20170E'), hx('#382718'), hx('#543C24'), hx('#7A5A38'), hx('#A88458')],
    '_default': [hx('#20170E'), hx('#D8CCB4'), hx('#FFFCF2')],
}
ACC_SAIL = [
    (lambda x, y, r, t, e: r == 'head' and (x + y) == 15, '#A83030'),   # 帆上暗红纹
    (lambda x, y, r, t, e: r == 'head' and (x + y) == 13, '#486C7A'),   # 帆边
    (lambda x, y, r, t, e: r == 'shaft' and y == 7, '#90A8A8'),         # 束带
]

# —— 启示录 —— 采自 apocalypse t0 / t3 / t6（暗绛封面 + 暗金页缘）
RAMP_APOC = {
    'pages': [hx('#5A4A2A'), hx('#8A6C38'), hx('#B4906C'), hx('#D8A860'), hx('#FCE490'), hx('#FFF6D8')],
    'face':  [hx('#200A10'), hx('#3C0C18'), hx('#5A1420'), hx('#782424'), hx('#9C4030'), hx('#B4563C')],
    'edge':  [hx('#0A0406'), hx('#17090D'), hx('#241014')],
    '_default': [hx('#200A10'), hx('#782424'), hx('#FCE490')],
}
ACC_APOC = [
    (lambda x, y, r, t, e: r == 'face' and (x + y) == 12 and y <= 6, '#D8A860'),  # 封面金装订带
    (lambda x, y, r, t, e: r == 'pages' and t > 0.9, '#FFF6D8'),
]

# —— 极光与幻梦 —— 采自 aurora_dream t0/t1/t2 / pulse / flow（深靛底 + 银紫刃 + 极光青绿）
RAMP_AURORA = {
    'blade':  [hx('#141428'), hx('#242448'), hx('#3B2F72'), hx('#6E62A8'), hx('#A8A0D0'), hx('#DCDCE8'), hx('#F4F4FC')],
    'guard':  [hx('#101024'), hx('#242458'), hx('#4A4A94'), hx('#8A88C0'), hx('#C8C6E2')],
    'grip':   [hx('#0A0A16'), hx('#16162A'), hx('#262644'), hx('#3E3E62')],
    '_default': [hx('#141428'), hx('#4A4A94'), hx('#EAF6F8')],
}
ACC_AURORA = [
    (lambda x, y, r, t, e: r == 'blade' and e and t > 0.70, '#EAF6F8'),   # 刃口银白
    (lambda x, y, r, t, e: r == 'blade' and (x + y) == 15, '#7CD0DC'),    # 极光青绿流光
    (lambda x, y, r, t, e: r == 'guard' and t > 0.85, '#B0F0E8'),         # 护手极光点
]

# —— 观测镜 —— 采自 look.png（板岩镜身 + 黄铜环 + 青镜片）
RAMP_LOOK = {
    'lens':   [hx('#06323C'), hx('#0A5A6E'), hx('#0CCCD8'), hx('#6FE8F2'), hx('#D8FBFF')],
    'barrel': [hx('#1A1410'), hx('#3A2A18'), hx('#5A3C1E'), hx('#906C3C'), hx('#C09C60'), hx('#E0C48C')],
    'grip':   [hx('#0A0C12'), hx('#16181F'), hx('#282C36'), hx('#464C58'), hx('#767E8C')],
    '_default': [hx('#0A0C12'), hx('#906C3C'), hx('#D8FBFF')],
}
ACC_LOOK = [
    (lambda x, y, r, t, e: r == 'barrel' and (x + y) == 16, '#E8D2A0'),      # 镜筒高光
    (lambda x, y, r, t, e: r == 'grip' and y >= 13, '#C09C60'),              # 尾端铜帽
    (lambda x, y, r, t, e: r == 'lens' and t > 0.9, '#FFFFFF'),
]

# ============================================================ 清单
# (输出名, 模板, 区域函数, 色阶, 覆盖, 中文名, 原版对照模板, 掏空)
def carve_sickle(x, y):
    """锄刃下缘掏掉 2 个像素，做出镰刀的弯钩（其余像素全部照抄原版）"""
    return (x, y) in ((10, 5), (11, 5))


SPECS = [
    ('angelcore_axe',        'netherite_axe',  region_axe,      RAMP_ANGEL,   ACC_ANGEL,   '天使核心',       'netherite_axe', None),
    ('coldcrow_crossbow',    'crossbow_standby', region_crossbow, RAMP_CROW,  ACC_CROW,    '寒鸦',           'crossbow_standby', None),
    ('deepseaecho_sword',    'iron_sword',     region_sword,    RAMP_DEEPSEA, ACC_DEEPSEA, '深海的回响',     'iron_sword', None),
    ('dreamscythe_sickle',   'netherite_sword', region_sword_neth, RAMP_DREAM, ACC_DREAM, '引梦镰',        'netherite_sword', None),
    ('flameremnant_sword',   'netherite_sword', region_sword_neth, RAMP_FLAME, ACC_FLAME,  '烈火，残躯',     'netherite_sword', None),
    ('naturewind_staff',     'blaze_rod',      region_rod,      RAMP_WIND,    ACC_WIND,    '风行于大地之上', 'blaze_rod', None),
    ('palette_palette',      'blaze_rod',      region_rod,      RAMP_PALETTE, ACC_PALETTE, '调色盘',         'blaze_rod', None),
    ('sail_staff',           'blaze_rod',      region_rod,      RAMP_SAIL,    ACC_SAIL,    '风帆',           'blaze_rod', None),
    ('sweetdream_apocalypse', 'book',          region_book,     RAMP_APOC,    ACC_APOC,    '启示录',         'book', None),
    ('sweetdream_aurora',    'netherite_sword', region_sword_neth, RAMP_AURORA, ACC_AURORA, '极光与幻梦',    'netherite_sword', None),
    ('sweetdream_look',      'spyglass',       region_glass,    RAMP_LOOK,    ACC_LOOK,    '观测镜',         'spyglass', None),
]


def up(im, s):
    return im.resize((im.width * s, im.height * s), Image.NEAREST)


def txt(d, xy, s, size=20, fill=(232, 232, 238)):
    try:
        f = ImageFont.truetype(FONT, size)
    except Exception:
        f = ImageFont.load_default()
    d.text(xy, s, font=f, fill=fill)


SHORT = {
    'angelcore_axe': '斧', 'coldcrow_crossbow': '弩', 'deepseaecho_sword': '剑',
    'dreamscythe_sickle': '剑', 'flameremnant_sword': '剑', 'naturewind_staff': '杖',
    'palette_palette': '杖', 'sail_staff': '杖', 'sweetdream_apocalypse': '书',
    'sweetdream_aurora': '剑', 'sweetdream_look': '镜',
}


def main():
    icons = {}
    for out_name, tpl, rfn, ramps, acc, cn, ref, carve in SPECS:
        im = build(tpl, rfn, ramps, acc, carve)
        im.save(os.path.join(ICON, out_name + '.png'))
        icons[out_name] = im
        print('icon ->', out_name, im.size)

    # 引梦镰备选：锄形
    alt = build('netherite_hoe', region_hoe, RAMP_DREAM, [
        (lambda x, y, r, t, e: r == 'blade' and e, '#EFE6FF'),
        (lambda x, y, r, t, e: r == 'blade' and y <= 2, '#1B1030'),
        (lambda x, y, r, t, e: r == 'collar' and t > 0.85, '#E4D8FC'),
    ])

    # ---------------- 对照大图 ----------------
    S, PAD = 9, 12
    CELL = 16 * S
    n = len(SPECS)
    W = PAD + n * (CELL + PAD)
    CAP, LBL, GAP = 22, 22, 14
    STEP = CAP + CELL + LBL + GAP
    H = PAD + 34 + STEP * 3 + CAP + CELL + LBL + PAD
    sheet = Image.new('RGBA', (W, H), (22, 24, 29, 255))
    d = ImageDraw.Draw(sheet)
    txt(d, (PAD, 10), '原版风 · 16×16 平面像素图标（轮廓逐像素照抄原版，只换成每件武器自己的配色）', 22, (246, 246, 250))

    slot = Image.new('RGBA', (CELL + 14, CELL + 14), (139, 139, 139, 255))

    def row(y, cap):
        txt(d, (PAD, y), cap, 15, (156, 160, 172))
        return y + CAP

    y = PAD + 40
    y = row(y, '① 原版轮廓 —— 每件武器套的是它同类/同底物的原版武器形状')
    for i, (out_name, tpl, rfn, ramps, acc, cn, ref, carve) in enumerate(SPECS):
        x = PAD + i * (CELL + PAD)
        big = up(Image.open(os.path.join(REF, tpl + '.png')).convert('RGBA'), S)
        sheet.paste(big, (x, y), big)
        txt(d, (x, y + CELL + 3), '原版·' + SHORT[out_name], 15, (160, 164, 176))
    y += CELL + LBL + GAP

    y = row(y, '② 我们的图标 —— 形状不变，换成该武器自己贴图里采的配色')
    for i, (out_name, tpl, rfn, ramps, acc, cn, ref, carve) in enumerate(SPECS):
        x = PAD + i * (CELL + PAD)
        big = up(icons[out_name], S)
        sheet.paste(big, (x, y), big)
        txt(d, (x, y + CELL + 3), cn, 16, (250, 224, 140))
    y += CELL + LBL + GAP

    y = row(y, '③ 背包格内实际观感')
    for i, (out_name, tpl, rfn, ramps, acc, cn, ref, carve) in enumerate(SPECS):
        x = PAD + i * (CELL + PAD)
        big = up(icons[out_name], S)
        c = slot.copy()
        c.paste(big, (7, 7), big)
        sheet.paste(c, (x, y))
    y += CELL + LBL + GAP

    y = row(y, '备选 —— 引梦镰若想更贴「镰」，可换锄形轮廓（默认用剑形，与底物一致）')
    for k, (im, lab) in enumerate([(icons['dreamscythe_sickle'], 'A 剑形（默认）'), (alt, 'B 锄形（更像镰）')]):
        x = PAD + k * (CELL + 230)
        big = up(im, S)
        c = slot.copy()
        c.paste(big, (7, 7), big)
        sheet.paste(c, (x, y))
        txt(d, (x + CELL + 20, y + CELL // 2 - 12), lab, 17, (206, 210, 220))
    y += CELL + LBL

    p = os.path.join(OUT, '全览_11件.png')
    sheet.save(p)
    print('sheet ->', p, sheet.size)


if __name__ == '__main__':
    main()
