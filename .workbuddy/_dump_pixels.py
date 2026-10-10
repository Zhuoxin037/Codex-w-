# -*- coding: utf-8 -*-
"""临时工具：把 16x16 图标 dump 成 ASCII 网格，便于逐像素设计与核对。"""
from PIL import Image

REF = r'D:\数据包\.workbuddy\_vanilla_ref'
ICON = r'D:\数据包\模型设计\原版风_资源包_20261010\icons'
RAMP = '.·:-=+*#%@'


def dump(path, title):
    im = Image.open(path).convert('RGBA')
    px = im.load()
    print('== %s  %dx%d' % (title, im.width, im.height))
    print('    ' + ''.join(str(x % 10) for x in range(im.width)))
    for y in range(im.height):
        row = ''
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                row += '.'
            else:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                row += RAMP[max(0, min(9, int(lum / 25.6)))]
        print('%2d  %s' % (y, row))


if __name__ == '__main__':
    for n, t in [('iron_sword', '原版铁剑（深海的回响的底物）'),
                 ('netherite_sword', '原版下界合金剑（烈火/极光/引梦的底物）')]:
        dump(REF + '\\' + n + '.png', t)
        print()
    for n, t in [('deepseaecho_sword', '现有·深海的回响'),
                 ('flameremnant_sword', '现有·烈火，残躯'),
                 ('sweetdream_aurora', '已认可·极光与幻梦')]:
        dump(ICON + '\\' + n + '.png', t)
        print()
