"""Check the saved A animation stage, not a parallel animation simulator."""
import base64, collections, json, math
import numpy as np
import a_ghost_representative_20261122 as a


def obbs(sc, name, m):
    es = [e for e in sc.elements if sc.element_bone[e['uuid']] == name]
    centers, halves, rotations = [], [], []
    for e in es:
        r = a.core.rotation(e); mid = (np.array(e['from'])+e['to'])/2
        local = r@(mid-e['origin'])+e['origin']-sc.groups[next(u for u, g in sc.groups.items() if g['name'] == name)]['origin']
        centers.append(m[name][:3, :3]@local+m[name][:3, 3]); halves.append((np.array(e['to'])-e['from'])/2)
        rotations.append(m[name][:3, :3]@r)
    return np.array(centers), np.array(halves), np.array(rotations)


def aabb(box):
    c, h, r = box; ext = np.einsum('nij,nj->ni', abs(r), h)
    return c-ext, c+ext


def pair_depth(ba, bb, ia, ib):
    ca, ha, ra = [x[ia] for x in ba]; cb, hb, rb = [x[ib] for x in bb]
    aa, ab = ra.transpose(0, 2, 1), rb.transpose(0, 2, 1)
    cross = np.cross(aa[:, :, None, :], ab[:, None, :, :]).reshape(-1, 9, 3)
    axes = np.concatenate([aa, ab, cross], axis=1); lengths = np.linalg.norm(axes, axis=2)
    axes /= np.maximum(lengths, 1e-20)[:, :, None]
    radii = (abs(np.einsum('nki,nij->nkj', axes, ra))*ha[:, None, :]).sum(2)
    radii += (abs(np.einsum('nki,nij->nkj', axes, rb))*hb[:, None, :]).sum(2)
    depths = radii-abs(np.einsum('nki,ni->nk', axes, cb-ca))
    depths[lengths < 1e-7] = np.inf
    return depths.min(1)


def run():
    b = a.load(a.D/(a.TITLE+'.bbmodel')); f = a.load(a.D/(a.TITLE+'_含流束与骨刺预览.bbmodel'))
    old = a.load(a.SRC); rec = a.load(a.D/'制作记录.json'); sc, os = a.Scene(b), a.Scene(old)
    source_ok = a.sha(a.SRC) == rec['source_sha256'] and a.sha(a.SRC.with_suffix('.ajblueprint')) == rec['source_aj_sha256']
    assert b['elements'] == old['elements'] and b['groups'][:96] == old['groups']
    assert source_ok
    m0 = a.matrices(sc, {}); om = a.matrices(os, {})
    old_points = os.pose()[0]; points = sc.pose()[0]
    rest_error = float(abs(points-old_points).max())
    errors = []; texture_pixels = []
    for title in [a.TITLE, a.TITLE+'_含流束与骨刺预览']:
        bb = a.load(a.D/(title+'.bbmodel')); aj = a.load(a.D/(title+'.ajblueprint'))
        for k in ['elements', 'groups', 'outliner', 'textures', 'animations']:
            if bb[k] != aj[k]: errors.append([title, k])
        nodes = a.group_nodes(bb); groupids = {g['uuid'] for g in bb['groups']}
        flattened = [x for n in nodes.values() for x in n['children'] if isinstance(x, str)]
        if set(nodes) != groupids or collections.Counter(flattened) != collections.Counter(e['uuid'] for e in bb['elements']): errors.append([title, 'outliner coverage'])
        if len(set(e['uuid'] for e in bb['elements'])) != len(bb['elements']): errors.append([title, 'duplicate elements'])
        textures = {t['uuid']: t for t in bb['textures']}
        for t in bb['textures']:
            if (a.D/t['relative_path']).read_bytes() != base64.b64decode(t['source'].split(',', 1)[1]): errors.append([title, t['name']])
        for e in bb['elements']:
            if any(z <= x for x, z in zip(e['from'], e['to'])): errors.append([title, e['name'], 'nonpositive volume'])
            r = e.get('rotation', [0, 0, 0]); nonzero = [v for v in r if abs(v) > 1e-6]
            if len(nonzero) > 1 or any(v not in [-45, -22.5, 22.5, 45] for v in nonzero): errors.append([e['name'], 'Java Cube rotation'])
            for face in e['faces'].values():
                ref = face.get('texture')
                if ref is None: continue
                tex = bb['textures'][ref] if isinstance(ref, int) else textures.get(ref)
                if tex is None or any(not 0 <= v <= tex.get('uv_width' if j%2 == 0 else 'uv_height', 512) for j, v in enumerate(face['uv'])): errors.append([e['name'], 'UV'])
        for c in bb['animations']:
            for uid, tr in c['animators'].items():
                if uid not in groupids: errors.append([c['name'], uid, 'unresolved track'])
                ks = [(k['channel'], k['time']) for k in tr['keyframes']]
                if len(ks) != len(set(ks)) or any(abs(t*20-round(t*20)) > 1e-6 for _, t in ks): errors.append([c['name'], tr['name'], 'keys'])
    texture_pixels = [x['source'] == y['source'] for x, y in zip(b['textures'], old['textures'])]
    fragment_names = {x['name'] for x in rec['fragments']}; protected = [n for n in sc.names if n not in fragment_names]
    still_names = ['pelvis', 'lower_robe', 'waist', 'chest', 'back_orbit', 'rear_bone_structure', 'rear_staff_frame', 'front_bone_structure', 'foot_left', 'foot_right']
    still_names += [n for n in sc.names if n.startswith(('fabric_fold_', 'thin_trailing_', 'front_', 'rear_outer_', 'back_keel_'))]
    joint_pairs = [('chest', 'upperarm_'+s) for s in a.SIDES]+[('upperarm_'+s, 'forearm_'+s) for s in a.SIDES]+[('forearm_'+s, 'claw_'+s) for s in a.SIDES]
    arm = ['bone_upper_shell_'+s for s in a.SIDES]+['bone_forearm_shell_'+s for s in a.SIDES]+['claw_'+s for s in a.SIDES]
    targets = ['chest', 'waist', 'head']; pairs = [(x, y) for x in arm for y in targets]
    baseline = {n: obbs(sc, n, m0) for n in arm+targets}
    max_joint = 0.; max_still = 0.; min_det = 1.; max_det = 1.; collisions = []; samples = 0
    for c in b['animations']:
        for i in range(round(c['length']*120)+1):
            t = i/120; pose = a.sample(c, t); m = a.matrices(sc, pose); samples += 1
            max_still = max(max_still, max(float(abs(m[n]-m0[n]).max()) for n in still_names))
            for n in protected:
                det = float(np.linalg.det(m[n][:3, :3])); min_det = min(min_det, det); max_det = max(max_det, det)
            for x, y in joint_pairs:
                max_joint = max(max_joint, abs(np.linalg.norm(m[x][:3, 3]-m[y][:3, 3])-np.linalg.norm(m0[x][:3, 3]-m0[y][:3, 3])))
            boxes = {n: obbs(sc, n, m) for n in arm+targets}; bounds = {n: aabb(boxes[n]) for n in boxes}
            for x, y in pairs:
                xa, xz = bounds[x]; ya, yz = bounds[y]
                if np.any(xz.max(0) < ya.min(0)) or np.any(yz.max(0) < xa.min(0)): continue
                mask = np.all((xz[:, None, :] >= ya[None, :, :]) & (yz[None, :, :] >= xa[:, None, :]), axis=2)
                ia, ib = np.where(mask)
                if not len(ia): continue
                dep = pair_depth(boxes[x], boxes[y], ia, ib); original = pair_depth(baseline[x], baseline[y], ia, ib)
                bad = (dep > .08) & (dep-np.maximum(original, 0) > .08)
                if np.any(bad): collisions.append({'clip': c['name'], 'time': t, 'groups': [x, y], 'max_extra': float((dep-np.maximum(original, 0))[bad].max())})
        print('Checked', c['name'], round(c['length']*120)+1, 'samples', flush=True)
    end = a.sample(b['animations'][0], 2.)
    hidden = [n for n in fragment_names if end[n]['scale'] == [0, 0, 0]]
    phase2 = a.sample(b['animations'][2], 0.)
    fs = a.Scene(f); emissions = []; helpers = rec['helpers']
    for clip in f['animations'][1:]:
        for shot in helpers['bolts']:
            m = a.matrices(fs, a.sample(clip, shot['shot']))
            error = float(np.linalg.norm(m[shot['name']][:3, 3]-shot['origin']))
            before = a.sample(clip, shot['shot']-.001)[shot['name']]['scale']
            emissions.append({'clip': clip['name'], 'name': shot['name'], 'time': shot['shot'], 'origin_error': error, 'hidden_before': before == [0, 0, 0]})
        early = a.sample(clip, .55); late = a.sample(clip, 1.25)
        assert early['cue_left']['scale'][0] > .99 and early['cue_right']['scale'] == [0, 0, 0]
        assert late['cue_left']['scale'] == [0, 0, 0] and late['cue_right']['scale'][0] > .99
    # Every adjacent flow segment shares endpoints when fully formed.
    max_gap = 0.
    for c in f['animations']:
        if c['name'] == 'bone_volley': continue
        for t in np.arange(1.5 if c['name'] == 'phase_transition' else 0, c['length']+.001, .05):
            m = a.matrices(fs, a.sample(c, float(t)))
            for side in a.SIDES:
                flows = [x for x in helpers['flows'] if x['side'] == side]
                for x, y in zip(flows[:-1], flows[1:]):
                    tip = m[x['name']]@np.array([0, x['length'], 0, 1])
                    max_gap = max(max_gap, float(np.linalg.norm(tip[:3]-m[y['name']][:3, 3])))
    report = {'source_unchanged': source_ok, 'original_1440_elements_byte_equal': b['elements'] == old['elements'],
              'original_96_groups_byte_equal': b['groups'][:96] == old['groups'], 'texture_pixels_preserved': all(texture_pixels),
              'rest_world_vertices_max_error': rest_error, 'character_cubes': len(b['elements']), 'character_groups': len(b['groups']),
              'preview_cubes': len(f['elements']), 'preview_groups': len(f['groups']), 'preview_texture_count': len(f['textures']),
              'three_cloth_groups_selected_elements': len(fragment_names), 'transition_hidden_elements': len(hidden),
              'remaining_character_cubes': 1440-len(hidden), 'samples_120hz': samples, 'joint_distance_max_error': max_joint,
              'lower_cloth_feet_and_back_hardware_matrix_max_error': max_still, 'protected_bone_determinant_range': [min_det, max_det],
              'collision_group_pairs': len(pairs), 'new_overlap_over_008_model_units': collisions,
              'flow_endpoint_max_error': max_gap, 'emissions': emissions, 'asset_errors': errors,
              'native_reopened': False, 'native_exported': False, 'game_tested': False,
              'limits': 'Saved Cubes/UV and sampled keys only. 18 selected arm-to-body OBB pairs; no blanket assertion of all contacts or client interpolation.'}
    report['passed'] = source_ok and not errors and not collisions and all(texture_pixels) and rest_error < 1e-9 and max_still < 1e-9 and max_joint < 1e-8 and len(hidden) == 38 and min_det > .999999 and max_det < 1.000001 and max_gap < 1e-4 and all(x['origin_error'] < 1e-5 and x['hidden_before'] for x in emissions)
    a.write(a.D/'离线动作与源保护核验.json', json.dumps(report, ensure_ascii=False, indent=2))
    print(json.dumps({k: v for k, v in report.items() if k not in ['emissions', 'new_overlap_over_008_model_units']}, ensure_ascii=False), flush=True)
    print('collisions', len(collisions), collisions[:4], flush=True)
    assert report['passed']


if __name__ == '__main__': run()
