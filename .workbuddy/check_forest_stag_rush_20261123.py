"""Saved-key checks for charged rush, loop seams, root motion and planting."""
import base64, json, math
import numpy as np
import animate_forest_stag_rush_20261123 as a
from check_forest_stag_slam_20261123 import sat_depth


def check_motion(phase, b, c):
    sc = a.old.Scene(b); base = sc.matrices(); ns = sc.names; ni = {n: i for i, n in enumerate(ns)}
    es = b['elements']; eg = [sc.element_bone[e['uuid']] for e in es]
    bi = np.array([ni[n] for n in eg]); vbi = np.repeat(bi, 8)
    loc = np.vstack([sc.corners[e['uuid']] for e in es]); centers = np.array([sc.corners[e['uuid']].mean(0) for e in es])
    cube_r = np.array([a.old.rig.rotation(e) for e in es]); half = np.array([(np.array(e['to'])-e['from'])/2 for e in es])
    is_loop = c['name'] in a.RUN; duration = c['length']; count = round(duration*120)+1
    roots, minimum, joint_error = [], 1e6, 0.
    contact_tracks = {}; maximum_plant = 0.; minimum_planted_sole = 1e6
    author = a.Author(b, phase); chains = author.chains
    toe_ids = {n: np.concatenate([np.arange(i*8, i*8+8) for i, e in enumerate(es) if e['name'].startswith(spec['groups'][-1]+'_toe_') and '_ridge_' not in e['name']]) for n, spec in chains.items()}
    bodies = [i for i, n in enumerate(eg) if n.startswith(('inner_barrel_', 'inner_croup'))]
    lowers = [i for i, n in enumerate(eg) if n.startswith(('fore_', 'hind_')) and ('_lower' in n or '_hock' in n or n.endswith('_foot'))]
    crowns = [i for i, n in enumerate(eg) if n.startswith('crown_') and 'leaf' not in n]
    heads = [i for i, n in enumerate(eg) if n == 'head' or n.startswith(('head_skull_', 'muzzle_', 'lower_jaw', 'cheek_plate_', 'ear_', 'brow_'))]
    pairs = np.array(list(dict.fromkeys([(i, j) for i in lowers for j in bodies]
                                      +[(i, j) for i in heads+crowns for j in bodies+lowers])), int)
    ii, jj = pairs.T; violations = []; narrow = 0
    base_c = np.array([base[n][:3, :3]@centers[i]+base[n][:3, 3] for i, n in enumerate(eg)])
    base_r = np.array([base[n][:3, :3]@cube_r[i] for i, n in enumerate(eg)])
    baseline = {}
    for i, j in pairs:
        if np.all(abs(base_c[i]-base_c[j]) <= abs(base_r[i])@half[i]+abs(base_r[j])@half[j]):
            baseline[(i, j)] = sat_depth(base_c[i], base_r[i], half[i], base_c[j], base_r[j], half[j])
    prep_times = {'hind_left': (.25, .70), 'hind_right': (.60, 1.05), 'fore_left': (.45, 1.05), 'fore_right': (.85, 1.45)}
    for tick in range(count):
        t = tick/120; pose = a.old.sample(c, t); m = a.old.matrices(sc, pose); mats = np.array([m[n] for n in ns])
        pts = np.einsum('nij,nj->ni', mats[vbi, :3, :3], loc)+mats[vbi, :3, 3]
        minimum = min(minimum, float(pts[:, 1].min())); roots.append(m['stag_root'][:3, 3].copy())
        for name, spec in chains.items():
            bones = spec['groups']
            for x, y in zip(bones[:-1], bones[1:]):
                joint_error = max(joint_error, abs(np.linalg.norm(m[x][:3, 3]-m[y][:3, 3])-np.linalg.norm(base[x][:3, 3]-base[y][:3, 3])))
            bucket = None
            if is_loop or a.ACCEL_END <= t < a.BRAKE:
                advanced = t/a.PERIOD+a.PHASES[name] if is_loop else (t-a.CHARGE)/a.PERIOD+a.PHASES[name]
                cyc = math.floor(advanced+1e-8); u = advanced-cyc
                if 0 <= u < a.DUTY-1e-7: bucket = ('gallop', name, cyc)
            elif not is_loop:
                start, end = prep_times[name]
                if t <= start: bucket = ('original', name)
                elif end <= t <= a.CHARGE: bucket = ('ready', name)
                elif (3.05 if name.startswith('fore') else a.STOP) <= t <= a.OPEN_END: bucket = ('stopped', name)
            if bucket is not None:
                p = m[bones[-1]][:3, 3].copy()
                if is_loop: p[2] -= a.SPEED*t
                if bucket not in contact_tracks: contact_tracks[bucket] = p
                maximum_plant = max(maximum_plant, float(np.linalg.norm(p-contact_tracks[bucket])))
                minimum_planted_sole = min(minimum_planted_sole, float(pts[toe_ids[name], 1].min()))
        if tick % 4 == 0:
            cc = np.einsum('nij,nj->ni', mats[bi, :3, :3], centers)+mats[bi, :3, 3]
            rr = np.einsum('nij,njk->nik', mats[bi, :3, :3], cube_r)
            bounds = np.einsum('nij,nj->ni', abs(rr), half)
            mask = np.all(abs(cc[ii]-cc[jj]) < bounds[ii]+bounds[jj], axis=1)
            for i, j in pairs[mask]:
                narrow += 1; depth = sat_depth(cc[i], rr[i], half[i], cc[j], rr[j], half[j])
                if depth > max(.20, baseline.get((i, j), 0)+.20):
                    if len(violations) < 16: violations.append({'time': round(t, 4), 'a': es[i]['name'], 'b': es[j]['name'], 'depth': depth})
        if tick % 240 == 0: print('phase', phase, c['name'], 'audit', round(t, 2), flush=True)
    first, last = [a.old.matrices(sc, a.old.sample(c, t)) for t in [0, duration]]
    if is_loop:
        end_error = max(float(abs(last[n]-first[n]).max()) for n in ns)
    else:
        end_error = 0.
        for n in ns:
            expected = first[n].copy(); expected[2, 3] -= a.DISTANCE
            end_error = max(end_error, float(abs(last[n]-expected).max()))
    roots = np.array(roots)
    heading_error = max(abs(float(k['data_points'][0]['y'])) for tr in c['animators'].values() if tr['name'] in ['body', 'neck', 'head'] for k in tr['keyframes'] if k['channel'] == 'rotation')
    result = {'phase': phase, 'clip': c['name'], 'samples_120hz': count, 'duration': duration,
              'minimum_all_geometry_y': minimum, 'minimum_planted_sole_y': minimum_planted_sole,
              'joint_length_error': joint_error, 'planted_world_pivot_drift': maximum_plant,
              'end_pose_or_loop_matrix_error': end_error, 'heading_yaw_key_error': heading_error,
              'root_displacement': (roots[-1]-roots[0]).tolist(),
              'root_lateral_error': float(abs(roots[:, :2]).max()),
              'root_forward_only': bool(np.diff(roots[:, 2]).max() < 1e-7),
              'clearance_pairs': len(pairs), 'clearance_sample_Hz': 30, 'SAT_narrow_checks': narrow,
              'new_deep_overlap_candidates': violations,
              'scope': 'Saved key interpolation; planting windows and selected lower limbs/head/crown vs inner barrel/lower limbs. Not all Cube pairs or runtime swept collision.'}
    result['passed'] = bool(minimum >= -.015 and joint_error < 1e-7 and maximum_plant < .65 and end_error < 1e-7
                            and not violations and heading_error == 0 and result['root_forward_only'])
    return result


def run():
    rec = a.load(a.D/'制作记录.json')
    for p, h in rec['source_hashes'].items(): assert a.sha(a.old.Path(p)) == h, 'Protected source changed'
    results = []
    for phase, title in enumerate(a.TITLES, 1):
        b = a.load(a.D/(title+'.bbmodel')); src = a.load(a.S/(a.old.TITLES[phase-1]+'.bbmodel'))
        for k in ['elements', 'groups', 'outliner', 'resolution']: assert b[k] == src[k], k
        assert b['animations'][:len(src['animations'])] == src['animations'], 'Existing slam changed'
        assert len(b['animations']) == len(src['animations'])+2
        assert [t['source'] for t in b['textures']] == [t['source'] for t in src['textures']]
        for t in b['textures']: assert (a.D/t['relative_path']).read_bytes() == base64.b64decode(t['source'].split(',', 1)[1])
        aj = a.load(a.D/(title+'.ajblueprint'))
        for k in ['elements', 'groups', 'outliner', 'textures', 'animations']: assert b[k] == aj[k]
        gids = {g['uuid'] for g in b['groups']}
        for c in b['animations'][len(src['animations']):]:
            for gid, tr in c['animators'].items():
                assert gid in gids
                keys = [(k['channel'], k['time']) for k in tr['keyframes']]
                assert len(keys) == len(set(keys)) and all(abs(t*c['snapping']-round(t*c['snapping'])) < 1e-6 for _, t in keys)
            results.append(check_motion(phase, b, c))
    report = {'passed': all(r['passed'] for r in results), 'protected_source_files_unchanged': True,
              'geometry_groups_UVs_texture_pixels_unchanged': True, 'old_slam_clips_unchanged': True,
              'results': results, 'game_targeting_collision_damage_AI_implemented': False,
              'native_reopened': False, 'native_exported': False, 'game_tested': False}
    a.jsave(a.D/'冲刺动作核验.json', report); print(json.dumps(report, ensure_ascii=False), flush=True)
    assert report['passed'], 'Inspect the actual saved-animation report'


if __name__ == '__main__': run()
