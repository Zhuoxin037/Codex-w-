"""Reconstruct exported Java meshes and serialized pose commands independently."""
import json, re
import numpy as np
from PIL import Image, ImageDraw
import b_staff_runtime_assets_20261121 as a


def qmat(q):
    x, y, z, w = q
    return np.array([[1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+y*w)],
                     [2*(x*y+z*w), 1-2*(x*x+z*z), 2*(y*z-x*w)],
                     [2*(x*z-y*w), 2*(y*z+x*w), 1-2*(x*x+y*y)]])


def run():
    b = a.load(a.D/(a.TITLE+'.bbmodel')); source = a.load(a.SRC); scene = a.Scene(b)
    export = a.load(a.D/'Java渲染导出.json'); gs = {g['name']: g for g in b['groups']}
    meshes = {}; source_points = {}; vertices = lambda e: np.array([[e['to'][i] if mask>>i&1 else e['from'][i] for i in range(3)] for mask in range(8)])
    errors = []
    for mesh in export['mesh_parts']:
        n = mesh['name']; model = a.load(a.RP/f'assets/fallendream_boss/models/entity/b_staff/{n}.json')
        es = [e for e in b['elements'] if scene.element_bone[e['uuid']] == n]
        source_points[n] = np.vstack([vertices(e)-gs[n]['origin'] for e in es])
        meshes[n] = np.vstack([(vertices(e)-8)/16 for e in model['elements']])
        if len(es) != len(model['elements']): errors.append([n, 'geometry count'])
        for e in model['elements']:
            if min(e['from']) < -16.0001 or max(e['to']) > 32.0001: errors.append([n, 'model bounds'])
            for f in e['faces'].values():
                if any(not 0 <= v <= 16 for v in f['uv']): errors.append([n, 'UV'])
        for resource in model['textures'].values():
            namespace, rel = resource.split(':', 1)
            if not (a.RP/f'assets/{namespace}/textures/{rel}.png').exists(): errors.append([n, 'texture path'])
    maximum = 0.; frames = 0; loops = {}; floor = {}
    for clip in b['animations']:
        cache = {}; low = 1e9
        for i in range(round(clip['length']*20)+1):
            path = a.F/f'visual/frames/{clip["name"]}/{i}.mcfunction'
            if path.exists():
                for line in path.read_text(encoding='utf8').splitlines():
                    n = re.search(r'tag=sd\.bs\.part\.([^,\]]+)', line)[1]
                    raw = line.split('] ', 1)[1]
                    raw = re.sub(r'(-?\d+(?:\.\d+)?(?:e[+-]?\d+)?)f\b', r'\1', raw)
                    cache[n] = json.loads(raw)['transformation']
            assert len(cache) == len(meshes), (clip['name'], i, len(cache))
            world = a.matrices(scene, a.sample(clip, i/20))
            for n, p in source_points.items():
                expected = (p@world[n][:3, :3].T+world[n][:3, 3])*[-1, 1, -1]/16
                t = cache[n]; actual = (meshes[n]*t['scale'])@qmat(t['left_rotation']).T+t['translation']
                maximum = max(maximum, float(np.abs(expected-actual).max()))
                if n in ['foot_left', 'foot_right', 'staff']: low = min(low, float(actual[:, 1].min()))
            frames += 1
        floor[clip['name']] = low
        if clip['loop'] == 'loop':
            m0 = a.matrices(scene, a.sample(clip, 0)); me = a.matrices(scene, a.sample(clip, clip['length']))
            loops[clip['name']] = max(float(np.abs(m0[n]-me[n]).max()) for n in m0)
    basic = a.load(a.D/'基础状态来源.json')
    unchanged = b['elements'] == source['elements'] and b['groups'] == source['groups'] and b['outliner'] == source['outliner'] and b['animations'][:6] == source['animations'] and a.sha(a.SRC) == basic['sha256']
    for title in [a.TITLE, a.TITLE+'_全部技能预览']:
        bb, aj = a.load(a.D/(title+'.bbmodel')), a.load(a.D/(title+'.ajblueprint'))
        if any(bb[k] != aj[k] for k in ['elements', 'groups', 'outliner', 'textures', 'animations']): errors.append([title, 'BB/AJ'])
        for t in bb['textures']:
            if (a.D/t['relative_path']).read_bytes() != a.base64.b64decode(t['source'].split(',', 1)[1]): errors.append([title, t['name']])
    result = {'source_geometry_and_six_attacks_preserved': unchanged, 'animations': len(b['animations']), 'serialized_pose_frames': frames,
              'shared_character_meshes': len(meshes), 'reconstruction_max_error_blocks': maximum, 'loop_matrix_errors': loops,
              'sampled_mesh_minimum_y_blocks': floor, 'asset_errors': errors, 'native_AJ_export': False, 'client_tested': False,
              'limits': '20Hz saved pose commands reconstructed from actual Java JSONs. Does not measure client interpolation, shader appearance or FPS.'}
    result['passed'] = unchanged and not errors and maximum < 2e-6 and max(loops.values()) < 1e-6 and min(floor.values()) > -.002
    a.write(a.D/'Java几何与基础状态核验.json', json.dumps(result, ensure_ascii=False, indent=2))
    print(json.dumps(result, ensure_ascii=True), flush=True)
    # Actual saved model pose sheet; no concept art or extra glow.
    board = Image.new('RGB', (1400, 1120), '#20252d'); draw = ImageDraw.Draw(board)
    names = [('idle', 1.2, '待机'), ('walk', .3, '前行'), ('walk_back', .3, '后行'), ('spawn', .4, '出现'), ('hurt', .15, '受击'), ('death', .9, '死亡'), ('repel_guard', .6, '受阻收势')]
    font = a.old.core.small
    for i, (name, t, label) in enumerate(names):
        clip = next(c for c in b['animations'] if c['name'] == name); frames2 = [a.frame(scene, clip, j/20) for j in range(round(clip['length']*20)+1)]
        center, ppu = a.fit(scene, frames2, (.5, .1, -1), (350, 500))
        board.paste(scene.render((.5, .1, -1), size=(350, 500), center=center, ppu=ppu, frame=a.frame(scene, clip, t)), ((i%4)*350, (i//4)*560+35))
        draw.text(((i%4)*350+12, (i//4)*560+10), label+' · 实际模型', font=font, fill='white')
    board.save(a.D/'基础状态_实际模型.png')


if __name__ == '__main__':
    run()
