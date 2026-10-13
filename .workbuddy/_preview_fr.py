# -*- coding: utf-8 -*-
"""终末天启·水平光束(正交薄片)的离线预览。

★ 必须自己把数据包侧的 `transformation.scale [1,1,16]` 补上 ——
  模型本体只是 16x16x16 的一小段, 真正在游戏里看到的是"1 格粗、16 格长"的光条。
  缩放绕实体中心(模型坐标 8,8,8), 所以 z' = 8 + (z-8)*16。
"""
import sys
from pathlib import Path
sys.path.insert(0, r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R

RP = Path(r'D:/数据包/sweetdream_rp_完整版'); OUT = Path(r'D:/数据包/logs')
repo = R.Repo(str(RP))
mod = R.load_model(str(RP / 'assets/sweetdream/models/item/fr_beam.json'))


def scaled_faces(zscale=16.0):
    out = []
    for quad, quv, tex, n in R.bake(mod, repo, ns_hint='sweetdream'):
        q = [(p[0], p[1], 8 + (p[2] - 8) * zscale) for p in quad]
        out.append((q, quv, tex, n))
    return out


def shot(name, yaw, pitch, w, h, zoom):
    faces = scaled_faces()
    fit = R.fit_all([[(faces, 1.0)]], w, h, yaw=yaw, pitch=pitch, zoom=zoom)
    rows, _ = R.render([(faces, 1.0)], w, h, yaw=yaw, pitch=pitch, fit=fit)
    p = OUT / name
    p.write_bytes(R.encode_png(w, h, rows))
    print('  -> %s  (%d 面)' % (p, len(faces)))


shot('preview_fr_side.png', yaw=90, pitch=4,  w=900, h=300, zoom=1.0)   # 侧面: 该看到竖直片
shot('preview_fr_top.png',  yaw=0,  pitch=86, w=900, h=300, zoom=1.0)   # 俯视: 该看到水平片
shot('preview_fr_3q.png',   yaw=42, pitch=20, w=820, h=420, zoom=1.0)   # 3/4
shot('preview_fr_axis.png', yaw=1,  pitch=1,  w=560, h=560, zoom=1.0)   # 沿轴向(前端截面)
