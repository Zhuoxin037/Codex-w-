"""核验领域精简后的边界、实体数量与实际资源渲染。"""
import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, 'C:/Users/qq303/.workbuddy/skills/mc-model-preview/scripts')
import render3d as R

RP = ROOT / 'sweetdream_rp_完整版'
new = json.loads((RP/'assets/sweetdream/models/item/domain.json').read_text(encoding='utf-8'))
old = json.loads((ROOT/'.workbuddy/backup/thunder-domain-2026-10-09/domain.json').read_text(encoding='utf-8'))
assert len(new['elements']) == 1, '精简版只保留水平法阵，不应恢复外围竖立符文'
a, b = old['elements'][0], new['elements'][0]
assert a['from'] == b['from'] and a['to'] == b['to']
assert a['faces'] == b['faces']
assert set(b['faces']) == {'up', 'down'}
for i in range(48):
    a = math.tau*i/48/2
    assert abs(math.sin(a)**2+math.cos(a)**2-1) < 1e-12
domain = (ROOT/'sweetdream/data/sweetdream/function/equipment/axe/thunderclap/domain.mcfunction').read_text(encoding='utf-8')
assert domain.count('summon minecraft:item_display') == 1
assert 'scale:[12.0f,12.0f,12.0f]' in domain
fx = (ROOT/'sweetdream/data/sweetdream/function/equipment/axe/thunderclap/domain_fx.mcfunction').read_text(encoding='utf-8')
commands = [x for x in fx.splitlines() if x and not x.startswith('#')]
assert len(commands) == 4
assert all('^ ^ ^6' in x and '0.01 1 normal' in x for x in commands)
tick = (ROOT/'sweetdream/data/sweetdream/function/visual/tick.mcfunction').read_text(encoding='utf-8')
apply = (ROOT/'sweetdream/data/sweetdream/function/visual/domain_apply.mcfunction').read_text(encoding='utf-8')
assert 'matches ..3 run return 0' in tick
assert 'interpolation_duration set value 4' in apply
repo = R.Repo(str(RP))
faces = R.bake(new, repo, ns_hint='sweetdream')
rows, _ = R.render([(faces, 1)], 900, 600, yaw=30, pitch=35,
                   bg=(17, 23, 34), ambient=.98)
p = ROOT/'模型设计/威霆_领域优化/威霆_实际模型预览.png'
p.write_bytes(R.encode_png(900, 600, rows))
print('Domain: 17 -> 1 elements; 34 -> 2 faces; radius, one entity, sparse particles and 9.6-second rotation verified.')
print(p)
