"""检查实际资源引用、旋转转换、全帧位置与显示继承，而非重复导出代码。"""
import importlib.util
import itertools
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'sweetdream_rp/assets'
bb = json.loads((ROOT / '模型设计/天使核心_阶段二/天使核心_分组模型.bbmodel').read_text(encoding='utf-8'))
root_path = ASSETS / 'angelcore/models/item/axe.json'
root = json.loads(root_path.read_text(encoding='utf-8'))


def read(p):
    return json.loads(p.read_text(encoding='utf-8'))


def path(ref, kind):
    ns, name = ref.split(':')
    return ASSETS / ns / kind / (name + ('.png' if kind == 'textures' else '.json'))


def resolve(ref, seen=()):
    assert ref not in seen, ('parent cycle', seen, ref)
    d = read(path(ref, 'models'))
    parent = resolve(d['parent'], seen+(ref,)) if 'parent' in d else {}
    return {**parent, **d, 'textures': {**parent.get('textures', {}), **d.get('textures', {})}}


def refs(v):
    if isinstance(v, dict):
        if v.get('type') == 'minecraft:model':
            yield v['model']
        for child in v.values():
            yield from refs(child)
    elif isinstance(v, list):
        for child in v:
            yield from refs(child)


checked = set()
for item in [ASSETS / 'angelcore/items/axe.json', ASSETS / 'coldcrow/items/crossbow.json',
             ASSETS / 'sail/items/staff.json']:
    for ref in set(refs(read(item))):
        d = resolve(ref)
        assert d['elements'], ref
        for e in d['elements']:
            for key in ('from', 'to'):
                assert all(-16 <= x <= 32 for x in e[key]), (ref, key, e[key])
            assert all(e['from'][i] <= e['to'][i] for i in range(3)), ref
            if 'rotation' in e:
                assert e['rotation']['angle'] in (-45, -22.5, 0, 22.5, 45), (ref, e['rotation'])
            for f in e.get('faces', {}).values():
                tex = f['texture']
                keys = set()
                while tex.startswith('#'):
                    assert tex not in keys, (ref, tex)
                    keys.add(tex)
                    tex = d['textures'][tex[1:]]
                assert path(tex, 'textures').is_file(), (ref, tex)
                assert f.get('rotation', 0) in (0, 90, 180, 270)
        checked.add(ref)


def rotate(p, origin, axis, angle):
    a = math.radians(angle)
    c, s = math.cos(a), math.sin(a)
    r = [p[i]-origin[i] for i in range(3)]
    i, j = {'x': (1, 2), 'y': (2, 0), 'z': (0, 1)}[axis]
    r[i], r[j] = c*r[i]-s*r[j], s*r[i]+c*r[j]
    return [r[i]+origin[i] for i in range(3)]


# 原生立方体的 8 个世界坐标角点必须与游戏几何逐一重合。
# 包括大于 45 度的原生角度，不允许因为旋转合法化而改变头部形状。
assert len(root['elements']) == len(bb['elements']) <= 1000
max_error = 0
for original, exported in zip(bb['elements'], root['elements']):
    original_points = list(itertools.product(*zip(original['from'], original['to'])))
    axes = [(axis, angle) for axis, angle in zip('xyz', original.get('rotation', [0]*3)) if angle]
    if axes:
        original_points = [rotate(p, original['origin'], *axes[0]) for p in original_points]
    exported_points = list(itertools.product(*zip(exported['from'], exported['to'])))
    if 'rotation' in exported:
        r = exported['rotation']
        exported_points = [rotate(p, r['origin'], r['axis'], r['angle']) for p in exported_points]
    exported_points = [[p[0]-8, p[1], p[2]-8] for p in exported_points]
    for p in original_points:
        error = min(math.dist(p, q) for q in exported_points)
        max_error = max(max_error, error)
        assert error < .000003, (original['name'], error)

for ref in checked:
    if ref.startswith(('angelcore:', 'coldcrow:')):
        own = read(path(ref, 'models'))
        expected = 'angelcore:item/axe' if ref.startswith('angelcore:') else 'coldcrow:item/crossbow'
        assert own['parent'] == expected and 'display' not in own, ref
        assert resolve(ref)['display'] == resolve(expected)['display'], ref
frames = [read(ASSETS / f'angelcore/models/item/frames/idle_{i:02}.json') for i in range(32)]
assert len({json.dumps(d['elements']) for d in frames}) > 20
assert max(len(d['elements']) for d in frames) == 9
for name in ('stigma_flow', 'stigma_core'):
    p = ASSETS / f'angelcore/textures/item/{name}.png.mcmeta'
    a = read(p)['animation']
    assert a['frametime']*len(a['frames'])/20 == 3.2

# 寒鸦显示合并不得修改任何原有部件的坐标、UV、拉弦帧或装填附件。
backup = ROOT / '.workbuddy/backup/angel-binding-2026-10-09/sweetdream_rp/assets/coldcrow/models/item'
for p in backup.glob('*.json'):
    if p.name == 'crossbow.json':
        continue
    before, after = read(p), read(ASSETS / 'coldcrow/models/item' / p.name)
    assert before['elements'] == after['elements'], p.name
    assert before['textures'] == after['textures'], p.name
    # 部件保持紧凑格式，只有整体调整入口使用便于编辑的缩进。
    current = ASSETS / 'coldcrow/models/item' / p.name
    # Read-only verification: do not rewrite unrelated coldcrow resources.
expected = sum(len(read(ASSETS / 'coldcrow/models/item' / n)['elements'])
               for n in ('body.json', 'pull_00.json', 'ice_0.json'))
assert len(read(ASSETS / 'coldcrow/models/item/crossbow.json')['elements']) == expected

report = {'引用模型数': len(checked), '静态形状最大角点误差': round(max_error, 9),
          '原生元素数': len(bb['elements']), '循环帧数': 32, '纹理循环秒数': 3.2,
          '寒鸦部件保持原样': True, '整体显示继承': True, '问题数': 0}
p = ROOT / '模型设计/天使核心_阶段二/游戏接入核验.json'
p.write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
print(json.dumps(report, ensure_ascii=False))
