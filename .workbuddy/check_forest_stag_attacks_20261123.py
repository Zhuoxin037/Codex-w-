"""Saved body motion, timed FX, visible helper geometry and UV checks."""
import base64, collections, math, sys
import numpy as np
import animate_forest_stag_attacks_20261123 as a
from check_forest_stag_slam_20261123 import sat_depth
from check_forest_stag_static_20261123 import clip as polygon_clip, area


def body_checks(b, phase):
    sc = a.old.Scene(b); es = b['elements']; names = sc.names; ni = {n: i for i, n in enumerate(names)}
    eg = [sc.element_bone[e['uuid']] for e in es]; bi = np.array([ni[n] for n in eg]); vbi = np.repeat(bi, 8)
    local = np.vstack([sc.corners[e['uuid']] for e in es]); mids = np.array([sc.corners[e['uuid']].mean(0) for e in es])
    half = np.array([(np.array(e['to'])-e['from'])/2 for e in es]); er = np.array([a.rig.rotation(e) for e in es])
    bind = sc.matrices(); author = a.Author(b, phase); chains = author.chains
    body = [i for i, n in enumerate(eg) if n.startswith(('inner_barrel_', 'inner_croup'))]
    lower = [i for i, n in enumerate(eg) if n.startswith(('fore_', 'hind_')) and ('_lower' in n or '_hock' in n or n.endswith('_foot'))]
    head = [i for i, n in enumerate(eg) if n == 'head' or n.startswith(('head_skull_', 'muzzle_', 'lower_jaw', 'cheek_plate_', 'ear_', 'brow_'))]
    crown = [i for i, n in enumerate(eg) if n.startswith('crown_') and 'leaf' not in n]
    cv = np.concatenate([np.arange(i*8, i*8+8) for i in crown])
    pairs = np.array(list(dict.fromkeys([(i, j) for i in lower for j in body]+[(i, j) for i in head+crown for j in body+lower])), int)
    ii, jj = pairs.T; baseline = {}
    bc = np.array([bind[n][:3, :3]@mids[i]+bind[n][:3, 3] for i, n in enumerate(eg)])
    br = np.array([bind[n][:3, :3]@er[i] for i, n in enumerate(eg)])
    for i, j in pairs:
        if np.all(abs(bc[i]-bc[j]) <= abs(br[i])@half[i]+abs(br[j])@half[j]): baseline[(i, j)] = sat_depth(bc[i], br[i], half[i], bc[j], br[j], half[j])
    reports = []
    for c in b['animations'][-3:]:
        minimum = 1e6; joint = plant = root = 0.; violations = []; narrow = 0; yaw_samples = []; max_reach = 0.
        count = round(c['length']*120)+1
        for tick in range(count):
            t = tick/120; m = a.old.matrices(sc, a.old.sample(c, t)); mats = np.array([m[n] for n in names])
            pts = np.einsum('nij,nj->ni', mats[vbi, :3, :3], local)+mats[vbi, :3, 3]
            minimum = min(minimum, float(pts[:, 1].min())); root = max(root, float(abs(m['stag_root'][:3, 3]).max()))
            for n, spec in chains.items():
                ns = spec['groups']
                for x, y in zip(ns[:-1], ns[1:]): joint = max(joint, abs(np.linalg.norm(m[x][:3, 3]-m[y][:3, 3])-np.linalg.norm(bind[x][:3, 3]-bind[y][:3, 3])))
                if not (c['name'].startswith('root_call') and n == 'fore_left' and .25 < t < .80):
                    plant = max(plant, float(np.linalg.norm(m[ns[-1]][:3, 3]-bind[ns[-1]][:3, 3])))
            if c['name'].startswith('crown_sweep'):
                forward = m['head'][:3, :3]@np.array([0., 0., -1.])
                yaw_samples.append((t, math.degrees(math.atan2(-forward[0], -forward[2]))))
                if 1. <= t <= 1.4 or (phase == 2 and 1.65 <= t <= 2.05):
                    max_reach = max(max_reach, float(np.linalg.norm(pts[cv][:, [0, 2]], axis=1).max()))
            if tick % 4 == 0:
                cc = np.einsum('nij,nj->ni', mats[bi, :3, :3], mids)+mats[bi, :3, 3]
                rr = np.einsum('nij,njk->nik', mats[bi, :3, :3], er); bounds = np.einsum('nij,nj->ni', abs(rr), half)
                mask = np.all(abs(cc[ii]-cc[jj]) < bounds[ii]+bounds[jj], axis=1)
                for i, j in pairs[mask]:
                    narrow += 1; depth = sat_depth(cc[i], rr[i], half[i], cc[j], rr[j], half[j])
                    if depth > max(.20, baseline.get((i, j), 0)+.20) and len(violations) < 12:
                        violations.append({'time': round(t, 4), 'a': es[i]['name'], 'b': es[j]['name'], 'depth': depth})
        first, last = [a.old.matrices(sc, a.old.sample(c, t)) for t in [0, c['length']]]
        enderr = max(float(abs(first[n]-last[n]).max()) for n in names)
        windows = []
        if yaw_samples:
            for k, (start, end) in enumerate([(1., 1.4)]+([(1.65, 2.05)] if phase == 2 else [])):
                ys = np.array([v for t, v in yaw_samples if start-1e-8 <= t <= end+1e-8]); direction = 1 if k == 0 else -1
                windows.append({'start': start, 'end': end, 'yaw_start': float(ys[0]), 'yaw_end': float(ys[-1]),
                                'monotonic': bool(np.min(np.diff(ys)*direction) > -.02)})
        result = {'phase': phase, 'clip': c['name'], 'samples_120hz': count, 'minimum_y': minimum,
                  'joint_length_error': joint, 'planted_pivot_drift': plant, 'root_translation_error': root,
                  'return_matrix_error': enderr, 'clearance_pairs': len(pairs), 'clearance_Hz': 30, 'SAT_narrow_checks': narrow,
                  'deep_overlap_candidates': violations, 'sweep_windows': windows,
                  'swept_crown_horizontal_radius_blocks': max_reach/16 if yaw_samples else None}
        result['passed'] = bool(minimum >= -.015 and joint < 1e-7 and plant < .20 and root < 1e-8 and enderr < 1e-8
                                and not violations and all(w['monotonic'] for w in windows))
        reports.append(result); print('Checked body', phase, c['name'], result['passed'], flush=True)
    return reports


def coplanar_helpers(sc, c, t, base_count):
    f = a.old.frame(sc, c, t); pts, normals, mats = sc.pose(f); live = abs(np.linalg.det(mats[:, :3, :3])) > 1e-6
    faces = []; ei = 0; cube_indices = []
    for idx, e in enumerate(sc.bb['elements']):
        nfaces = len(e['faces'])
        if idx >= base_count and live[sc.index[sc.element_bone[e['uuid']]]]:
            cube_indices.append(idx)
            for j in range(nfaces):
                q = (ei+j)*4; faces.append((e['name'], pts[q:q+4], normals[q]))
        ei += nfaces
    buckets = collections.defaultdict(list)
    for n, q, norm in faces: buckets[tuple(np.round(norm, 6))+(round(float(norm@q[0]), 5),)].append((n, q, norm))
    out = []
    import itertools
    for items in buckets.values():
        for (an, aq, n), (bn, bq, _) in itertools.combinations(items, 2):
            u = a.rig.unit(aq[1]-aq[0]); v = np.cross(n, u); qa = np.c_[aq@u, aq@v]; qb = np.c_[bq@u, bq@v]
            if np.any(qa.max(0) < qb.min(0)+1e-5) or np.any(qb.max(0) < qa.min(0)+1e-5): continue
            poly = polygon_clip(qa, qb)
            if len(poly) >= 3 and abs(area(poly)) > .002: out.append({'a': an, 'b': bn, 'area': abs(area(poly))})
    return out


def fx_checks(b, main, phase, helper):
    count = len(main['elements']); assert b['elements'][:count] == main['elements']; assert b['groups'][:len(main['groups'])] == main['groups']
    tex = {t['uuid']: t for t in b['textures']}; refs = []; groups = []
    def walk(nodes):
        for n in nodes:
            if isinstance(n, str): refs.append(n)
            else: groups.append(n['uuid']); walk(n['children'])
    walk(b['outliner'])
    assert collections.Counter(refs) == collections.Counter(e['uuid'] for e in b['elements'])
    assert collections.Counter(groups) == collections.Counter(g['uuid'] for g in b['groups'])
    for e in b['elements'][count:]:
        assert all(z > q for q, z in zip(e['from'], e['to']))
        assert sum(abs(v) > 1e-8 for v in e['rotation']) <= 1 and all(abs(v) in [0, 22.5, 45] for v in e['rotation'])
        for f in e['faces'].values(): assert f['texture'] in tex and all(0 <= v <= 512 for v in f['uv'])
    sc = a.old.Scene(b); ns = sc.names; ni = {n: i for i, n in enumerate(ns)}
    bi = np.array([ni[sc.element_bone[e['uuid']]] for e in b['elements']]); vbi = np.repeat(bi, 8)
    loc = np.vstack([sc.corners[e['uuid']] for e in b['elements']]); reports = []
    for c in b['animations']:
        minimum = 1e6; peak = 0; min_gap = 1e6; snapshots = []
        for tick in range(round(c['length']*120)+1):
            t = tick/120; m = a.old.matrices(sc, a.old.sample(c, t)); mats = np.array([m[n] for n in ns]); live = abs(np.linalg.det(mats[:, :3, :3])) > 1e-6
            vl = live[vbi]; pts = np.einsum('nij,nj->ni', mats[vbi, :3, :3], loc)+mats[vbi, :3, 3]
            minimum = min(minimum, float(pts[vl, 1].min())); peak = max(peak, int(np.sum(live[bi[count:]])))
            if tick in [0, round(c['length']*120)]: assert np.sum(live[bi[count:]]) == 0, 'Uncleared effect'
            if phase == 2 and c['name'].startswith('root_call'):
                sides = []
                for token in ['left', 'right']:
                    vi = np.concatenate([np.arange(i*8, i*8+8) for i, e in enumerate(b['elements']) if i >= count and token in e['name']])
                    selected = vi[vl[vi]]
                    sides.append(pts[selected, 0] if len(selected) else np.array([]))
                if len(sides[0]) and len(sides[1]): min_gap = min(min_gap, float(sides[1].min()-sides[0].max()))
        if c['name'].startswith('resin_cast'):
            main_clip = next(v for v in main['animations'] if v['name'] == c['name']); body_scene = a.old.Scene(main)
            for blob in helper['blobs']:
                spawn = a.old.matrices(body_scene, a.old.sample(main_clip, blob['shot']))['head']@np.array([0, 3.7, -.6, 1.])
                pose = a.old.sample(c, blob['shot']); assert np.linalg.norm(spawn[:3]-pose[blob['name']]['position']) < 1e-5
                assert a.old.sample(c, blob['shot']-.001)[blob['name']]['scale'] == [0., 0., 0.]
                assert a.old.sample(c, blob['land'])[blob['name']]['scale'] == [0., 0., 0.]
            for pool in helper['pools']: assert abs(pool['end']-pool['start']-4) < 1e-8
        for t in ([1.65, 1.8, 2.5, 3.2] if c['name'].startswith('root_call') else [1.65, 2.5, 4.]):
            hits = coplanar_helpers(sc, c, t, count)
            snapshots.append({'time': t, 'overlapping_same_facing_surface_candidates': hits[:12]})
        result = {'phase': phase, 'clip': c['name'], 'samples_120hz': round(c['length']*120)+1,
                  'helper_cubes_total': len(b['elements'])-count, 'peak_visible_helper_cubes': peak, 'minimum_visible_y': minimum,
                  'minimum_root_band_gap_units': None if min_gap == 1e6 else min_gap,
                  'initial_and_final_FX_cleared': True, 'coplanar_helper_snapshots': snapshots,
                  'fixed_illustrative_targets': True}
        result['passed'] = bool(minimum >= -.015 and (min_gap == 1e6 or min_gap >= 40.-1e-7)
                                and not any(s['overlapping_same_facing_surface_candidates'] for s in snapshots))
        reports.append(result); print('Checked FX', phase, c['name'], result['passed'], flush=True)
    return reports


def ring_boundary_checks(b):
    rings = {}
    for e in b['elements']:
        if not e['name'].startswith(('fx_root_cue_', 'fx_resin_cue_')): continue
        group, index = e['name'].rsplit('_edge', 1)
        size = np.array(e['to'])-e['from']; center = (np.array(e['to'])+e['from'])/2
        axis = int(np.argmax(size)); tangent = a.rig.rotation(e)[:, axis]
        endpoints = np.array([center-tangent*size[axis]/2, center+tangent*size[axis]/2])[:, [0, 2]]
        rings.setdefault(group, []).append(endpoints)
    maximum = 0.
    for name, edges in rings.items():
        assert len(edges) == 8
        endpoints = np.vstack(edges)
        distances = np.linalg.norm(endpoints[:, None]-endpoints[None, :], axis=2)
        np.fill_diagonal(distances, np.inf)
        gap = float(distances.min(axis=1).max()); maximum = max(maximum, gap)
        assert gap < 1e-6, (name, 'Warning boundary not closed', gap)
    return {'closed_warning_rings': len(rings), 'maximum_endpoint_gap_units': maximum, 'passed': True}


def run():
    rec = a.load(a.D/'制作记录.json')
    for p, h in rec['source_hashes'].items(): assert a.sha(a.old.Path(p)) == h, 'Source changed'
    reuse = '--effects-only' in sys.argv
    if reuse:
        previous = a.load(a.D/'新增三招动作与效果核验.json')
        inspected = a.load(a.D/'交付核验.json')
        assert previous['passed']
        for title in a.TITLES:
            for ext in ['bbmodel', 'ajblueprint']:
                name = title+'.'+ext
                assert a.sha(a.D/name) == inspected['hashes'][name], 'Cannot reuse checks for changed body'
    bodies = []; effects = []; boundaries = []
    for phase, title in enumerate(a.TITLES, 1):
        b = a.load(a.D/(title+'.bbmodel')); src = a.load(a.S/(a.prior.TITLES[phase-1]+'.bbmodel'))
        for k in ['elements', 'groups', 'outliner', 'resolution']: assert b[k] == src[k]
        assert b['animations'][:len(src['animations'])] == src['animations'] and len(b['animations']) == 6
        assert [t['source'] for t in b['textures']] == [t['source'] for t in src['textures']]
        for t in b['textures']: assert (a.D/t['relative_path']).read_bytes() == base64.b64decode(t['source'].split(',', 1)[1])
        for name in [title, a.PREVIEWS[phase-1]]:
            bb = a.load(a.D/(name+'.bbmodel')); aj = a.load(a.D/(name+'.ajblueprint'))
            for k in ['elements', 'groups', 'outliner', 'textures', 'animations']: assert bb[k] == aj[k]
            gids = {g['uuid'] for g in bb['groups']}
            for c in bb['animations']:
                for gid, tr in c['animators'].items():
                    assert gid in gids
                    keys = [(k['channel'], k['time']) for k in tr['keyframes']]
                    assert len(keys) == len(set(keys)) and all(abs(t*c['snapping']-round(t*c['snapping'])) < 1e-5 for _, t in keys)
        bodies += [v for v in previous['body_results'] if v['phase'] == phase] if reuse else body_checks(b, phase)
        fx = a.load(a.D/(a.PREVIEWS[phase-1]+'.bbmodel'))
        boundaries.append({'phase': phase, **ring_boundary_checks(fx)})
        effects += fx_checks(fx, b, phase, rec['helpers'][str(phase)])
    result = {'passed': all(x['passed'] for x in bodies+effects), 'source_files_and_old_animations_unchanged': True,
              'body_results': bodies, 'effect_results': effects, 'warning_boundary_results': boundaries,
              'body_geometry_UVs_unchanged': True, 'unchanged_body_checks_reused_after_hash_verification': reuse,
              'native_reopened': False, 'native_exported': False, 'game_tested': False,
              'scope': 'Saved body/FX animation and selected static parts. No runtime targeting, swept hitboxes, damage, terrain, AI or FPS verification.'}
    a.jsave(a.D/'新增三招动作与效果核验.json', result); print(__import__('json').dumps(result, ensure_ascii=False), flush=True)
    assert result['passed'], 'Inspect saved body/effect report'


if __name__ == '__main__': run()
