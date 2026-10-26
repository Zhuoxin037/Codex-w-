# -*- coding: utf-8 -*-
"""批 J2 的 32 颗超限石总览图(给用户验收图标用, 不写任何游戏资源)。"""
import io
import json
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, 'D:/数据包/.workbuddy')
from _gen_ol_stones_j2 import NEW  # noqa: E402

TEX = 'D:/数据包/sweetdream_rp_完整版/assets/sweetdream/textures/item/stone/ol_%s.png'
OUT = 'D:/数据包/.workbuddy/超限石_批J2_32颗_总览.png'
FONT = 'C:/Windows/Fonts/msyh.ttc'

COLS, CELL, PAD = 8, 150, 16
rows = (len(NEW) + COLS - 1) // COLS
W = PAD + COLS * (CELL + PAD)
H = 104 + rows * (CELL + 46) + PAD
board = Image.new('RGB', (W, H), '#23262c')
d = ImageDraw.Draw(board)
title = ImageFont.truetype(FONT, 26)
small = ImageFont.truetype(FONT, 14)
d.text((PAD, 16), '超限石 · 批 J2 · 32 颗（16×16 实际贴图）', font=title, fill='#eee3ce')
d.text((PAD, 50), '晶石切面沿用前 28 颗；中心刻纹每颗不同，颜色跟随装备本名色。'
                  '下方小方格 = 物品栏实际尺寸。', font=small, fill='#acb4b9')

CMD = {}
for node in []:
    pass

for i, (uid, cat, motif, colour, _rows) in enumerate(NEW):
    x = PAD + (i % COLS) * (CELL + PAD)
    y = 92 + (i // COLS) * (CELL + 46)
    d.rectangle((x, y, x + CELL - 1, y + CELL + 30), fill='#2e333a')
    im = Image.open(TEX % uid).convert('RGBA')
    big = im.resize((112, 112), Image.Resampling.NEAREST)
    board.paste(big, (x + 19, y + 6), big)
    slot = im.resize((32, 32), Image.Resampling.NEAREST)
    board.paste(slot, (x + CELL - 40, y + CELL - 34), slot)
    box = d.textbbox((0, 0), uid, font=small)
    d.text((x + (CELL - (box[2] - box[0])) // 2, y + CELL - 8), uid, font=small, fill='#cfd6d9')
    d.text((x + 4, y + CELL + 12), motif, font=small, fill='#8fa0a6')

board.save(OUT)
print('board ->', OUT, board.size)
