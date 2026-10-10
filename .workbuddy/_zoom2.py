# -*- coding: utf-8 -*-
"""放大看指定图标，便于目视校对"""
import os, sys
from PIL import Image, ImageDraw

D = r'D:\数据包\模型设计\原版风_资源包_20261010\剑_预览'
keys = sys.argv[1:] or ['tinder', 'everfrost']
S, PAD = 16, 24
W = PAD + len(keys) * (16 * S + PAD)
H = PAD + 16 * S + PAD + 26
sheet = Image.new('RGBA', (W, H), (24, 26, 32, 255))
d = ImageDraw.Draw(sheet)
x = PAD
for k in keys:
    p = os.path.join(D, k + '.png')
    if not os.path.isfile(p):
        print('missing', p); continue
    im = Image.open(p).convert('RGBA')
    big = im.resize((16 * S, 16 * S), Image.NEAREST)
    slot = Image.new('RGBA', (16 * S + 16, 16 * S + 16), (139, 139, 139, 255))
    slot.paste(big, (8, 8), big)
    sheet.paste(slot, (x, PAD))
    d.text((x + 8, PAD + 16 * S + 20), k, fill=(250, 224, 140))
    x += 16 * S + PAD
out = r'D:\数据包\模型设计\原版风_资源包_20261010\剑_预览\_zoom.png'
sheet.save(out)
print('->', out, sheet.size)
