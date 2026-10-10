# -*- coding: utf-8 -*-
"""把三把原版剑模板 dump 成 ASCII（区域 + 明暗），供逐像素设计。"""
import os
import sys
from PIL import Image

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_icons import region_sword, region_sword_neth, lum, REF

TPL = {
    'iron_sword': region_sword,
    'diamond_sword': region_sword,
    'netherite_sword': region_sword_neth,
}
INIT = {'blade': 'B', 'guard': 'G', 'grip': 'r', 'pommel': 'p'}

for name, rfn in TPL.items():
    im = Image.open(os.path.join(REF, name + '.png')).convert('RGBA')
    px = im.load()
    print('========== %s (16x16) ==========' % name)
    print('     ' + ''.join('%X' % (x % 16) for x in range(16)))
    for y in range(16):
        row = []
        for x in range(16):
            c = px[x, y]
            if c[3] == 0:
                row.append('.')
            else:
                row.append(INIT.get(rfn(x, y, c), '?'))
        print('%2d   %s' % (y, ''.join(row)))
    # 明暗（0..9）
    print('  -- 亮度 --')
    for y in range(16):
        row = []
        for x in range(16):
            c = px[x, y]
            row.append('.' if c[3] == 0 else '%d' % min(9, int(lum(c) / 26)))
        print('%2d   %s' % (y, ''.join(row)))
    print()
