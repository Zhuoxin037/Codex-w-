"""Stage-one geometry for the approved 月蚀流光 concept. No pack deployment."""
from pathlib import Path
import base64
import io
import json
import math
import uuid
from collections import Counter

import numpy as np
from PIL import Image, ImageDraw, ImageFont

from model_review_io import check, export_static, renderer, save_native

OUT = Path('D:/数据包/模型设计/极光与幻梦_月蚀流光_20261010/阶段一_柄部与月牙')
OUT.mkdir(parents=True, exist_ok=True)
NAME = '极光与幻梦_柄部_分组模型'
if (OUT / (NAME + '.bbmodel')).exists():
    raise SystemExit('该工程已有 Blockbench MCP 精修成果，不得以初稿生成器覆盖。')
SEED = uuid.UUID('bb8e7c16-4b31-4ee5-99c0-6f28e40cd409')
ELEMENTS, GROUPS = [], {}
SERIAL = Counter()


def gid(name):
    return str(uuid.uuid5(SEED, name))


def group(name, parent='总体', origin=(0, 0, 0)):
    g = dict(name=name, uuid=gid('group/' + name), origin=list(origin),
             rotation=[0, 0, 0], children=[], visibility=True,
             export=True, isOpen=True, color=len(GROUPS) % 8)
    GROUPS[name] = g
    if parent is not None:
        GROUPS[parent]['children'].append(g)
    return g


group('总体', None)
for name in ['握柄', '柄尾', '护手', '单侧月牙', '两片悬晶']:
    group(name)
for name, parent in [
    ('紫皮握柄', '握柄'), ('银色纵脊', '握柄'), ('上护箍', '握柄'), ('下护箍', '握柄'),
    ('柄尾银座', '柄尾'), ('柄尾紫晶', '柄尾'),
    ('连续剑根座', '护手'), ('护手侧翼', '护手'), ('中央紫晶托座', '护手'),
    ('中央紫晶', '护手'), ('月牙金属主体', '单侧月牙'),
    ('月牙正面斜面', '单侧月牙'), ('月牙背面斜面', '单侧月牙'),
    ('月牙双面嵌色', '单侧月牙'), ('近侧悬浮晶片', '两片悬晶'),
    ('远侧悬浮晶片', '两片悬晶')]:
    group(name, parent)


# Medium-scale painted material atlas. Surface detail does not increase geometry.
PALETTE = [
    ('月银', '#bbb7c5'), ('亮银', '#ddd5db'), ('银灰', '#9591a4'), ('深钢', '#514859'),
    ('紫皮', '#302746'), ('暗紫皮', '#251f35'), ('银紫脊', '#6a5d83'), ('内衬', '#393343'),
    ('深紫晶', '#6651b7'), ('蓝紫晶', '#8773d9'), ('浅紫晶', '#b49bf0'), ('晶亮棱', '#d7c9ff'),
    ('靛晶', '#453779'), ('青晶', '#86bdce'), ('月牙嵌紫', '#9c98d2'), ('冷银', '#aaa9bf'),
]


def atlas():
    im = Image.new('RGBA', (128, 128))
    rng = np.random.default_rng(20261010)
    for i, (label, hx) in enumerate(PALETTE):
        rgb = np.array(tuple(bytes.fromhex(hx[1:])), dtype=float)
        yy, xx = np.mgrid[0:32, 0:32]
        gradient = (16 - xx) * .22 + (15 - yy) * .08
        # Broad, low-contrast tonal variation; no checkerboard or outline grid.
        coarse = rng.uniform(-2.5, 2.5, (4, 4)).repeat(8, 0).repeat(8, 1)
        shade = gradient + coarse
        if i in [4, 5]:
            shade += np.where((yy % 12) == 9, -5, 0)
            shade += np.where((yy % 12) == 10, 2, 0)
        if i >= 8 and i <= 14:
            shade += np.maximum(0, 10 - abs(xx - 9)) * .5
        tile = np.zeros((32, 32, 4), dtype=np.uint8)
        tile[:, :, :3] = np.clip(rgb + shade[:, :, None], 0, 255)
        tile[:, :, 3] = 255
        im.paste(Image.fromarray(tile), ((i % 4) * 32, (i // 4) * 32))
    im.save(OUT / '月蚀流光_柄部材质.png')
    buf = io.BytesIO()
    im.save(buf, format='PNG')
    return [dict(uuid=gid('texture/hilt'), name='月蚀流光_柄部材质.png',
                 relative_path='月蚀流光_柄部材质.png', mode='bitmap', saved=True,
                 width=128, height=128, uv_width=128, uv_height=128,
                 render_mode='default', render_sides='auto',
                 source='data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode())]


TEXTURES = atlas()


def uv(tile, variant=0):
    x, y = (tile % 4) * 32, (tile // 4) * 32
    start = 2 + (variant % 3) * 2
    return [x + start, y + 2, x + 30, y + 30]


def cube(g, label, center, size, material, rotation=(0, 0, 0), materials=None):
    SERIAL[g] += 1
    ident = gid(f'cube/{g}/{SERIAL[g]}')
    c = np.array(center, dtype=float)
    s = np.array(size, dtype=float)
    assert np.min(s) > 0
    assert sum(abs(v) > 1e-9 for v in rotation) <= 1
    assert all(v in [-45, -22.5, 0, 22.5, 45] for v in rotation)
    faces = {}
    for f in ['north', 'south', 'east', 'west', 'up', 'down']:
        mat = materials.get(f, material) if materials else material
        faces[f] = dict(uv=uv(mat, SERIAL[g] % 3), texture=0, rotation=0)
    e = dict(name=label, uuid=ident, type='cube', from_=(c-s/2).tolist())
    e['from'] = e.pop('from_')
    e.update(to=(c+s/2).tolist(), origin=c.tolist(), rotation=list(rotation),
             faces=faces, visibility=True, export=True, rescale=False, color=GROUPS[g]['color'])
    ELEMENTS.append(e)
    GROUPS[g]['children'].append(ident)
    return e


def collar(g, y, width=.91, height=.17, depth=.75):
    # Continuous octagonal band with genuine diagonal corner faces.
    cube(g, '护箍横面', (0, y, 0), (width-.24, height, depth), 0,
         materials={'north': 1, 'south': 0, 'down': 2})
    cube(g, '护箍侧面', (0, y, 0), (width, height, depth-.24), 0,
         materials={'north': 1, 'south': 0, 'down': 2})
    for sx in [-1, 1]:
        for sz in [-1, 1]:
            cube(g, '护箍斜面', (sx*(width/2-.14), y, sz*(depth/2-.14)),
                 (.22, height, .16), 1 if sz < 0 else 15,
                 rotation=(0, sx*sz*45, 0))


# A slim, practical grip. Four long bevels and restrained silver ribs.
for i in range(9):
    y = 1.04 + i*.505
    cube('紫皮握柄', '连续紫皮握柄', (0, y, 0), (.60, .513, .48), 4 if i % 4 else 5)
    for sx in [-1, 1]:
        for sz in [-1, 1]:
            cube('紫皮握柄', '握柄倒角', (sx*.275, y, sz*.215), (.145, .513, .135),
                 4 if sz < 0 else 5, rotation=(0, sx*sz*45, 0))
for x in [-.262, .262]:
    for z in [-.259, .259]:
        cube('银色纵脊', '细银纵脊', (x, 3.15, z), (.039, 4.08, .044), 6)
collar('下护箍', .72, .99, .23, .85)
collar('上护箍', 5.48, .95, .22, .79)
collar('上护箍', 5.95, .78, .15, .68)
cube('上护箍', '上护箍颈', (0, 5.72, 0), (.60, .37, .49), 3)


# Solid, broad root socket; later blade joins this width instead of a thin stem.
cube('连续剑根座', '连续剑根暗钢', (0, -.60, 0), (1.02, 1.36, .70), 7)
cube('连续剑根座', '正面靛紫剑根', (0, -.73, -.369), (.73, 1.0, .07), 12)
cube('连续剑根座', '背面靛紫剑根', (0, -.73, .369), (.73, 1.0, .07), 12)
for sx in [-1, 1]:
    for sz in [-1, 1]:
        cube('连续剑根座', '剑根月银外棱', (sx*.434, -.62, sz*.297),
             (.135, 1.34, .14), 0, rotation=(0, sx*sz*45, 0))


# Compact asymmetric guard. No orbital rings or giant round gem.
for sx in [-1, 1]:
    cube('护手侧翼', '护手暗钢横梁', (sx*.57, .31, .045), (.89, .28, .61), 3,
         rotation=(0, 0, sx*22.5))
    cube('护手侧翼', '护手银翼', (sx*.65, .40, -.03), (.85, .16, .64), 1,
         rotation=(0, 0, sx*22.5))
    cube('护手侧翼', '银翼垂边', (sx*.982, .254, .025), (.16, .32, .63), 0,
         rotation=(0, 0, sx*22.5))
cube('中央紫晶托座', '中央紫晶暗座', (0, .025, -.42), (.73, 1.48, .31), 3)
for sx in [-1, 1]:
    cube('中央紫晶托座', '紫晶侧托上', (sx*.247, .363, -.55), (.14, .72, .24), 0,
         rotation=(0, 0, -sx*22.5))
    cube('中央紫晶托座', '紫晶侧托下', (sx*.187, -.325, -.55), (.14, .65, .24), 1,
         rotation=(0, 0, sx*22.5))
cube('中央紫晶托座', '下托尖', (0, -.738, -.53), (.16, .32, .23), 1)


def crystal(g, cx, cy, cz, length, width, depth, n=11, bend=0):
    """Tapered prism with actual front/rear roof facets and distinct colors."""
    a = math.radians(22.5)
    for i in range(n):
        f = (i+.5)/n
        # Lower half longer and pointed; intentional continuous diamond silhouette.
        profile = min(f/.57, (1-f)/.43)
        w = max(.035, width * profile)
        dep = max(.045, depth * profile)
        x = cx + bend*(f-.5)
        y = cy - length/2 + length*f
        h = length/n + .002
        cube(g, '紫晶实心', (x, y, cz), (w, h, dep), 8,
             materials={'south': 12, 'east': 9, 'up': 10})
        for rear in [False, True]:
            for side in [-1, 1]:
                z = cz + (1 if rear else -1)*(dep/2 + w/4*math.tan(a))
                angle = side*22.5*(1 if rear else -1)
                mat = (9 if side == -1 else 8) if rear else (10 if side == -1 else 9)
                cube(g, '紫晶折光斜面', (x+side*w/4, y, z),
                     (w/2/math.cos(a), h, .025), mat, rotation=(0, angle, 0))
        if i in [n//2-1, n//2]:
            cube(g, '紫晶浅色细棱', (x-w*.13, y, cz-dep/2-w*.50*math.tan(a)-.017),
                 (.037, h, .026), 11)


crystal('中央紫晶', 0, .09, -.661, 1.16, .49, .16, n=10, bend=.07)
# Long pommel crystal in a restrained fitted cradle.
cube('柄尾银座', '柄尾底座', (0, 6.15, 0), (.64, .27, .57), 3)
collar('柄尾银座', 6.15, .72, .16, .61)
for sx in [-1, 1]:
    cube('柄尾银座', '柄尾银爪', (sx*.272, 6.35, .012), (.13, .48, .30), 0,
         rotation=(0, 0, -sx*22.5))
crystal('柄尾紫晶', 0, 6.98, -.013, 1.63, .62, .33, n=12, bend=.12)


# Crescent polygon in its own tilted plane. The grip stays in the opening.
MOON_OUTER = [(-.33, 5.98), (-1.29, 5.79), (-2.16, 5.22), (-2.78, 4.39),
              (-3.01, 3.41), (-2.94, 2.41), (-2.55, 1.53), (-1.87, .83),
              (-.97, .39), (-.45, .33)]
MOON_INNER = [(-.45, .33), (-1.39, 1.11), (-1.92, 1.87), (-2.20, 2.62),
              (-2.23, 3.39), (-2.04, 4.19), (-1.51, 5.05), (-.33, 5.98)]
POLY = MOON_OUTER + MOON_INNER[1:]
TILT = math.radians(22.5)
COS, SIN = math.cos(TILT), math.sin(TILT)


def moon_cube(g, label, center, size, mat, local_angle=0):
    x, y, z = center
    c = (COS*x + SIN*z, y, -SIN*x + COS*z + .10)
    return cube(g, label, c, size, mat, rotation=(0, 22.5+local_angle, 0))


def intersections(poly, y):
    xs = []
    for p, q in zip(poly, poly[1:]+poly[:1]):
        if min(p[1], q[1]) <= y < max(p[1], q[1]):
            xs.append(p[0]+(y-p[1])*(q[0]-p[0])/(q[1]-p[1]))
    return sorted(xs)


moon_rows = 31
dy = (5.98-.33)/moon_rows
for i in range(moon_rows):
    y = .33 + (i+.5)*dy
    xs = intersections(POLY, y)
    assert len(xs) == 2, (i, xs)
    left, right = xs
    w = right-left
    x = (left+right)/2
    core_depth = min(.34, .08+w*.50)
    moon_cube('月牙金属主体', '月牙连续金属', (x, y, 0), (w, dy+.002, core_depth), 2)
    for rear in [False, True]:
        for side in [-1, 1]:
            sign = 1 if rear else -1
            z = sign*(core_depth/2 + w/4*math.tan(TILT))
            angle = side*22.5*(1 if rear else -1)
            # The crescent has two real sloped surfaces on each face.
            mat = (0 if side == -1 else 15) if rear else (1 if side == -1 else 0)
            moon_cube('月牙背面斜面' if rear else '月牙正面斜面', '月牙折面',
                      (x+side*w/4, y, z), (w/2/COS, dy+.002, .045), mat, angle)
    if 8 <= i <= 23:
        for rear in [False, True]:
            sign = 1 if rear else -1
            z = sign*(core_depth/2 + w/2*math.tan(TILT)+.032)
            mat = 13 if 11 <= i <= 16 else 14
            moon_cube('月牙双面嵌色', '月牙青紫嵌线', (x, y, z),
                      (min(.17, w*.32), dy+.003, .03), mat)

# The lower end is mechanically connected to the guard; no disconnected crescent.
moon_cube('月牙金属主体', '月牙下端连接', (-.45, .365, .018), (.43, .22, .35), 0)
moon_cube('月牙金属主体', '月牙上端连接', (-.36, 5.91, .01), (.38, .19, .29), 0)

# Two fragments only, with different depths; sizes follow the approved concept.
crystal('近侧悬浮晶片', 1.39, 2.98, -.38, 1.31, .31, .16, n=8, bend=-.09)
crystal('远侧悬浮晶片', 1.90, 4.53, .54, .99, .28, .15, n=7, bend=.10)
GROUPS['近侧悬浮晶片']['origin'] = [1.39, 2.98, -.38]
GROUPS['远侧悬浮晶片']['origin'] = [1.90, 4.53, .54]
GROUPS['柄尾紫晶']['origin'] = [0, 6.98, 0]
GROUPS['中央紫晶']['origin'] = [0, .09, -.661]

DISPLAY = {
    'thirdperson_righthand': {'rotation': [0, 90, -180], 'translation': [0, 0, 0], 'scale': [.8, .8, .8]},
    'thirdperson_lefthand': {'rotation': [0, -90, 180], 'translation': [0, 0, 0], 'scale': [.8, .8, .8]},
    'firstperson_righthand': {'rotation': [0, -15, 175], 'translation': [1.5, 1.5, 0], 'scale': [.72, .72, .72]},
    'firstperson_lefthand': {'rotation': [0, 15, -175], 'translation': [1.5, 1.5, 0], 'scale': [.72, .72, .72]},
    'gui': {'rotation': [0, 0, 145], 'translation': [0, -2.2, 0], 'scale': [1.30, 1.30, 1.30]},
    'ground': {'rotation': [0, 0, 180], 'translation': [0, 1, 0], 'scale': [.45, .45, .45]},
    'fixed': {'rotation': [0, 0, 180], 'translation': [0, 0, 0], 'scale': [1, 1, 1]},
}

check(ELEMENTS, GROUPS, '总体', TEXTURES)
native = save_native(OUT, NAME, ELEMENTS, GROUPS, '总体', TEXTURES, DISPLAY)
overall, count = export_static(OUT, 'aurora_dream_hilt', 'auroradream', ELEMENTS,
                               GROUPS, '总体', TEXTURES, DISPLAY)

# This Java-format bbmodel opens directly in Blockbench's Display workspace.
# It contains the same real groups and all geometry in one editable project.
java_bb = json.loads(native.read_text(encoding='utf-8'))
java_bb['meta']['model_format'] = 'java_block'
java_bb['meta']['bone_rig'] = False
java_bb['name'] = '极光与幻梦_柄部_整体显示调整'
for e in java_bb['elements']:
    for key in ['from', 'to', 'origin']:
        e[key] = [round(v+8, 7) for v in e[key]]
for g in java_bb['groups']:
    g['origin'] = [v+8 for v in g['origin']]
display_native = OUT / '极光与幻梦_柄部_整体显示调整.bbmodel'
display_native.write_text(json.dumps(java_bb, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')

# Numerical match between the grouped native model and its Java overall export.
exported = json.loads(overall.read_text(encoding='utf-8'))
assert len(exported['elements']) == len(ELEMENTS)
for e, q in zip(ELEMENTS, exported['elements']):
    for key in ['from', 'to']:
        assert max(abs(a+8-b) for a, b in zip(e[key], q[key])) < .000001
    r = q.get('rotation')
    if r:
        ax = 'xyz'.index(r['axis'])
        assert e['rotation'][ax] == r['angle']
        assert max(abs(a+8-b) for a, b in zip(e['origin'], r['origin'])) < .000001

ns = renderer(native)
render = ns['render']
bg = (19, 20, 24)
font = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 29)
small = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 20)
tiny = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 17)
board = Image.new('RGB', (1600, 1100), bg)
board.paste(render((730, 825), yaw=0, pitch=0, scale=75, focus=(-.35, 3.25, .1)), (0, 125))
board.paste(render((790, 490), yaw=-.56, pitch=.15, scale=45, focus=(-.50, 3.2, .1)), (780, 126))
board.paste(render((430, 350), yaw=math.pi, pitch=0, scale=33, focus=(-.5, 3.25, .1)), (765, 620))
board.paste(render((350, 350), yaw=1.4, pitch=.07, scale=33, focus=(-.5, 3.25, .1)), (1230, 620))
d = ImageDraw.Draw(board)
d.text((33, 23), '极光与幻梦 · 月蚀流光', font=font, fill='#dfd6f0')
d.text((34, 69), '阶段一 · 握柄 / 单侧月牙 / 两片悬晶 · 实际分组模型渲染', font=small, fill='#a8a1b6')
d.text((48, 940), '正面：留出握持空间，月牙独立于握柄平面', font=small, fill='#c5bfd2')
d.text((809, 608), '斜侧：月牙双面斜棱与中央紫晶托座', font=small, fill='#c5bfd2')
d.text((785, 967), '背面', font=small, fill='#c5bfd2')
d.text((1260, 967), '侧面：悬晶前后错开', font=small, fill='#c5bfd2')
d.line((32, 1005, 1568, 1005), fill='#40394d', width=1)
d.text((34, 1028), f'{count} 个立方体 · {len(GROUPS)} 个分组 · 柄部阶段，尚未制作剑刃及动画', font=small, fill='#a8a1b6')
d.text((34, 1061), '新建审阅工程；未接入游戏。后续剑刃将与下方实心宽座连续衔接。', font=tiny, fill='#8a819a')
preview = OUT / '极光与幻梦_柄部_实际模型.png'
board.save(preview)
render((1100, 960), yaw=-.50, pitch=.10, scale=86, focus=(-.55, 3.25, .1)).save(OUT / '极光与幻梦_柄部_斜侧细节.png')

scene = ns['scene']()
bounds = np.concatenate([v for e, v, m in scene])
report = dict(cubes=count, faces=sum(len(q['faces']) for q in exported['elements']),
              groups=len(GROUPS), per_group=dict(SERIAL),
              bounds={'min': bounds.min(0).tolist(), 'max': bounds.max(0).tolist()},
              checks={'group_ownership': True, 'texture_uvs': True,
                      'java_legal_rotations': True, 'java_coordinate_limits': True,
                      'native_export_match': True, 'deploy': False},
              artifacts={'native': str(native), 'java_display_project': str(display_native),
                         'overall_json': str(overall), 'actual_preview': str(preview)})
(OUT / '模型检查.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
(OUT / '阶段说明.md').write_text(f'''# 极光与幻梦 · 月蚀流光 · 阶段一

2026-10-10。按用户确认的全新「月蚀流光」设计制作柄部；此前三版不复用。

本阶段完成握柄、单侧月牙、中央长紫晶、柄尾紫晶、两片悬晶及连续剑根座。
{count} 个立方体，{len(GROUPS)} 个真实分组。预览从交付工程的立方体、旋转和 UV 渲染，未使用概念图替代模型。
月牙正背面都有真实斜面与青紫嵌色；两片悬晶在前后不同位置。
剑刃、刃内极光、待机和施法动画将在后续阶段制作。当前未绑定或部署。

## 编辑

- `极光与幻梦_柄部_分组模型.bbmodel`：原点居中的分组原始工程。
- `极光与幻梦_柄部_整体显示调整.bbmodel`：相同分组、相同几何的 Java 方块格式工程，供 Blockbench「显示」工作区调整总体握姿。
- `显示调整示例/assets/auroradream/models/item/aurora_dream_hilt.json`：含完整几何和 display 的总体 JSON，不是只有 parent 的包装文件。贴图位于对应 assets 的 textures 路径。

所有部分在「总体」下分组；调整握姿请使用「显示」工作区的第一/第三人称项，整件一起调整。
独立移动握柄分组会改变其与护手/月牙的连接位置；不应当用该操作代替整件 display。
本阶段预置握姿只供审阅，待完整剑身与动画制作后校准。
静态阶段没有动画；分组为后续晶片漂浮与施法动作保留。

## 验证

已检查分组唯一归属、无孤立元素、UV、贴图内嵌、Java 合法单轴旋转及坐标范围。
总体 JSON 与原始工程的立方体坐标及旋转逐个比对通过。
背面和侧面有实际几何预览。尚未在运行中的 Blockbench/Minecraft 内实测。
''', encoding='utf-8')
print(json.dumps(report, ensure_ascii=False, indent=2))
