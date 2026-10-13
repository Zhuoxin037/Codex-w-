# -*- coding: utf-8 -*-
"""把 tide_ripple.png 的 16 帧摊成 4x4 网格预览(每格垫上 tide_deep 当海面),
用来肉眼确认"波纹环在往外推"。输出 logs/tide_ripple_16frames.png"""
from PIL import Image, ImageDraw
import pathlib

RP = pathlib.Path(__file__).resolve().parent.parent / 'sweetdream_rp_完整版/assets/sweetdream/textures/item'
OUT = pathlib.Path(__file__).resolve().parent.parent / 'logs' / 'tide_ripple_16frames.png'

deep = Image.open(RP / 'tide_deep.png').convert('RGBA')
rip = Image.open(RP / 'tide_ripple.png').convert('RGBA')
F = 64
N = rip.height // F

SC = 3            # 放大倍数
GAP = 8
COLS = 4
ROWS = (N + COLS - 1) // COLS
CELL = F * SC
W = COLS * CELL + (COLS + 1) * GAP
H = ROWS * CELL + (ROWS + 1) * GAP

canvas = Image.new('RGBA', (W, H), (10, 14, 20, 255))
d = ImageDraw.Draw(canvas)

for i in range(N):
    frame = rip.crop((0, i * F, F, (i + 1) * F))
    cell = deep.copy()
    cell.alpha_composite(frame)
    cell = cell.resize((CELL, CELL), Image.NEAREST)
    cx = GAP + (i % COLS) * (CELL + GAP)
    cy = GAP + (i // COLS) * (CELL + GAP)
    canvas.alpha_composite(cell, (cx, cy))
    d.rectangle([cx - 1, cy - 1, cx + CELL, cy + CELL], outline=(70, 80, 95, 255))
    d.text((cx + 3, cy + 2), str(i), fill=(255, 230, 120, 255))

canvas.save(OUT)
print('ok ->', OUT, canvas.size)
