# -*- coding: utf-8 -*-
"""_gen_late_icons.py —— 补齐"只做了 give、没做外观"那 46 件的贴图（唯一真相来源）。

【背景】批 14（_gen_new42.py）当初只做 give，文件头明写「不挂 item_model，外观留后续
  批次」。批 12 补了 7 件，剩下的 46 件在游戏里一直还是底材的原版外观 —— 玩家看到的就是
  「还有很多武器装备没有贴图」。本脚本把它们一次补齐：

    · 21 件盔甲：16×16 背包图标 + 64×32 穿戴层（头/胸/靴 = humanoid，护腿 = humanoid_leggings）
    · 4 把剑 / 5 把斧 / 5 把弩（各 6 态）/ 8 根法杖：16×16 背包图标
    · 3 件副手：32×32 透明像素图，唯一画稿在 tools/art/offhand_20261018/

【★ 为什么不能"整把压成一个色阶"】
  批 12 那 3 把是单色阶重映射，出来的刀是"一整块同色"。"不要过于相似"这条要求下，
  单色阶会让一批新刀读起来像同一把换了滤镜。所以这里分两套画法：

  · 剑 —— **按材质分类**：骨架像素按 HSV 分成 刃(低饱和金属)/金(暖亮)/柄(暖暗)/彩(高饱和)，
    各类各自映射到自己的色阶，保住"钢刃 + 铜护手 + 木柄"的三段对比。
    （vanilla 剑图标正好是这三种材质，分类很稳，实测下来效果最好。）
  · 斧/弩/法杖/副手 —— **按亮度三段切**：把所有像素按亮度排序，最暗的一档 → 柄/杆色阶，
    最亮的一档 → 高光/宝珠色阶，中间 → 主体色阶。这些骨架的材质分布太偏（例如
    `draught` 62 个像素全是"暖暗"、`agony` 60 个全是高饱和彩），按材质分会把整把塞进
    一个色阶里，出来的斧子一片黑。按亮度切则无论如何都有三段，可预测。

【★ 每件一个 identity：色阶 + motif】
  · 色阶：`ramp(h, s)` 由 hue/sat 生成 6 档亮度阶梯（暗→亮），亮端色相略偏暖。
  · motif：同骨架换色难免撞脸，所以每件再加 1~2 处**定向笔触**（刃尖一点、斧柄锈斑、
    靴口一圈、头盔额心一颗宝石…）。盔甲 motif 落在固定 UV 区：
      头 front (8..15, 8..15) / 胸 front (20..27, 20..31) /
      腿 front (4..7, 20..31) / 靴 front (4..7, 28..31)
  · 同批防撞脸：生成后打印"类别内主色 hue 两两最小夹角"，< 18° 告警（同类撞色 =
    玩家分不出来）。

【用法】
    python .workbuddy/_gen_late_icons.py            # 只写贴图
    python .workbuddy/_gen_late_icons.py --preview  # 写贴图 + 出对照大图
"""
import colorsys
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RP = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream')
TEX_ITEM = os.path.join(RP, 'textures', 'item', 'vanilla')
TEX_WORN = os.path.join(RP, 'textures', 'entity', 'equipment')
CB_STATES = ('standby', 'pulling_0', 'pulling_1', 'pulling_2', 'arrow', 'firework')


# ============================================================ 色阶
def ramp(h, s, n=6, lo=0.10, hi=0.97, warm=10.0):
    """hue/sat -> n 档亮度阶梯（暗→亮）。warm = 亮端色相偏暖的度数。"""
    out = []
    for i in range(n):
        t = i / (n - 1.0)
        v = lo + (hi - lo) * (t ** 0.85)
        hh = (h + warm * (t ** 2)) % 360.0
        ss = max(0.0, min(1.0, s * (1.0 - 0.38 * t)))
        r, g, b = colorsys.hsv_to_rgb(hh / 360.0, ss, v)
        out.append((int(r * 255 + .5), int(g * 255 + .5), int(b * 255 + .5)))
    return out


def lum(c):
    return 299 * c[0] + 587 * c[1] + 114 * c[2]


def hsv_of(c):
    h, s, v = colorsys.rgb_to_hsv(c[0] / 255.0, c[1] / 255.0, c[2] / 255.0)
    return h * 360.0, s, v


def open_rgba(path):
    return Image.open(path).convert('RGBA')


# ============================================================ 两套重映射
def cls_of(c):
    """把骨架像素分到 blade / gold / haft / accent 四类（只给剑用）。"""
    h, s, v = hsv_of(c)
    if s < 0.30 and v > 0.22:
        return 'blade'                      # 钢/银：低饱和
    if 20.0 <= h <= 78.0:
        return 'gold' if v >= 0.50 else 'haft'   # 暖亮 = 金；暖暗 = 木柄
    if h < 20.0 or h > 340.0:
        return 'haft'                       # 棕/暗红 = 柄
    return 'accent'                         # 高饱和彩件（法球/宝石/布）


def remap_cls(src_path, spec):
    """按材质分类映射（剑）。spec = {类名: ramp}，缺的类回落到 blade。"""
    im = open_rgba(src_path)
    px = im.load()
    w, h = im.size
    buckets = {}
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            if p[3] < 40:
                continue
            buckets.setdefault(cls_of(p), []).append((x, y, p))
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    op = out.load()
    for k, items in buckets.items():
        pal = spec.get(k) or spec.get('blade')
        items.sort(key=lambda t: lum(t[2]))
        n = len(items)
        for i, (x, y, p) in enumerate(items):
            op[x, y] = pal[min(len(pal) - 1, i * len(pal) // n)] + (p[3],)
    return out


def remap3(src_path, pal3, d=0.34, b=0.86):
    """按亮度三段切（斧/弩/法杖/副手）。
    pal3 = {'dark': ramp, 'main': ramp, 'bright': ramp}
      最暗 d  → dark（柄/杆）
      最亮 1-b → bright（刃口/宝珠/高光）
      其余    → main
    """
    im = open_rgba(src_path)
    px = im.load()
    w, h = im.size
    items = []
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            if p[3] >= 40:
                items.append((x, y, p))
    items.sort(key=lambda t: lum(t[2]))
    n = len(items)
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    op = out.load()
    for i, (x, y, p) in enumerate(items):
        r = i / float(n - 1) if n > 1 else 0.5
        if r < d:
            pal, t = pal3['dark'], r / d
        elif r > b:
            pal, t = pal3['bright'], (r - b) / (1.0 - b)
        else:
            pal, t = pal3['main'], (r - d) / (b - d)
        op[x, y] = pal[min(len(pal) - 1, int(t * len(pal)))] + (p[3],)
    return out


# ============================================================ 笔触
def dot(im, xy_list, color):
    px = im.load()
    for x, y in xy_list:
        if 0 <= x < im.width and 0 <= y < im.height and px[x, y][3] >= 40:
            px[x, y] = color + (255,)


def hbar(im, y, x0, x1, color):
    dot(im, [(x, y) for x in range(x0, x1 + 1)], color)


def edge_darken(im, color, x0=0, y0=0, x1=None, y1=None):
    """把区域里"挨着透明"的像素压成 color —— 收轮廓，防止亮色糊成一团。"""
    x1 = im.width - 1 if x1 is None else x1
    y1 = im.height - 1 if y1 is None else y1
    px = im.load()
    todo = []
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if px[x, y][3] < 40:
                continue
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < im.width and 0 <= ny < im.height and px[nx, ny][3] < 40:
                    todo.append((x, y))
                    break
    for x, y in todo:                        # ★ 先收集再改：边遍历边改会越染越宽（坑 196）
        px[x, y] = color + (255,)


# ============================================================ 手绘像素画
def art(rows, pal):
    """16×16 像素画：rows 每行 16 个字符，'.' = 透明，pal = {字符: (r,g,b)}。

    ★ 为什么要手绘而不是继续换色：副手那 3 件第一版是拿包内现成的
      `tool_blaze_plume`(炽翎) / `tool_bitter_cold`(苦寒) / `tool_nullify`(无效)
      当骨架换色的 —— 轮廓像素级一模一样，玩家一眼就看出"就换了个色"。
      凡是"物件类"（丝线束 / 镜子 / 带扣 / 钟）都得单独造型，换色救不了。
    """
    h = len(rows)
    w = max(len(r) for r in rows)
    for i, r in enumerate(rows):
        if len(r) != w:
            raise SystemExit('像素画第 %d 行宽度 %d != %d：%r' % (i, len(r), w, r))
        for ch in r:
            if ch != '.' and ch not in pal:
                raise SystemExit('像素画第 %d 行有未定义字符 %r' % (i, ch))
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    px = im.load()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == '.':
                continue
            c = pal[ch]
            px[x, y] = (c[0], c[1], c[2], 255)
    return im


def _line(x0, y0, x1, y1):
    """Bresenham 直线（像素画里铺细丝 / 杖杆用）。"""
    pts = []
    dx, dy = abs(x1 - x0), abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy
    while True:
        pts.append((x0, y0))
        if x0 == x1 and y0 == y1:
            return pts
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy


def _offhand_master(item_id):
    """三件副手重绘的唯一画稿；只读取 PNG，不再用旧程序图案覆盖。"""
    path = os.path.join(ROOT, 'tools', 'art', 'offhand_20261018', item_id + '.png')
    with Image.open(path) as image:
        return image.convert('RGBA')


def art_coffin_silk():
    """殓丝：骨白线轴、暗红丝线与斜穿银针。"""
    return _offhand_master('coffin_silk')


def art_frostmirror():
    """冰鉴：棱角银框、蓝色冰裂镜面与冰晶柄坠。"""
    return _offhand_master('frostmirror')


def art_tide_buckle():
    """回潮扣：卷浪铜扣、潮蓝宝石与两侧皮带。"""
    return _offhand_master('tide_buckle')


def art_wake_bell():
    """醒梦钟：杖杆 + 钟形杖头（圆顶 / 收腰 / 外扩钟口 / 下缘暗边）+ 钟舌宝珠。

    用户明确"我希望设计成钟状"——原来只是拿 `staff_chime` 换色，出来是普通法杖。
    """
    m = ramp(36, .58, 6, .30, .99)      # 铜金（hue 偏高会发橄榄绿，36 才是正经铜）
    k = ramp(26, .42, 5, .10, .45)      # 暗铜
    b = ramp(272, .52, 4, .48, .96)     # 梦紫宝珠
    pal = {'B': m[3], 'b': m[5], 'D': k[2], 'K': k[0], 'G': b[3],
           'H': k[3], 'h': m[0]}
    rows = [
        '................',
        '.......KK.......',   # 提纽
        '......bBBB......',   # 圆顶（左上高光）
        '.....bBBBBb.....',   # 钟肩
        '.....BBBBBB.....',
        '.....hBBBBh.....',   # 腰箍（暗一档）
        '.....BBBBBB.....',
        '....DDDDDDDD....',   # 钟口外扩（暗铜口沿；用纯黑会读成"一顶帽子"）
        '.......GG.......',   # 钟舌宝珠（梦紫，悬在钟口下）
        '.......HH.......',   # 杖杆
        '.......HH.......',
        '.......Hb.......',   # 金属箍
        '.......HH.......',
        '......HHHH......',   # 握把
        '......HHHH......',
        '.......HH.......',
    ]
    return art(rows, pal)


# ============================================================ 名单
# 剑：按材质分类映射（pal 键 = blade / gold / haft / accent）
SWORDS = [
    # 退汐（水刃）—— 骨架反弹锋：黛青海刃 + 青铜护手 + 湿木柄
    dict(id='backflow_tide', cn='退汐', skel='rebound',
         pal={'blade': ramp(188, .62), 'gold': ramp(38, .50, 5, .24, .92),
              'haft': ramp(200, .30, 5, .10, .42), 'accent': ramp(188, .62)},
         motif=lambda im, p: dot(im, [(13, 2), (12, 3)], p['blade'][-1])),
    # 盲烛（烛火）—— 骨架千散：烛焰黄刃 + 暗红护手 + 焦黑柄
    dict(id='blind_candle', cn='盲烛', skel='qiansan',
         pal={'blade': ramp(42, .80, 6, .30, .99), 'gold': ramp(6, .62, 5, .28, .74),
              'haft': ramp(20, .25, 5, .10, .32), 'accent': ramp(42, .80)},
         motif=lambda im, p: dot(im, [(14, 1), (13, 1)], (255, 250, 214))),
    # 失血 —— 骨架神裁：干涸绛血刃 + 骨白护手 + 褐黑柄
    dict(id='blood_loss', cn='失血', skel='verdict',
         pal={'blade': ramp(352, .74, 6, .22, .80), 'gold': ramp(40, .10, 5, .58, .97),
              'haft': ramp(18, .36, 5, .06, .28), 'accent': ramp(352, .74)},
         motif=lambda im, p: dot(im, [(7, 9), (8, 9)], p['blade'][0])),
    # 雷楔（雷）—— 骨架游星：电紫刃 + 铁灰护手 + 深蓝柄
    dict(id='thunder_wedge', cn='雷楔', skel='rogue_star',
         pal={'blade': ramp(272, .58), 'gold': ramp(210, .10, 5, .30, .80),
              'haft': ramp(250, .40, 5, .06, .30), 'accent': ramp(272, .58)},
         motif=lambda im, p: dot(im, [(5, 11), (5, 12)], (232, 220, 255))),
]

# 斧/弩/法杖/副手：按亮度三段切（pal = dark / main / bright）
AXES = [
    # 沉锚 —— 骨架陨星：深海钴刃 + 锈褐斧柄
    dict(id='anchor', cn='沉锚', skel='meteor',
         pal=dict(main=ramp(204, .58, 6, .18, .86), dark=ramp(24, .44, 5, .10, .44),
                  bright=ramp(28, .40, 4, .58, .92)),
         motif=lambda im, p: dot(im, [(10, 2), (11, 2)], (120, 200, 220))),
    # 断页 —— 骨架歌谣：纸白刃 + 墨黑柄 + 朱印红
    dict(id='broken_page', cn='断页', skel='ballad',
         pal=dict(main=ramp(46, .10, 6, .48, .99), dark=ramp(220, .12, 5, .04, .22),
                  bright=ramp(0, .62, 4, .40, .86))),
    # 丧铃 —— 骨架饮鸩：青铜锈刃 + 暗铁柄
    dict(id='death_bell', cn='丧铃', skel='draught',
         pal=dict(main=ramp(158, .34, 6, .18, .82), dark=ramp(215, .10, 5, .06, .30),
                  bright=ramp(46, .40, 4, .46, .90)),
         motif=lambda im, p: hbar(im, 3, 9, 11, p['bright'][-1])),
    # 重溟 —— 骨架苦痛：近墨深蓝刃 + 深渊青
    dict(id='deep_brine', cn='重溟', skel='agony',
         pal=dict(main=ramp(228, .54, 6, .08, .70), dark=ramp(238, .34, 5, .04, .22),
                  bright=ramp(184, .50, 4, .46, .92))),
    # 剜霜 —— 骨架天穹：冰青白刃 + 苍白柄
    dict(id='frost_carve', cn='剜霜', skel='skyvault',
         pal=dict(main=ramp(178, .28, 6, .34, .99), dark=ramp(200, .14, 5, .12, .50),
                  bright=ramp(186, .10, 4, .82, 1.0))),
]

CROSSBOWS = [
    # 退弦 —— 骨架骨蚀：冷钢灰（卸力后的素净）
    dict(id='backstring', cn='退弦', skel='bone_erode',
         pal=dict(main=ramp(210, .10, 6, .24, .94), dark=ramp(220, .10, 5, .10, .46),
                  bright=ramp(30, .18, 4, .52, .88))),
    # 黯日 —— 骨架霓虹：日蚀暗金（整体压暗，只有边缘发金光）
    dict(id='dark_sun', cn='黯日', skel='rainbow',
         pal=dict(main=ramp(48, .58, 6, .09, .58), dark=ramp(30, .40, 5, .04, .22),
                  bright=ramp(44, .70, 4, .70, .99))),
    # 烬弦 —— 骨架弧光：余烬橙红 + 焦黑木
    dict(id='ember_string', cn='烬弦', skel='arc',
         pal=dict(main=ramp(10, .74, 6, .22, .94), dark=ramp(18, .35, 5, .04, .26),
                  bright=ramp(34, .55, 4, .60, .96))),
    # 眠羽 —— 骨架幽响：羽白 + 淡紫金属
    dict(id='feather_sleep', cn='眠羽', skel='sculk_echo',
         pal=dict(main=ramp(280, .16, 6, .44, .99), dark=ramp(275, .18, 5, .16, .56),
                  bright=ramp(268, .34, 4, .70, 1.0))),
    # 逆弦 —— 骨架清梦：反过来的青绿
    dict(id='reverse_string', cn='逆弦', skel='lucid_dream',
         pal=dict(main=ramp(150, .50, 6, .16, .94), dark=ramp(160, .30, 5, .06, .32),
                  bright=ramp(96, .45, 4, .50, .92))),
]

STAFFS = [
    # 折径 —— 骨架苦酒：冷青杆 + 折光洋红宝珠
    dict(id='bent_ray', cn='折径', skel='staff_delusion',
         pal=dict(main=ramp(196, .32, 6, .20, .92), dark=ramp(205, .22, 5, .10, .46),
                  bright=ramp(330, .62, 4, .48, .96))),
    # 命缕 —— 骨架歌鸲：血红丝 + 暗金箍
    dict(id='fate_thread', cn='命缕', skel='staff_gu_poison',
         pal=dict(main=ramp(348, .55, 6, .18, .90), dark=ramp(350, .32, 5, .06, .28),
                  bright=ramp(48, .55, 4, .46, .94))),
    # 迟庭 —— 骨架梦呓：暮紫杆 + 旧金宝珠
    dict(id='late_court', cn='迟庭', skel='staff_delusion',
         pal=dict(main=ramp(288, .40, 6, .16, .88), dark=ramp(282, .26, 5, .07, .34),
                  bright=ramp(44, .56, 4, .50, .97))),
    # 长夜 —— 骨架坠梦：夜蓝近黑 + 星白
    dict(id='long_night', cn='长夜', skel='staff_fallen_dream',
         pal=dict(main=ramp(240, .50, 6, .08, .74), dark=ramp(242, .34, 5, .04, .22),
                  bright=ramp(210, .05, 4, .84, 1.0))),
    # 彼岸 —— 骨架暮色：黄泉青杆 + 彼岸花红宝珠
    dict(id='other_shore', cn='彼岸', skel='staff_twilight',
         pal=dict(main=ramp(162, .42, 6, .16, .88), dark=ramp(170, .26, 5, .07, .34),
                  bright=ramp(354, .64, 4, .48, .96))),
    # 续火 —— 骨架红莲：焰橙杆 + 金芯
    dict(id='renew_fire', cn='续火', skel='staff_begonia',
         pal=dict(main=ramp(26, .68, 6, .18, .96), dark=ramp(16, .40, 5, .05, .28),
                  bright=ramp(50, .62, 4, .58, .99))),
    # 引雷针 —— 骨架极光：雷紫杆 + 铁灰针尖
    dict(id='thunderrod', cn='引雷针', skel='staff_polarized_light',
         pal=dict(main=ramp(262, .58, 6, .16, .94), dark=ramp(252, .36, 5, .05, .28),
                  bright=ramp(204, .06, 4, .80, 1.0))),
    # 醒梦钟 —— 手绘钟形杖头（用户要求"设计成钟状"）：圆顶/收腰/外扩钟口 + 钟舌宝珠
    dict(id='wake_bell', cn='醒梦钟', draw=art_wake_bell,
         pal=dict(main=ramp(56, .50, 6, .18, .94), dark=ramp(42, .34, 5, .08, .34),
                  bright=ramp(272, .52, 4, .48, .96))),
]

TOOLS = [
    # ★ 三件副手全部手绘独立造型 —— 第一版拿包内现成的炽翎/苦寒/无效换色，
    #   轮廓像素级相同，玩家一眼看出"就换了个色"。物件类必须单独造型。
    # 殓丝 —— 挂环 + 束带 + 三缕垂丝（中长外短）末端打结
    dict(id='coffin_silk', cn='殓丝', draw=art_coffin_silk,
         pal=dict(main=ramp(64, .10, 6, .46, .99), dark=ramp(150, .36, 5, .10, .40),
                  bright=ramp(150, .40, 4, .40, .78))),
    # 冰鉴 —— 圆镜面 + 短柄（双像素斜高光、右下压暗做球面感）
    dict(id='frostmirror', cn='冰鉴', draw=art_frostmirror,
         pal=dict(main=ramp(198, .16, 6, .44, 1.0), dark=ramp(205, .22, 5, .12, .50),
                  bright=ramp(192, .30, 4, .72, 1.0))),
    # 回潮扣 —— 矩形带扣框 + 中间横销 + 左侧皮带 + 框内潮蓝宝石
    dict(id='tide_buckle', cn='回潮扣', draw=art_tide_buckle,
         pal=dict(main=ramp(176, .46, 6, .18, .92), dark=ramp(190, .28, 5, .08, .36),
                  bright=ramp(36, .50, 4, .46, .92))),
]

# 盔甲：id, 中文, 槽位, 图标骨架, 穿戴骨架, 色阶, 强调色
ARMOR = [
    dict(id='backlight', cn='返照', slot='helmet', icon='armor_brain_leech',
         worn='armor_brain_leech', pal=ramp(50, .22, 6, .30, .99), accent=(255, 236, 176)),
    dict(id='empty_pillow', cn='空枕', slot='helmet', icon='armor_dionysus_helmet',
         worn='armor_dionysus_helmet', pal=ramp(212, .10, 6, .34, .97), accent=(226, 236, 246)),
    dict(id='flint_hat', cn='燧帽', slot='helmet', icon='armor_iridescent',
         worn='armor_iridescent', pal=ramp(16, .46, 6, .16, .86), accent=(255, 158, 60)),
    dict(id='needle_sleep', cn='针眠', slot='helmet', icon='armor_spirit_sight',
         worn='armor_spirit_sight', pal=ramp(250, .48, 6, .10, .90), accent=(196, 208, 255)),
    dict(id='boil_trace', cn='沸痕', slot='chestplate', icon='armor_blaze_armor',
         worn='armor_blaze_armor', pal=ramp(6, .60, 6, .14, .90), accent=(255, 196, 120)),
    dict(id='char_coat', cn='焦衣', slot='chestplate', icon='armor_eternity',
         worn='armor_eternity', pal=ramp(40, .26, 6, .07, .62), accent=(212, 96, 32)),
    dict(id='condensed_shell', cn='凝壳', slot='chestplate', icon='armor_furnace_core',
         worn='armor_furnace_core', pal=ramp(168, .26, 6, .16, .88), accent=(224, 248, 240)),
    dict(id='crimson_seam', cn='绯缝', slot='chestplate', icon='armor_intravenous_pump',
         worn='armor_intravenous_pump', pal=ramp(340, .64, 6, .13, .90), accent=(255, 214, 120)),
    dict(id='last_breath', cn='归息', slot='chestplate', icon='armor_resonance',
         worn='armor_resonance', pal=ramp(150, .08, 6, .30, .96), accent=(180, 226, 210)),
    dict(id='tide_watch', cn='候潮', slot='chestplate', icon='armor_spine_symbiote',
         worn='armor_spine_symbiote', pal=ramp(194, .56, 6, .14, .92), accent=(214, 244, 255)),
    dict(id='beach_vein', cn='滩纹', slot='leggings', icon='armor_ember',
         worn='armor_ember', pal=ramp(40, .38, 6, .22, .95), accent=(150, 220, 226)),
    dict(id='gyre', cn='回旋', slot='leggings', icon='armor_external_power',
         worn='armor_external_power', pal=ramp(154, .50, 6, .12, .90), accent=(236, 252, 250)),
    dict(id='mirror_sleep', cn='镜寐', slot='leggings', icon='armor_fade',
         worn='armor_fade', pal=ramp(286, .24, 6, .18, .98), accent=(240, 232, 255)),
    dict(id='mottle_vein', cn='杂纹', slot='leggings', icon='armor_mirage',
         worn='armor_mirage', pal=ramp(320, .52, 6, .10, .80), accent=(128, 210, 96),
         specks=[(3, 4, (128, 210, 96)), (11, 6, (96, 190, 230)),
                 (6, 9, (240, 200, 90)), (12, 11, (200, 90, 120))]),
    dict(id='thorn_vein', cn='刺纹', slot='leggings', icon='armor_stellar_elegy',
         worn='armor_stellar_elegy', pal=ramp(108, .44, 6, .10, .78), accent=(196, 60, 56)),
    dict(id='candle_step', cn='烛跬', slot='boots', icon='armor_dusk_dawn',
         worn='armor_dusk_dawn', pal=ramp(44, .66, 6, .18, .96), accent=(255, 244, 190)),
    dict(id='cross_dream', cn='渡梦', slot='boots', icon='armor_flesh_mill',
         worn='armor_flesh_mill', pal=ramp(268, .52, 6, .14, .90), accent=(168, 206, 255)),
    dict(id='light_pillow', cn='轻枕', slot='boots', icon='armor_immolate',
         worn='armor_immolate', pal=ramp(350, .20, 6, .36, .99), accent=(255, 232, 224)),
    dict(id='rain_trace', cn='雨迹', slot='boots', icon='armor_lethe_shore',
         worn='armor_lethe_shore', pal=ramp(206, .46, 6, .14, .86), accent=(190, 232, 250)),
    dict(id='smoke_step', cn='烟履', slot='boots', icon='armor_lightless_sea',
         worn='armor_lightless_sea', pal=ramp(210, .05, 6, .07, .56), accent=(240, 244, 248)),
    dict(id='tread_ash', cn='踏灰', slot='boots', icon='armor_dusk_dawn',
         worn='armor_dusk_dawn', pal=ramp(30, .05, 6, .10, .64), accent=(255, 122, 46)),
]

# 槽位 -> 穿戴层目录
WORN_DIR = {'helmet': 'humanoid', 'chestplate': 'humanoid',
            'leggings': 'humanoid_leggings', 'boots': 'humanoid'}


def armor_motif(im, slot, accent, pal):
    """按槽位在固定 UV 区点一笔，让同骨架的两件也能一眼分开。"""
    if slot == 'helmet':
        hbar(im, 10, 11, 12, accent)          # 头盔额心宝石
        dot(im, [(11, 11), (12, 11)], accent)
    elif slot == 'chestplate':
        hbar(im, 22, 21, 26, accent)          # 胸口横带
        dot(im, [(23, 26), (24, 26)], accent)  # 腰饰
    elif slot == 'leggings':
        hbar(im, 25, 4, 7, accent)            # 膝甲
        hbar(im, 26, 4, 7, pal[0])
    else:
        hbar(im, 28, 4, 7, accent)            # 靴口
        dot(im, [(5, 31), (6, 31)], pal[0])


def draw_icon_armor(spec):
    """盔甲背包图标：套原版该部位图标的轮廓 + 单色阶 + 一点强调色。"""
    im = remap3(os.path.join(TEX_ITEM, spec['icon'] + '.png'),
                dict(main=spec['pal'], dark=spec['pal'][:3] + [tuple(
                    max(0, int(c * .55)) for c in spec['pal'][2])],
                     bright=spec['pal'][-2:]), d=0.30, b=0.80)
    xy = {'helmet': [(7, 3), (8, 3)], 'chestplate': [(7, 7), (8, 7)],
          'leggings': [(6, 10), (7, 10)], 'boots': [(5, 13), (6, 13)]}[spec['slot']]
    dot(im, xy, spec['accent'])
    for x, y, c in spec.get('specks') or []:   # 杂纹这类"本身就花"的件：多点异色斑
        dot(im, [(x, y)], c)
    return im


def draw_worn(spec):
    """64×32 穿戴层：全天候骨架换色 + 槽位 motif。"""
    d = WORN_DIR[spec['slot']]
    src = os.path.join(TEX_WORN, d, spec['worn'] + '.png')
    im = remap3(src, dict(main=spec['pal'],
                          dark=spec['pal'][:3] + [tuple(
                              max(0, int(c * .5)) for c in spec['pal'][1])],
                          bright=spec['pal'][-2:]), d=0.32, b=0.88)
    armor_motif(im, spec['slot'], spec['accent'], spec['pal'])
    return im


def save(im, path):
    d = os.path.dirname(path)
    if not os.path.isdir(d):
        os.makedirs(d)
    im.save(path)
    return os.path.relpath(path, ROOT)


# ============================================================ 防撞脸自检
def hue_report():
    """打印"同类内"主色 hue 的最小夹角（<18° 告警）。

    ★ 比较范围按玩家真正会放在一起挑的粒度给：剑/斧/弩/法杖/副手各成一组；
      盔甲**按槽位**分组（头盔比头盔、靴子比靴子）—— 跨槽位一件头一件靴，
      轮廓本来就不同，硬凑色相只会逼出难看的配色。
    """
    groups = {'剑': [(s['id'], s['pal']['blade']) for s in SWORDS],
              '斧': [(s['id'], s['pal']['main']) for s in AXES],
              '弩': [(s['id'], s['pal']['main']) for s in CROSSBOWS],
              '法杖': [(s['id'], s['pal']['main']) for s in STAFFS],
              '副手': [(s['id'], s['pal']['main']) for s in TOOLS]}
    for slot, cn in (('helmet', '头'), ('chestplate', '胸'),
                     ('leggings', '腿'), ('boots', '靴')):
        groups['甲·' + cn] = [(s['id'], s['pal']) for s in ARMOR if s['slot'] == slot]
    warn = 0
    for g, items in groups.items():
        rows = []
        neutral = 0
        for i in range(len(items)):
            for j in range(i + 1, len(items)):
                ha, sa, _ = hsv_of(items[i][1][3])
                hb, sb, _ = hsv_of(items[j][1][3])
                if min(sa, sb) < 0.12:      # 近中性色（灰/白/黑）色相没有意义，
                    neutral += 1             # 它们靠明度与槽位区分，不参与色相判定
                    continue
                dd = abs(ha - hb)
                dd = min(dd, 360 - dd)
                rows.append((dd, items[i][0], items[j][0]))
        rows.sort()
        worst = rows[0] if rows else (999, '-', '-')
        flag = '  << 撞色' if worst[0] < 18 else ''
        if worst[0] < 18:
            warn += 1
        print('  %-4s 最小色相夹角 %5.1f°  %s / %s%s   （中性配对 %d 组免判）'
              % (g, worst[0], worst[1], worst[2], flag, neutral))
    return warn


def main():
    made = []
    print('== 剑（材质分类）')
    for spec in SWORDS:
        im = remap_cls(os.path.join(TEX_ITEM, spec['skel'] + '.png'), spec['pal'])
        if spec.get('motif'):
            spec['motif'](im, spec['pal'])
        made.append(save(im, os.path.join(TEX_ITEM, spec['id'] + '.png')))
    print('== 斧（亮度三段）')
    for spec in AXES:
        im = remap3(os.path.join(TEX_ITEM, spec['skel'] + '.png'), spec['pal'])
        if spec.get('motif'):
            spec['motif'](im, spec['pal'])
        made.append(save(im, os.path.join(TEX_ITEM, spec['id'] + '.png')))
    print('== 法杖（亮度三段；醒梦钟手绘钟形）')
    for spec in STAFFS:
        im = spec['draw']() if spec.get('draw') else remap3(
            os.path.join(TEX_ITEM, spec['skel'] + '.png'), spec['pal'])
        if spec.get('motif'):
            spec['motif'](im, spec['pal'])
        made.append(save(im, os.path.join(TEX_ITEM, 'staff_' + spec['id'] + '.png')))
    print('== 副手（三件全部手绘独立造型，key 带 tool_）')
    for spec in TOOLS:
        im = spec['draw']() if spec.get('draw') else remap3(
            os.path.join(TEX_ITEM, spec['skel'] + '.png'), spec['pal'])
        if spec.get('motif'):
            spec['motif'](im, spec['pal'])
        made.append(save(im, os.path.join(TEX_ITEM, 'tool_' + spec['id'] + '.png')))
    print('== 弩（6 态）')
    for spec in CROSSBOWS:
        for st in CB_STATES:
            src = os.path.join(TEX_ITEM, 'crossbow_%s_%s.png' % (spec['skel'], st))
            if not os.path.exists(src):
                print('  !! 缺骨架', src)
                continue
            made.append(save(remap3(src, spec['pal']), os.path.join(
                TEX_ITEM, 'crossbow_%s_%s.png' % (spec['id'], st))))
    print('== 盔甲图标 + 穿戴层')
    for spec in ARMOR:
        made.append(save(draw_icon_armor(spec), os.path.join(
            TEX_ITEM, 'armor_' + spec['id'] + '.png')))
        made.append(save(draw_worn(spec), os.path.join(
            TEX_WORN, WORN_DIR[spec['slot']], 'armor_' + spec['id'] + '.png')))
    print('---- 共写 %d 张' % len(made))
    print('== 防撞脸自检')
    warn = hue_report()
    print('  撞色告警 %d 组' % warn)
    if '--preview' in sys.argv:
        showcase()


def showcase():
    """对照大图：按类别分行，每件放在一个"背包格子"里（最像游戏里挑东西的样子）。"""
    S = 8
    pad = 5
    cell = 16 * S
    slot = cell + pad * 2
    rows = [('剑', [(s['id'], s['cn']) for s in SWORDS]),
            ('斧', [(s['id'], s['cn']) for s in AXES]),
            ('弩', [('crossbow_%s_standby' % s['id'], s['cn']) for s in CROSSBOWS]),
            ('法杖', [('staff_' + s['id'], s['cn']) for s in STAFFS]),
            ('副手', [('tool_' + s['id'], s['cn']) for s in TOOLS]),
            ('头盔', [('armor_' + s['id'], s['cn']) for s in ARMOR if s['slot'] == 'helmet']),
            ('胸甲', [('armor_' + s['id'], s['cn']) for s in ARMOR if s['slot'] == 'chestplate']),
            ('护腿', [('armor_' + s['id'], s['cn']) for s in ARMOR if s['slot'] == 'leggings']),
            ('靴子', [('armor_' + s['id'], s['cn']) for s in ARMOR if s['slot'] == 'boots'])]
    cols = max(len(r[1]) for r in rows)
    W = cols * slot + pad
    H = len(rows) * slot + pad
    im = Image.new('RGB', (W, H), (26, 28, 33))
    px = im.load()
    for y in range(H):                     # 淡淡的纵向渐变，像游戏内的面板底色
        k = y / float(H - 1)
        c = (int(30 + 10 * k), int(33 + 11 * k), int(39 + 12 * k))
        for x in range(W):
            px[x, y] = c
    for r, (_cn, items) in enumerate(rows):
        for c, (n, _nm) in enumerate(items):
            x0 = pad + c * slot
            y0 = pad + r * slot
            # 格子底 + 1px 描边（模拟背包槽）
            for y in range(y0, y0 + slot - pad):
                for x in range(x0, x0 + slot - pad):
                    edge = (x in (x0, x0 + slot - pad - 1) or y in (y0, y0 + slot - pad - 1))
                    px[x, y] = (58, 62, 70) if edge else (44, 47, 54)
            p = os.path.join(TEX_ITEM, n + '.png')
            if not os.path.exists(p):
                continue
            s = open_rgba(p).resize((cell, cell), Image.NEAREST)
            im.paste(s, (x0 + pad, y0 + pad), s)
        # 行末画一条分隔线
        for x in range(pad, W - pad):
            px[x, y0 + slot - pad + 1] = (70, 74, 84)
    out = os.path.join(ROOT, '.workbuddy', '_late_showcase.png')
    im.save(out)
    print('  ->', out, im.size)


if __name__ == '__main__':
    main()
