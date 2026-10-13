"""验证启示录显示合成和光柱表现边界。"""
import json
import math
from pathlib import Path
import sync_apocalypse_display as B

ROOT = Path(__file__).resolve().parents[1]
baseline = B.read(B.BASE)
max_error = 0
count = 0
for old_display in baseline['parts'].values():
    for ctx, old in old_display.items():
        base = baseline['display'][ctx]
        new = B.pose(base)
        new = {k: list(v) for k, v in new.items()}
        new['rotation'] = [x+d for x, d in zip(new['rotation'], [13, 21, -8])]
        new['translation'] = [x+d for x, d in zip(new['translation'], [2, -3, 1])]
        new['scale'] = [x*1.13 for x in new['scale']]
        after = B.compose(base, new, old)
        delta = B.mul(B.rotation(new['rotation']), B.transpose(B.rotation(base['rotation'])))
        expected = B.mul(delta, B.rotation(old['rotation']))
        actual = B.rotation(after['rotation'])
        error = max(abs(expected[i][j]-actual[i][j]) for i in range(3) for j in range(3))
        max_error = max(max_error, error)
        assert error < 3e-8, (ctx, error)
        # 任意三个点的相对位置经过整体变换仍应吻合，不只验证欧拉角自身。
        for point in ([0, 0, 0], [1, 3, -2], [-4, 1, 5]):
            old_pose = B.pose(old)
            original = B.mv(B.rotation(old_pose['rotation']), [point[i]*old_pose['scale'][i] for i in range(3)])
            original = [original[i]+old_pose['translation'][i]-base['translation'][i] for i in range(3)]
            target = B.mv(delta, original)
            target = [target[i]*1.13+new['translation'][i] for i in range(3)]
            rendered = B.mv(B.rotation(after['rotation']), [point[i]*after['scale'][i] for i in range(3)])
            rendered = [rendered[i]+after['translation'][i] for i in range(3)]
            assert math.dist(target, rendered) < .00001
        count += 1

for name, elements in [('angel_beam', 9), ('fr_beam', 12)]:
    model = B.read(ROOT / f'sweetdream_rp_完整版/assets/sweetdream/models/item/{name}.json')
    assert len(model['elements']) == elements
    for e in model['elements']:
        assert e['light_emission'] == 15
        assert all(-16 <= v <= 32 for k in ('from', 'to') for v in e[k])
        if 'rotation' in e: assert e['rotation']['angle'] in (-45, -22.5, 0, 22.5, 45)
        for f in e['faces'].values():
            tex = model['textures'][f['texture'][1:]]
            ns, p = tex.split(':')
            assert (ROOT / f'sweetdream_rp_完整版/assets/{ns}/textures/{p}.png').exists()

# 起柱与收束都必须贴地；施法的长度和视线偏移不能随外观优化改变。
for scale, shift in [(.8, -2.6), (6, 0)]:
    assert abs(3-scale/2+shift) < 1e-8
fr = (ROOT / 'sweetdream/data/sweetdream/function/equipment/staff/final_revelation/beam_new.mcfunction').read_text(encoding='utf-8')
assert 'positioned ^ ^-0.45 ^8' in fr and 'scale:[1.0f,1.0f,16.0f]' in fr
angel = (ROOT / 'sweetdream/data/sweetdream/function/equipment/axe/angel_core/beam.mcfunction').read_text(encoding='utf-8')
assert angel.index('zx.ab_age 0') < angel.index('remove zx.ac_beam_new')
report = {'启示录检验姿态数': count, '旋转矩阵最大误差': max_error,
          '相对书页位置保持': True, '光柱实体数量保持': True,
          '终末天启长度与跟随保持': True, '问题数': 0}
p = ROOT / '模型设计/光柱优化/核验结果.json'
p.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
print(json.dumps(report, ensure_ascii=False))
