# -*- coding: utf-8 -*-
"""给强化材料(6 升级石 + 1 超限石)画 2D 物品图标, 并挂到 recovery_compass 上

【为什么底座统一 recovery_compass】
  广义性质的"碎片"里, 只有它是**任何合成配方都不会吃到**的东西:
    - 下界之星 -> 信标
    - 锻造模板 -> 锻造台
    - 海晶碎片/砂粒/紫水晶/回响碎片 -> 各种方块合成
  追溯指针唯一的合成方向是"被造出来"(指南针+回响碎片), 不会被当原料吃掉。

【代价】底座一样 => 必须靠 custom_model_data 换模型, 否则 7 块石头一模一样。
【怎么挂】重写 assets/minecraft/items/recovery_compass.json:
    外层   range_dispatch(minecraft:custom_model_data, index 0)
    fallback = 原版那一整套 compass range_dispatch(32 帧指针动画)
  ★ fallback 必须是原版整棵子树, 不能只写 models/item/recovery_compass,
    否则观测镜(它就是没 cmd 的 recovery_compass)的指针动画会被干掉。
  ★ entries 的 threshold 必须从 1 起步: 没有 cmd 的物品取值 0,
    给 threshold 0 就会把原版指针顶掉。

【画法】纯标准库手绘点阵, 不依赖 PIL。
【重跑】python .workbuddy/_gen_stone_icons.py
"""
import io, os, json, math, struct, zlib

HERE = os.path.dirname(os.path.abspath(__file__))
RP = "D:/数据包/sweetdream_rp/assets"
# 原版定义已固化进项目(.workbuddy/vanilla/), 免得每次重跑都要去翻 jar。
# 来源: 1.21.5 jar 的 assets/minecraft/items/recovery_compass.json
ORIG = HERE + "/vanilla/recovery_compass.json"


# ---------------------------------------------------------------- PNG
def write_png(path, w, h, rows):
    """rows: h 行, 每行 w 个 (r,g,b,a)"""
    raw = bytearray()
    for r in rows:
        raw.append(0)
        for (rr, gg, bb, aa) in r:
            raw += bytes((rr, gg, bb, aa))
    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "wb").write(png)


def rgba(px, x, y, c, a=255):
    px[y][x] = (c[0], c[1], c[2], a)


# ---------------------------------------------------------------- 字形 (7x7)
GLYPH = {
    "a": [
        ".......",
        "..###..",
        ".#...#.",
        ".###.#.",
        ".#...#.",
        ".#..##.",
        ".#####.",
    ],
    "b": [
        "###....",
        "#..#...",
        "#..#..#",
        "####..#",
        "#..#..#",
        "#..#..#",
        "####...",
    ],
    "o": [
        ".#####.",
        "#.....#",
        "#.....#",
        "#..#..#",
        "#.....#",
        "##...##",
        ".#####.",
    ],
}


def draw_glyph(px, glyph, cx, cy, col):
    art = GLYPH[glyph]
    for gy in range(7):
        for gx in range(7):
            if art[gy][gx] != "#":
                continue
            rgba(px, cx - 3 + gx, cy - 3 + gy, col)


# ---------------------------------------------------------------- 各层
def disc(px, main, dark, lite):
    """形状①▪圆盘(魔力提升系列): 外描边 + 左上亮右下暗"""
    for y in range(16):
        for x in range(16):
            d = math.hypot(x + 0.5 - 8.0, y + 0.5 - 8.0)
            if d > 7.4:
                continue                      # 盘外留白(透明)
            if d > 6.1:
                rgba(px, x, y, dark)          # 深色描边
                continue
            t = ((x + y) / 30.0) * 0.55 + (d / 7.0) * 0.45
            rgba(px, x, y, tuple(int(main[i] + (dark[i] - main[i]) * t) for i in range(3)))
    for (x, y) in ((5, 4), (6, 4), (5, 5), (4, 6), (4, 7)):
        rgba(px, x, y, lite)


def rhombus(px, main, dark, lite):
    """形状②◆菱形(魔力增殖系列): |dx|+|dy| 判据, 让"系列"一眼可辨"""
    for y in range(16):
        for x in range(16):
            dx, dy = abs(x + 0.5 - 8.0), abs(y + 0.5 - 8.0)
            s = dx + dy
            if s > 7.4:
                continue
            if s > 6.3:
                rgba(px, x, y, dark)
                continue
            t = (dx / 7.0) * 0.6 + (s / 7.4) * 0.4
            rgba(px, x, y, tuple(int(main[i] + (dark[i] - main[i]) * t) for i in range(3)))
    for (x, y) in ((6, 4), (7, 4), (6, 5), (5, 6), (5, 7)):
        rgba(px, x, y, lite)


def ring_dots(px, n, col):
    """等级环: 盘外的点。α=0, β=4"""
    if n == 0:
        return
    import math as m
    for k in range(n):
        a = -m.pi / 4 + k * (2 * m.pi / n)
        x = int(round(8.0 + 6.7 * m.cos(a)))
        y = int(round(8.0 + 6.7 * m.sin(a)))
        if 0 <= x < 16 and 0 <= y < 16:
            rgba(px, x, y, col)


def tier_ring(px, col):
    """Ω 专属: 紧贴轮廓的一圈完整亮环(和 β 的散点区分开)"""
    for y in range(16):
        for x in range(16):
            dx, dy = x + 0.5 - 8.0, y + 0.5 - 8.0
            d = math.hypot(dx, dy)
            if 6.5 < d < 7.35:
                rgba(px, x, y, col)


def tier_rhombus_edge(px, col):
    """Ω 专属: 菱形外的一圈完整亮边"""
    for y in range(16):
        for x in range(16):
            dx, dy = abs(x + 0.5 - 8.0), abs(y + 0.5 - 8.0)
            s = dx + dy
            if 6.6 < s < 7.35:
                rgba(px, x, y, col)


def ring_dots_rhombus(px, n, col):
    """β 专属(菱形版): 四角散点"""
    import math as m
    for k in range(n):
        a = m.pi / 4 + k * (2 * m.pi / n)
        x = int(round(8.0 + 7.1 * m.cos(a)))
        y = int(round(8.0 + 7.1 * m.sin(a)))
        if 0 <= x < 16 and 0 <= y < 16:
            rgba(px, x, y, col)


def star(px, main, dark, lite):
    """形状③★八芒星(超限系列): 和普通升级明确区分"""
    for y in range(16):
        for x in range(16):
            dx, dy = x + 0.5 - 8.0, y + 0.5 - 8.0
            d = math.hypot(dx, dy)
            if d > 7.2:
                continue
            a = math.atan2(dy, dx)
            # 八芒: cos(4a) 取峰 -> 4 长芒; 再叠一个小半径核
            reach = 3.0 + 3.5 * abs(math.cos(a * 2.0)) ** 0.55
            if d > reach + 0.9:
                continue
            if d > reach:
                rgba(px, x, y, dark)
                continue
            t = d / 7.6
            rgba(px, x, y, tuple(int(main[i] + (lite[i] - main[i]) * max(0.0, 0.55 - t)) for i in range(3)))
    for (x, y) in ((7, 6), (8, 6), (7, 7), (8, 7)):
        rgba(px, x, y, lite)


# ---------------------------------------------------------------- 第二批形状 (冷却剂/硬化/魔力沸涌/愿景)
# 【为什么再加 4 个轮廓】前 6 块只用了 圆盘 / 菱形 两种; 再加 4 个系列还沿用它们,
#   玩家根本分不清是哪条线 —— 轮廓 = "这是哪一系列", 与中心的字母(α/β/Ω)、
#   四角点(β) 各管一件事, 三者叠加才唯一确定一块石头。
# 【画法约定】填色类形状走 fill_shape(): 内部 main 做渐变、最外 1 px 描 dark;
#   装饰一律**避开中心 7x7**(那里是白色字母, 画了也看不见) -> 只放四角/边缘。
def fill_shape(px, inside, cols):
    """inside(u, v) -> bool; u/v 是相对中心(8,8)的像素中心偏移"""
    main, dark, lite = cols
    for y in range(16):
        for x in range(16):
            u, v = x + 0.5 - 8.0, y + 0.5 - 8.0
            if not inside(u, v):
                continue
            border = not (inside(u + 1, v) and inside(u - 1, v)
                          and inside(u, v + 1) and inside(u, v - 1))
            if border:
                rgba(px, x, y, dark)
            else:
                t = ((u + v) / 30.0) * 0.55 + (math.hypot(u, v) / 8.0) * 0.45
                rgba(px, x, y, tuple(int(main[i] + (dark[i] - main[i]) * t)
                                     for i in range(3)))


def pdot(px, xf, yf, r, col):
    """按浮点圆心画一个小圆(给细装饰用, 不描边)"""
    for y in range(16):
        for x in range(16):
            if math.hypot(x + 0.5 - xf, y + 0.5 - yf) <= r:
                rgba(px, x, y, col)


def snowflake(px, main, dark, lite):
    """形状④❄雪花(冷却剂系列): 6 条主枝 + 每枝两对分叉。
    ★ 一开始用的是"平顶正六边形", 但 16x16 下六边形和圆盘轮廓几乎看不出区别
      (R=7 时宽 14 / 高 12.1, 太接近 1:1) —— 换成线画雪花, 系列归属一眼可辨。
    ★ 细线形状的配色: 外圈 dark 描边 + 内芯 main + 枝端 lite 亮点。"""
    R = 7.2

    def seg(x0, y0, x1, y1, r, col):
        n = int(math.hypot(x1 - x0, y1 - y0) * 4) + 1
        for i in range(n + 1):
            t = i / float(n)
            pdot(px, x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, r, col)

    for k in range(6):
        a = k * math.pi / 3
        ca, sa = math.cos(a), math.sin(a)
        ex, ey = 8.0 + ca * R, 8.0 + sa * R
        seg(8.0, 8.0, ex, ey, 1.15, dark)             # 主枝(描边)
        seg(8.0, 8.0, ex, ey, 0.60, main)             # 主枝(芯)
        for f in (0.46, 0.74):                        # 每枝两对分叉
            bx, by = 8.0 + ca * R * f, 8.0 + sa * R * f
            for sgn in (1, -1):
                ang = sgn * math.pi / 3
                dx, dy = (ca * math.cos(ang) - sa * math.sin(ang)) * 2.3, \
                         (ca * math.sin(ang) + sa * math.cos(ang)) * 2.3
                seg(bx, by, bx + dx, by + dy, 1.05, dark)
                seg(bx, by, bx + dx, by + dy, 0.52, main)
        pdot(px, ex, ey, 1.2, lite)                   # 枝端亮点
    pdot(px, 8.0, 8.0, 2.3, dark)                     # 中心核
    pdot(px, 8.0, 8.0, 1.4, main)


def shield(px, main, dark, lite):
    """形状⑤🛡盾形(硬化系列): 上宽下收成尖 + 顶角两枚铆钉"""
    def inside(u, v):
        if abs(v) > 7.2:
            return False
        if v <= -1.0:                                 # 上半: 圆角矩形
            if abs(u) > 6.2:
                return False
            if v < -5.6 and abs(u) > 3.4 + (-5.6 - v) * 1.7:
                return False                          # 顶部两角斜切
            return True
        f = math.sqrt(max(0.0, 1.0 - (v / 7.4) ** 2))  # 下半: 收成尖
        return abs(u) <= 6.2 * f

    fill_shape(px, inside, (main, dark, lite))
    for (u, v) in ((-4.2, -4.0), (4.2, -4.0)):        # 铆钉(避开中央字母)
        pdot(px, 8.0 + u, 8.0 + v, 0.8, lite)


def droplet(px, main, dark, lite):
    """形状⑥💧液滴(魔力沸涌系列): 圆底 + 尖顶 + 两枚气泡 + 左上高光"""
    def inside(u, v):
        if math.hypot(u, v - 2.0) <= 4.6:             # 圆底
            return True
        if -7.2 <= v <= 2.0:                          # 尖顶(向下张开的三角)
            return abs(u) <= 4.6 * (v + 7.2) / 9.2
        return False

    fill_shape(px, inside, (main, dark, lite))
    pdot(px, 5.4, 11.6, 0.85, lite)                   # 气泡(字母下方)
    pdot(px, 10.6, 10.6, 0.6, lite)
    pdot(px, 4.9, 7.2, 0.8, lite)                     # 圈内左上高光(必须落在圆底内!)
    # ★ 别把高光放到尖顶那一侧: v=-4.8 时三角半宽只有 1.2px, r=0.9 的圆点会整颗飘在形状外。


def eye(px, main, dark, lite):
    """形状⑦👁眼形(愿景系列): 两段圆弧相交出的杏核 + 左右尖角微光"""
    R, o = 7.8, 4.3                                  # 杏核: 高 7 / 宽 13

    def inside(u, v):
        s = R * R - u * u
        if s <= 0:
            return False
        s = math.sqrt(s)
        return s >= o and (o - s) <= v <= (s - o)

    fill_shape(px, inside, (main, dark, lite))
    pdot(px, 2.9, 8.0, 0.8, lite)                     # 左右尖角
    pdot(px, 13.1, 8.0, 0.8, lite)


def hollow(px, main, dark, lite):
    """形状⑦◎空心环(无色石): 外环实、中心**全空** —— "把升级抠掉"的意象。
    灰白色, 没有字形/等级点(不在 α/β/Ω 链里)。"""
    for y in range(16):
        for x in range(16):
            d = math.hypot(x + 0.5 - 8.0, y + 0.5 - 8.0)
            if d > 7.4:
                continue                      # 环外留白(透明)
            if d > 6.1:
                rgba(px, x, y, dark)          # 深色描边
                continue
            if d < 3.4:
                continue                      # 中心掏空(透明)
            t = ((x + y) / 30.0) * 0.5 + (d / 7.0) * 0.5
            rgba(px, x, y, tuple(int(main[i] + (dark[i] - main[i]) * t) for i in range(3)))
    for (x, y) in ((5, 4), (6, 4), (4, 6), (4, 7)):
        rgba(px, x, y, lite)


def flame(px, main, dark, lite):
    """形状⑧🔥火苗(火炬): 圆底 + 顶端向右摇曳的尖 —— 和"液滴(魔力沸涌)"区分开。
    ★ 液滴是**对称**尖顶、整体偏下坠; 火苗的尖顶随高度**向右偏**, 一眼能分。"""
    def inside(u, v):
        if math.hypot(u, v - 2.2) <= 4.5:             # 圆底
            return True
        if -7.4 <= v <= 2.2:                          # 尖顶(向上收, 并向右摇)
            t = (2.2 - v) / 9.6
            half = 4.5 * (1.0 - t) ** 0.85
            cx = 1.6 * t * t
            return abs(u - cx) <= half
        return False

    fill_shape(px, inside, (main, dark, lite))
    pdot(px, 6.6, 11.4, 1.0, lite)                    # 火心(偏左下, 避开中央字母)
    pdot(px, 4.8, 6.6, 0.7, lite)                     # 圈内左上高光


def bubble(px, main, dark, lite):
    """形状⑨🫧气泡(沸腾): 满圆 + 三枚空心小泡 —— "又冷又热、咕嘟冒泡"的意象。
    ★ 气泡必须整个落在圆内(最远 2.6+1.5=4.1 < 6.6), 否则会飘到形状外面。"""
    def inside(u, v):
        return math.hypot(u, v) <= 6.6

    fill_shape(px, inside, (main, dark, lite))
    for (bx, by, r) in ((-2.8, 2.6, 1.5), (2.4, 0.4, 1.1), (0.2, -3.0, 1.3)):
        for y in range(16):
            for x in range(16):
                d = math.hypot(x + 0.5 - 8.0 - bx, y + 0.5 - 8.0 - by)
                if abs(d - r) < 0.55:                 # 细环(描一圈气泡壁)
                    rgba(px, x, y, lite)


SHAPES = {"snowflake": snowflake, "shield": shield, "droplet": droplet, "eye": eye,
          "hollow": hollow, "flame": flame, "bubble": bubble}


# ---------------------------------------------------------------- 定义
# 【编号表】CMD = custom_model_data.floats[0] 的值, 必须与
#   ① 资源包 assets/minecraft/items/recovery_compass.json 的 entries
#   ② 各 give 里的 floats:[N.0f]
#   三处逐字一致(改一边要改两边)。已占: 1..6 升级石 / 7 流光 / 8..21 = 本批 14 块。
SPEC = [
    #  id,           字形, 形状,     主色,              暗色,            亮色,            等级点
    ("mana_up_a",   "a", "disc",   (150,  96, 214), ( 62,  36, 104), (206, 176, 248), 0),
    ("mana_up_b",   "b", "disc",   (128,  76, 200), ( 50,  28,  88), (192, 158, 244), 4),
    ("mana_up_o",   "o", "disc",   (206, 108, 232), ( 88,  36, 110), (240, 200, 255), 8),
    ("mana_gain_a", "a", "rhombus",( 72, 170, 168), ( 24,  76,  78), (160, 232, 230), 0),
    ("mana_gain_b", "b", "rhombus",( 56, 146, 146), ( 18,  62,  64), (146, 222, 220), 4),
    ("mana_gain_o", "o", "rhombus",(104, 214, 206), ( 28,  96,  94), (198, 255, 250), 8),
    # ---- 第二批(2026-10-06): 4 个新系列 × α/β/Ω ----
    # 冷却剂(武器主动技能冷却 -5/-10/-20%) -> 冰蓝 + 雪花
    ("coolant_a",   "a", "snowflake",(108, 170, 225), ( 34,  68, 112), (196, 232, 255), 0),
    ("coolant_b",   "b", "snowflake",( 86, 150, 215), ( 26,  54, 100), (178, 222, 255), 4),
    ("coolant_o",   "o", "snowflake",(150, 205, 248), ( 58, 110, 168), (232, 248, 255), 8),
    # 硬化(护甲值 +2/+4/+6...) -> 钢银 + 盾形
    ("harden_a",    "a", "shield", (168, 176, 188), ( 72,  78,  90), (236, 242, 250), 0),
    ("harden_b",    "b", "shield", (146, 156, 172), ( 60,  66,  78), (226, 234, 244), 4),
    ("harden_o",    "o", "shield", (196, 206, 220), ( 96, 104, 118), (248, 252, 255), 8),
    # 魔力沸涌(低魔时冷却缩短) -> 朱红 + 液滴
    ("mana_surge_a","a", "droplet",(222,  74,  68), (112,  26,  24), (255, 190, 180), 0),
    ("mana_surge_b","b", "droplet",(206,  60,  56), (100,  20,  18), (255, 178, 168), 4),
    ("mana_surge_o","o", "droplet",(240, 110,  98), (140,  40,  34), (255, 214, 205), 8),
    # 愿景(技能伤害 +10/+20/+30%) -> 金瞳 + 眼形
    ("vision_a",    "a", "eye",    (216, 182,  84), (108,  80,  20), (255, 244, 196), 0),
    ("vision_b",    "b", "eye",    (200, 166,  68), ( 96,  70,  16), (255, 238, 180), 4),
    ("vision_o",    "o", "eye",    (238, 208, 116), (132, 100,  32), (255, 250, 220), 8),
    # ---- 特殊石头(不在 α/β/Ω 链里, 定义表无条目) ----
    # 无色石(2026-10-07): 消除最近敲入的一个升级并返还该等级石头 -> 空心环灰白
    ("uncolor",     "",  "hollow", (212, 214, 220), ( 96, 100, 112), (255, 255, 255), 0),
    # ---- 最后一批(2026-10-08) ----
    # 火炬(流火 -> 夜火, 10%) -> 橙金火苗
    ("torch",       "",  "flame",  (252, 148,  44), (130,  52,   8), (255, 226, 170), 0),
    # 沸腾(冻结+燃烧 追加真实伤害) -> 青蓝气泡(和"火苗"冷热对仗)
    ("boil",        "",  "bubble", ( 86, 196, 214), ( 20,  74,  92), (206, 246, 255), 0),
    # 夜视仪(头盔专属, 常驻夜视) -> 亮黄盾形(头盔感 + 视野)
    ("night_vision","",  "shield", (238, 214,  92), (108,  84,  16), (255, 250, 196), 0),
    # 生命提升(盔甲) α -> β -> Ω: 最大生命 +2 / +6 / +10(Ω 附常态再生Ⅰ)
    ("life_up_a",   "a", "disc",   (214,  84,  86), ( 92,  26,  28), (252, 186, 188), 0),
    ("life_up_b",   "b", "disc",   (196,  68,  70), ( 80,  20,  22), (246, 168, 170), 4),
    ("life_up_o",   "o", "disc",   (238, 108, 104), (110,  34,  34), (255, 208, 206), 8),
]

# 超限石(八芒星, 与升级石区分): (id, 主色, 暗色, 亮色)
OL_SPEC = [
    ("liuguang",       (255, 168,  72), (168,  52,  20), (255, 244, 200)),   # 流光(橙)
    ("brain_leech",    (206,  62, 110), ( 86,  16,  44), (255, 186, 214)),   # 脑髓蛭(绯红·蛊虫)
    ("spine_symbiote", (150, 196, 206), ( 48,  84,  96), (222, 248, 252)),   # 脊骨共生(骨青)
    # ---- 最后一批(2026-10-08) ----
    ("myriad",         (196,  52,  62), ( 88,  12,  18), (255, 176, 176)),   # 万念/千散(赤刃)
    ("stellar_elegy",  ( 96, 132, 248), ( 24,  40, 108), (200, 220, 255)),   # 群星坠落之挽歌(星蓝)
    ("dusk_dawn",      (252, 200,  76), (132,  84,  12), (255, 244, 208)),   # 黄昏黎明之交界(暮金)
    # ---- 批 E1(2026-10-08): 超限·剑 ----
    ("rogue_star",     (128, 220, 255), ( 20,  72, 120), (226, 248, 255)),   # 游星(星屑青)
    ("shadow_blade",   ( 88,  76, 120), ( 24,  18,  40), (206, 196, 255)),   # 影刃(暗影紫)
    ("deepsea_echo",   ( 40, 132, 208), (  8,  36,  84), (200, 234, 255)),   # 深海的回响(深海蓝)
    # ---- 批 E2(2026-10-08): 超限·剑 ----
    ("everfrost",         (150, 226, 255), ( 16,  76, 128), (232, 250, 255)),   # 永霜(寒霜蓝白)
    ("flame_brokenbody",  (255,  96,  40), (140,  32,   8), (255, 216, 180)),   # 烈火残躯(炽焰橙)
    ("sickle_dreams",     (176, 120, 236), ( 60,  24, 108), (236, 214, 255)),   # 引梦镰(梦魇紫)
    ("hengdao",           (226, 214, 176), ( 96,  84,  56), (255, 250, 232)),   # 横刀(刃锋米白)
    # ---- 批 F1(2026-10-09): 超限·斧 ----
    ("red_lotus",         (255,  96,  64), (128,  24,   8), (255, 210, 186)),   # 红莲(赤莲橙)
    ("charge",            (110, 130, 255), ( 32,  40, 128), (224, 230, 255)),   # 超•负•荷(靛电蓝)
    ("anion",             ( 80, 224, 214), ( 16,  88,  90), (214, 255, 250)),   # 负离子(电浆青)
    # ---- 批 F2(2026-10-10): 超限·斧弩 ----
    ("cold_crow",         (128, 216, 240), ( 28,  84, 112), (232, 252, 255)),   # 寒鸦(霜羽青)
    ("bone_erode",        (188, 196, 168), ( 60,  66,  50), (240, 246, 222)),   # 蚀骨(骨屑苔灰)
    ("sculk_echo",        ( 72, 168, 156), ( 16,  62,  58), (206, 246, 240)),   # 幽匿残响(幽匿青)
    ("dream_reader",      (246, 232, 198), (110,  92,  60), (255, 252, 238)),   # 释梦(白昼梦暖白金)
    # ---- 批 G/H(2026-10-10): 超限·法杖/盔甲 ----
    ("begonia",           (244, 148, 190), (110,  30,  70), (255, 226, 240)),   # 海棠(海棠粉)
    ("polarized_light",   (226, 238, 255), ( 60,  80, 120), (255, 255, 255)),   # 偏振光(极化白)
    ("dionysus_helmet",   (212, 132, 232), ( 70,  26,  96), (250, 216, 255)),   # 狄俄尼索斯之桂冠(酒神葡萄紫)
    ("furnace_core",      (255, 118,  52), (120,  30,   8), (255, 214, 178)),   # 炉心(炉火橙)
]

GLYPH_OF = {"mana_up_a": "a", "mana_up_b": "b", "mana_up_o": "o",
            "mana_gain_a": "a", "mana_gain_b": "b", "mana_gain_o": "o"}

CMD = {"mana_up_a": 1, "mana_up_b": 2, "mana_up_o": 3,
       "mana_gain_a": 4, "mana_gain_b": 5, "mana_gain_o": 6,
       "liuguang": 7, "ol_liuguang": 7,
       "coolant_a": 8, "coolant_b": 9, "coolant_o": 10,
       "harden_a": 11, "harden_b": 12, "harden_o": 13,
       "mana_surge_a": 14, "mana_surge_b": 15, "mana_surge_o": 16,
       "vision_a": 17, "vision_b": 18, "vision_o": 19,
       "ol_brain_leech": 20, "ol_spine_symbiote": 21,
       "uncolor": 22,
       # 最后一批(2026-10-08): 6 升级石 + 3 超限石
       "torch": 23, "boil": 24, "night_vision": 25,
       "life_up_a": 26, "life_up_b": 27, "life_up_o": 28,
       "ol_myriad": 29, "ol_stellar_elegy": 30, "ol_dusk_dawn": 31,
       "ol_rogue_star": 32, "ol_shadow_blade": 33, "ol_deepsea_echo": 34,
       "ol_everfrost": 35, "ol_flame_brokenbody": 36,
       "ol_sickle_dreams": 37, "ol_hengdao": 38,
       # 批 F1(2026-10-09): 超限·斧
       "ol_red_lotus": 39, "ol_charge": 40, "ol_anion": 41,
       # 批 F2(2026-10-10): 超限·斧弩
       "ol_cold_crow": 42, "ol_bone_erode": 43, "ol_sculk_echo": 44, "ol_dream_reader": 45,
       # 批 G/H(2026-10-10): 超限·法杖/盔甲
       "ol_begonia": 46, "ol_polarized_light": 47,
       "ol_dionysus_helmet": 48, "ol_furnace_core": 49}


def new_px():
    return [[(0, 0, 0, 0)] * 16 for _ in range(16)]


def build(shape, glyph, main, dark, lite, dots):
    """shape: disc(提升) / rhombus(增殖) / hexagon / shield / droplet / eye / star(超限);
    dots: 0=α 4=β 8=Ω(Ω 的描边沿用前 6 块的写法: 先画再被填充盖住 -> Ω 实际靠
    "更亮的配色 + 字母 o + 无四角点" 区分, 与前 6 块保持完全一致的视觉语言)"""
    px = new_px()
    if shape == "star":
        star(px, main, dark, lite)
        return px
    if shape == "disc":
        if dots == 8:
            tier_ring(px, lite)
        disc(px, main, dark, lite)
        if dots == 4:
            ring_dots(px, 4, lite)
    elif shape == "rhombus":
        if dots == 8:
            tier_rhombus_edge(px, lite)
        rhombus(px, main, dark, lite)
        if dots == 4:
            ring_dots_rhombus(px, 4, lite)
    else:                                             # 第二批的 4 个轮廓
        SHAPES[shape](px, main, dark, lite)
        if dots == 4:
            ring_dots_rhombus(px, 4, lite)
    if glyph:
        draw_glyph(px, glyph, 7, 8, (255, 255, 255))
    return px


def model_json(uid):
    return ('{\n  "parent": "minecraft:item/generated",\n'
            '  "textures": {\n    "layer0": "sweetdream:item/stone/%s"\n  }\n}\n' % uid)


# ---------------------------------------------------------------- 输出
out_px = []
for (uid, glyph, shape, main, dark, lite, dots) in SPEC:
    px = build(shape, glyph, main, dark, lite, dots)
    write_png("%s/sweetdream/textures/item/stone/%s.png" % (RP, uid), 16, 16, px)
    mp = "%s/sweetdream/models/item/stone/%s.json" % (RP, uid)
    os.makedirs(os.path.dirname(mp), exist_ok=True)
    io.open(mp, "w", encoding="utf-8").write(model_json(uid))
    out_px.append((uid, px))

# ★ 2026-10-10 起 24 颗超限石贴图改由 .workbuddy/draw_overlimit_stone_redraw.py
#   手绘维护（晶石切面 + 主题刻纹），重跑本生成器**不得覆盖** ol_*.png ——
#   这里只写模型 JSON 与 recovery_compass 路由（CMD 映射不变）。
for (uid, main, dark, lite) in OL_SPEC:
    px = build("star", "", main, dark, lite, 0)
    mp = "%s/sweetdream/models/item/stone/ol_%s.json" % (RP, uid)
    os.makedirs(os.path.dirname(mp), exist_ok=True)
    io.open(mp, "w", encoding="utf-8").write(model_json("ol_" + uid))
    out_px.append(("ol_" + uid, px))

# ---- recovery_compass: 外层挂 custom_model_data, fallback = 原版整棵 ----
vanilla = json.load(io.open(ORIG, encoding="utf-8"))
entries = []
for name, _ in out_px:
    entries.append({"threshold": float(CMD[name]),
                    "model": {"type": "minecraft:model",
                              "model": "sweetdream:item/stone/%s" % name}})
entries.sort(key=lambda e: e["threshold"])
doc = {"hand_animation_on_swap": False,   # 见文件头: 免得将来有人把它改成动态时要重新排查
       "model": {"type": "minecraft:range_dispatch",
                 "property": "minecraft:custom_model_data",
                 "index": 0,
                 "fallback": vanilla["model"],
                 "entries": entries}}
d = "%s/minecraft/items" % RP
os.makedirs(d, exist_ok=True)
io.open(d + "/recovery_compass.json", "w", encoding="utf-8").write(
    json.dumps(doc, indent=2, ensure_ascii=False) + "\n")

print("icons:", len(out_px), "->", ", ".join(n for n, _ in out_px))
print("cmd 映射:", CMD)
