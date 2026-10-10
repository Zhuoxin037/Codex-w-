# -*- coding: utf-8 -*-
"""
build_vanilla_ex.py —— 「原版风 · 技能版」图标试作（剑类，2 件）

第一代（build_vanilla_icons.py）= 原版轮廓 + 本武器配色，形状 100% 照抄。
本代 = 在它之上加一层「按技能/名字设计的像素纹样」，并允许极少量轮廓级改动。

设计依据（读自 give.mcfunction 的技能原文，非臆造）：
  · 深海的回响：被动水下呼吸Ⅰ；主动标记 12 格内最近生物附「渊海」→ 1 秒后对其 3 格内
    生物造成 当前魔力×0.15 → 连锁重复 2 次（每次耗 110 魔力）。
    意象 = 深水 · 一圈圈扩散、越远越弱的回响 · 渊海之珠。
    → 刃身做「横向水波」（波纹垂直于剑身轴线，沿刃长每 3px 一道，符合"水在流"），
      护手两端上翘成浪尖，剑首镶珠，剑尖挂水光。
  · 烈火，残躯：前方 5×3 造成 最大魔力×0.1；命中「夜火」→ 冷却立即结束 + 每个积 1 层
    「熔浆」；熔浆 ≥4 层 → 两段 5×3 + 自身 6 格内 最大魔力×0.2，然后清空。
    意象 = 崩缺的剑身 · 裂缝里渗出的熔浆 · 余烬。
    → 刃缘咬掉两块（残躯），裂缝沿刃由尖向柄渐冷（#FFE8A8→#8C2408，像熔浆往下淌），
      剑尖缺一角，护手积一点熔浆。

两档力度（给用户选方向）：
  A 克制：轮廓一个像素不动（透明掩码与纯换色版完全一致）。
  B 表达：额外允许刃口崩缺 / 护手浪尖等轮廓改动。

输出：模型设计/原版风_资源包_20261010/剑_预览/
"""
import os
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_icons import (build, region_sword, region_sword_neth,
                                 RAMP_DEEPSEA, ACC_DEEPSEA, RAMP_FLAME, ACC_FLAME,
                                 REF, up, txt)
from PIL import Image, ImageDraw

OUT = r'D:\数据包\模型设计\原版风_资源包_20261010\剑_预览'
os.makedirs(OUT, exist_ok=True)


def at(pts, color):
    s = set(pts)
    return (lambda x, y, r, t, e: (x, y) in s, color)


def rowrule(mod, rem, color, region='blade'):
    return (lambda x, y, r, t, e: r == region and x % mod == rem, color)


# ============================================================ 深海的回响
# 试过并放弃：刃身横纹（45° 斜刃上任何 x%n 都退化成阶梯噪声）、刃缘隔行粼光（把剑弄花）。
# 定稿思路：垂直的「水线」切过斜刃 = 把剑身分成三段，正对技能的「连锁重复 2 次 = 三段伤害」。
DEEP_A = [
    (lambda x, y, r, t, e: r == 'blade' and x == 11, '#C8F4FC'),  # 第二道水线
    (lambda x, y, r, t, e: r == 'blade' and x == 6, '#9FE8F6'),   # 第一道水线（靠护手）
    at([(4, 9)], '#F4FEFF'),           # 渊海之珠（镶在护手中心）
    at([(15, 0)], '#D8F6FF'),          # 剑尖水光
]
DEEP_B = DEEP_A + [
    at([(2, 6), (2, 7)], '#8FDCEE'),  # 护手两端上翘成浪尖
    at([(8, 12)], '#86E4F4'),         # 剑柄旁那枚原版孤立点 → 第一圈涟漪
    at([(3, 12)], '#7FE0F0'),         # 柄上一颗上浮的气泡
]
# B 版另在轮廓外补一枚余波像素（build 之后再画）
DEEP_B_EXTRA_PX = [((5, 12), (111, 216, 236, 255))]

# ============================================================ 烈火，残躯
# 裂缝沿刃中由尖向柄渐冷：#FFE8A8 → #5C1604（熔浆正在往下淌、越远越冷）
FLAME_A = [
    at([(15, 0)], '#FFC24A'),   # 剑尖（最先烧起来）
    at([(13, 2)], '#FFE8A8'),
    at([(12, 3)], '#FFB03C'),
    at([(11, 4)], '#FF8A20'),
    at([(10, 5)], '#F0540C'),
    at([(9, 6)], '#C03808'),
    at([(8, 7)], '#8C2408'),
    at([(7, 9)], '#5C1604'),    # 最冷（贴近护手）
    at([(4, 10)], '#FC600C'),   # 护手处积下的一点熔浆
]
# 崩缺：刃缘咬掉三块（(12,4) 竖咬；(10,6)(9,7) 斜咬）+ 剑尖缺一角
FLAME_NOTCH = {(12, 4), (10, 6), (9, 7), (15, 0)}
FLAME_B = FLAME_A + [
    at([(11, 3)], '#FFD264'),   # 咬口内壁还亮着的熔浆
    at([(9, 6)], '#F87A1C'),
    at([(8, 8)], '#C03808'),
]

# ============================================================ 烈火，残躯
FLAME_A = [
    at([(15, 0)], '#FFC24A'),          # 剑尖起点
    at([(13, 2)], '#FFE8A8'),          # 裂缝：炽白
    at([(10, 5)], '#FFB03C'),
    at([(8, 7)], '#F0540C'),
    at([(7, 9)], '#8C2408'),           # 越靠护手越冷 = 熔浆正往下淌
    at([(4, 10)], '#FC600C'),          # 护手积的熔浆
]
# 崩缺：刃缘咬掉两块（(12,3)+(12,4) 竖咬一口；(10,6)+(9,7) 斜咬一口）+ 剑尖缺角
FLAME_NOTCH = {(12, 3), (12, 4), (10, 6), (9, 7), (15, 0)}
FLAME_B = FLAME_A + [
    at([(11, 3)], '#FFD264'),          # 咬口内壁还亮着的熔浆
    at([(9, 6)], '#E0480C'),
    at([(14, 1)], '#F8A030'),          # 缺角旁的烧灼边
]


def flame_notch(x, y):
    return (x, y) in FLAME_NOTCH


# ============================================================ 生成
VARIANTS = [
    ('deep_A', 'iron_sword', region_sword, RAMP_DEEPSEA, ACC_DEEPSEA, DEEP_A, None),
    ('deep_B', 'iron_sword', region_sword, RAMP_DEEPSEA, ACC_DEEPSEA, DEEP_B, None),
    ('flame_A', 'netherite_sword', region_sword_neth, RAMP_FLAME, ACC_FLAME, FLAME_A, None),
    ('flame_B', 'netherite_sword', region_sword_neth, RAMP_FLAME, ACC_FLAME, FLAME_B, flame_notch),
]

imgs = {}
EXTRA_PX = {'deep_B': DEEP_B_EXTRA_PX}
for key, tpl, rfn, ramp, acc, extra, carve in VARIANTS:
    im = build(tpl, rfn, ramp, list(acc) + list(extra), carve)
    for px, col in EXTRA_PX.get(key, []):   # 轮廓外补的像素（B 版专属）
        im.putpixel(px, col)
    im.save(os.path.join(OUT, key + '.png'))
    imgs[key] = im

base = {
    'deep': build('iron_sword', region_sword, RAMP_DEEPSEA, ACC_DEEPSEA, None),
    'flame': build('netherite_sword', region_sword_neth, RAMP_FLAME, ACC_FLAME, None),
}


def marks(new, old):
    """列出与纯换色版不同的像素（含颜色变、以及被挖空的）"""
    p1, p2 = new.load(), old.load()
    out = []
    for y in range(16):
        for x in range(16):
            if p1[x, y] != p2[x, y]:
                out.append((x, y))
    return out


# ============================================================ 对照大图
S, PAD = 12, 16
CELL = 16 * S
COLS = 2
LBLH = 26
GAP = 18
rowdefs = [
    ('① 原版底物（形状 100% 照抄的原型）',
     lambda k: Image.open(os.path.join(REF, ('iron_sword' if k == 'deep' else 'netherite_sword') + '.png')).convert('RGBA')),
    ('② 第一代 · 纯换色（现有、已入包的那版）', lambda k: base[k]),
    ('③ A 版 · 克制（轮廓不动，只加技能纹样）', lambda k: imgs[k + '_A']),
    ('④ B 版 · 表达（额外允许崩缺 / 浪尖等轮廓改动）', lambda k: imgs[k + '_B']),
]
markrows = [('⑤ A 版改动的像素（洋红框 = 与②不同）', lambda k: imgs[k + '_A'], lambda k: base[k]),
            ('⑥ B 版改动的像素', lambda k: imgs[k + '_B'], lambda k: base[k])]

HEAD = 32
W = PAD + COLS * (CELL + PAD * 7)
H = PAD + HEAD + len(rowdefs) * (LBLH + CELL + GAP) + len(markrows) * (LBLH + CELL + GAP) + LBLH + 80
sheet = Image.new('RGBA', (W, H), (20, 22, 27, 255))
d = ImageDraw.Draw(sheet)
txt(d, (PAD, 8), '剑类 · 「原版风 + 技能/名字」图标试作 —— 深海/烈火各两档，请挑方向', 21, (246, 246, 250))

slot = Image.new('RGBA', (CELL + 18, CELL + 18), (139, 139, 139, 255))
CN = {'deep': '深海的回响', 'flame': '烈火，残躯'}


def cell_at(k, x, y, im, box=None):
    big = up(im, S)
    c = slot.copy()
    c.paste(big, (9, 9), big)
    sheet.paste(c, (x, y))
    if box:
        for (mx, my) in box:
            X, Y = x + 9 + mx * S, y + 9 + my * S
            d.rectangle([X - 1, Y - 1, X + S, Y + S], outline=(255, 64, 160, 255), width=2)


y = PAD + HEAD
for cap, fn in rowdefs:
    txt(d, (PAD, y), cap, 15, (150, 156, 170))
    y += LBLH
    for i, k in enumerate(['deep', 'flame']):
        x = PAD + i * (CELL + PAD * 7)
        cell_at(k, x, y, fn(k))
        if cap.startswith('①'):
            txt(d, (x, y + CELL + 22), CN[k], 16, (250, 224, 140))
    y += CELL + GAP

for cap, fn, bfn in markrows:
    txt(d, (PAD, y), cap, 15, (150, 156, 170))
    y += LBLH
    for i, k in enumerate(['deep', 'flame']):
        x = PAD + i * (CELL + PAD * 7)
        cell_at(k, x, y, fn(k), marks(fn(k), bfn(k)))
    y += CELL + GAP

# 实际尺寸行：游戏里物品图标就是 16px，改动必须在这个尺度下也读得出来
txt(d, (PAD, y), '⑦ 实际尺寸观感（1× = 背包格真实大小 / 2× / 4×）—— 取 B 版', 15, (150, 156, 170))
y += LBLH
for i, k in enumerate(['deep', 'flame']):
    x = PAD + i * (CELL + PAD * 7)
    cx = x
    for s, lab in ((1, '1×'), (2, '2×'), (4, '4×')):
        big = up(imgs[k + '_B'], s)
        sheet.paste(big, (cx, y), big)
        txt(d, (cx, y + 16 * s + 4), lab, 13, (150, 156, 170))
        cx += 16 * s + 26
y += 70

p = os.path.join(OUT, '剑_技能版对照.png')
sheet.save(p)
print('sheet ->', p)
for k in ('deep_A', 'deep_B', 'flame_A', 'flame_B'):
    print('  %-8s 改动像素 %2d 个' % (k, len(marks(imgs[k], base['deep' if 'deep' in k else 'flame']))))
