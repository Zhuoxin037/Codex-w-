# -*- coding: utf-8 -*-
"""武器专属状态 · 头顶图标绘制（预览 / 图集两用）。

【为什么要有这个脚本】
  老资源包里的 sweetdream_rp/tools/make_icons.py 随"资源包只留完整版"一起没了,
  而图标字形是**不可见私有区字符**, 手改必丢。所以重写一份: 定义像素图 -> 出预览
  -> (通过后) 追加进 完整版 的 icons.png, 并把 icons.json 的 chars 补齐。

【画风 —— 实测现有 5 个图标反推出来的硬指标】(2026-10-13 重做)
  解剖 icons.png 前 5 格得到:
  · 形状是**高填充率的实心块**(非空 276~486 px / 1024 = 27%~47%), 不是线条;
    形状有机、不对称, 边缘带锯齿, 还零星撒几个孤立像素(火星/光点);
  · 配色**只有 3 档**(白昼梦例外 8 档): 暗=深且低饱和(打底, 占 ~55%)、
    中=饱和(主体, ~35%)、亮=去饱和偏白(高光, ~10%), **无描边**;
  · 高光一律在**左上**(上缘/左缘), 右缘与下缘走暗档。
  ⇒ 所以本脚本只定义**实心形状 mask**, 明暗交给统一的 shade() 着色器自动生成,
    保证 5 个新图标和现有 5 个是同一套光影逻辑。

用法：
  python .workbuddy/_draw_tag_icons.py preview   # 出 logs/tag_icons_preview.png
"""
import io
import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:  # 构建类脚本走 default venv
    raise SystemExit('需要 PIL: 用 ...\\python\\envs\\default\\Scripts\\python.exe 跑')

ROOT = Path(r'D:\数据包')
RP = ROOT / 'sweetdream_rp_完整版'
ATLAS = RP / 'assets' / 'sweetdream' / 'textures' / 'font' / 'icons.png'
FONT_JSON = RP / 'assets' / 'sweetdream' / 'font' / 'icons.json'

DIM_ALPHA = 102          # 实测现有 dim 字形的 alpha
DIM_DESAT = 0.35         # 实测现有 dim 的轻微去饱和

# ---------------------------------------------------------------- 调色板
# 1=暗(打底) 2=中(主体) 3=亮(左上高光) 4=核心白
# 数值照现有 5 个的比例手调: 暗色要"深而压得住", 亮色要"去饱和偏白"
PAL = {
    'shenghen': {'1': (110, 68, 14),  '2': (226, 172, 60),  '3': (255, 238, 186), '4': (255, 255, 255)},
    'stg':      {'1': (14, 64, 100),  '2': (58, 168, 212),  '3': (182, 230, 250), '4': (255, 255, 255)},
    'dianci':   {'1': (30, 42, 104),  '2': (96, 132, 236),  '3': (212, 228, 255), '4': (255, 255, 255)},
    'shizhou':  {'1': (48, 26, 74),   '2': (138, 80, 200),  '3': (220, 176, 248), '4': (255, 226, 255)},
}
# 漫彩是四条彩虹带, 每条各带主色/亮色(不适用统一三档)
BAND = {
    0: ((206, 68, 52),  (244, 134, 98)),    # 外: 红
    1: ((226, 152, 50), (248, 206, 116)),   #     橙黄
    2: ((84, 182, 110), (154, 230, 172)),   #     青绿
    3: ((92, 120, 212), (160, 190, 248)),   # 内: 蓝紫
}


# ---------------------------------------------------------------- 形状工具
def mask_from_rows(rows):
    """'#' = 实心。顺手校验每行等长(手写点阵最容易错的就是这个)。"""
    n = len(rows)
    for i, r in enumerate(rows):
        if len(r) != n:
            raise SystemExit('第 %d 行长度 %d != %d: %r' % (i, len(r), n, r))
    return [[c == '#' for c in r] for r in rows]


def shade(mask, sparkle=()):
    """统一着色器: 内部=中调, 上缘/左上角=亮(高光), 右缘/下缘=暗(阴影)。

    与现有 5 个图标的光影逻辑一致(实测: 亮档集中在左上, 暗档占一半以上)。
    """
    n = len(mask)
    g = [['.'] * n for _ in range(n)]

    def m(x, y):
        return 0 <= x < n and 0 <= y < n and mask[y][x]

    for y in range(n):
        for x in range(n):
            if not mask[y][x]:
                continue
            up, down = m(x, y - 1), m(x, y + 1)
            left, right = m(x - 1, y), m(x + 1, y)
            if not up:
                g[y][x] = '3'                      # 上缘 -> 高光
            elif not right or not down:
                g[y][x] = '1'                      # 右/下缘 -> 阴影
            elif not left:
                g[y][x] = '1' if y > n * 0.55 else '2'   # 左缘: 上半留中调, 下半压暗
            else:
                g[y][x] = '2'                      # 内部 -> 主体
    for (x, y, c) in sparkle:
        if m(x, y):
            g[y][x] = c
    return g


# ---------------------------------------------------------------- 各图标形状
def make_shenghen():
    """圣痕: 圣光星芒(垂直长芒 + 水平长芒 + 中央菱形 + 两侧断开的碎光)。"""
    rows = [
        '.......##.......',
        '.......##.......',
        '.......##.......',
        '......####......',
        '......####......',
        '.....######.....',
        '##...######...##',
        '################',
        '################',
        '##...######...##',
        '.....######.....',
        '......####......',
        '......####......',
        '.......##.......',
        '.......##.......',
        '.......##.......',
    ]
    return shade(mask_from_rows(rows), sparkle=[(7, 7, '4'), (8, 8, '4'), (6, 6, '3'), (9, 9, '3')])


def make_stg():
    """升痕: 向上的锐箭(细杆大三角, 头底全宽收在 14/16, 杆 4 宽)。"""
    rows = [
        '.......##.......',
        '......####......',
        '......####......',
        '.....######.....',
        '.....######.....',
        '....########....',
        '....########....',
        '...##########...',
        '..############..',
        '.##############.',
        '......####......',
        '......####......',
        '......####......',
        '......####......',
        '......####......',
        '.......##.......',
    ]
    g = shade(mask_from_rows(rows), sparkle=[(7, 1, '4'), (7, 3, '3'), (6, 4, '3')])
    # 杆两侧的上升气流碎点(照夜火/流火那种"零星孤立像素")
    for (x, y) in [(2, 11), (13, 12), (3, 13)]:
        g[y][x] = '1'
    return g


def make_dianci():
    """电刺: 粗闪电 Z(上段陡斜 -> 短横板 -> 下段陡斜), 外围撒电火花。"""
    rows = [
        '.........####...',
        '.........####...',
        '........#####...',
        '........####....',
        '.......#####....',
        '.......####.....',
        '......#####.....',
        '.....######.....',
        '....#########...',
        '....######......',
        '.....#######....',
        '......########..',
        '.......#######..',
        '........######..',
        '.........#####..',
        '..........###...',
    ]
    g = shade(mask_from_rows(rows), sparkle=[(10, 1, '4'), (9, 2, '3'), (6, 8, '4'), (9, 11, '3')])
    # 溅出的电火花
    for (x, y) in [(14, 3), (1, 8), (14, 12), (2, 14)]:
        g[y][x] = '3'
    return g


def make_mancai():
    """漫彩: 四带彩虹拱(外红->内蓝紫), 每条带的上缘走亮档。"""
    import math
    n = 16
    g = [['.'] * n for _ in range(n)]
    cx, cy = 7.5, 12.0
    edges = [(7.0, 8.9), (5.4, 7.0), (3.8, 5.4), (2.2, 3.8)]   # 由外到内

    def band_of(x, y):
        d = math.hypot(x - cx, y - cy)
        for i, (lo, hi) in enumerate(edges):
            if lo <= d < hi:
                return i
        return None

    for y in range(13):                      # 只画拱的上半, 底部自然切平
        for x in range(n):
            b = band_of(x, y)
            if b is None:
                continue
            above = band_of(x, y - 1) if y > 0 else None
            g[y][x] = ('b%d' % b) if above == b else ('B%d' % b)   # B=该带上缘(亮)
    return g


def make_shizhou():
    """世咒: 紫色符印圆盘(外环 + 内盘 + 五芒星 + 环上五符点), 32x32 原生(白昼梦同例)。"""
    import math
    n = 32
    g = [['.'] * n for _ in range(n)]
    cx, cy = 15.5, 15.5

    def put(x, y, c):
        if 0 <= x < n and 0 <= y < n:
            g[y][x] = c

    # 外环(暗) + 内盘(中)
    for y in range(n):
        for x in range(n):
            d = math.hypot(x - cx, y - cy)
            if 12.6 <= d <= 14.4:
                g[y][x] = '1'
            elif d < 12.6:
                g[y][x] = '2'
    # 内盘压暗一圈(让中心星浮起来): 内盘靠近环的部分走暗档
    for y in range(n):
        for x in range(n):
            d = math.hypot(x - cx, y - cy)
            if 10.5 <= d < 12.6:
                g[y][x] = '1'

    # 五芒星(隔点连线), 半径 9.2
    R = 9.2
    pts = []
    for k in range(5):
        a = math.radians(-90 + 72 * k)
        pts.append((cx + R * math.cos(a), cy + R * math.sin(a)))

    def line(x0, y0, x1, y1, c, thick=3):
        dist = math.hypot(x1 - x0, y1 - y0)
        steps = int(dist * 4) + 1
        for i in range(steps + 1):
            t = i / steps
            x = x0 + (x1 - x0) * t
            y = y0 + (y1 - y0) * t
            for ox in range(-(thick // 2), thick // 2 + 1):
                for oy in range(-(thick // 2), thick // 2 + 1):
                    put(int(round(x)) + ox, int(round(y)) + oy, c)

    for i in range(5):
        x0, y0 = pts[i]
        x1, y1 = pts[(i + 2) % 5]
        line(x0, y0, x1, y1, '3')
    # 五个尖角点白 + 环上五个符点(与尖角同向)
    for k in range(5):
        a = math.radians(-90 + 72 * k)
        px, py = int(round(cx + R * math.cos(a))), int(round(cy + R * math.sin(a)))
        for ox in (-1, 0, 1):
            for oy in (-1, 0, 1):
                put(px + ox, py + oy, '4')
        qx, qy = int(round(cx + 13.4 * math.cos(a))), int(round(cy + 13.4 * math.sin(a)))
        for ox in (-1, 0):
            for oy in (-1, 0):
                put(qx + ox, qy + oy, '3')
    # 中心一点咒核
    for ox in (-1, 0):
        for oy in (-1, 0):
            put(int(cx) + ox, int(cy) + oy, '4')
    return g


MARKS = [
    ('shenghen', make_shenghen, 16),
    ('stg',      make_stg,      16),
    ('dianci',   make_dianci,   16),
    ('mancai',   make_mancai,   16),
    ('shizhou',  make_shizhou,  32),
]

CN = {'shenghen': '圣痕', 'stg': '升痕', 'dianci': '电刺', 'mancai': '漫彩', 'shizhou': '世咒'}


# ---------------------------------------------------------------- 渲染
def _color(name, key):
    """把网格字符映射成 RGB。漫彩的 B0..3/b0..3 走彩虹带表。"""
    if key.startswith(('B', 'b')) and key[1:].isdigit():
        i = int(key[1:])
        main, hi = BAND[i]
        return hi if key[0] == 'B' else main
    return PAL[name][key]


def render_cell(grid, name, out_size=32, dim=False):
    n = len(grid)
    scale = out_size // n
    im = Image.new('RGBA', (out_size, out_size), (0, 0, 0, 0))
    for y in range(n):
        for x in range(n):
            c = grid[y][x]
            if c == '.':
                continue
            r, g, b = _color(name, c)
            a = 255
            if dim:
                a = DIM_ALPHA
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                r = int(r + (lum - r) * DIM_DESAT)
                g = int(g + (lum - g) * DIM_DESAT)
                b = int(b + (lum - b) * DIM_DESAT)
            for dy in range(scale):
                for dx in range(scale):
                    im.putpixel((x * scale + dx, y * scale + dy), (r, g, b, a))
    return im


def stats(grid, name):
    """自检: 填充率 / 明暗比例, 用来跟现有 5 个对照。"""
    n = len(grid)
    tot = n * n
    cnt = {}
    fill = 0
    for row in grid:
        for c in row:
            if c != '.':
                fill += 1
                cnt[c] = cnt.get(c, 0) + 1
    return fill, fill * 100.0 / tot, cnt


def _font(size=16):
    for cand in (r'C:\Windows\Fonts\msyh.ttc', r'C:\Windows\Fonts\simhei.ttf'):
        if os.path.exists(cand):
            try:
                return ImageFont.truetype(cand, size)
            except Exception:
                pass
    return ImageFont.load_default()


def preview():
    Z = 6                     # 放大倍数
    cell = 32 * Z
    pad = 16
    label_h = 30
    cols = 5
    rows = 3                  # 现有 / 新增 / 新增淡色
    W = pad + cols * (cell + pad)
    H = pad + rows * (cell + label_h + pad) + label_h + 60 + pad
    canvas = Image.new('RGBA', (W, H), (28, 30, 36, 255))
    d = ImageDraw.Draw(canvas)
    f = _font(16)
    f2 = _font(13)

    ex = Image.open(ATLAS).convert('RGBA')
    ex_names = ['yuanhai', 'liuhuo', 'yehuo', 'shixin', 'dream']

    def blit(img, col, row, label, sub=''):
        x = pad + col * (cell + pad)
        y = pad + label_h + row * (cell + label_h + pad)
        canvas.alpha_composite(img.resize((cell, cell), Image.NEAREST), (x, y))
        d.text((x, y - label_h + 2), label, font=f, fill=(230, 232, 240, 255))
        if sub:
            d.text((x, y - label_h + 2 + 16), sub, font=f2, fill=(150, 155, 170, 255))

    d.text((pad, 4),
           '第1行 = 现有 5 状态（风格基准）   第2行 = 新增 5 状态   第3行 = 剩余≤3秒·淡色字形',
           font=f2, fill=(170, 175, 190, 255))

    for i, n in enumerate(ex_names):
        blit(ex.crop((i * 32, 0, i * 32 + 32, 32)), i, 0, n, 'existing')
    for i, (name, fn, size) in enumerate(MARKS):
        g = fn()
        blit(render_cell(g, name), i, 1, CN[name], name)
        blit(render_cell(g, name, dim=True), i, 2, CN[name] + '·淡', name + '.dim')
        fill, pct, cnt = stats(g, name)
        print('  %-9s 填充 %3d/%d = %.0f%%  明暗分布 %s' % (name, fill, size * size, pct, cnt))

    # 真·游戏内大小: 7 个图标并排(现有 2 + 新增 5), 放大 x3 看可辨识度
    strip_y = H - label_h - 16 * 3 - pad
    d.text((pad, strip_y - 34), '游戏内实际大小（16px 字形并排 · 此处放大 x3）',
           font=f2, fill=(170, 175, 190, 255))
    tx = pad
    for name in ['yuanhai', 'liuhuo', 'shenghen', 'stg', 'dianci', 'mancai', 'shizhou']:
        if name in [n for n, _, _ in MARKS]:
            fn = [f for n, f, _ in MARKS if n == name][0]
            g = fn()
            c16 = render_cell(g, name, out_size=32).resize((16, 16), Image.NEAREST)
        else:
            i = ex_names.index(name)
            c16 = ex.crop((i * 32, 0, i * 32 + 32, 32)).resize((16, 16), Image.NEAREST)
        canvas.alpha_composite(c16.resize((16 * 3, 16 * 3), Image.NEAREST), (tx, strip_y))
        tx += 16 * 3 + 8

    out = ROOT / 'logs' / 'tag_icons_preview.png'
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert('RGB').save(out)
    print('wrote', out, canvas.size)


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'preview'
    if cmd == 'preview':
        preview()
    else:
        raise SystemExit('未知参数: ' + cmd)
