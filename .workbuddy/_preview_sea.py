# -*- coding: utf-8 -*-
"""暗海三形态 vs 暗潮 平图对比预览: 每行取 4 帧波纹叠在该行海底上, 放大输出。
第 1 行 = 暗潮(tide, 缓岸的圆湖); 第 2~4 行 = 暗海三形态(a 缓湾湖 / b 长湖 / c 半月湖)。
输出 logs/sea_vs_tide.png（棋盘格 = 透明, 方便看轮廓差异）。
"""
import sys, zlib, struct
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from texlab import decode

ROOT = Path(r'D:/数据包')
TEX = ROOT / 'sweetdream_rp_完整版/assets/sweetdream/textures/item'
OUT = ROOT / 'logs' / 'sea_vs_tide.png'

ROWS = [
    ('tide_deep.png', 'tide_ripple.png'),
    ('sea_a_deep.png', 'sea_a_ripple.png'),
    ('sea_b_deep.png', 'sea_b_ripple.png'),
    ('sea_c_deep.png', 'sea_c_ripple.png'),
]


def png(w, h, px):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(px[y * w + x])

    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def over(dst, src):
    """src 的 RGBA 叠到 dst 上(alpha 合成)"""
    for i in range(64 * 64):
        r, g, b, a = src[i]
        if a == 0:
            continue
        dr, dg, db, _ = dst[i]
        if a == 255:
            dst[i] = (r, g, b, 255)
        else:
            k = a / 255.0
            dst[i] = (int(dr * (1 - k) + r * k), int(dg * (1 - k) + g * k),
                      int(db * (1 - k) + b * k), 255)


def draw_row(canvas, W, top, deep_name, ripple_name, picks, SC, GAP, ln=None):
    _, _, dpx = decode(TEX / deep_name)
    deep = [dpx(x, y) for y in range(64) for x in range(64)]
    print('  %-22s 不透明像素 %d / 4096' % (deep_name, sum(1 for p in deep if p[3] > 128)))
    _, rh, rpx = decode(TEX / ripple_name)
    for idx, f in enumerate(picks):
        layer = [rpx(x, f * 64 + y) for y in range(64) for x in range(64)]
        cell = list(deep)
        over(cell, layer)
        cx = GAP + idx * (64 * SC + GAP)
        for y in range(64):
            for x in range(64):
                r, g, b, a = cell[y * 64 + x]
                if a == 0:
                    continue
                for dy in range(SC):
                    for dx in range(SC):
                        canvas[(top + y * SC + dy) * W + (cx + x * SC + dx)] = (r, g, b, 255)


def main():
    SC, GAP, COLS = 3, 10, 4
    picks = [0, 4, 8, 12]
    CELL = 64 * SC
    W = COLS * CELL + (COLS + 1) * GAP
    H = len(ROWS) * CELL + (len(ROWS) + 1) * GAP
    canvas = [(0, 0, 0, 0)] * (W * H)
    for y in range(H):
        for x in range(W):
            canvas[y * W + x] = (30, 34, 40, 255) if ((x // 8 + y // 8) % 2) else (22, 25, 30, 255)

    for i, (d, r) in enumerate(ROWS):
        draw_row(canvas, W, GAP * (i + 1) + CELL * i, d, r, picks, SC, GAP)

    OUT.parent.mkdir(exist_ok=True)
    OUT.write_bytes(png(W, H, canvas))
    print('ok ->', OUT, (W, H))
    print('  第1行 暗潮(缓岸圆湖) / 第2行 暗海a 缓湾湖 / 第3行 暗海b 长湖 / 第4行 暗海c 半月湖')


if __name__ == '__main__':
    main()
