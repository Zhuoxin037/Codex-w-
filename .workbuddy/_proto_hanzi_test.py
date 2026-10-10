# -*- coding: utf-8 -*-
"""测：16x16 里能不能看清汉字（超限石候选关键字）"""
import os
from PIL import Image, ImageDraw, ImageFont

OUT = r'D:\数据包\模型设计\超限石_重设计_20261010'
os.makedirs(OUT, exist_ok=True)

# 24 件候选关键字
WORDS = ['光', '念', '星', '影', '海', '霜', '烈', '梦', '刀', '离',
         '荷', '莲', '释', '骨', '鸦', '匿', '棠', '偏', '蛭', '脊',
         '挽', '昏', '冠', '炉']

FONT = r'C:\Windows\Fonts\simhei.ttf'
SCALE = 12


def mask_of(ch, size, ox, oy):
    f = ImageFont.truetype(FONT, size)
    im = Image.new('L', (16, 16), 0)
    d = ImageDraw.Draw(im)
    d.text((ox, oy), ch, font=f, fill=255)
    px = im.load()
    return [[px[x, y] >= 110 for x in range(16)] for y in range(16)]


def build(size, ox, oy, name):
    cols = 8
    rows = (len(WORDS) + cols - 1) // cols
    cw = 16 * SCALE + 8
    ch_ = 16 * SCALE + 26
    img = Image.new('RGB', (8 + cols * cw, 30 + rows * ch_), (26, 26, 32))
    d = ImageDraw.Draw(img)
    d.text((8, 7), '汉字点阵 %dpx（8 列，放大 %d×）' % (size, SCALE),
           font=ImageFont.truetype(r'C:\Windows\Fonts\msyh.ttc', 16),
           fill=(240, 240, 248))
    for i, w in enumerate(WORDS):
        m = mask_of(w, size, ox, oy)
        tile = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
        tp = tile.load()
        for y in range(16):
            for x in range(16):
                if m[y][x]:
                    tp[x, y] = (245, 245, 250, 255)
        big = tile.resize((16 * SCALE, 16 * SCALE), Image.NEAREST)
        x0 = 8 + (i % cols) * cw
        y0 = 30 + (i // cols) * ch_
        img.paste(big, (x0, y0), big)
        d.text((x0 + 2, y0 + 16 * SCALE + 3), w,
               font=ImageFont.truetype(r'C:\Windows\Fonts\msyh.ttc', 13),
               fill=(224, 224, 232))
    p = os.path.join(OUT, name)
    img.save(p)
    print('->', p)


if __name__ == '__main__':
    build(12, 2, 1, '_试_汉字12px.png')
    build(13, 1, 1, '_试_汉字13px.png')
