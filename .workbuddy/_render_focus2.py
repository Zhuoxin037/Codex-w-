# -*- coding: utf-8 -*-
"""永霜（上一版「冰壳」 vs 新版「零外扩」）+ 火种（熄灭/燃烧两态）专项对照图

★ 上一版冰壳只在图上重建用于对比，不再进生成器（用户已否掉："太宽大"）。
"""
import os
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_icons import (build, region_sword, hx, up, txt, REF, load)
from build_vanilla_swords import A, RG, MID, FS, OUT
from PIL import Image, ImageDraw


def add_shell(im, tpl, fill, rim, alpha=150):
    """旧版永霜的「整圈外扩 1px 半透明冰壳」—— 仅用于对比图重建。"""
    px, W, H = load(tpl)
    base = im.load()
    M = [[base[x, y][3] > 0 for x in range(W)] for y in range(H)]
    shell = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    s = shell.load()
    f = hx(fill); f = (f[0], f[1], f[2], alpha)
    r = hx(rim);  r = (r[0], r[1], r[2], min(255, alpha + 45))
    for y in range(H):
        for x in range(W):
            if M[y][x]:
                continue
            if any(0 <= x + dx < W and 0 <= y + dy < H and M[y + dy][x + dx]
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                s[x, y] = f
    S = [[s[x, y][3] > 0 for x in range(W)] for y in range(H)]
    for y in range(H):
        for x in range(W):
            if not S[y][x]:
                continue
            if any(not (0 <= x + dx < W and 0 <= y + dy < H)
                   or (not S[y + dy][x + dx] and not M[y + dy][x + dx])
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                s[x, y] = r
    shell.alpha_composite(im)
    return shell


# ---- 上一版永霜（整圈冰壳）—— 只用于对比 ----
OLD_SHELL = build('diamond_sword', FS, {
    'blade':  [hx('#1B4A66'), hx('#2C6E92'), hx('#4A93B6'), hx('#78BFD8'), hx('#A6DEEB'), hx('#CBF0F7'), hx('#E6FBFF')],
    'guard':  [hx('#12384E'), hx('#1E5E7E'), hx('#3182A6'), hx('#5EB4D2'), hx('#9ADCEE')],
    'grip':   [hx('#0C2A3C'), hx('#154459'), hx('#1F5E78'), hx('#2E7E9C')],
    'pommel': [hx('#12384E'), hx('#3182A6'), hx('#9ADCEE')],
    '_default': [hx('#2E7A9E'), hx('#8FD2E6'), hx('#FFFFFF')],
}, [MID('#FFFFFF'), RG('blade', lambda x, y, t, e: e, '#DCF4FC'),
    RG('guard', lambda x, y, t, e: t > 0.72, '#D8F2FA'),
    RG('grip', lambda x, y, t, e: t > 0.75, '#7FC8E0')])
OLD_SHELL = add_shell(OLD_SHELL, 'diamond_sword', '#2A6A88', '#16465E', 150)

NEW_EVER = Image.open(os.path.join(OUT, 'everfrost.png')).convert('RGBA')
T_OFF = Image.open(os.path.join(OUT, 'tinder_off.png')).convert('RGBA')
T_ON = Image.open(os.path.join(OUT, 'tinder_on.png')).convert('RGBA')

ROWS = [
    dict(title='永霜 · 二次重做：轮廓零外扩，「冰」做进刃身', tpl='diamond_sword',
         cells=[('上一版「冰壳」（已否）', OLD_SHELL), ('★ 新版（本次）', NEW_EVER)],
         note='刃锋结霜一条亮白 / 刃背深冷压暗 / 中缝冻结的芯 / 剑尖裹霜 / 护手碎冰 —— 一个像素都没外扩'),
    dict(title='火种 · 两态（同一把剑，状态不同）', tpl='netherite_sword',
         cells=[('★ 熄灭态', T_OFF), ('★ 燃烧态', T_ON)],
         note='熄灭：焦炭剑身，只剩几粒暗红余烬 ／ 燃烧：整把烧起来，柄尾炽白，火舌上扬'),
]

S = 12
PAD = 26
CELL = 16 * S
LBLH = 26
ROWNOTE = 30
ROWH = CELL + LBLH + ROWNOTE + 26
HEAD = 84
W = PAD * 2 + CELL * 3 + PAD * 2 + 340
H = HEAD + len(ROWS) * ROWH + 2 * CELL + 96
sheet = Image.new('RGBA', (W, H), (20, 22, 27, 255))
d = ImageDraw.Draw(sheet)

txt(d, (PAD, 16), '剑类 · 定稿一件 + 重做一件 —— 永霜（二次重做）· 火种（两态）', 26, (246, 246, 250))
txt(d, (PAD, 50), '每行：左＝该件所用的原版底物，其余＝我们的图标（12×）；最下方是 1× / 2× 真实观感', 15, (150, 156, 170))

y = HEAD
for r in ROWS:
    txt(d, (PAD, y), r['title'], 20, (250, 224, 140))
    y += 28
    x = PAD
    v = Image.open(os.path.join(REF, r['tpl'] + '.png')).convert('RGBA')
    b = up(v, S)
    slot = Image.new('RGBA', (CELL + 16, CELL + 16), (139, 139, 139, 255))
    slot.paste(b, (8, 8), b)
    sheet.paste(slot, (x, y))
    txt(d, (x, y + CELL + 20), '原版底物', 14, (170, 176, 190))
    x += CELL + PAD + 10

    for cap, im in r['cells']:
        b = up(im, S)
        slot = Image.new('RGBA', (CELL + 16, CELL + 16), (139, 139, 139, 255))
        slot.paste(b, (8, 8), b)
        sheet.paste(slot, (x, y))
        col = (255, 214, 120) if cap.startswith('★') else (170, 176, 190)
        txt(d, (x, y + CELL + 20), cap, 14, col)
        x += CELL + PAD + 10
    txt(d, (PAD, y + CELL + 44), r['note'], 14, (150, 156, 170))
    y += ROWH

txt(d, (PAD, y + 4), '实际尺寸（1× 背包真实大小 / 2×）', 15, (150, 156, 170))
y += 30
cx = PAD
for im in (OLD_SHELL, NEW_EVER, T_OFF, T_ON):
    for s in (1, 2):
        b = up(im, s)
        sheet.paste(b, (cx, y), b)
        cx += 16 * s + 6
    cx += 22
p = os.path.join(OUT, '剑_永霜与火种_对照.png')
sheet.save(p)

# ---- 自检：新版永霜的 alpha 是否与钻石剑一致（只允许多出 1 个像素 = 剑尖霜屑）----
px, W0, H0 = load('diamond_sword')
va = [[px[x, y][3] > 0 for x in range(W0)] for y in range(H0)]
ea = [[NEW_EVER.getpixel((x, y))[3] > 0 for x in range(16)] for y in range(16)]
extra = [(x, y) for y in range(16) for x in range(16) if ea[y][x] and not va[y][x]]
miss = [(x, y) for y in range(16) for x in range(16) if va[y][x] and not ea[y][x]]
print('->', p, sheet.size)
print('   新版永霜 alpha: 多出 %d 像素 %s / 缺失 %d' % (len(extra), extra, len(miss)))
