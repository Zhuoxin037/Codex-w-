# -*- coding: utf-8 -*-
"""超限石重设计 · 定稿提案 v3（只出图）

方案一：晶石座 + 汉字关键字（固定框归一化居中 + 简单字 + 印象色去重）
方案三：双色八芒星（芒=类别色，芯=印象色去重）
产出在 模型设计/超限石_重设计_20261010/。

用法: python .workbuddy/_proto_stone_final.py
"""
import os
import math
from PIL import Image, ImageDraw, ImageFont

import sys
sys.path.insert(0, r'D:\数据包\.workbuddy')
from _proto_stone_palette import PALETTE          # id, 名, 印象色（已 ΔE 验证）
from _proto_hanzi_fit import fit_mask             # 固定框归一化汉字

ROOT = r'D:\数据包'
OUT = os.path.join(ROOT, '模型设计', '超限石_重设计_20261010')
os.makedirs(OUT, exist_ok=True)
W = H = 16
YAHEI = r'C:\Windows\Fonts\msyh.ttc'

CAT = {
    'sword': ('剑', (206, 212, 224)), 'axe': ('斧', (190, 134, 84)),
    'bow': ('弩', (120, 176, 108)), 'staff': ('法杖', (176, 134, 224)),
    'armor': ('盔甲', (228, 184, 94)),
}
ITEM_CAT = {
    'liuguang': 'sword', 'myriad': 'sword', 'rogue_star': 'sword',
    'shadow_blade': 'sword', 'deepsea_echo': 'sword', 'everfrost': 'sword',
    'flame_brokenbody': 'sword', 'sickle_dreams': 'sword', 'hengdao': 'sword',
    'anion': 'axe', 'charge': 'axe', 'red_lotus': 'axe', 'dream_reader': 'axe',
    'bone_erode': 'bow', 'cold_crow': 'bow', 'sculk_echo': 'bow',
    'begonia': 'staff', 'polarized_light': 'staff',
    'brain_leech': 'armor', 'spine_symbiote': 'armor', 'stellar_elegy': 'armor',
    'dusk_dawn': 'armor', 'dionysus_helmet': 'armor', 'furnace_core': 'armor',
}
# 关键字 v2：笔画少优先（霜→冰 焰→火 鸦→乌 响→幽 偏→光 群星→坠 游星→星）
HANZI2 = {
    'liuguang': '流', 'myriad': '念', 'rogue_star': '星', 'shadow_blade': '刃',
    'deepsea_echo': '海', 'everfrost': '冰', 'flame_brokenbody': '火',
    'sickle_dreams': '引', 'hengdao': '刀', 'anion': '负', 'charge': '荷',
    'red_lotus': '莲', 'dream_reader': '梦', 'bone_erode': '骨',
    'cold_crow': '乌', 'sculk_echo': '幽', 'begonia': '棠',
    'polarized_light': '光', 'brain_leech': '蛭', 'spine_symbiote': '脊',
    'stellar_elegy': '坠', 'dusk_dawn': '昏', 'dionysus_helmet': '冠',
    'furnace_core': '炉',
}


def font(sz):
    return ImageFont.truetype(YAHEI, sz)


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def lighten(c, k):
    return tuple(max(0, min(255, int(v + (255 - v) * k))) for v in c)


def luma(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def to_img(px):
    im = Image.new('RGBA', (W, H))
    im.putdata([px[y][x] or (0, 0, 0, 0) for y in range(H) for x in range(W)])
    return im


def sheet(tiles, cols, scale, pad, labels=None, title=None, sub=None,
          bg=(26, 26, 32), lbl_h=18):
    n = len(tiles)
    rows = (n + cols - 1) // cols
    cw = W * scale + pad
    chh = H * scale + pad + lbl_h
    top = 46 if title else pad
    img = Image.new('RGB', (pad + cols * cw, top + rows * chh), bg)
    d = ImageDraw.Draw(img)
    if title:
        d.text((pad, 8), title, font=font(17), fill=(240, 240, 248))
    if sub:
        d.text((pad, 31), sub, font=font(12), fill=(150, 152, 166))
    for i, t in enumerate(tiles):
        x = pad + (i % cols) * cw
        y = top + (i // cols) * chh
        big = t.resize((W * scale, H * scale), Image.NEAREST)
        img.paste(big, (x, y), big)
        if labels:
            d.text((x + 2, y + H * scale + 3), labels[i], font=font(12),
                   fill=(224, 224, 232))
    return img


def seat_mask(u, v):
    return max(abs(u), abs(v)) <= 7.4 and (abs(u) + abs(v)) <= 10.4


def star_mask(u, v):
    """现有超限石的八芒星（近似）：中心盘 + 8 向芒"""
    d = math.hypot(u, v)
    if d <= 3.6:
        return True
    ang = math.degrees(math.atan2(v, u)) % 45.0
    spike = min(ang, 45 - ang)
    return d <= 8.0 - spike * 0.155


# ---------------------------------------------------------------- 方案一
def render_hanzi_stone(main, ch, box=11, ink_target=44):
    """晶石座 + 归一化汉字。字色自适应：石座亮 → 深刻；石座暗 → 浮雕亮字"""
    dark = shade(main, 0.30)
    lite = lighten(main, 0.86)
    deep = shade(main, 0.22)
    px = blank = [[None] * W for _ in range(H)]
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
                px[y][x] = dark
                continue
            t = (-u - v) / 19.0 + math.hypot(u, v) / 24.0
            if t > 0:
                px[y][x] = lighten(main, min(0.5, t * 0.6))
            else:
                px[y][x] = shade(main, 1.0 + max(-0.46, t * 0.86))
    hm = fit_mask(ch, box, ink_target)
    # 石座很亮 → 字深刻（暗字暗描边），否则浮雕（亮字暗描边）
    carve = luma(main) > 168
    ink_col = deep if carve else lite
    edge_col = lighten(main, 0.62) if carve else dark
    for y in range(H):
        for x in range(W):
            if hm[y][x] or not m[y][x]:
                continue
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and hm[yy][xx]:
                        px[y][x] = edge_col
                        break
    for y in range(H):
        for x in range(W):
            if hm[y][x] and m[y][x]:
                px[y][x] = ink_col
    return px


# ---------------------------------------------------------------- 方案三
# 原超限石贴图的真实 alpha 掩码（十字花：四条粗臂 + 中心芯）
from PIL import Image as _Img
_src = _Img.open(os.path.join(
    ROOT, 'sweetdream_rp', 'assets', 'sweetdream', 'textures', 'item',
    'stone', 'ol_liuguang.png')).convert('RGBA')
_a = _src.split()[3].load()
STAR_M = [[_a[x, y] > 60 for x in range(W)] for y in range(H)]


def render_dual_star(main, catcol):
    """保留原十字花轮廓：臂 = 类别色，中心芯 = 印象色（去重后）"""
    px = [[None] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            if not STAR_M[y][x]:
                continue
            u, v = x + 0.5 - 8, y + 0.5 - 8
            if 5 <= x <= 10 and 5 <= y <= 10:
                t = (-u - v) / 10.0
                px[y][x] = lighten(main, min(0.40, max(0, t) * 0.66)) if t > 0 \
                    else shade(main, 1.0 + max(-0.38, t * 0.78))
            else:
                t = (-u - v) / 16.0
                px[y][x] = lighten(catcol, min(0.32, max(0, t) * 0.58)) if t > 0 \
                    else shade(catcol, 1.0 + max(-0.34, t * 0.78))
    for y in range(H):
        for x in range(W):
            if not STAR_M[y][x]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < W and 0 <= yy < H and not STAR_M[yy][xx]:
                    px[y][x] = shade(px[y][x], 0.68)
                    break
    return px


# ---------------------------------------------------------------- 图版
def main():
    tiles, labs = [], []
    for pid, cn, col in PALETTE:
        tiles.append(to_img(render_hanzi_stone(col, HANZI2[pid])))
        labs.append('%s·%s' % (HANZI2[pid], cn))
    img = sheet(tiles, 6, 11, 8, labs,
                '方案一 · 定稿：晶石座 + 汉字（固定框归一化 · 严格居中）+ 印象色（ΔE 全验证）',
                '关键字换简单字：霜→冰 焰→火 鸦→乌 响→幽 偏→光 群星→坠 游星→星；石座亮时字自动改深刻')
    p = os.path.join(OUT, '_定稿_方案一_晶石座汉字.png')
    img.save(p)
    print('->', p, img.size)

    tiles, labs = [], []
    for pid, cn, col in PALETTE:
        cat = ITEM_CAT[pid]
        tiles.append(to_img(render_dual_star(col, CAT[cat][1])))
        labs.append('%s(%s)' % (cn, CAT[cat][0]))
    img = sheet(tiles, 6, 11, 8, labs,
                '方案三 · 定稿：双色八芒星（芒=类别色 · 芯=印象色去重）',
                '芒身标识装备类别；内芯为该件印象色，24 颗两两 Lab ΔE ≥ 18')
    p = os.path.join(OUT, '_定稿_方案三_双色星.png')
    img.save(p)
    print('->', p, img.size)

    # 印象色带（验证观感）
    tiles = []
    for pid, cn, col in PALETTE:
        im = Image.new('RGBA', (W, H), col + (255,))
        tiles.append(im)
    img = sheet(tiles, 8, 8, 6, [n for _, n, _ in PALETTE],
                '印象色总览（24 颗两两 ΔE ≥ 18 · 最小 19.1）',
                '重复即换色后的定稿 —— 同色系用明度/饱和度分层')
    p = os.path.join(OUT, '_定稿_印象色总览.png')
    img.save(p)
    print('->', p, img.size)


if __name__ == '__main__':
    main()
