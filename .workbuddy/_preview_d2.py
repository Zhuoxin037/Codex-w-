# -*- coding: utf-8 -*-
"""领域符文碎片近距离 + 陨石。"""
import sys
from pathlib import Path
sys.path.insert(0, r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R

RP = Path(r'D:/数据包/sweetdream_rp'); OUT = Path(r'D:/数据包/logs')
repo = R.Repo(str(RP))
dom = R.load_model(str(RP / 'assets/sweetdream/models/item/domain.json'))


def shot(name, model, yaw, pitch, w, h, zoom, frame=None, pad=None):
    faces = R.bake(model, repo, ns_hint='sweetdream')
    if frame is not None:
        for _q, _uv, tex, _n in faces:
            tex.set_frame(frame)
    kw = dict(yaw=yaw, pitch=pitch, zoom=zoom)
    if pad: kw['pad'] = pad
    fit = R.fit_all([[(faces, 1.0)]], w, h, **kw)
    rows, _ = R.render([(faces, 1.0)], w, h, yaw=yaw, pitch=pitch, fit=fit)
    p = OUT / name
    p.write_bytes(R.encode_png(w, h, rows))
    print('  -> %s' % p)


shot('preview_domain_shard.png', dom, yaw=20, pitch=20, w=560, h=560, zoom=2.6)
shot('preview_domain_side.png',  dom, yaw=0,  pitch=6,  w=760, h=360, zoom=1.0, pad=0.98)
