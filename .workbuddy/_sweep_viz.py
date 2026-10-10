# -*- coding: utf-8 -*-
"""把 sweep_fx_gen 的粒子数据栅格化成 PNG，用来眼睛验收覆盖形状。
（HTML 那份是给用户看的矢量图，这份是给我自己快速核对的。）"""
import sys, os, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sweep_fx_gen as G
from render3d import encode_png

W, H = 280, 280          # 单格
PICK = [5, 8, 9, 13]

BG = (16, 14, 26)
BOX = (199, 155, 255)


def blend(px, x, y, rgb, a):
    if not (0 <= x < W and 0 <= y < H):
        return
    i = (y * W + x) * 3
    for k in range(3):
        px[i + k] = int(px[i + k] * (1 - a) + rgb[k] * a)


def rect(px, x0, y0, x1, y1, rgb, a):
    if x0 > x1:
        x0, x1 = x1, x0
    if y0 > y1:
        y0, y1 = y1, y0
    for y in range(int(y0), int(y1) + 1):
        for x in range(int(x0), int(x1) + 1):
            blend(px, x, y, rgb, a)


def draw(lines, top=True):
    px = bytearray(BG * (W * H))
    if top:
        lo, hi, lo2, hi2 = -3.4, 3.4, -1.2, 5.4          # x , z
    else:
        lo, hi, lo2, hi2 = -1.2, 5.4, -1.4, 4.6          # z , y
    def mx(v): return (v - lo) / (hi - lo) * (W - 1)
    def my(v): return H - 1 - (v - lo2) / (hi2 - lo2) * (H - 1)
    # 判定盒
    if top:
        rect(px, mx(G.BX[0]), my(G.BZ[1]), mx(G.BX[1]), my(G.BZ[1]), BOX, 0.95)
        rect(px, mx(G.BX[0]), my(G.BZ[0]), mx(G.BX[1]), my(G.BZ[0]), BOX, 0.95)
        rect(px, mx(G.BX[0]), my(G.BZ[0]), mx(G.BX[0]), my(G.BZ[1]), BOX, 0.95)
        rect(px, mx(G.BX[1]), my(G.BZ[0]), mx(G.BX[1]), my(G.BZ[1]), BOX, 0.95)
    else:
        rect(px, mx(G.BZ[0]), my(G.BY[1]), mx(G.BZ[1]), my(G.BY[1]), BOX, 0.95)
        rect(px, mx(G.BZ[0]), my(G.BY[0]), mx(G.BZ[1]), my(G.BY[0]), BOX, 0.95)
        rect(px, mx(G.BZ[0]), my(G.BY[0]), mx(G.BZ[0]), my(G.BY[1]), BOX, 0.95)
        rect(px, mx(G.BZ[1]), my(G.BY[0]), mx(G.BZ[1]), my(G.BY[1]), BOX, 0.95)
        rect(px, 0, my(0), W - 1, my(0), (60, 55, 85), 1.0)
    # 玩家
    rect(px, mx(0) - 1, my(0) - 1, mx(0) + 1, my(0) + 1, (255, 233, 168), 1.0)
    rr = random.Random(4242)
    for d in lines:
        if d['kind'] == 'sound':
            continue
        x, y, z = d['pos']
        dx, dy, dz = d['delta']
        if d['kind'] == 'dust':
            r, g, b = d['color']
            rgb = (int(r * 255), int(g * 255), int(b * 255))
            s = d['scale']
        else:
            rgb = (127, 255, 224) if 'soul' in d['kind'] else (191, 168, 255)
            s = 0.5
        al = min(0.95, 0.34 + 0.16 * s)
        rad = 1 if s < 0.6 else 2
        # 按 count 在散布框里撒点 —— 这才是游戏里真正会看到的样子
        n = max(1, d['count'])
        for _ in range(n):
            px_ = x + rr.uniform(-dx, dx)
            py_ = y + rr.uniform(-dy, dy)
            pz_ = z + rr.uniform(-dz, dz)
            if top:
                rect(px, mx(px_) - rad, my(pz_) - rad, mx(px_) + rad, my(pz_) + rad, rgb, al)
            else:
                rect(px, mx(pz_) - rad, my(py_) - rad, mx(pz_) + rad, my(py_) + rad, rgb, al)
    return px


def main():
    cols, gap = 2, 10
    tiles = PICK[:10]
    rows_n = (len(tiles) + cols - 1) // cols
    TW = cols * W + (cols - 1) * gap
    TH = rows_n * (2 * H + gap + 12) + gap
    canvas = bytearray((14, 12, 22) * (TW * TH))
    for idx, t in enumerate(tiles):
        cx = (idx % cols) * (W + gap)
        cy = (idx // cols) * (2 * H + gap + 12) + gap
        for half, top in ((0, True), (1, False)):
            px = draw(G.CAPTURED[t], top)
            oy = cy + half * (H + 2)
            for y in range(H):
                si = y * W * 3
                di = ((oy + y) * TW + cx) * 3
                canvas[di:di + W * 3] = px[si:si + W * 3]
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       'texlab_out', 'sweep_fx_grid.png')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, 'wb') as f:
        f.write(encode_png(TW, TH, [bytes(canvas[y * TW * 3:(y + 1) * TW * 3])
                                    for y in range(TH)]))
    print('-> %s  (%dx%d)' % (out, TW, TH))
    print('每格：上=俯视(x横 / z纵, 前为上)  下=侧视(z横 / y纵, 前为右)')
    print('顺序:', tiles)


if __name__ == '__main__':
    G.random.seed(20261003)
    G.build()
    main()
