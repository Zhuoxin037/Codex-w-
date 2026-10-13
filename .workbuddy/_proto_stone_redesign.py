# -*- coding: utf-8 -*-
"""超限石重设计 · 原型/提案脚本 v2（只出图，不改任何产物）

问题：现有 24 颗超限石 = **同一种八芒星 + 纯靠颜色区分**，颜色已重叠（4 橙 / 7 青蓝）。
方向：**「晶石座 + 类别印记」** —— 统一石座标识"这是超限石"，中心印记标识"给哪类装备"，
      颜色继续承载个体主题（并系统化，拉开色相）。形状/印记 = 可扩展的硬区分维度。

产出（模型设计/超限石_重设计_20261010/）：
  _现状_24颗.png / _现状_色相分布.png
  _速览_类别印记.png    5 个印记特写（放大 16×）
  _方案_晶石座.png      24 颗新设计全貌
用法: python .workbuddy/_proto_stone_redesign.py
"""
import os
import math
from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\数据包'
STONE = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream',
                     'textures', 'item', 'stone')
OUT = os.path.join(ROOT, '模型设计', '超限石_重设计_20261010')
os.makedirs(OUT, exist_ok=True)

W = H = 16

ITEMS = [
    ('liuguang',         '流光',           'sword', (255, 168,  72)),
    ('myriad',           '万念',           'sword', (196,  52,  62)),
    ('rogue_star',       '游星',           'sword', (128, 220, 255)),
    ('shadow_blade',     '影刃',           'sword', ( 88,  76, 120)),
    ('deepsea_echo',     '深海的回响',     'sword', ( 40, 132, 208)),
    ('everfrost',        '永霜',           'sword', (150, 226, 255)),
    ('flame_brokenbody', '烈火残躯',       'sword', (255,  96,  40)),
    ('sickle_dreams',    '引梦镰',         'sword', (176, 120, 236)),
    ('hengdao',          '横刀',           'sword', (226, 214, 176)),
    ('anion',            '负离子',         'axe',   ( 80, 224, 214)),
    ('charge',           '超·负·荷',       'axe',   (110, 130, 255)),
    ('red_lotus',        '红莲',           'axe',   (255,  96,  64)),
    ('dream_reader',     '释梦',           'axe',   (246, 232, 198)),
    ('bone_erode',       '蚀骨',           'bow',   (188, 196, 168)),
    ('cold_crow',        '寒鸦',           'bow',   (128, 216, 240)),
    ('sculk_echo',       '幽匿残响',       'bow',   ( 72, 168, 156)),
    ('begonia',          '海棠',           'staff', (244, 148, 190)),
    ('polarized_light',  '偏振光',         'staff', (226, 238, 255)),
    ('brain_leech',      '脑髓蛭',         'armor', (206,  62, 110)),
    ('spine_symbiote',   '脊骨共生',       'armor', (150, 196, 206)),
    ('stellar_elegy',    '群星坠落之挽歌', 'armor', ( 96, 132, 248)),
    ('dusk_dawn',        '黄昏黎明之交界', 'armor', (252, 200,  76)),
    ('dionysus_helmet',  '狄俄尼索斯之桂冠', 'armor', (212, 132, 232)),
    ('furnace_core',     '炉心',           'armor', (255, 118,  52)),
]
CAT_CN = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖', 'armor': '盔甲'}

FONT = r'C:\Windows\Fonts\msyh.ttc'


def font(sz):
    try:
        return ImageFont.truetype(FONT, sz)
    except Exception:
        return ImageFont.load_default()


# ---------------------------------------------------------------- 像素工具
def blank():
    return [[None] * W for _ in range(H)]


def put(px, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        px[y][x] = (int(c[0]), int(c[1]), int(c[2]), 255)


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def lighten(c, k):
    return tuple(max(0, min(255, int(v + (255 - v) * k))) for v in c)


def to_img(px):
    im = Image.new('RGBA', (W, H))
    im.putdata([px[y][x] or (0, 0, 0, 0) for y in range(H) for x in range(W)])
    return im


def label_img(text, w, h, sz=13, col=(228, 228, 236)):
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.text((1, 0), text, font=font(sz), fill=col)
    return im


def sheet(tiles, cols, scale, pad, bg, labels=None, lbl_h=18, title=None,
          sub=None):
    n = len(tiles)
    rows = (n + cols - 1) // cols
    cw = W * scale + pad
    ch = H * scale + pad + lbl_h
    top = (52 if sub else 34) if title else pad
    img = Image.new('RGB', (pad + cols * cw, top + rows * ch), bg)
    d = ImageDraw.Draw(img)
    if title:
        d.text((pad, 8), title, font=font(17), fill=(240, 240, 248))
    if sub:
        d.text((pad, 31), sub, font=font(12), fill=(150, 152, 166))
    for i, t in enumerate(tiles):
        x = pad + (i % cols) * cw
        y = top + (i // cols) * ch
        big = t.resize((W * scale, H * scale), Image.NEAREST)
        img.paste(big, (x, y), big)
        if labels:
            d.text((x + 2, y + H * scale + 3), labels[i], font=font(12),
                   fill=(224, 224, 232))
    return img


# ---------------------------------------------------------------- 晶石座
def seat_mask(u, v):
    """八边形晶石座：切角方形（比正圆更有"宝石"感，也和升级石的圆/菱形分开）"""
    return max(abs(u), abs(v)) <= 7.4 and (abs(u) + abs(v)) <= 10.4


def render_seat(main, sig, dark_k=0.34):
    """晶石座 + 中心印记（印记 = 亮色/暗色双描，保证在任何底色上都可读）"""
    dark = shade(main, dark_k)
    lite = lighten(main, 0.70)
    px = blank()
    m = [[seat_mask(x + 0.5 - 8, y + 0.5 - 8) for x in range(W)] for y in range(H)]

    def solid(x, y):
        return 0 <= x < W and 0 <= y < H and m[y][x]

    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            u, v = x + 0.5 - 8, y + 0.5 - 8
            border = not (solid(x + 1, y) and solid(x - 1, y)
                          and solid(x, y + 1) and solid(x, y - 1))
            if border:
                put(px, x, y, dark)
                continue
            # 切割面：对角受光（左上亮）+ 四角棱面更亮
            t = (-u - v) / 18.0 + 0.30 * (max(abs(u), abs(v)) >= 5.2) \
                + math.hypot(u, v) / 26.0
            if t > 0:
                put(px, x, y, lighten(main, min(0.5, t * 0.62)))
            else:
                put(px, x, y, shade(main, 1.0 + max(-0.44, t * 0.85)))
    # 印记：9x9，先给整枚印记描一圈暗边，再画亮线 ⇒ 任何底色上都可读
    if sig:
        n = len(sig)
        x0 = (W - n) // 2
        y0 = (H - n) // 2
        cells = {(gx, gy) for gy in range(n) for gx in range(n)
                 if sig[gy][gx] == '#'}
        for (gx, gy) in cells:
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    if (gx + dx, gy + dy) in cells:
                        continue
                    xx, yy = x0 + gx + dx, y0 + gy + dy
                    if 0 <= xx < W and 0 <= yy < H and m[yy][xx]:
                        put(px, xx, yy, dark)
        for (gx, gy) in cells:
            put(px, x0 + gx, y0 + gy, lite)
    return px


# 9x9 类别印记
SIG = {
    'sword': ["....#....",
              "....#....",
              "...###...",
              "...###...",
              "....#....",
              ".#######.",
              "....#....",
              "....#....",
              "...###..."],
    'axe':   ["..#####..",
              ".#######.",
              ".#######.",
              "..#####..",
              "...###...",
              "....#....",
              "....#....",
              "....#....",
              "...###..."],
    'bow':   [".#######.",
              "##....#..",
              "#.....#..",
              "#.....#..",
              "#.....#..",
              "#.....#..",
              "#.....#..",
              "##....#..",
              ".#######."],
    'staff': ["...###...",
              "..#####..",
              ".#######.",
              "..#####..",
              "...###...",
              "....#....",
              "....#....",
              "....#....",
              "...###..."],
    'armor': [".#######.",
              "#########",
              "##.###.##",
              "##.###.##",
              ".#######.",
              "..#####..",
              "...###...",
              "...#.....",
              "..###...."],
}


# ---------------------------------------------------------------- 方案 B：大块几何轮廓 = 类别
def g_sword(u, v):
    """剑：竖直棱柱（顶收尖、底收柄）"""
    if abs(v) > 7.4 or abs(u) > 3.2:
        return False
    if v < -4.6 and abs(u) > 3.2 - (-4.6 - v) * 1.4:
        return False
    if v > 4.8 and abs(u) > 3.2 - (v - 4.8) * 1.5:
        return False
    return True


def g_axe(u, v):
    """斧：上宽刃 + 下窄柄"""
    if -7.3 <= v <= -0.4:
        t = (v + 7.3) / 6.9
        half = 7.2 - 4.2 * t
        if v < -5.6 and abs(u) > 7.2 - (-5.6 - v) * 2.2:
            return False
        return abs(u) <= half
    if -0.4 < v <= 7.4:
        return abs(u) <= 1.5
    return False


def g_bow(u, v):
    """弩：右侧开口的粗环（弓背朝左）+ 一根弦（与弓相接）"""
    d = math.hypot(u, v)
    if 3.4 <= d <= 7.3 and u <= 2.2:
        return True
    if abs(u - 5.2) <= 0.55 and abs(v) <= 5.1:      # 弦
        return True
    return False


def g_staff(u, v):
    """法杖：竖杆 + 顶端菱晶（相接）"""
    if 0.2 <= v <= 7.4 and abs(u) <= 1.2:
        return True
    if abs(u) * 0.86 + abs(v + 3.4) <= 3.7 and v <= 0.2:
        return True
    return False


def g_armor(u, v):
    """盔甲：方肩棱盾"""
    if abs(v) > 7.4:
        return False
    if v <= -0.8:
        if abs(u) > 6.4:
            return False
        if v < -5.0 and abs(u) > 3.0 + (-5.0 - v) * 1.7:
            return False
        return True
    f = math.sqrt(max(0.0, 1.0 - (v / 7.4) ** 2))
    return abs(u) <= 6.4 * f


GEO = {'sword': g_sword, 'axe': g_axe, 'bow': g_bow,
       'staff': g_staff, 'armor': g_armor}


def render_geo(inside, main):
    dark = shade(main, 0.32)
    lite = lighten(main, 0.62)
    px = blank()
    m = [[inside(x + 0.5 - 8, y + 0.5 - 8) for x in range(W)] for y in range(H)]

    def solid(x, y):
        return 0 <= x < W and 0 <= y < H and m[y][x]

    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            u, v = x + 0.5 - 8, y + 0.5 - 8
            if not (solid(x + 1, y) and solid(x - 1, y)
                    and solid(x, y + 1) and solid(x, y - 1)):
                put(px, x, y, dark)
                continue
            t = (-u - v) / 19.0 + math.hypot(u, v) / 24.0
            if t > 0:
                put(px, x, y, lighten(main, min(0.52, t * 0.66)))
            else:
                put(px, x, y, shade(main, 1.0 + max(-0.46, t * 0.88)))
    return px


def build_geo_preview():
    tiles, labs = [], []
    for cat in ('sword', 'axe', 'bow', 'staff', 'armor'):
        rep = [it for it in ITEMS if it[2] == cat][0]
        tiles.append(to_img(render_geo(GEO[cat], rep[3])))
        labs.append('%s（%s）' % (CAT_CN[cat], rep[1]))
    return sheet(tiles, 5, 16, 12, (26, 26, 32), labs, 20,
                 '方案B 轮廓特写 16×：大块几何 = 类别（不做具象物体）')


def build_geo_sheet():
    tiles, labs = [], []
    for cid, cn, cat, col in ITEMS:
        tiles.append(to_img(render_geo(GEO[cat], col)))
        labs.append('%s(%s)' % (cn, CAT_CN[cat]))
    return sheet(tiles, 6, 9, 8, (26, 26, 32), labs, 18,
                 '方案B：轮廓 = 装备类别（颜色仍承载个体主题）')


# ---------------------------------------------------------------- 方案 C：晶石座 + 汉字关键字
HANZI = {
    'liuguang': '流', 'myriad': '念', 'rogue_star': '游', 'shadow_blade': '刃',
    'deepsea_echo': '海', 'everfrost': '霜', 'flame_brokenbody': '焰',
    'sickle_dreams': '引', 'hengdao': '刀', 'anion': '离', 'charge': '荷',
    'red_lotus': '莲', 'dream_reader': '梦', 'bone_erode': '骨',
    'cold_crow': '鸦', 'sculk_echo': '响', 'begonia': '棠',
    'polarized_light': '偏', 'brain_leech': '蛭', 'spine_symbiote': '脊',
    'stellar_elegy': '星', 'dusk_dawn': '昏', 'dionysus_helmet': '冠',
    'furnace_core': '炉',
}
HEI = r'C:\Windows\Fonts\simhei.ttf'


def hanzi_mask(ch, size=13):
    f = ImageFont.truetype(HEI, size)
    tmp = Image.new('L', (40, 40), 0)
    bbox = ImageDraw.Draw(tmp).textbbox((0, 0), ch, font=f)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    ox = (W - w) // 2 - bbox[0]
    oy = (H - h) // 2 - bbox[1]
    im = Image.new('L', (W, H), 0)
    ImageDraw.Draw(im).text((ox, oy), ch, font=f, fill=255)
    p = im.load()
    return [[p[x, y] >= 108 for x in range(W)] for y in range(H)]


def render_hanzi(main, ch, size=13):
    dark = shade(main, 0.28)
    lite = lighten(main, 0.84)
    px = blank()
    m = [[seat_mask(x + 0.5 - 8, y + 0.5 - 8) for x in range(W)] for y in range(H)]

    def solid(x, y):
        return 0 <= x < W and 0 <= y < H and m[y][x]

    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            u, v = x + 0.5 - 8, y + 0.5 - 8
            if not (solid(x + 1, y) and solid(x - 1, y)
                    and solid(x, y + 1) and solid(x, y - 1)):
                put(px, x, y, dark)
                continue
            t = (-u - v) / 19.0 + math.hypot(u, v) / 24.0
            if t > 0:
                put(px, x, y, lighten(main, min(0.5, t * 0.6)))
            else:
                put(px, x, y, shade(main, 1.0 + max(-0.46, t * 0.86)))
    # 刻字（浮雕：先给字形外邻描一圈暗边、再把字形画亮）
    hm = hanzi_mask(ch, size)
    for y in range(H):
        for x in range(W):
            if hm[y][x] or not m[y][x]:
                continue
            near = False
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and hm[yy][xx]:
                        near = True
            if near:
                put(px, x, y, dark)
    for y in range(H):
        for x in range(W):
            if hm[y][x] and m[y][x]:
                put(px, x, y, lite)
    return px


def build_hanzi_sheet():
    tiles, labs = [], []
    for cid, cn, cat, col in ITEMS:
        tiles.append(to_img(render_hanzi(col, HANZI[cid], size=11)))
        labs.append('%s(%s)' % (cn, CAT_CN[cat]))
    return sheet(tiles, 6, 11, 8, (26, 26, 32), labs, 18,
                 '方案一：晶石座 + 汉字关键字（唯一可读 · 永不重复）')


# ---------------------------------------------------------------- 方案 D：双色八芒星（最小改动）
CAT_COLOR = {'sword': (206, 212, 224), 'axe': (182, 126, 78),
             'bow': (118, 176, 108), 'staff': (172, 130, 224),
             'armor': (226, 182, 92)}


def render_dual(main, catcol):
    """保留现有八芒星，但"芒身"用类别固定色、"内芯"用主题色"""
    dark = shade(catcol, 0.42)
    px = blank()
    for y in range(H):
        for x in range(W):
            u, v = x + 0.5 - 8, y + 0.5 - 8
            d = math.hypot(u, v)
            if d > 7.2:
                continue
            a = math.atan2(v, u)
            reach = 3.0 + 3.5 * abs(math.cos(a * 2.0)) ** 0.55
            if d > reach + 0.9:
                continue
            if d > reach:
                put(px, x, y, dark)
            elif d > reach * 0.55:
                t = (d / 7.6)
                put(px, x, y, shade(catcol, 1.0 - t * 0.35))
            else:
                t = (d / 7.6) * 2.2
                put(px, x, y, lighten(main, max(0.0, 0.5 - t)))
    return px


def build_dual_sheet():
    tiles, labs = [], []
    for cid, cn, cat, col in ITEMS:
        tiles.append(to_img(render_dual(col, CAT_COLOR[cat])))
        labs.append('%s(%s)' % (cn, CAT_CN[cat]))
    return sheet(tiles, 6, 9, 8, (26, 26, 32), labs, 18,
                 '方案三：保留八芒星 · 芒身 = 类别色 / 内芯 = 主题色（改动最小）')


# ---------------------------------------------------------------- 现状图
def build_now():
    tiles, labs = [], []
    for cid, cn, cat, col in ITEMS:
        tiles.append(Image.open(os.path.join(STONE, 'ol_%s.png' % cid)).convert('RGBA'))
        labs.append('%s(%s)' % (cn, CAT_CN[cat]))
    return sheet(tiles, 6, 9, 8, (26, 26, 32), labs, 18,
                 '现状：24 颗超限石 = 同一种八芒星，只靠颜色分')


def hue_of(rgb):
    r, g, b = [v / 255.0 for v in rgb]
    mx, mn = max(r, g, b), min(r, g, b)
    if mx == mn:
        return None
    d = mx - mn
    h = ((g - b) / d) % 6 if mx == r else ((b - r) / d + 2 if mx == g
                                           else (r - g) / d + 4)
    return h * 60.0


def hsv_rgb(h, s, v):
    i = int(h * 6) % 6
    f = h * 6 - int(h * 6)
    p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    r, g, b = [(v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q)][i]
    return (int(r * 255), int(g * 255), int(b * 255))


def build_hue_ring():
    S, R = 430, 150
    img = Image.new('RGB', (S, S), (22, 22, 28))
    d = ImageDraw.Draw(img)
    cx = cy = S // 2
    for k in range(360):
        a0, a1 = math.radians(k - 0.5), math.radians(k + 0.5)
        d.polygon([(cx, cy),
                   (cx + R * math.cos(a0), cy + R * math.sin(a0)),
                   (cx + R * math.cos(a1), cy + R * math.sin(a1))],
                  fill=hsv_rgb(k / 360.0, 0.7, 0.95))
    d.ellipse([cx - 46, cy - 46, cx + 46, cy + 46], fill=(22, 22, 28))
    layer = {'sword': 0.60, 'axe': 0.78, 'bow': 0.94, 'staff': 0.72, 'armor': 0.86}
    for cid, cn, cat, col in ITEMS:
        h = hue_of(col) or 0.0
        rad = math.radians(h)
        rr = R * layer[cat]
        x, y = cx + rr * math.cos(rad), cy + rr * math.sin(rad)
        d.ellipse([x - 5, y - 5, x + 5, y + 5], fill=col, outline=(20, 20, 24))
    d.text((10, 8), '现状色相分布：同色相挤成一堆 = 会混', font=font(15),
           fill=(240, 240, 248))
    return img


# ---------------------------------------------------------------- 新方案全貌
def build_seat_sheet():
    tiles, labs = [], []
    for cid, cn, cat, col in ITEMS:
        tiles.append(to_img(render_seat(col, SIG[cat])))
        labs.append('%s(%s)' % (cn, CAT_CN[cat]))
    return sheet(tiles, 6, 9, 8, (26, 26, 32), labs, 18,
                 '方案：晶石座 + 类别印记（统一石座标"超限石"，中心印记标类别）')


def build_sig_preview():
    tiles, labs = [], []
    for cat in ('sword', 'axe', 'bow', 'staff', 'armor'):
        rep = [it for it in ITEMS if it[2] == cat][0]
        tiles.append(to_img(render_seat(rep[3], SIG[cat])))
        labs.append('%s（%s）' % (CAT_CN[cat], rep[1]))
    return sheet(tiles, 5, 16, 12, (26, 26, 32), labs, 20,
                 '印记特写 16×：剑 / 斧 / 弩 / 法杖 / 盔甲')


if __name__ == '__main__':
    jobs = [
        ('_现状_24颗.png', build_now),
        ('_现状_色相分布.png', build_hue_ring),
        ('_方案一_晶石座+汉字.png', build_hanzi_sheet),
        ('_方案二_类别轮廓.png', build_geo_sheet),
        ('_速览_类别轮廓.png', build_geo_preview),
        ('_方案三_双色星.png', build_dual_sheet),
    ]
    for name, fn in jobs:
        p = os.path.join(OUT, name)
        fn().save(p)
        print('->', p)
