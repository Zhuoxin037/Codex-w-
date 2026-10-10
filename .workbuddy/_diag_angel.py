# -*- coding: utf-8 -*-
"""量化诊断 angel_glow.png 的 alpha 分布 + 模型上的实际朝向。
用法: python .workbuddy/_diag_angel.py
"""
import sys
from pathlib import Path

sys.path.insert(0, r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R  # noqa: E402
import texlab  # noqa: E402

RP = Path(r'D:/数据包/sweetdream_rp')
A = RP / 'assets/sweetdream/textures/item/angel_glow.png'

w, h, px = texlab.decode(str(A))
print('贴图 %dx%d' % (w, h))
print('alpha 矩阵(行=贴图 y, 从图片顶部往下; 列=x):')
for y in range(h):
    print('  y=%2d ' % y + ' '.join('%3d' % px(x, y)[3] for x in range(w)))
print()
print('竖直方向 alpha 极值(用于看上下趋势): 行 0..15 的中心列 x=7')
for y in range(h):
    a = px(7, y)[3]
    print('  行 %2d -> a=%3d %s' % (y, a, '#' * (a // 8)))
print()
print('水平方向 alpha 极值(第 8 行):')
for x in range(w):
    a = px(x, 8)[3]
    print('  列 %2d -> a=%3d %s' % (x, a, '#' * (a // 8)))

# ---- 模型方向验证: 用一个"上红下蓝"的假贴图渲一次, 看哪端是红
import json  # noqa: E402
import struct  # noqa: E402
import zlib  # noqa: E402


def pngbytes(w, h, rows):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(rows[y][x])

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d
                + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff))
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


model = R.load_model(str(RP / 'assets/sweetdream/models/item/angel_beam.json'))


class FakeRepo:
    """返回一张内嵌的方向探针贴图, 不落盘。"""
    def __init__(self):
        rows = [[((255, 0, 0, 255) if y < 8 else (0, 0, 255, 255))
                 for _x in range(16)] for y in range(16)]
        self._b = pngbytes(16, 16, rows)
        self._t = {}

    def texture(self, ref, tmap, ns_hint='minecraft'):
        if not ref:
            return None
        if ref not in self._t:
            p = Path(r'D:/数据包/logs/_probe_tex.png')
            p.parent.mkdir(exist_ok=True)
            p.write_bytes(self._b)
            self._t[ref] = R.Tex(str(p))
        return self._t[ref]


faces = R.bake(model, FakeRepo(), ns_hint='sweetdream')
fit = R.fit_all([[(faces, 1.0)]], 120, 400, yaw=0, pitch=0, zoom=0.98)
rows, _ = R.render([[(faces, 1.0)]], 120, 400, yaw=0, pitch=0, fit=fit,
                   bg=(0, 0, 0))
Path(r'D:/数据包/logs/_diag_orient.png').write_bytes(R.encode_png(120, 400, rows))
print()
print('方向探针已出: logs/_diag_orient.png  (贴图上半=红, 下半=蓝)')
print('  → 若模型顶端是红, 说明 v 轴 = 图片顶部; 若顶端是蓝, 则 v 轴反了。')
