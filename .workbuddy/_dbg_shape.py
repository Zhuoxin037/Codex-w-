# -*- coding: utf-8 -*-
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from texlab import decode
TEX = Path(r'D:/数据包/sweetdream_rp_完整版/assets/sweetdream/textures/item')
for name in ['tide_deep.png', 'sea_deep.png']:
    w, h, px = decode(TEX / name)
    print('=== %s (%dx%d) ===' % (name, w, h))
    for y in [6, 12, 20, 32, 44, 52, 58]:
        print('  y=%2d %s' % (y, ''.join('#' if px(x, y)[3] > 128 else '.' for x in range(64))))
