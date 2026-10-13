# -*- coding: utf-8 -*-
"""离线渲染「终末天启·实体光柱」模型(验证贴图 alpha 与元素排布是否正确)。
只用来看形状/贴图, 不代表游戏里的发光效果 —— 实体那边 brightness 拉满。
输出: logs/beam_preview.png
"""
import json
import sys
from pathlib import Path

SKILL = Path(r'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
sys.path.insert(0, str(SKILL))
import render3d as R  # noqa: E402

ROOT = Path(r'D:/数据包')
RP = ROOT / 'sweetdream_rp_完整版'
OUT = ROOT / 'logs' / 'beam_preview.png'

repo = R.Repo(str(RP))
model = R.load_model(str(RP / 'assets/sweetdream/models/item/fr_beam.json'))
faces = R.bake(model, repo, ns_hint='sweetdream')

# entity 那边用 transformation.scale=[1,1,16] 把条子拉长 16 倍(以模型中心 z=8 为基准)
CZ, K = 8.0, 16.0
scaled = []
for quad, quv, tex, n in faces:
    q = [(x, y, (z - CZ) * K + CZ) for (x, y, z) in quad]
    scaled.append((q, quv, tex, n))

W, H = 320, 900
# 游戏里实体 brightness = 15(自发光), 而渲染器会按面朝向压暗 + 把半透明混进底色。
# 所以这里用浅底 + 一个"提亮"glow, 才接近游戏观感(纯白、两端渐隐)。
BG = (232, 238, 248)
AMBIENT = 0.95


def glow(tex, u, v, rgb):
    return (min(255.0, c * 1.25) for c in rgb)


rows, fit = R.render([(scaled, 1.0)], W, H, yaw=68, pitch=22,
                     bg=BG, ambient=AMBIENT, glow=glow)
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_bytes(R.encode_png(W, H, rows))

# 再出一张"正对光条侧面"的(看两端收细)
rows2, _ = R.render([(scaled, 1.0)], W, H, yaw=90, pitch=0, fit=fit,
                    bg=BG, ambient=AMBIENT, glow=glow)
OUT.with_name('beam_preview_side.png').write_bytes(R.encode_png(W, H, rows2))
print('写入', OUT, OUT.with_name('beam_preview_side.png'))
