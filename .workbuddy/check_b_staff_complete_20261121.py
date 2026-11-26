"""Sample the actual six-clip saved projects; no game/source writes."""
import collections, json, math, sys
import numpy as np
import b_staff_complete_20261121 as x


def check():
    b, source = x.load(x.D/(x.TITLE+'.bbmodel')), x.load(x.SRC)
    fx = x.load(x.D/(x.TITLE+'_全部技能预览.bbmodel')); record = x.load(x.D/'制作记录.json')
    sc, fs = x.Scene(b), x.Scene(fx); gs = {g['name']: g for g in b['groups']}
    geo = {n: [e for e in b['elements'] if sc.element_bone[e['uuid']] == n] for n in sc.names}
    local = {n: (np.array([e['from'] for e in es]), np.array([e['to'] for e in es])) for n, es in geo.items() if es}
    def boxes(n, m):
        lo, hi = local[n]; rot = m[n][:3, :3]
        c = ((lo+hi)/2-gs[n]['origin'])@rot.T+m[n][:3, 3]; h = (hi-lo)/2
        extent = h@abs(rot).T
        return (c, h, rot), (np.min(c-extent, axis=0), np.max(c+extent, axis=0))
    def depth(a, z):
        lo = np.maximum(a[1][0], z[1][0]); hi = np.minimum(a[1][1], z[1][1]); overlap = hi-lo
        if overlap.min() < -1e-6:
            return float(overlap.min())
        return x.fan.depth(a[0], z[0])
    parts = ['pelvis', 'waist', 'chest', 'neck', 'head']+[p+'_'+s for s in ['left', 'right'] for p in ['arm_upper', 'arm_lower', 'hand', 'leg_upper', 'leg_lower', 'foot']]
    pairs = [('staff', n) for n in parts if n != 'hand_right']
    pairs += [('staff', n) for n in local if n.startswith(('robe_', 'head_drape')) or n in ['tabard', 'coat_045']]
    pairs += [(n, body) for n in ['arm_lower_right', 'hand_right', 'arm_lower_left', 'hand_left'] for body in ['head', 'neck', 'chest', 'waist', 'pelvis']]
    lower_cloth = [n for n in local if n.startswith('robe_') and '_2_' in n]
    legpairs = [(p+'_'+side, n) for side in ['right', 'left'] for p in ['leg_upper', 'leg_lower', 'foot'] for n in lower_cloth if ('robe_'+side) in n]
    joints = [('chest', 'arm_upper_'+s) for s in ['left', 'right']]+[('pelvis', 'leg_upper_'+s) for s in ['left', 'right']]+[(p+'_'+s, q+'_'+s) for s in ['left', 'right'] for p, q in [('arm_upper', 'arm_lower'), ('arm_lower', 'hand'), ('leg_upper', 'leg_lower'), ('leg_lower', 'foot')]]
    m0 = sc.matrices(); base = {p: max(0., depth(boxes(p[0], m0), boxes(p[1], m0))) for p in pairs+legpairs}
    grip = np.linalg.inv(m0['hand_right'])@m0['staff']
    selected = sys.argv[1:] or list(x.SPECS)
    previous = x.D/'完整动作离线核验.json'
    clips = x.load(previous)['clips'] if len(selected) < 4 and previous.exists() else {}
    for name in selected:
        spec = x.SPECS[name]
        a = next(a for a in b['animations'] if a['name'] == name); fa = next(a for a in fx['animations'] if a['name'] == name)
        bad, lost, legbad = [], [], []; grip_error = 0.; minimum = {n: 1e9 for n in ['staff', 'foot_left', 'foot_right']}
        stance_positions = collections.defaultdict(list); count = round(spec['length']*120)+1
        active_pairs = pairs+(legpairs if name == 'repel_retreat' else [])
        for i in range(count):
            t = i/120; m = sc.matrices(x.sample(a, t)); cache = {n: boxes(n, m) for n in local}
            for n in minimum:
                points = np.vstack([sc.corners[e['uuid']] for e in geo[n]])@m[n][:3, :3].T+m[n][:3, 3]
                minimum[n] = min(minimum[n], float(points[:, 1].min()))
            for left, right in joints:
                if depth(cache[left], cache[right]) < -1e-5:
                    lost.append([t, left, right])
            grip_error = max(grip_error, float(np.abs(np.linalg.inv(m['hand_right'])@m['staff']-grip).max()))
            for left, right in active_pairs:
                extra = depth(cache[left], cache[right])-base[left, right]
                if extra > .08:
                    (legbad if (left, right) in legpairs else bad).append([t, left, right, extra])
            if name == 'repel_retreat' and 1. < t < 3.4:
                actor = x.sample(fa, t)['root']['position'][2]
                for side in ['left', 'right']:
                    phase = (x.retreat_distance(t)/32+(0 if side == 'right' else .5))
                    if .025 < phase%1 < .475:
                        stance_positions[side, math.floor(phase)].append((m['foot_'+side][:3, 3]+[0, 0, actor]).tolist())
        slip = max([float(np.ptp(np.array(v)[:, 2])) for v in stance_positions.values()]+[0.])
        report = {'samples_120hz': count, 'specified_body_pairs': len(pairs), 'additional_leg_cloth_pairs': len(legpairs) if name == 'repel_retreat' else 0,
                  'grip_relative_error': grip_error, 'floor_minimum_y': minimum, 'lost_joint_contacts': lost,
                  'new_body_intersections_over_008': bad, 'new_leg_cloth_intersections_over_008': legbad, 'stance_slip_model_units': slip}
        report['passed'] = not(bad or lost or legbad) and grip_error < 1e-8 and min(minimum.values()) > -.02 and slip < .25
        clips[name] = report
        print(name, 'passed', report['passed'], 'floor', minimum, 'body', len(bad), 'leg_cloth', len(legbad), 'lost', len(lost), 'slip', slip, flush=True)
    errors = []; fields = ['elements', 'groups', 'outliner', 'textures', 'animations']
    for title in [x.TITLE, x.TITLE+'_全部技能预览']:
        model = x.load(x.D/(title+'.bbmodel')); aj = x.load(x.D/(title+'.ajblueprint'))
        if any(model[k] != aj[k] for k in fields):
            errors.append([title, 'BB/AJ mismatch'])
        for tex in model['textures']:
            if (x.D/tex['relative_path']).read_bytes() != x.base64.b64decode(tex['source'].split(',', 1)[1]):
                errors.append([title, tex['name']])
        elements = collections.Counter(); groups = collections.Counter()
        def walk(nodes):
            for n in nodes:
                if isinstance(n, str):
                    elements[n] += 1
                else:
                    groups[n['uuid']] += 1; walk(n['children'])
        walk(model['outliner'])
        if set(elements) != {e['uuid'] for e in model['elements']} or any(v != 1 for v in elements.values()) or set(groups) != {g['uuid'] for g in model['groups']} or any(v != 1 for v in groups.values()):
            errors.append([title, 'invalid parent references'])
    textures = {t['uuid']: t for t in fx['textures']}
    for e in fx['elements']:
        r = e.get('rotation', [0, 0, 0]); nonzero = [v for v in r if abs(v) > 1e-6]
        if len(nonzero) > 1 or any(abs(v) not in [22.5, 45] for v in nonzero):
            errors.append([e['name'], 'illegal Cube rotation', r])
        for face in e['faces'].values():
            ref = face.get('texture')
            if ref is None:
                continue
            tex = fx['textures'][ref] if isinstance(ref, int) else textures.get(ref)
            if tex is None or any(not 0 <= v <= tex.get('uv_width' if i%2 == 0 else 'uv_height', 512) for i, v in enumerate(face['uv'])):
                errors.append([e['name'], 'UV/texture'])
    peaks = {}
    for a in fx['animations']:
        peak = 0
        for tr in a['animators'].values():
            seen = set()
            for k in tr.get('keyframes', []):
                identity = (k['channel'], k['time'])
                if identity in seen or abs(k['time']*20-round(k['time']*20)) > 1e-6:
                    errors.append([a['name'], tr['name'], 'duplicate/off-tick', identity])
                seen.add(identity)
        for i in range(round(a['length']*20)+1):
            matrices = x.core.matrices(fs, x.sample(a, i/20))
            active = {n for n, m in matrices.items() if np.linalg.norm(m[:3, :3]) > 1e-5}
            peak = max(peak, sum(fs.element_bone[e['uuid']] in active for e in fx['elements'][620:]))
        peaks[a['name']] = peak
    unchanged = all(b[k] == source[k] for k in ['elements', 'groups', 'outliner']) and b['animations'][:2] == source['animations'] and all(t['source'] == old['source'] for t, old in zip(b['textures'], source['textures']))
    hashes = x.sha(x.SRC) == record['source_sha256'] and x.sha(x.SRC.with_suffix('.ajblueprint')) == record['source_aj_sha256'] and x.sha(x.PREVIEW_SRC) == record['source_preview_sha256']
    result = {'clips': clips, 'rechecked_clips_this_pass': selected, 'asset_errors': errors, 'source_body_and_old_clips_unchanged': unchanged, 'source_hashes_unchanged': hashes,
              'peak_active_preview_cubes': peaks, 'native_reopen': False, 'native_export': False, 'game_tested': False,
              'limitations': 'Offline selected OBBs and saved Euler-key interpolation; visual geometry only. Actor retreat path has no terrain/collision validation. Not runtime hitboxes, performance or art approval.'}
    result['passed'] = all(v['passed'] for v in clips.values()) and not errors and unchanged and hashes
    (x.D/'完整动作离线核验.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf8')
    print('Overall', result['passed'], 'assets', errors[:6], 'peaks', peaks, flush=True)


if __name__ == '__main__':
    check()
