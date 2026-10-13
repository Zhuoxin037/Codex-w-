# -*- coding: utf-8 -*-
"""渲染「天使核心·圣光柱」预览(离线, 不需要开游戏)。

用法: python .workbuddy/_preview_angel.py
产出: logs/preview_angel_*.png
"""
import sys
from pathlib import Path

sys.path.insert(0, r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R  # noqa: E402

RP = Path(r'D:/数据包/sweetdream_rp_完整版')
OUT = Path(r'D:/数据包/logs')
OUT.mkdir(parents=True, exist_ok=True)

repo = R.Repo(str(RP))
model = R.load_model(str(RP / 'assets/sweetdream/models/item/angel_beam.json'))
faces = R.bake(model, repo, ns_hint='sweetdream')
print('元素面数 =', len(faces))


def scale_y(fs, k):
    return [([(x, y * k, z) for (x, y, z) in q], uv, t, n) for (q, uv, t, n) in fs]


def shot(name, fg, yaw, pitch, w=300, h=900):
    fit = R.fit_all([fg], w, h, yaw=yaw, pitch=pitch, zoom=0.96)
    rows, _ = R.render(fg, w, h, yaw=yaw, pitch=pitch, fit=fit)
    p = OUT / name
    p.write_bytes(R.encode_png(w, h, rows))
    print('  ->', p, p.stat().st_size)


# 游戏里: transformation.scale = [1,6,1] ⇒ 高 6 格(模型 [0,16] = 1 格)
FG = [(scale_y(faces, 6.0), 1.0)]

shot('preview_angel_side.png', FG, yaw=0, pitch=6)      # 正侧: 看"片"还是"管"
shot('preview_angel_3q.png', FG, yaw=40, pitch=12)      # 3/4 视角
# 原始比例(未拉高), 看十字结构与贴图本身
shot('preview_angel_raw.png', [(faces, 1.0)], yaw=40, pitch=14, w=600, h=600)
