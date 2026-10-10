# -*- coding: utf-8 -*-
"""把剑类 13 件图标横向排一张对照图（横版更容易看清）。"""
import os
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_swords import SPECS, OUT
from build_vanilla_icons import up, txt, REF
from PIL import Image, ImageDraw

S, PAD = 7, 12
CELL = 16 * S
COLS = [SPECS[i * 7:(i + 1) * 7] for i in range((len(SPECS) + 6) // 7)]


def grid(d, sheet, getter, y, cap, scale=S):
    txt(d, (PAD, y), cap, 15, (150, 156, 170))
    y += 22
    for chunk in COLS:
        x = PAD
        for sp in chunk:
            b = up(getter(sp), scale)
            sheet.paste(b, (x, y), b)
            if scale == S:
                txt(d, (x, y + CELL + 2), sp['cn'], 14, (250, 224, 140))
            x += (16 * scale if scale != S else CELL) + PAD
        y += (CELL if scale == S else 16 * scale) + (26 if scale == S else 20)
    return y + 8


def main():
    icons = {sp['key']: Image.open(os.path.join(OUT, sp['key'] + '.png')).convert('RGBA') for sp in SPECS}

    def van(sp):
        return Image.open(os.path.join(REF, sp['tpl'] + '.png')).convert('RGBA')

    W = PAD + max(len(c) for c in COLS) * (CELL + PAD)
    sheet = Image.new('RGBA', (W, 1400), (20, 22, 27, 255))
    d = ImageDraw.Draw(sheet)
    txt(d, (PAD, 10), '原版风 · 技能版 · 剑类 13 件（B 档 · 放大胆）', 20, (246, 246, 250))
    y = 40
    y = grid(d, sheet, van, y, '① 各件当前的原版底物（铁剑 / 钻石剑 / 下界合金剑）')
    y = grid(d, sheet, lambda sp: icons[sp['key']], y, '② 我们的图标（形状照抄底物，换成技能配色 + 纹样）')
    y = grid(d, sheet, lambda sp: icons[sp['key']], y, '③ 约 2× 观感', scale=2)
    sheet = sheet.crop((0, 0, W, y + 6))
    p = os.path.join(OUT, '剑_技能版_13件_横版.png')
    sheet.save(p)
    print('sheet ->', p, sheet.size)


if __name__ == '__main__':
    main()
