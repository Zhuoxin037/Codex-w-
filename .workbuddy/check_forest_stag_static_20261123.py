"""Offline Cube-export rehearsal and exposed coplanar surface probe.

This is a model-stage check, not a native AJ export or Minecraft test.
"""
import base64, collections, copy, hashlib, itertools, json
import numpy as np
import build_forest_stag_static_20261123 as a


def rounded(v):
    return [round(float(x), 9) for x in v]


def export_rehearsal(models):
    dest = a.D/'离线导出核验'; library = {}; states = []; errors = []
    texture = 'fallendream_boss:item/forest_stag_atlas'
    for stage, b in enumerate(models, 1):
        sc = a.Scene(b); gs = {g['name']: g for g in b['groups']}; ms = sc.matrices(); grouped = collections.defaultdict(list)
        for e in b['elements']: grouped[sc.element_bone[e['uuid']]].append(e)
        state = {}
        for name, elements in grouped.items():
            origin = np.array(gs[name]['origin'])
            lo = np.min([np.array(e['from'])-origin for e in elements], axis=0)
            hi = np.max([np.array(e['to'])-origin for e in elements], axis=0)
            center = (lo+hi)/2; factor = min(1., 46/max(hi-lo))
            asset = {'textures': {'0': texture, 'particle': texture}, 'ambientocclusion': True, 'elements': []}
            for e in elements:
                axis = [i for i, x in enumerate(e['rotation']) if abs(x) > 1e-8]
                assert len(axis) <= 1, (e['name'], e['rotation'])
                assert all(abs(v) in [0., 22.5, 45.] for v in e['rotation']), e['name']
                conv = lambda v: rounded((np.array(v)-origin-center)*factor+8)
                item = {'from': conv(e['from']), 'to': conv(e['to']), 'faces': {}}
                assert all(-16 <= v <= 32 for k in ['from', 'to'] for v in item[k])
                if axis: item['rotation'] = {'axis': 'xyz'[axis[0]], 'angle': e['rotation'][axis[0]], 'origin': conv(e['origin']), 'rescale': False}
                for face, f in e['faces'].items():
                    item['faces'][face] = {'texture': '#0', 'uv': rounded(np.array(f['uv'])*16/512)}
                    assert all(0 <= u <= 16 for u in item['faces'][face]['uv'])
                asset['elements'].append(item)
                # The model plus its recorded transform must reconstruct every
                # saved Cube vertex, including its own legal rotation.
                vr = np.array([[item['to'][j] if mask >> j & 1 else item['from'][j] for j in range(3)] for mask in range(8)])
                if 'rotation' in item:
                    r = a.rotation(e); ro = np.array(item['rotation']['origin']); vr = (vr-ro)@r.T+ro
                p = (vr-8)/factor+center
                p = p@ms[name][:3, :3].T+ms[name][:3, 3]
                expected = sc.corners[e['uuid']]@ms[name][:3, :3].T+ms[name][:3, 3]
                errors.append(float(abs(expected-p).max()))
            raw = json.dumps(asset, sort_keys=True, separators=(',', ':')).encode()
            code = hashlib.sha256(raw).hexdigest()[:20]
            library.setdefault(code, asset)
            state[name] = {'model': 'fallendream_boss:forest_stag_static/'+code, 'center_in_bone': rounded(center),
                           'model_factor': factor, 'bone_matrix_row_major': ms[name].tolist()}
        states.append({'stage': stage, 'geometry_bones': len(grouped), 'transforms': state})
    for code, asset in library.items():
        a.jsave(dest/('assets/fallendream_boss/models/forest_stag_static/'+code+'.json'), asset)
        a.jsave(dest/('assets/fallendream_boss/items/forest_stag_static/'+code+'.json'), {'model': {'type': 'minecraft:model', 'model': 'fallendream_boss:forest_stag_static/'+code}})
    # Retire only our old content-addressed rehearsal assets. Never remove a
    # user-edited model or any native project / live-pack file.
    model_dir = dest/'assets/fallendream_boss/models/forest_stag_static'
    for old in model_dir.glob('*.json'):
        if old.stem in library: continue
        assert old.resolve().is_relative_to(dest.resolve())
        old_asset = a.load(old); raw = json.dumps(old_asset, sort_keys=True, separators=(',', ':')).encode()
        if hashlib.sha256(raw).hexdigest()[:20] != old.stem: continue
        item = dest/('assets/fallendream_boss/items/forest_stag_static/'+old.stem+'.json')
        expected = {'model': {'type': 'minecraft:model', 'model': 'fallendream_boss:forest_stag_static/'+old.stem}}
        if item.exists() and a.load(item) == expected: item.unlink()
        old.unlink()
    a.write(dest/'assets/fallendream_boss/textures/item/forest_stag_atlas.png', base64.b64decode(models[0]['textures'][0]['source'].split(',', 1)[1]))
    a.jsave(dest/'assets/minecraft/atlases/blocks.json', {'sources': [{'type': 'minecraft:single', 'resource': texture, 'sprite': texture}]})
    a.jsave(dest/'两阶段分部变换.json', states)
    assert max(errors) < 1e-7, max(errors)
    return {'legal_Java_element_coordinates_rotations_UVs': True, 'unique_geometry_models': len(library),
            'geometry_bones_each_form': [s['geometry_bones'] for s in states],
            'reused_models_across_forms': sum(s['geometry_bones'] for s in states)-len(library),
            'maximum_vertex_reconstruction_error': max(errors), 'texture_file_and_explicit_atlas_source': True,
            'native_AJ_export': False, 'game_loaded': False,
            'scope': 'Offline static model assets and reconstruction only; no runtime summon, animation, AI, combat, cleanup or deployment.'}


def area(poly):
    if len(poly) < 3: return 0.
    v = np.array(poly); u = np.roll(v, -1, axis=0)
    return float(np.sum(v[:, 0]*u[:, 1]-v[:, 1]*u[:, 0])/2)


def clip(subject, boundary):
    if area(boundary) < 0: boundary = boundary[::-1]
    out = list(subject)
    cross = lambda v, w: v[0]*w[1]-v[1]*w[0]
    for i, aa in enumerate(boundary):
        bb = boundary[(i+1) % len(boundary)]; edge = bb-aa; old, out = out, []
        if not old: break
        def inside(p): return cross(edge, p-aa) >= -1e-7
        for j, q in enumerate(old):
            p = old[j-1]; ip, iq = inside(p), inside(q)
            if ip != iq:
                delta = q-p; den = cross(edge, delta)
                if abs(den) > 1e-12: out.append(p+delta*(cross(edge, aa-p)/den))
            if iq: out.append(q)
    return np.array(out)


def coplanar_probe(b):
    sc = a.Scene(b); points, normals, _ = sc.pose(); ms = sc.matrices(); gs = {g['name']: g for g in b['groups']}
    centers, rots, halves, owners = [], [], [], []
    for e in b['elements']:
        name = sc.element_bone[e['uuid']]; mat = ms[name]; mid = (np.array(e['from'])+e['to'])/2; eo = np.array(e['origin'])
        c = mat[:3, :3]@(a.rotation(e)@(mid-eo)+eo-np.array(gs[name]['origin']))+mat[:3, 3]
        centers.append(c); rots.append(mat[:3, :3]@a.rotation(e)); halves.append((np.array(e['to'])-e['from'])/2)
        owners.extend([e['name']]*len(e['faces']))
    centers, rots, halves = map(np.array, [centers, rots, halves])
    buckets = collections.defaultdict(list)
    for i in range(len(points)//4):
        quad = points[i*4:i*4+4]; n = normals[i*4]; key = tuple(np.round(n, 6))+(round(float(n@quad[0]), 5),)
        buckets[key].append((i, quad, n))
    candidates = 0; exposed = []
    for bucket in buckets.values():
        if len(bucket) < 2: continue
        for (ia, qa, n), (ib, qb, _) in itertools.combinations(bucket, 2):
            u = a.unit(qa[1]-qa[0]); v = np.cross(n, u); q1 = np.c_[qa@u, qa@v]; q2 = np.c_[qb@u, qb@v]
            if np.any(q1.max(0) < q2.min(0)+1e-5) or np.any(q2.max(0) < q1.min(0)+1e-5): continue
            poly = clip(q1, q2)
            if len(poly) < 3 or abs(area(poly)) < .002: continue
            candidates += 1
            cp = poly.mean(0); world = u*cp[0]+v*cp[1]+n*(n@qa[0])
            delta = world+n*.002-centers; local = np.einsum('ni,nij->nj', delta, rots)
            covered = np.any(np.all(abs(local) < halves-.0001, axis=1))
            if not covered:
                exposed.append({'a': owners[ia], 'b': owners[ib], 'area': abs(area(poly)), 'point': rounded(world)})
    return {'coincident_same_facing_face_candidates': candidates, 'exposed_centroid_candidates': exposed,
            'limits': 'Planar same-facing polygon intersection + outward-centroid occlusion probe, area >=0.002 model units squared. Not exhaustive arbitrary-mesh collision or runtime z-buffer testing.'}


def volume_connectivity(b):
    sc = a.Scene(b); mats = sc.matrices(); groups = {g['name']: g for g in b['groups']}
    cs, rs, hs = [], [], []
    for e in b['elements']:
        n = sc.element_bone[e['uuid']]; m = mats[n]; mid = (np.array(e['from'])+e['to'])/2; o = np.array(e['origin'])
        cs.append(m[:3, :3]@(a.rotation(e)@(mid-o)+o-np.array(groups[n]['origin']))+m[:3, 3])
        rs.append(m[:3, :3]@a.rotation(e)); hs.append((np.array(e['to'])-e['from'])/2)
    cs, rs, hs = map(np.array, [cs, rs, hs]); ah = np.einsum('nij,nj->ni', abs(rs), hs)
    lo, hi = cs-ah, cs+ah; roots = list(range(len(cs))); tested = 0; tolerance = .03
    def find(i):
        while roots[i] != i: roots[i] = roots[roots[i]]; i = roots[i]
        return i
    def touches(i, j):
        r = rs[i].T@rs[j]; ar = abs(r)+1e-10; t = rs[i].T@(cs[j]-cs[i])
        if np.any(abs(t) > hs[i]+ar@hs[j]+tolerance): return False
        if np.any(abs(r.T@t) > hs[j]+ar.T@hs[i]+tolerance): return False
        for k in range(3):
            for q in range(3):
                axis = np.cross(rs[i][:, k], rs[j][:, q]); length = float(np.linalg.norm(axis))
                if length < 1e-7: continue
                axis /= length
                radius = abs(axis@rs[i])@hs[i]+abs(axis@rs[j])@hs[j]
                if abs(axis@(cs[j]-cs[i])) > radius+tolerance: return False
        return True
    for i in range(len(cs)):
        possible = np.where(np.all(lo <= hi[i]+tolerance, axis=1)&np.all(hi >= lo[i]-tolerance, axis=1))[0]
        for j in possible:
            if j <= i or find(i) == find(j): continue
            tested += 1
            if touches(i, j): roots[find(j)] = find(i)
    components = collections.defaultdict(list)
    for i, e in enumerate(b['elements']): components[find(i)].append(e['name'])
    parts = sorted(components.values(), key=len, reverse=True)
    return {'connected_components': len(parts), 'component_sizes': [len(p) for p in parts],
            'small_components': parts[1:], 'OBB_contact_pairs_tested': tested,
            'contact_tolerance_model_units': tolerance,
            'scope': 'Saved static oriented Cube volume/contact graph; deliberate physical intersections and contacts are allowed. Not animated collision or runtime hitbox testing.'}


def main():
    models = [a.load(a.D/(n+'.bbmodel')) for n in a.NAMES]
    export = export_rehearsal(models)
    probes = [coplanar_probe(b) for b in models]
    volumes = [volume_connectivity(b) for b in models]
    report = {'offline_export': export, 'coplanar_probes': probes, 'volume_connectivity': volumes,
              'passed': not any(p['exposed_centroid_candidates'] for p in probes) and all(v['connected_components'] == 1 for v in volumes)}
    a.jsave(a.D/'分部导出与共面核验.json', report)
    print(json.dumps(report, ensure_ascii=False), flush=True)
    assert report['passed'], 'Inspect exposed coincident face candidates in saved report'


if __name__ == '__main__': main()
