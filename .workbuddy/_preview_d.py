# -*- coding: utf-8 -*-
"""渲染 D 批次预览(陨石 + 威霆领域)。用法: python .workbuddy/_preview_d.py"""
import sys
from pathlib import Path

sys.path.insert(0, r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R  # noqa: E402

RP = Path(r'D:/数据包/sweetdream_rp')
OUT = Path(r'D:/数据包/logs')
OUT.mkdir(parents=True, exist_ok=True)
repo = R.Repo(str(RP))


def shot(name, model, yaw, pitch, w=520, h=520, frame=None):
    faces = R.bake(model, repo, ns_hint='sweetdream')
    if frame is not None:
        for _q, _uv, tex, _n in faces:
            tex.set_frame(frame)
    fit = R.fit_all([[(faces, 1.0)]], w, h, yaw=yaw, pitch=pitch, zoom=0.94)
    rows, _ = R.render([(faces, 1.0)], w, h, yaw=yaw, pitch=pitch, fit=fit)
    p = OUT / name
    p.write_bytes(R.encode_png(w, h, rows))
    print('  -> %s  (%d 面)' % (p, len(faces)))


rock = R.load_model(str(RP / 'assets/sweetdream/models/item/meteor_rock.json'))
shot('preview_meteor_rock.png', rock, yaw=36, pitch=22)

dom = R.load_model(str(RP / 'assets/sweetdream/models/item/domain.json'))
shot('preview_domain_top.png', dom, yaw=0, pitch=88, frame=0)
shot('preview_domain_3q.png', dom, yaw=35, pitch=38, frame=0)
shot('preview_domain_top2.png', dom, yaw=0, pitch=88, frame=6)   # 第 6 帧(转了 90 度)
