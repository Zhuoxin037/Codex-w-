"""Check saved keys, planting, crown contact, protected geometry and body clearance."""
import base64, collections, json, math
import numpy as np
import animate_forest_stag_slam_20261123 as a


def sat_depth(c1, r1, h1, c2, r2, h2):
    axes = [r1[:, i] for i in range(3)]+[r2[:, i] for i in range(3)]
    axes += [np.cross(r1[:, i], r2[:, j]) for i in range(3) for j in range(3)]
    result = 1e10
    for axis in axes:
        length = float(np.linalg.norm(axis))
        if length < 1e-7: continue
        axis = axis/length
        overlap = float(abs(axis@r1)@h1+abs(axis@r2)@h2-abs(axis@(c2-c1)))
        if overlap <= 0: return 0.
        result = min(result, overlap)
    return result


def check_phase(phase, b, source):
    clip = b['animations'][0]; sc = a.Scene(b); base = a.Scene(source)
    for k in ['elements', 'groups', 'outliner', 'resolution']: assert b[k] == source[k], 'protected '+k
    assert [t['source'] for t in b['textures']] == [t['source'] for t in source['textures']]
    for t in b['textures']:
        assert (a.D/t['relative_path']).read_bytes() == base64.b64decode(t['source'].split(',', 1)[1])
    aj = a.load(a.D/(a.TITLES[phase-1]+'.ajblueprint'))
    for k in ['elements', 'groups', 'outliner', 'textures', 'animations']: assert b[k] == aj[k]
    assert clip['loop'] == 'once' and clip['length'] == a.LENGTH and len(b['animations']) == 1
    ids = {g['uuid'] for g in b['groups']}
    for gid, animator in clip['animators'].items():
        assert gid in ids
        ks = animator['keyframes']; pairs = [(k['channel'], k['time']) for k in ks]
        assert len(set(pairs)) == len(pairs)
        assert all(abs(t*20-round(t*20)) < 1e-6 for ch, t in pairs)
        assert all(k['interpolation'] == 'linear' for k in ks)
        for ch in {k['channel'] for k in ks}:
            seq = [k for k in ks if k['channel'] == ch]
            assert len(seq) == 85 and seq[0]['time'] == 0 and seq[-1]['time'] == a.LENGTH
    names = sc.names; index = {n: i for i, n in enumerate(names)}; gs = {g['name']: g for g in b['groups']}
    elements = b['elements']; enames = [e['name'] for e in elements]
    egroups = [sc.element_bone[e['uuid']] for e in elements]
    bi = np.array([index[n] for n in egroups]); vbi = np.repeat(bi, 8)
    local = np.vstack([sc.corners[e['uuid']] for e in elements])
    source_m = base.matrices(); first_m = a.matrices(sc, a.sample(clip, 0)); last_m = a.matrices(sc, a.sample(clip, a.LENGTH))
    return_error = max(float(abs(first_m[n]-last_m[n]).max()) for n in names)
    bind_error = max(float(abs(first_m[n]-source_m[n]).max()) for n in names)
    assert return_error < 1e-10 and bind_error < 1e-10
    chains = a.load(a.S/'制作记录.json')['limb_chains']
    # Cube OBBs retain native legal single-axis Cube rotations.
    cube_r = np.array([a.rig.rotation(e) for e in elements]); half = np.array([(np.array(e['to'])-e['from'])/2 for e in elements])
    local_center = np.array([sc.corners[e['uuid']].mean(0) for e in elements])
    body_ids = [i for i, n in enumerate(egroups) if n.startswith(('inner_barrel_', 'inner_croup'))]
    lower_ids = [i for i, n in enumerate(egroups) if n.startswith('fore_') and ('_lower' in n or n.endswith('_foot'))]
    crown_ids = [i for i, n in enumerate(egroups) if n.startswith('crown_') and 'leaf' not in n]
    head_ids = [i for i, n in enumerate(egroups) if n == 'head' or n.startswith(('head_skull_', 'muzzle_', 'lower_jaw', 'cheek_plate_', 'ear_', 'brow_'))]
    # No intended parent mounts in these selected clearance comparisons.
    selected = list(dict.fromkeys([(i, j) for i in lower_ids for j in body_ids]
                                 +[(i, j) for i in head_ids+crown_ids for j in body_ids+lower_ids]))
    pairs = np.array(selected, int); ai, bj = pairs.T
    initial_c = np.array([source_m[n][:3, :3]@local_center[i]+source_m[n][:3, 3] for i, n in enumerate(egroups)])
    initial_r = np.array([source_m[n][:3, :3]@cube_r[i] for i, n in enumerate(egroups)])
    baseline = {}
    for i, j in selected:
        if np.any(abs(initial_c[i]-initial_c[j]) > abs(initial_r[i])@half[i]+abs(initial_r[j])@half[j]): continue
        baseline[(i, j)] = sat_depth(initial_c[i], initial_r[i], half[i], initial_c[j], initial_r[j], half[j])
    minimum = 1e6; max_joint = 0.; max_plant = 0.; max_foot_tilt = 0.; contact = None; violations = []; collision_checks = 0
    toe_vertices = {name: np.concatenate([np.arange(i*8, i*8+8) for i, e in enumerate(elements) if e['name'].startswith(spec['groups'][-1]+'_toe_') and '_ridge_' not in e['name']]) for name, spec in chains.items()}
    max_ground_deviation = 0.
    for tick in range(505):
        t = tick/120; m = a.matrices(sc, a.sample(clip, t)); mats = np.array([m[n] for n in names])
        pts = np.einsum('nij,nj->ni', mats[vbi, :3, :3], local)+mats[vbi, :3, 3]
        minimum = min(minimum, float(pts[:, 1].min()))
        for name, spec in chains.items():
            ns = spec['groups']
            for x, y in zip(ns[:-1], ns[1:]):
                d0 = np.linalg.norm(source_m[x][:3, 3]-source_m[y][:3, 3]); d = np.linalg.norm(m[x][:3, 3]-m[y][:3, 3])
                max_joint = max(max_joint, abs(d-d0))
            planted = phase == 2 or name.startswith('hind') or t <= .25 or a.HIT <= t <= a.END_OPENING or t == a.LENGTH
            if planted:
                expected = source_m[ns[-1]][:3, 3].copy()
                if phase == 1 and name.startswith('fore') and a.HIT <= t <= a.END_OPENING:
                    expected += [-1.1 if 'left' in name else 1.1, 0, -4]
                max_plant = max(max_plant, float(np.linalg.norm(m[ns[-1]][:3, 3]-expected)))
                max_foot_tilt = max(max_foot_tilt, float(abs(m[ns[-1]][:3, :3]-np.eye(3)).max()))
                max_ground_deviation = max(max_ground_deviation, abs(float(pts[toe_vertices[name], 1].min())-.25))
        if abs(t-a.HIT) < 1e-6:
            cp = pts[np.concatenate([np.arange(i*8, i*8+8) for i in crown_ids])]
            hp = pts[np.concatenate([np.arange(i*8, i*8+8) for i in head_ids])]
            low = int(np.argmin(cp[:, 1])); contact = {'time': t, 'crown_minimum_y': float(cp[low, 1]),
                                                      'crown_contact_point': cp[low].tolist(), 'head_minimum_y': float(hp[:, 1].min())}
        # Sample actual saved interpolation at 30 Hz for selected OBB clearance.
        if tick % 4 == 0:
            centers = np.einsum('nij,nj->ni', mats[bi, :3, :3], local_center)+mats[bi, :3, 3]
            rots = np.einsum('nij,njk->nik', mats[bi, :3, :3], cube_r)
            bound = np.einsum('nij,nj->ni', abs(rots), half)
            mask = np.all(abs(centers[ai]-centers[bj]) < bound[ai]+bound[bj], axis=1)
            for i, j in pairs[mask]:
                collision_checks += 1
                depth = sat_depth(centers[i], rots[i], half[i], centers[j], rots[j], half[j])
                if depth > max(.20, baseline.get((i, j), 0)+.20):
                    if len(violations) < 18: violations.append({'time': round(t, 4), 'a': enames[i], 'b': enames[j], 'depth': depth, 'baseline': baseline.get((i, j), 0)})
        if tick % 120 == 0: print('phase', phase, 'audit', round(t, 2), flush=True)
    result = {'phase': phase, 'clip': clip['name'], 'length': a.LENGTH, 'samples_120hz': 505,
              'unchanged_elements_groups_UVs': True, 'bound_pose_error': bind_error, 'return_matrix_error': return_error,
              'joint_length_error': max_joint, 'maximum_planted_pivot_drift': max_plant,
              'maximum_planted_foot_matrix_deviation': max_foot_tilt, 'maximum_planted_sole_y_deviation': max_ground_deviation,
              'all_geometry_minimum_y': minimum, 'contact': contact,
              'selected_OBB_pairs': len(selected), 'selected_OBB_sample_Hz': 30, 'SAT_narrow_checks': collision_checks,
              'new_deep_overlap_candidates': violations,
              'limits': 'Offline native key interpolation. OBB clearance covers lower front limbs/feet versus inner barrel, and head/crown versus barrel/front lower limbs/feet, not every Cube pair or game collision.'}
    result['passed'] = bool(minimum >= -.015 and max_joint < 1e-7 and max_plant < .35 and max_ground_deviation < .30
                            and contact is not None and .1 <= contact['crown_minimum_y'] <= .8 and contact['head_minimum_y'] > .4 and not violations)
    return result


def run():
    rec = a.load(a.D/'制作记录.json')
    for path, digest in rec['source_hashes'].items(): assert a.sha(a.Path(path)) == digest, 'Source changed: '+path
    results = []
    for phase, title in enumerate(a.TITLES, 1):
        results.append(check_phase(phase, a.load(a.D/(title+'.bbmodel')), a.load(a.S/(a.rig.NAMES[phase-1]+'.bbmodel'))))
    report = {'passed': all(r['passed'] for r in results), 'source_projects_unchanged': True, 'results': results,
              'native_reopened': False, 'native_exported': False, 'game_tested': False, 'damage_AI_or_root_followups_implemented': False}
    a.jsave(a.D/'动作核验.json', report); print(json.dumps(report, ensure_ascii=False), flush=True)
    assert report['passed'], 'Inspect the saved actual-animation audit report'


if __name__ == '__main__': run()
