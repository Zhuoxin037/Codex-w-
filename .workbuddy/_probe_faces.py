# -*- coding: utf-8 -*-
"""
6 个面(faces)的几何退化探针 —— 每次改完 render3d.py 的 FACES 表都该跑一遍。

【为什么要有它】render3d 的 FACES 表用三元组选择器挑顶点, 但 bake() 只做**真值判断**
  (`t[i] if sel[i] else f[i]`) ⇒ 任何非 0 的值都等于 "to"。历史上 down / up / east
  的 z 槽位误写成 1(本意是 from), 于是那一列全被当成 to、四边形塌成线段 ⇒ **这三个面
  从来没有被渲染出来过**(只画得出一个三角形或干脆空白), 而 render() 的
  `if abs(det) < 1e-9: continue` 会让它**静默消失**, 一个错都不报。2026-10-08 修。

【判据】一个面必须给出 4 个**互不重合**的顶点。少于 4 = 退化。

【自包含】不再借用 sweetdream_rp_完整版 里的 `_probe_solid.png`, 而是在临时目录里现造一个
  只含纯色贴图的最小资源包 —— 探针脚本不许往真实资源包里丢垃圾。
"""
import sys
import struct
import zlib
from pathlib import Path

sys.path.insert(0, r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R  # noqa: E402

TMP = Path(r'D:/数据包/.workbuddy/tmp_probe_rp')


def solid_png(w=16, h=16, rgb=(255, 0, 0)):
    """不透明纯色 PNG(自带 writer, 不依赖 PIL)。

    ★ 每像素必须写满 4 个字节(RGBA, colortype 6)。只写 3 个字节整张图会短一截,
      texlab.decode 在解滤镜时直接 IndexError —— 而且报的是 "index out of range",
      看不出是自家 writer 的问题(2026-10-08 踩过)。
    """
    raw = bytearray()
    row = (bytes(rgb) + b'\xff') * w
    for _ in range(h):
        raw.append(0)      # 滤镜 = None
        raw.extend(row)

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d
                + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff))
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


TEX = TMP / 'assets' / 'probe' / 'textures' / 'item'
TEX.mkdir(parents=True, exist_ok=True)
(TEX / 'solid.png').write_bytes(solid_png())

repo = R.Repo(str(TMP))

BAD = []
for fn in ('down', 'up', 'north', 'south', 'west', 'east'):
    m = {"textures": {"all": "item/solid"},
         "elements": [{"from": [0, 0, 0], "to": [16, 16, 16],
                       "faces": {fn: {"texture": "#all"}}}]}
    fs = R.bake(m, repo, ns_hint='probe')
    assert len(fs) == 1, (fn, '面数不对', len(fs))
    quad = fs[0][0]
    n = len(set(quad))
    ok = n == 4
    print('%-6s 顶点去重=%d  %s  %s' % (fn, n, 'OK ' if ok else '退化', quad))
    if not ok:
        BAD.append(fn)

print()
print('退化面: %s' % ('、'.join(BAD) if BAD else '无'))
sys.exit(1 if BAD else 0)
