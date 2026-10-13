# -*- coding: utf-8 -*-
"""把 21 块强化/超限石的物品图标拼成一张大图, 放大 10 倍方便肉眼验收。
输出: logs/stone_icons.png  (5 列 x 5 行, 每格 16px -> 放大后 160px, 留 6px 间隔)

看什么:
  · 4 个新系列的**轮廓**是否互相分得开、也和老两系(圆盘/菱形/八芒星)分得开;
  · β 的四角点有没有压在形状上; 白色字母(α/β/Ω)是否清楚;
  · 有没有"飘在形状外面的孤立像素"(装饰点掉出边界)。
重跑: python .workbuddy/_preview_stone_icons.py
"""
import os, sys, zlib, struct

ROOT = r'D:\数据包'
STONE = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream', 'textures', 'item', 'stone')
OUT = os.path.join(ROOT, 'logs', 'stone_icons.png')

ORDER = [
    ('mana_up_a', 'mana_up_b', 'mana_up_o', 'mana_gain_a', 'mana_gain_b'),
    ('mana_gain_o', 'ol_liuguang', 'coolant_a', 'coolant_b', 'coolant_o'),
    ('harden_a', 'harden_b', 'harden_o', 'mana_surge_a', 'mana_surge_b'),
    ('mana_surge_o', 'vision_a', 'vision_b', 'vision_o', 'ol_brain_leech'),
    ('ol_spine_symbiote', None, None, None, None),
]
SCALE, PAD, BG = 10, 6, (26, 26, 32, 255)


def read_png(p):
    d = open(p, 'rb').read()
    pos, idat = 8, b''
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos + 4])[0]
        tag = d[pos + 4:pos + 8]
        if tag == b'IHDR':
            w, h = struct.unpack('>II', d[pos + 8:pos + 16])
        elif tag == b'IDAT':
            idat += d[pos + 8:pos + 8 + ln]
        pos += 12 + ln
    raw = zlib.decompress(idat)
    stride, prev, rows, i = w * 4, bytearray(w * 4), [], 0
    for _ in range(h):
        f = raw[i]; i += 1
        line = bytearray(raw[i:i + stride]); i += stride
        if f == 1:
            for x in range(4, stride):
                line[x] = (line[x] + line[x - 4]) & 255
        elif f == 2:
            for x in range(stride):
                line[x] = (line[x] + prev[x]) & 255
        elif f == 3:
            for x in range(stride):
                line[x] = (line[x] + ((line[x - 4] if x >= 4 else 0) + prev[x]) // 2) & 255
        elif f == 4:
            def pa(a, b, c):
                q = a + b - c
                x_, y_, z_ = abs(q - a), abs(q - b), abs(q - c)
                return a if x_ <= y_ and x_ <= z_ else (b if y_ <= z_ else c)
            for x in range(stride):
                a = line[x - 4] if x >= 4 else 0
                b = prev[x]
                c = prev[x - 4] if x >= 4 else 0
                line[x] = (line[x] + pa(a, b, c)) & 255
        prev = line
        rows.append([tuple(line[x * 4:x * 4 + 4]) for x in range(w)])
    return w, h, rows


def write_png(path, w, h, rows):
    raw = bytearray()
    for r in rows:
        raw.append(0)
        for px in r:
            raw += bytes(px)

    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data
                + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff))
    png = (b'\x89PNG\r\n\x1a\n'
           + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
           + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'wb').write(png)


def over(dst, src):
    """src 叠到 dst 上(src 用 alpha 混合, 免得半透明像素把棋盘格盖错)"""
    a = src[3] / 255.0
    return (tuple(int(src[i] * a + dst[i] * (1 - a)) for i in range(3))
            + (255,))


cols = max(len(r) for r in ORDER)
cell = 16 * SCALE
W = cols * cell + (cols + 1) * PAD
H = len(ORDER) * cell + (len(ORDER) + 1) * PAD
sheet = [[BG] * W for _ in range(H)]

for ri, row in enumerate(ORDER):
    for ci, name in enumerate(row):
        if not name:
            continue
        w, h, px = read_png(os.path.join(STONE, name + '.png'))
        ox = PAD + ci * (cell + PAD)
        oy = PAD + ri * (cell + PAD)
        for y in range(h):
            for x in range(w):
                src = px[y][x]
                if src[3] == 0:
                    continue
                for dy in range(SCALE):
                    for dx in range(SCALE):
                        Y, X = oy + y * SCALE + dy, ox + x * SCALE + dx
                        sheet[Y][X] = over(sheet[Y][X], src)

write_png(OUT, W, H, sheet)
print('->', OUT, '%dx%d' % (W, H), '格数', sum(1 for r in ORDER for n in r if n))
