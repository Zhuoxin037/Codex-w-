"""Validate actual saved A phase-two assets, articulation and effect origins."""
import base64, collections, json
import numpy as np
import a_ghost_phase2_expand_20261122 as a
from check_a_ghost_representative_20261122 import obbs, aabb, pair_depth


def candidates(ba, bb):
    xa, xz = aabb(ba); ya, yz = aabb(bb)
    if np.any(xz.max(0) < ya.min(0)) or np.any(yz.max(0) < xa.min(0)): return np.array([], int), np.array([], int)
    return np.where(np.all((xz[:, None] >= ya[None]) & (yz[None] >= xa[:, None]), axis=2))


def visible_points(sc, clip, t):
    f = a.frame(sc, clip, t); p, _, m = sc.pose(f)
    vis = np.linalg.norm(m[:, :3, :3], axis=1).min(axis=1) > 1e-5
    return p[vis[sc.bone]]


def run():
    b = a.load(a.D/(a.TITLE+'.bbmodel')); fx = a.load(a.D/(a.TITLE+'_完整效果预览.bbmodel')); rec = a.load(a.D/'制作记录.json')
    source, prev = a.load(a.SRC), a.load(a.FXSRC); sc, fs = a.Scene(b), a.Scene(fx)
    errors = []; invariants = []
    assert a.sha(a.SRC) == rec['source_sha256'] and a.sha(a.SRC.with_suffix('.ajblueprint')) == rec['source_aj_sha256']
    assert a.sha(a.FXSRC) == rec['preview_source_sha256']
    assert b['elements'][:1440] == source['elements'] and b['groups'][:134] == source['groups']
    oldcast = next(c for c in source['animations'] if c['name'] == 'bone_volley'); newcast = next(c for c in b['animations'] if c['name'] == 'bone_volley')
    assert all(newcast['animators'][u] == tr for u, tr in oldcast['animators'].items())
    assert all(x['source'] == y['source'] for x, y in zip(source['textures'], b['textures']))
    for title in [a.TITLE, a.TITLE+'_完整效果预览']:
        bb = a.load(a.D/(title+'.bbmodel')); aj = a.load(a.D/(title+'.ajblueprint'))
        assert all(bb[k] == aj[k] for k in ['elements', 'groups', 'outliner', 'textures', 'animations'])
        nodes = a.old.group_nodes(bb); groupids = {g['uuid'] for g in bb['groups']}
        refs = [x for n in nodes.values() for x in n['children'] if isinstance(x, str)]
        assert set(nodes) == groupids and collections.Counter(refs) == collections.Counter(e['uuid'] for e in bb['elements'])
        assert len(groupids) == len(bb['groups']) and len(set(e['uuid'] for e in bb['elements'])) == len(bb['elements'])
        textures = {t['uuid']: t for t in bb['textures']}
        for t in bb['textures']:
            assert (a.D/t['relative_path']).read_bytes() == base64.b64decode(t['source'].split(',', 1)[1])
        for e in bb['elements']:
            assert all(z > x for x, z in zip(e['from'], e['to']))
            angles = [r for r in e.get('rotation', [0]*3) if abs(r) > 1e-6]
            assert len(angles) <= 1 and all(r in [-45, -22.5, 22.5, 45] for r in angles)
            for f in e['faces'].values():
                ref = f.get('texture')
                if ref is None: continue
                tex = bb['textures'][ref] if isinstance(ref, int) else textures[ref]
                assert all(0 <= v <= tex.get('uv_width' if j%2 == 0 else 'uv_height', 512) for j, v in enumerate(f['uv']))
        for c in bb['animations']:
            for u, tr in c['animators'].items():
                assert u in groupids
                ids = [(k['channel'], k['time']) for k in tr['keyframes']]
                assert len(ids) == len(set(ids)) and all(abs(t*20-round(t*20)) < 1e-6 for _, t in ids)
    m0 = a.matrices(sc, {}); static = ['pelvis', 'lower_robe', 'waist', 'chest', 'foot_left', 'foot_right', 'rear_staff_frame', 'rear_bone_structure', 'front_bone_structure']
    static += [n for n in sc.names if n.startswith(('fabric_fold_', 'thin_trailing_', 'front_', 'rear_outer_', 'back_keel_'))]
    protected = [g['name'] for g in source['groups'] if not g['name'].startswith('dissolve_patch_')]
    arms = ['bone_upper_shell_'+s for s in a.old.SIDES]+['bone_forearm_shell_'+s for s in a.old.SIDES]+['claw_'+s for s in a.old.SIDES]
    body = ['chest', 'waist', 'head', 'back_orbit']
    checks = [(x, y) for x in arms for y in body]+[('back_orbit', n) for n in ['chest', 'head', 'crown_frame', 'rear_staff_frame']]
    names = list(dict.fromkeys(arms+body+['crown_frame', 'rear_staff_frame']))
    baseline = {n: obbs(sc, n, m0) for n in names}
    joints = [('chest', 'upperarm_'+s) for s in a.old.SIDES]+[('upperarm_'+s, 'forearm_'+s) for s in a.old.SIDES]+[('forearm_'+s, 'claw_'+s) for s in a.old.SIDES]
    max_relative = max_joint = 0.; min_det = 1.; max_det = 1.; floor = 1e9; collisions = []; samples = 0
    for clip in b['animations']:
        if clip['name'] == 'bone_volley': continue
        for i in range(round(clip['length']*120)+1):
            t = i/120; p = a.sample(clip, t); m = a.matrices(sc, p); samples += 1
            root_inv = np.linalg.inv(m['root'])
            max_relative = max(max_relative, max(float(abs(root_inv@m[n]-m0[n]).max()) for n in static))
            for n in protected:
                det = float(np.linalg.det(m[n][:3, :3])); min_det = min(min_det, det); max_det = max(max_det, det)
            for x, y in joints:
                max_joint = max(max_joint, abs(np.linalg.norm(m[x][:3, 3]-m[y][:3, 3])-np.linalg.norm(m0[x][:3, 3]-m0[y][:3, 3])))
            for n in ['foot_left', 'foot_right']:
                for e in sc.elements:
                    if sc.element_bone[e['uuid']] == n:
                        floor = min(floor, float((sc.corners[e['uuid']]@m[n][:3, :3].T+m[n][:3, 3])[:, 1].min()))
            boxes = {n: obbs(sc, n, m) for n in names}
            # Compare in a common root frame, so lifting the whole actor is neutral.
            for n in boxes: boxes[n] = (boxes[n][0]-m['root'][:3, 3], boxes[n][1], boxes[n][2])
            for x, y in checks:
                ia, ib = candidates(boxes[x], boxes[y])
                if not len(ia): continue
                dep = pair_depth(boxes[x], boxes[y], ia, ib); old = pair_depth(baseline[x], baseline[y], ia, ib)
                bad = (dep > .08) & (dep-np.maximum(old, 0) > .08)
                if np.any(bad): collisions.append({'clip': clip['name'], 'time': t, 'groups': [x, y], 'extra': float((dep-np.maximum(old, 0))[bad].max())})
        print('Checked', clip['name'], round(clip['length']*120)+1, 'samples', flush=True)
    idle = next(c for c in b['animations'] if c['name'] == 'phase2_idle'); transition = b['animations'][0]
    start, end = [a.matrices(sc, a.sample(idle, t)) for t in [0, 3]]
    trans_end = a.matrices(sc, a.sample(transition, 2)); visible = [n for n in sc.names if not n.startswith('dissolve_patch_')]
    loop = max(float(abs(start[n]-end[n]).max()) for n in visible)
    seam = max(float(abs(start[n]-trans_end[n]).max()) for n in visible)
    emission = []
    orbit = next(g for g in b['groups'] if g['name'] == 'back_orbit')
    for clip in fx['animations']:
        if clip['name'] not in ['bone_volley', 'bone_volley_phase2']: continue
        for shot in rec['helpers']['bolts']:
            m = a.matrices(fs, a.sample(clip, shot['shot'])); local = np.array(shot['origin'])-orbit['origin']
            expected = (m['back_orbit']@np.r_[local, 1])[:3]
            error = float(np.linalg.norm(m[shot['name']][:3, 3]-expected))
            before = a.sample(clip, shot['shot']-.001)[shot['name']]['scale']
            emission.append({'clip': clip['name'], 'needle': shot['name'], 'origin_error': error, 'hidden_before': before == [0]*3})
    max_flow_gap = 0.
    for clip in b['animations']:
        if clip['name'] == 'bone_volley': continue
        for t in np.arange(1.4 if clip['name'] == 'phase_transition' else 0, clip['length']+.001, .05):
            m = a.matrices(sc, a.sample(clip, float(t)))
            for side in a.old.SIDES:
                for layer in ['upper', 'lower']:
                    flows = [x for x in rec['mantles'] if x['side'] == side and x['layer'] == layer]
                    for x, y in zip(flows[:-1], flows[1:]):
                        tip = m[x['name']]@np.array([0, x['length'], 0, 1])
                        max_flow_gap = max(max_flow_gap, float(np.linalg.norm(tip[:3]-m[y['name']][:3, 3])))
    p1 = visible_points(sc, transition, 0); p2 = visible_points(sc, idle, 0)
    bounds = [{'min': p.min(0).tolist(), 'max': p.max(0).tolist(), 'size': np.ptp(p, axis=0).tolist()} for p in [p1, p2]]
    result = {'source_unchanged': True, 'original_1440_cubes_preserved': True, 'first_phase_existing_tracks_preserved': True,
              'character_cubes': len(b['elements']), 'character_groups': len(b['groups']), 'preview_cubes': len(fx['elements']), 'preview_groups': len(fx['groups']),
              'samples_120hz': samples, 'joint_distance_error': max_joint, 'protected_determinant_range': [min_det, max_det],
              'lower_cloth_feet_and_rear_frame_relative_error': max_relative, 'minimum_foot_y': floor,
              'loop_matrix_error': loop, 'transition_to_idle_matrix_error': seam, 'flow_endpoint_error': max_flow_gap,
              'collision_group_pairs': len(checks), 'new_overlap_over_008_model_units': collisions,
              'emissions': emission, 'phase_bounds': bounds, 'phase_width_ratio': bounds[1]['size'][0]/bounds[0]['size'][0],
              'asset_errors': errors, 'native_reopened': False, 'native_exported': False, 'game_tested': False}
    result['passed'] = not collisions and not errors and min_det > .999999 and max_det < 1.000001 and max_joint < 1e-8 and max_relative < 1e-8 and floor > -.001 and loop < 1e-5 and seam < 1e-5 and max_flow_gap < 1e-4 and all(x['origin_error'] < 1e-5 and x['hidden_before'] for x in emission)
    a.write(a.D/'离线动作与源保护核验.json', json.dumps(result, ensure_ascii=False, indent=2))
    print(json.dumps({k: v for k, v in result.items() if k not in ['emissions', 'new_overlap_over_008_model_units']}, ensure_ascii=False), flush=True)
    print('collisions', len(collisions), collisions[:6], flush=True)
    assert result['passed']


if __name__ == '__main__': run()
