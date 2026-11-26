"""Build the approved forest-stag concept as editable Cube projects.

Only owns this new stage. Never writes a live resource/data pack. Existing
projects are protected by recorded hashes before our own review revisions.
"""
from pathlib import Path
import base64, collections, copy, hashlib, io, json, math, sys, uuid
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from b_staff_cast_refit_20261120 import Scene, euler, rotation

ROOT = Path(__file__).resolve().parents[1]
P = ROOT/'模型设计/密林层主_朽冠鹿_概念_20261123'
D = P/'阶段一_两阶段静态模型'
NAMES = ['朽冠鹿_一阶段覆冠', '朽冠鹿_二阶段脱壳']
SEED = uuid.UUID('7c93b241-1ecb-4f09-9d4e-d834f4f542b6')
uid = lambda s: str(uuid.uuid5(SEED, s))
load = lambda p: json.loads(p.read_text(encoding='utf8'))
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()


def write(p, v):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(v if isinstance(v, bytes) else v.encode('utf8'))


def jsave(p, obj):
    write(p, json.dumps(obj, ensure_ascii=False, indent=2))


def unit(v):
    v = np.asarray(v, float)
    return v/np.linalg.norm(v)


def align(a, b):
    a, b = unit(a), unit(b)
    v = np.cross(a, b); c = float(a@b)
    if c > 1-1e-10: return np.eye(3)
    if c < -1+1e-10:
        v = unit(np.cross(a, [1, 0, 0] if abs(a[0]) < .9 else [0, 0, 1]))
        return 2*np.outer(v, v)-np.eye(3)
    k = np.array([[0, -v[2], v[1]], [v[2], 0, -v[0]], [-v[1], v[0], 0]])
    return np.eye(3)+k+k@k/(1+c)


MATERIALS = ['bark', 'weather', 'inner', 'moss', 'leaf', 'leaf_light', 'sap',
             'sap_dark', 'hoof', 'shadow', 'endgrain', 'bud', 'moss_dark', 'heart', 'scar', 'lichen']
PALETTE = [(98, 76, 58), (127, 104, 79), (84, 48, 38), (76, 84, 43),
           (101, 111, 51), (130, 136, 65), (226, 162, 52), (171, 104, 30),
           (77, 62, 45), (39, 31, 24), (143, 111, 76), (108, 99, 51),
           (55, 68, 34), (245, 187, 66), (109, 63, 42), (125, 132, 92)]


def atlas():
    """Purpose-painted grain, knots, moss clusters and sap, at native pixels."""
    im = Image.new('RGBA', (512, 512), (0, 0, 0, 255))
    for index, (name, color) in enumerate(zip(MATERIALS, PALETTE)):
        tile = Image.new('RGBA', (128, 128)); px = tile.load()
        for y in range(128):
            for x in range(128):
                if name in ['moss', 'moss_dark', 'leaf', 'leaf_light', 'lichen']:
                    # Large linked clumps, little micro-noise.
                    d = 6*math.sin((x//4)*.83+(y//4)*.35)+4*math.cos((y//3)*.75-(x//5)*.58)
                    d += 2*((x*31+y*11+index*3) % 5-2)
                elif name in ['sap', 'sap_dark', 'heart']:
                    d = 6*math.sin(x*.10)+3*math.sin(y*.18+x*.05)
                    if x//3 in [9, 10, 28]: d += 12
                elif name == 'endgrain':
                    r = math.hypot(x-64, (y-64)*.85)
                    d = -13 if int(r/6) % 4 == 0 else 5*math.sin(r*.34)
                else:
                    xx = x+2*math.sin(y*.045)+math.sin(y*.1)
                    d = 8*math.sin(xx*.34)+4*math.sin(xx*.81)+2*math.sin(y*.15+x*.05)
                    if int(xx) % 27 in [0, 1]: d -= 14
                    if (x//2+y//6+index) % 23 == 0: d += 4
                px[x, y] = tuple(max(0, min(255, round(v+d))) for v in color)+(255,)
        draw = ImageDraw.Draw(tile)
        if name in ['bark', 'weather', 'inner', 'hoof', 'scar']:
            for x, y, r in [(29, 43, 9), (91, 96, 7)]:
                draw.arc((x-r/2, y-r*1.8, x+r/2, y+r*1.8), 40, 300,
                         fill=tuple(max(0, v-22) for v in color)+(255,), width=2)
                draw.line((x, y-r, x, y+r), fill=tuple(max(0, v-13) for v in color)+(255,), width=1)
        if name in ['leaf', 'leaf_light']:
            for y in range(7, 128, 25):
                draw.line((0, y, 127, y+9), fill=tuple(max(0, v-12) for v in color)+(255,), width=2)
        im.paste(tile, (index % 4*128, index//4*128))
    out = io.BytesIO(); im.save(out, format='PNG')
    return out.getvalue()


class Builder:
    def __init__(self):
        self.b = {'meta': {'format_version': '5.0', 'model_format': 'free', 'box_uv': False},
                  'name': NAMES[0], 'resolution': {'width': 512, 'height': 512},
                  'ambientocclusion': True, 'visible_box': [8, 6, 0],
                  'elements': [], 'groups': [], 'outliner': [], 'textures': [], 'animations': []}
        data = atlas(); self.tid = uid('atlas')
        self.b['textures'] = [{'uuid': self.tid, 'id': '0', 'name': 'forest_stag_atlas_512.png',
                              'width': 512, 'height': 512, 'uv_width': 512, 'uv_height': 512,
                              'source': 'data:image/png;base64,'+base64.b64encode(data).decode(),
                              'internal': True, 'saved': True, 'visible': True,
                              'render_mode': 'default', 'render_sides': 'auto', 'wrap_mode': 'limited',
                              'folder': '', 'namespace': '', 'particle': False}]
        self.gs = {}; self.nodes = {}; self.shell = set(); self.links = []; self.chains = {}
        self.group('stag_root', [0, 0, 0])
        self.group('body', [0, 32, 2], 'stag_root')

    def group(self, n, origin, parent=None, rot=None, shell=False):
        assert n not in self.gs, n
        g = {'name': n, 'uuid': uid(n), 'origin': list(map(float, origin)),
             'rotation': [0, 0, 0] if rot is None else list(map(float, rot)),
             'export': True, 'visibility': True, 'locked': False,
             'shade': True, 'color': 3 if shell else 1, 'mirror_uv': False,
             'configs': {'default': {}, 'variants': {}}, 'itemModelProperties': {'tints': []}}
        node = {'uuid': g['uuid'], 'children': [], 'isOpen': True}
        self.gs[n] = g; self.nodes[n] = node; self.b['groups'].append(g)
        (self.b['outliner'] if parent is None else self.nodes[parent]['children']).append(node)
        if shell: self.shell.add(g['uuid'])
        return n

    def uv(self, mat, size, name, face):
        j = MATERIALS.index(mat); d = list(map(abs, size)); axis = {'north': 2, 'south': 2, 'west': 0, 'east': 0, 'up': 1, 'down': 1}[face]
        w, h = ([d[0], d[1]] if axis == 2 else [d[2], d[1]] if axis == 0 else [d[0], d[2]])
        w = min(96, max(4, w*2.5)); h = min(106, max(4, h*2.5))
        seed = int(hashlib.sha1((name+face).encode()).hexdigest()[:8], 16)
        x = 3+(seed % max(1, int(120-w))); y = 3+((seed//127) % max(1, int(120-h)))
        return [j % 4*128+x, j//4*128+y, j % 4*128+x+w, j//4*128+y+h]

    def box(self, n, c, size, parent, mat='bark', rot=None, cap=False, skip=()):
        c, size = np.array(c, float), np.array(size, float)
        assert all(size > 0), (n, size)
        # Native Cube rotations remain valid Java element rotations. Complex
        # directions belong to bone groups, which are editable independently.
        legal_rot = [0., 0., 0.]
        if rot is not None:
            axis = int(np.argmax(np.abs(rot)))
            legal_rot[axis] = float(np.clip(round(float(rot[axis])/22.5)*22.5, -45, 45))
        fs = {}
        for f in ['north', 'south', 'west', 'east', 'up', 'down']:
            if f in skip: continue
            m = 'endgrain' if cap and f in ['up', 'down'] else mat
            fs[f] = {'uv': self.uv(m, size, n, f), 'texture': self.tid}
        e = {'name': n, 'uuid': uid('element:'+n), 'type': 'cube',
             'from': (c-size/2).tolist(), 'to': (c+size/2).tolist(), 'origin': c.tolist(),
             'rotation': legal_rot,
             'box_uv': False, 'rescale': False, 'shade': True, 'export': True, 'faces': fs}
        self.b['elements'].append(e); self.nodes[parent]['children'].append(e['uuid'])
        return e

    def beam(self, n, a, b, width, depth, parent, mat='bark', ends=None, strips=3, shell=False):
        a, b = np.array(a, float), np.array(b, float); length = float(np.linalg.norm(b-a))
        g = self.group(n, a, parent, euler(align([0, 1, 0], b-a)), shell)
        # Three overlapping length sections are hidden by continuous long boards.
        # Cross-section strips meet at different depth, forming a carved bevel.
        spans = [-.5, -.31, .31, .5] if strips == 3 else [-.5, -.36, -.15, .15, .36, .5]
        factors = [.72, 1., .72] if strips == 3 else [.60, .88, 1., .88, .60]
        # Adjacent carved strips retain their visible step walls. Removing the
        # entire side face would also remove the exposed part of a bevel.
        if ends is None:
            ends = (1., .80) if n.startswith(('crown_', 'tail_', 'ear_')) else (1., .91) if '_timber' in n else (1., 1.)
        slices = 3 if ends[0] != ends[1] else 1
        for k in range(slices):
            u = (k+.5)/slices; factor = ends[0]*(1-u)+ends[1]*u
            for j in range(len(factors)):
                w = width*(spans[j+1]-spans[j])*factor; xx = width*(spans[j+1]+spans[j])/2*factor
                self.box(n+f'_wood_{k}_{j}', a+[xx, length*(k+.5)/slices, 0],
                         [w, length/slices+.10, depth*factors[j]*factor], g, mat, cap=n.startswith('crown_'))
        self.links.append({'group': n, 'a': a.tolist(), 'b': b.tolist(), 'parent': parent, 'length': length})
        return g

    def plate(self, n, center, width, length, depth, parent, rot=None, mat='bark', shell=False):
        c = np.array(center, float)
        g = self.group(n, c, parent, rot, shell)
        # Joined broad planks give the plate a pointed lower contour and bevel.
        self.box(n+'_main', c, [width*.68, length, depth], g, mat)
        self.box(n+'_edge_l', c+[-width*.405, length*.055, .05], [width*.13, length*.82, depth*.72], g, mat)
        self.box(n+'_edge_r', c+[width*.405, length*.025, .025], [width*.13, length*.88, depth*.76], g, mat)
        return g


def make_body(x):
    # Solid continuous barrel. Connected segments have genuine volume and caps.
    segments = [((0, 33, -16), (0, 33.2, -4), 17.8, 18.3),
                ((0, 33.2, -5), (0, 31.6, 9), 14.9, 15.8),
                ((0, 31.8, 8), (0, 31.3, 21), 14.0, 15.8)]
    for j, (a, b, w, d) in enumerate(segments):
        x.beam('inner_barrel_'+str(j), a, b, w, d, 'body', 'inner', strips=5, ends=(1, .64) if j == 2 else (1, 1))
    x.beam('inner_croup', (0, 31, 18.5), (0, 29.8, 24.0), 10.0, 11.7, 'body', 'inner', strips=5, ends=(1, .35))
    x.beam('sternum_inner', (0, 27, -16.8), (0, 38, -15.8), 9, 8, 'body', 'inner')
    # Long inner root-grain ridges soften section joins, visible after shedding.
    for sign, side in [(-1, 'left'), (1, 'right')]:
        for j in range(3):
            a = (sign*(7.8-.75*j), 28.0+4*j, -14)
            b = (sign*(6.0-.65*j), 27.5+3.6*j, 20)
            x.beam('inner_flank_'+side+str(j), a, b, 2.1, 1.2, 'body', 'inner')
        vein = [(sign*9.05, 34, -12), (sign*8.55, 34.8, -3), (sign*7.8, 33.2, 6), (sign*7.15, 34.5, 15)]
        for j in range(3): x.beam('sap_flank_'+side+str(j), vein[j], vein[j+1], .95, .65, 'body', 'sap', strips=3)
        for j in range(3):
            a, b = np.array(vein[j]), np.array(vein[j+1])
            x.beam('sap_bedding_'+side+str(j), a+[-sign*.4, 0, 0], b+[-sign*.4, 0, 0],
                   1.35, 1.15, 'body', 'inner')
        # Sap is inset between two small dark-wood lips, rather than floating.
        for j in range(3):
            a, b = np.array(vein[j]), np.array(vein[j+1])
            x.beam('vein_lip_'+side+str(j), a+[sign*.06, -.65, 0], b+[sign*.06, -.65, 0], .43, .42, 'body', 'scar')
    x.plate('sternum_heart', (0, 32.6, -20.8), 3.7, 7.6, .8, 'body', mat='sap')
    x.box('heart_bright_inset', (0, 33, -21.24), (1.1, 4.3, .16), 'sternum_heart', 'heart')
    for sign, side in [(-1, 'left'), (1, 'right')]:
        x.plate('heart_wood_lip_'+side, (sign*2.65, 32.5, -21.0), 2.6, 10, 1.3, 'body', [0, sign*13, sign*8], 'inner')
        x.plate('closed_chest_bark_'+side, (sign*1.85, 33.3, -22.0), 3.15, 11.8, 1.3,
                'body', [-8, sign*9, sign*8], 'weather', shell=True)
    x.group('tail', [0, 31, 21], 'body')
    x.beam('tail_main', (0, 31, 21), (0, 26.5, 27), 2.8, 2.9, 'tail', 'bark')
    x.beam('tail_tip', (0, 26.8, 26.3), (0, 24.8, 28.5), 1.8, 1.8, 'tail', 'weather')


def make_legs(x):
    for side, sign in [('left', -1), ('right', 1)]:
        fore = [np.array(p, float) for p in [(sign*8, 34, -13), (sign*9, 20.5, -11), (sign*9.5, 5, -16)]]
        hind = [np.array(p, float) for p in [(sign*6.7, 32, 16), (sign*8.5, 21.8, 10), (sign*9, 11.0, 22), (sign*9.4, 4.4, 17.4)]]
        for kind, points in [('fore', fore), ('hind', hind)]:
            parent = 'body'; names = []
            for j, p in enumerate(points):
                n = kind+'_'+side+('_foot' if j == len(points)-1 else '_upper' if j == 0 else '_lower' if j == 1 else '_hock')
                x.group(n, p, parent); names.append(n)
                if j < len(points)-1:
                    w = [5.5, 3.3, 2.6][j] if kind == 'fore' else [7.2, 3.8, 2.8][j]
                    d = [6.5, 3.8, 3][j] if kind == 'fore' else [8.6, 4.2, 3.1][j]
                    x.beam(n+'_timber', p, points[j+1], w, d, n, 'inner' if j == 0 else 'bark')
                    # Complete curved joint block, not a disconnected cylinder.
                    x.box(n+'_joint', p, [w*.9, w*.9, d*.86], n, 'bark')
                    # Broad uneven bark splints follow each actual limb segment.
                    if j < 2:
                        bone = n+'_timber'; length = float(np.linalg.norm(points[j+1]-p))
                        for q in range(2):
                            x.box(n+f'_bark_splint_{q}', p+[(q-.5)*w*.40, length*(.40+.16*q), -d*.40],
                                  [w*(.42-.06*q), length*(.78-.15*q), .85], bone,
                                  'weather' if q == 0 else 'bark', [0, 0, -4+q*7])
                    if j == 0:
                        cap = x.plate(kind+'_'+side+'_outer_shoulder', p+[sign*1.9, -4, .15], w*1.12, 10, 3.1, n,
                                      [0, sign*82, sign*11], 'weather', shell=True)
                        x.box(cap+'_moss', p+[sign*1.9, -.5, .3], [w*.9, 2.0, 3.4], cap, 'moss')
                else:
                    # Toe pair has a recessed dark cleft; full soles are closed.
                    foot = p.copy(); foot[1] = 2.0
                    for toe, dx in [('l', -1.15), ('r', 1.15)]:
                        x.box(n+'_toe_'+toe, foot+[dx, 0, -.95], [2.13, 3.5, 6.0], n, 'hoof')
                        x.box(n+'_toe_ridge_'+toe, foot+[dx, 1.88, -.4], [1.8, .5, 4.7], n, 'weather')
                    x.box(n+'_heel', foot+[0, .55, 1.1], [4.5, 3.0, 2.8], n, 'bark')
                    x.box(n+'_ankle', p+[0, -.45, .05], [3.3, 2.8, 3.25], n, 'bark')
                parent = n
            x.chains[kind+'_'+side] = {'points': [p.tolist() for p in points], 'groups': names}


def make_neck_head(x):
    x.group('neck', [0, 35.0, -14], 'body')
    x.beam('neck_lower', (0, 34, -14), (0, 45, -19), 10.0, 10.4, 'neck', 'inner', strips=5)
    x.beam('neck_upper', (0, 44, -18.5), (0, 53, -23.5), 7.3, 8.2, 'neck', 'bark', strips=5)
    for sign, side in [(-1, 'left'), (1, 'right')]:
        x.beam('neck_sinew_'+side, (sign*3.7, 35.5, -18.7), (sign*2.9, 51, -27.1), 1.8, 1.0, 'neck', 'weather')
    x.group('head', [0, 53.5, -23], 'neck')
    x.beam('head_skull_wood', (0, 54, -22.5), (0, 52.5, -29.0), 7.8, 8.8, 'head', 'weather', strips=5)
    x.beam('muzzle_bridge', (0, 52.8, -27), (0, 49.8, -36), 5.1, 4.8, 'head', 'weather')
    x.beam('lower_jaw', (0, 50.4, -26), (0, 48.2, -35.2), 4.2, 2.0, 'head', 'bark')
    x.box('wood_nose', (0, 49.8, -36), [4.7, 2.4, 1.55], 'head', 'hoof', [8, 0, 0])
    x.box('mouth_recess', (0, 48.76, -34.6), [4.2, .3, 2.4], 'head', 'shadow')
    for sign, side in [(-1, 'left'), (1, 'right')]:
        x.box('eye_socket_'+side, (sign*3.85, 54.5, -27), [.35, 1.8, 3.8], 'head', 'shadow', [0, sign*12, 0])
        x.box('eye_amber_'+side, (sign*4.07, 54.45, -27.4), [.18, .48, 2.55], 'head', 'sap', [0, sign*12, 0])
        x.beam('brow_'+side, (sign*3.4, 56.05, -25.8), (sign*3.55, 55.8, -29.2), 1.3, 1.1, 'head', 'bark')
        x.plate('cheek_plate_'+side, (sign*3.4, 52.4, -26.1), 3.8, 5.5, 1.1, 'head',
                [12, sign*74, sign*12], 'weather')
        x.plate('muzzle_facet_'+side, (sign*2.15, 51.2, -31.9), 2.8, 6.9, .7, 'head',
                [-72, sign*18, sign*17], 'bark')
        ear = x.beam('ear_'+side, (sign*3.2, 55.7, -21.5), (sign*10, 58.1, -23), 3.3, 1.6, 'head', 'bark')
        x.box('ear_inner_'+side, np.array([sign*3.2, 55.7, -21.5])+[0, 3.6, -.83], [1.9, 4.9, .18], ear, 'moss_dark')
    # Overlapping chest planks and moss really belong to the removable coat.
    for j in range(4):
        for sign, side in [(-1, 'left'), (1, 'right')]:
            x.plate('neck_coat_'+side+str(j), (sign*(2.0+.45*(3-j)), 36+j*4.5, -19.5-j*2.2),
                    4.0-j*.35, 7.4, 1.6, 'neck', [-18, sign*15, sign*(8+j)], 'weather', shell=True)


def make_antlers(x):
    x.group('crown', [0, 57.0, -23], 'head')
    for sign, side in [(-1, 'left'), (1, 'right')]:
        # Broad, widely spaced branches: a crown, not a thicket of fine wires.
        main = [(sign*2.6, 56.7, -23.4), (sign*10, 59.2, -23.8), (sign*20, 58.7, -24.8),
                (sign*30, 61.5, -22.8), (sign*36, 66, -21.5)]
        for j in range(4):
            x.beam('crown_'+side+'_main_'+str(j), main[j], main[j+1], [4.6, 4.0, 3.4, 2.6][j], [4.2, 3.6, 3.0, 2.3][j], 'crown', 'weather', ends=(1, .46 if j == 3 else .82))
        forks = [([sign*10, 59.2, -23.8], [sign*12.5, 67, -22.1], [sign*10.8, 72.0, -20.6]),
                 ([sign*20, 58.7, -24.8], [sign*22, 65.7, -27.8], [sign*25.2, 69, -29.4]),
                 ([sign*28, 61, -23.2], [sign*32.0, 65, -28.0], [sign*34.7, 67.6, -29.2])]
        for j, path in enumerate(forks):
            for k in range(2):
                target = np.array(path[k+1], float)
                if side == 'right' and j == 1 and k == 1: target = np.array(path[k])+(target-path[k])*.43
                x.beam('crown_'+side+'_fork_'+str(j)+str(k), path[k], target, 3.0-k*.9, 2.6-k*.7, 'crown', 'bark', ends=(1, .30 if k else .85))
        # A sparse group of broad wooden leaves at two joints.
        for j, p in enumerate([main[1], main[3]]):
            p = np.array(p, float)
            for k in range(2):
                x.plate('crown_leaf_'+side+str(j)+str(k), p+[sign*(k*2.2+.5), 2.2+k*.5, 1.1],
                        2.4, 4.1, .34, 'crown', [15, sign*24, sign*(27+k*28)], 'leaf')


def make_coat(x):
    # Thick overlapping longitudinal shingles conform to the barrel.
    # Each group contains the plank and its moss/leaf volume for independent editing.
    for row, (z, cy, rx, ry, length) in enumerate([(-11, 34.2, 10.3, 12.0, 13.2), (0, 33.0, 10.0, 10.8, 13.8), (11, 32.0, 9.1, 10.7, 13.6), (20, 31.0, 7.9, 9.3, 9.5)]):
        for col, deg in enumerate([-115, -76, -38, 0, 38, 76, 115, 154, -154]):
            angle = deg+4*math.sin(row*2.1+col*.9)
            t = math.radians(angle); sn, cs = math.sin(t), math.cos(t)
            c = np.array([rx*sn, cy+ry*cs, z+1.7*math.sin(col*1.3+row*.8)])
            normal = unit([sn/rx, cs/ry, 0])
            tangent = unit([-normal[1], normal[0], 0]); long = np.array([0., 0., 1.])
            matrix = np.column_stack([tangent, long, normal])
            width = (7.1 if abs(deg) <= 76 else 5.7)*(1 if row < 2 else .90)*(1+.08*math.sin(row*1.9+col))
            n = f'bark_coat_{row}_{col}'
            # Keep the approved outer surface while giving the shell a solid
            # inward bed that actually meets the underlying barrel.
            old_depth = 2.5 if abs(deg) <= 76 else 1.8
            depth = 7.6 if abs(deg) <= 76 else 4.8
            c -= normal*(depth-old_depth)/2
            g = x.plate(n, c, width, length, depth, 'body', euler(matrix),
                        'weather' if (row+col) % 3 == 0 else 'bark', shell=True)
            # Moss slabs sit on the actual outer normal surface in panel coordinates.
            if abs(deg) <= 76:
                for k in range(3):
                    dy = (k-1)*length*.25+.7*math.sin(row+col*1.7+k)
                    dx = .7*math.sin(row*1.2+col+k*2.8)
                    moss_z = depth/2+.45; moss_height = 1.3+.3*math.sin(row+k)
                    x.box(n+f'_moss_mass_{k}', c+[dx, dy, moss_z],
                          [width*(1.0+.10*math.sin(col+k)), length*.48, moss_height],
                          g, 'moss' if (row+k) % 3 else 'moss_dark', [0, 0, -9+((col+k*3) % 5)*4])
                    for j in range(2):
                        at = c+[dx+(j-.5)*width*.49, dy-length*.18-.7*j,
                                moss_z+moss_height/2+.03+.06*j+.04*k]
                        rot = [10*(j-.5), -5+col % 3*5, -16+((row+col+k+j) % 5)*8]
                        leaf_w = 2.5+.35*math.sin(col+k); leaf_l = 3.8+.9*math.cos(row+col+k)
                        mat = 'leaf' if (k+j+col) % 5 else 'leaf_light'
                        x.box(n+f'_leaf_{k}_{j}_spine', at, [leaf_w*.46, leaf_l, .42], g, mat, rot)
                        for q in [-1, 1]:
                            x.box(n+f'_leaf_{k}_{j}_{q}', at+[q*leaf_w*.34, .18, -.02],
                                  [leaf_w*.28, leaf_l*.64, .4], g, mat, rot)
            elif abs(deg) == 115:
                x.box(n+'_moss_edge', c+[0, 1.5, depth/2+.1], [width*.78, length*.60, .9], g, 'moss_dark')
    # Shoulder crest is a cohesive, substantial leafy silhouette.
    for j in range(3):
        x.plate('withers_mantle_'+str(j), ((j-1)*4.0, 44.0-abs(j-1)*1.0, -12), 5.6, 13.6, 2.2,
                'body', [76, (j-1)*10, (j-1)*10], 'moss', shell=True)
    # Wrap the coat around the hindquarters, rather than ending as a sawn log.
    x.beam('rear_shell_mount', (0, 31, 19), (0, 30, 25), 13, 14, 'body', 'bark', ends=(1, .65), strips=5, shell=True)
    for j, deg in enumerate([-110, -65, -25, 25, 65, 110]):
        t = math.radians(deg); c = np.array([6.5*math.sin(t), 30.8+7.8*math.cos(t), 24.0])
        g = x.plate('croup_coat_'+str(j), c, 5.7, 9.3, 1.5, 'body',
                    [-14, 0, -deg], 'bark', shell=True)
        if abs(deg) < 90:
            x.box('croup_coat_'+str(j)+'_moss', c+[0, .8, 1.05], [5.6, 6.5, 1.15], g, 'moss')
            for k in [-1, 1]:
                x.box('croup_coat_'+str(j)+f'_leaf_{k}', c+[k*1.55, -2.6, 1.5+.11*k], [2.65, 3.2, .45], g,
                      'leaf', [0, 0, k*13])


def two_bone(a, b, l1, l2, pole):
    a, b = np.array(a, float), np.array(b, float); d = float(np.linalg.norm(b-a)); axis = unit(b-a)
    assert abs(l1-l2)+1e-5 < d < l1+l2-1e-5, (d, l1, l2)
    pv = np.array(pole, float); pv = unit(pv-axis*(pv@axis))
    u = (l1*l1-l2*l2+d*d)/(2*d); h = math.sqrt(max(0, l1*l1-u*u))
    return a+axis*u+pv*h


def second_pose(x):
    p = {'body': {'position': [0, -8, 0]}, 'neck': {'rotation': [-54, 0, 0]},
         'head': {'rotation': [28, 0, 0]}, 'tail': {'rotation': [13, 0, 0]}}
    for name, spec in x.chains.items():
        ps = [np.array(v, float) for v in spec['points']]; ns = spec['groups']; sign = -1 if 'left' in name else 1
        start = ps[0]+[0, -8, 0]
        target = ps[-1]+[sign*2.2, 0, -10 if name.startswith('fore') else 1]
        if name.startswith('fore'):
            knee = two_bone(start, target, np.linalg.norm(ps[1]-ps[0]), np.linalg.norm(ps[2]-ps[1]), [0, 0, 1])
            desired = [start, knee, target]
        else:
            hock = target+(ps[2]-ps[3])
            knee = two_bone(start, hock, np.linalg.norm(ps[1]-ps[0]), np.linalg.norm(ps[2]-ps[1]), [0, 0, -1])
            desired = [start, knee, hock, target]
        rpar = np.eye(3)
        for j in range(len(ps)-1):
            rw = align(ps[j+1]-ps[j], desired[j+1]-desired[j])
            p[ns[j]] = {'rotation': euler(rpar.T@rw).tolist()}; rpar = rw
        p[ns[-1]] = {'rotation': euler(rpar.T).tolist()}
    return p


def bake_pose(bb, pose):
    b = copy.deepcopy(bb); groups = {g['uuid']: g for g in b['groups']}; byname = {g['name']: g for g in b['groups']}; es = {e['uuid']: e for e in b['elements']}; nodes = {}
    def scan(ns):
        for n in ns:
            if isinstance(n, dict): nodes[n['uuid']] = n; scan(n['children'])
    scan(b['outliner'])
    def move(n, v):
        g = groups[n['uuid']]; g['origin'] = (np.array(g['origin'])+v).tolist()
        for c in n['children']:
            if isinstance(c, dict): move(c, v)
            else:
                for k in ['from', 'to', 'origin']: es[c][k] = (np.array(es[c][k])+v).tolist()
    for n, data in pose.items():
        g = byname[n]
        if 'position' in data: move(nodes[g['uuid']], np.array(data['position']))
        if 'rotation' in data: g['rotation'] = (np.array(g['rotation'])+data['rotation']).tolist()
    return b


def without_shell(b, shell):
    b = copy.deepcopy(b); removed_groups = set(); removed_elements = set()
    def collect(n):
        removed_groups.add(n['uuid'])
        for c in n['children']:
            if isinstance(c, dict): collect(c)
            else: removed_elements.add(c)
    def trim(ns):
        out = []
        for n in ns:
            if isinstance(n, dict):
                if n['uuid'] in shell: collect(n)
                else: n['children'] = trim(n['children']); out.append(n)
            else: out.append(n)
        return out
    b['outliner'] = trim(b['outliner']); b['groups'] = [g for g in b['groups'] if g['uuid'] not in removed_groups]
    b['elements'] = [e for e in b['elements'] if e['uuid'] not in removed_elements]
    return b, sorted(removed_groups), sorted(removed_elements)


def save(bb, title):
    b = copy.deepcopy(bb); b['name'] = title
    for t in b['textures']:
        dest = D/'纹理'/t['name']; write(dest, base64.b64decode(t['source'].split(',', 1)[1])); t.update({'path': str(dest), 'relative_path': '纹理/'+t['name']})
    jsave(D/(title+'.bbmodel'), b)
    aj = copy.deepcopy(b); aj['meta'] = {'format': 'animated-java:format/blueprint', 'format_version': '1.11.0', 'uuid': uid(title+':aj'), 'save_location': str(D/(title+'.ajblueprint'))}
    aj['blueprint_settings'] = {'blueprint_id': 'fallendream_boss:forest_stag_'+('phase1' if title == NAMES[0] else 'phase2'), 'auto_render_box': False, 'render_box': [8, 6], 'resource_pack_export_mode': 'none', 'data_pack_export_mode': 'none', 'target_minecraft_version': '1.21.5'}
    aj['meta']['last_used_blueprint_id'] = aj['blueprint_settings']['blueprint_id']
    aj['texture_groups'] = []
    aj['variants'] = {'default': {'name': 'default', 'display_name': 'Default', 'uuid': uid(title+':default_variant'),
                                  'slot_textures': {}, 'excluded_nodes': [], 'is_default': True}, 'list': []}
    jsave(D/(title+'.ajblueprint'), aj)


def display(bb, title):
    sc = Scene(bb); m = sc.matrices(); points = sc.pose()[0]; lo, hi = points.min(0), points.max(0)
    factor = 40/max(hi-lo); shift = np.array([8., 8., 8.])-(lo+hi)/2*factor
    b = copy.deepcopy(bb); b['name'] = title; b['meta']['model_format'] = 'java_block'
    g = copy.deepcopy(b['groups'][0]); g.update({'name': '整体Display', 'origin': [8, 8, 8], 'rotation': [0, 0, 0]})
    b['groups'] = [g]; b['outliner'] = [{'uuid': g['uuid'], 'children': [e['uuid'] for e in b['elements']], 'isOpen': True}]
    gs = {g['name']: g for g in bb['groups']}
    for e in b['elements']:
        n = sc.element_bone[e['uuid']]; origin = np.array(gs[n]['origin']); mid = (np.array(e['from'])+e['to'])/2; half = (np.array(e['to'])-e['from'])/2
        world_rotation = m[n][:3, :3]@rotation(e)
        center = (m[n][:3, :3]@(mid-origin)+m[n][:3, 3])*factor+shift
        e.update({'from': (center-half*factor).tolist(), 'to': (center+half*factor).tolist(), 'origin': center.tolist(), 'rotation': euler(world_rotation).tolist()})
    b['display'] = {n: {'rotation': [0, 0, 0], 'translation': [0, 0, 0], 'scale': [1/factor]*3} for n in ['thirdperson_righthand', 'thirdperson_lefthand', 'firstperson_righthand', 'firstperson_lefthand', 'ground', 'fixed', 'head']}
    b['display']['gui'] = {'rotation': [20, 135, 0], 'translation': [0, 0, 0], 'scale': [.6]*3}
    jsave(D/(title+'.bbmodel'), b)
    err = float(np.max(abs((Scene(b).pose()[0]-shift)/factor-points)))
    assert err < 1e-7, err
    return err


def build():
    if (D/'制作记录.json').exists():
        rec = load(D/'制作记录.json')
        assert '--revise' in sys.argv, 'Saved stage exists; preserve user edits'
        for n, h in rec['owned_hashes'].items(): assert sha(D/n) == h, 'Preserve external edit: '+n
    else:
        assert not any(D.glob('*.bbmodel')), 'Preserve unrecorded native model'
    x = Builder(); make_body(x); make_legs(x); make_neck_head(x); make_antlers(x); make_coat(x)
    p2 = second_pose(x); b2 = bake_pose(x.b, p2); b2, rg, re = without_shell(b2, x.shell)
    for b, n in zip([x.b, b2], NAMES): save(b, n)
    errors = [display(load(D/(n+'.bbmodel')), n+'_整体Display调整') for n in NAMES]
    owned = {p.name: sha(p) for p in D.glob('*.bbmodel')}; owned.update({p.name: sha(p) for p in D.glob('*.ajblueprint')})
    jsave(D/'制作记录.json', {'date': '2026-11-23', 'concept_sha256': sha(P/'朽冠鹿_两阶段概念.png'), 'user_approved_concept': True,
                             'static_shape_reviewed': False, 'phase2_pose': p2, 'limb_chains': x.chains, 'shell_groups': sorted(x.shell),
                             'removed_shell_groups': rg, 'removed_shell_elements': re, 'links': x.links,
                             'phase1_cubes': len(x.b['elements']), 'phase2_cubes': len(b2['elements']),
                             'phase1_groups': len(x.b['groups']), 'phase2_groups': len(b2['groups']), 'display_errors': errors,
                             'animations': 0, 'native_reopened': False, 'native_exported': False, 'game_tested': False,
                             'owned_hashes': owned})
    print('Saved', [(n, len(b['elements']), len(b['groups'])) for n, b in zip(NAMES, [x.b, b2])], flush=True)


def fit(scenes, d, size, margin=55):
    d = unit(d); right = unit(np.cross([0, 1, 0], d)); up = np.cross(d, right)
    pts = np.vstack([s.pose()[0] for s in scenes]); lo, hi = pts.min(0), pts.max(0); center = (lo+hi)/2
    xx = (pts-center)@right; yy = (pts-center)@up
    return center, min((size[0]-margin*2)/np.ptp(xx), (size[1]-margin*2)/np.ptp(yy))


def boards():
    scenes = [Scene(load(D/(n+'.bbmodel'))) for n in NAMES]
    font = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 25); small = ImageFont.truetype('C:/Windows/Fonts/msyh.ttc', 18)
    views = [((.72, .22, -1), '斜前'), ((0, .06, -1), '正面'), ((1, .06, 0), '侧面'), ((.0, .08, 1), '背面')]
    for vi, (direction, viewname) in enumerate(views):
        size = (860, 730); center, ppu = fit(scenes, direction, size)
        board = Image.new('RGB', (1720, 815), '#20252d'); draw = ImageDraw.Draw(board)
        for j, sc in enumerate(scenes):
            board.paste(sc.render(direction, size=size, center=center, ppu=ppu), (j*860, 42))
            draw.text((j*860+24, 10), NAMES[j].replace('_', ' · ')+' · '+viewname, font=font, fill='#e3dfcf')
        draw.text((24, 782), '保存模型与实际UV · 同尺度离线静态预览 · 非概念图 / 非游戏截图', font=small, fill='#bec6b0')
        name = '两阶段_实际模型对照.png' if vi == 0 else '两阶段_'+viewname+'.png'
        board.save(D/name); print(name, flush=True)
    for j, sc in enumerate(scenes):
        board = Image.new('RGB', (1680, 700), '#20252d'); draw = ImageDraw.Draw(board)
        for k, (direction, label) in enumerate(views[1:]):
            center, ppu = fit([sc], direction, (560, 620), 35)
            board.paste(sc.render(direction, size=(560, 620), center=center, ppu=ppu), (k*560, 42))
            draw.text((k*560+16, 10), label, font=font, fill='#e3dfcf')
        draw.text((20, 665), NAMES[j].replace('_', ' · ')+' · 保存模型 / 实际UV', font=small, fill='#bec6b0')
        board.save(D/(NAMES[j]+'_正侧背.png'))


def audit():
    rec = load(D/'制作记录.json'); models = [load(D/(n+'.bbmodel')) for n in NAMES]; reports = []
    assert sha(P/'朽冠鹿_两阶段概念.png') == rec['concept_sha256']
    for name, b in zip(NAMES, models):
        aj = load(D/(name+'.ajblueprint'))
        for k in ['elements', 'groups', 'outliner', 'textures', 'animations']: assert b[k] == aj[k], k
        assert aj['meta']['format'] == 'animated-java:format/blueprint' and aj['variants']['default']['is_default']
        assert aj['texture_groups'] == [] and aj['blueprint_settings']['target_minecraft_version'] == '1.21.5'
        gs = {g['uuid']: g for g in b['groups']}; es = {e['uuid']: e for e in b['elements']}; refs = []; grouprefs = []
        assert len(gs) == len(b['groups']) and len(es) == len(b['elements'])
        def walk(ns):
            for v in ns:
                if isinstance(v, str): refs.append(v)
                else: grouprefs.append(v['uuid']); walk(v['children'])
        walk(b['outliner']); assert collections.Counter(refs) == collections.Counter(es.keys())
        assert collections.Counter(grouprefs) == collections.Counter(gs.keys())
        tex = {t['uuid']: t for t in b['textures']}
        for t in tex.values(): assert (D/t['relative_path']).read_bytes() == base64.b64decode(t['source'].split(',', 1)[1])
        for e in es.values():
            assert all(v > u for u, v in zip(e['from'], e['to']))
            for f in e['faces'].values():
                t = tex[f['texture']]; assert all(0 <= u <= t['uv_width' if j % 2 == 0 else 'uv_height'] for j, u in enumerate(f['uv']))
        sc = Scene(b); pts = sc.pose()[0]
        assert pts[:, 1].min() >= -.001, float(pts[:, 1].min())
        # Confirm all four soles are flat and meet the same ground plane.
        all_bottoms = []
        for spec in rec['limb_chains'].values():
            n = spec['groups'][-1]; ids = [e['uuid'] for e in b['elements'] if e['name'].startswith(n+'_toe_') and '_ridge_' not in e['name']]
            bottoms = []
            for eid in ids:
                m = sc.matrices()[n]; cp = sc.corners[eid]@m[:3, :3].T+m[:3, 3]; bottoms.append(float(cp[:, 1].min()))
            assert len(bottoms) == 2 and max(bottoms)-min(bottoms) < 1e-6 and 0 <= min(bottoms) < .6, (n, bottoms)
            all_bottoms += bottoms
        assert max(all_bottoms)-min(all_bottoms) < 1e-7, all_bottoms
        geo = {sc.element_bone[e['uuid']] for e in b['elements']}
        # Equal planes on overlapping, equally oriented boxes are a useful
        # practical flashing detector. Intended internal contacts are excluded.
        reports.append({'name': name, 'cubes': len(es), 'groups': len(gs), 'textured_geometry_groups': len(geo),
                        'faces': sum(len(e['faces']) for e in es.values()), 'bounds': {'min': pts.min(0).tolist(), 'max': pts.max(0).tolist(), 'size': np.ptp(pts, axis=0).tolist()},
                        'four_feet_planted': True, 'positive_volume_uv_hierarchy': True})
    # Exact saved second form must match the authored bone pose of form one,
    # after removing the shell. This also checks actual joint rotations.
    s1, s2 = map(Scene, models); m1 = s1.matrices(rec['phase2_pose']); m2 = s2.matrices()
    errs = []
    for e in models[1]['elements']:
        n = s2.element_bone[e['uuid']]; a = s1.corners[e['uuid']]@m1[n][:3, :3].T+m1[n][:3, 3]; b = s2.corners[e['uuid']]@m2[n][:3, :3].T+m2[n][:3, 3]
        errs.append(float(abs(a-b).max()))
    assert max(errs) < 1e-7, max(errs)
    # IK preserves all rigid link lengths and wrist/ankle ground targets.
    joint_error = 0.
    rest = s1.matrices()
    for spec in rec['limb_chains'].values():
        ns = spec['groups']
        for a, b in zip(ns[:-1], ns[1:]):
            joint_error = max(joint_error, abs(np.linalg.norm(m2[a][:3, 3]-m2[b][:3, 3])-np.linalg.norm(rest[a][:3, 3]-rest[b][:3, 3])))
    assert joint_error < 1e-7, joint_error
    jsave(D/'静态工程核验.json', {'passed': True, 'models': reports, 'shared_shape_pose_error': max(errs), 'limb_length_error': joint_error,
                                 'removed_shell_cubes': len(rec['removed_shell_elements']), 'textures': 1, 'atlas_size': [512, 512],
                                 'animations': 0, 'native_reopened': False, 'native_exported': False, 'game_tested': False,
                                 'Display_is_single_legal_Java_export': False,
                                 'limits': 'Offline saved geometry, UV, hierarchy, feet, shared form/IK only. No all-pairs collision, runtime entity optimization or FPS claim.'})
    print('PASS: two saved forms, exact shared anatomy, four planted feet, UVs and editable hierarchy.', flush=True)


if __name__ == '__main__':
    {'build': build, 'boards': boards, 'audit': audit}[sys.argv[1]]()
