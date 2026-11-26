"""Audit the body-only second form from its saved native projects."""
import base64, collections, json
import numpy as np
import a_ghost_body_morph_20261122 as a
from check_a_ghost_representative_20261122 import obbs, pair_depth
from check_a_ghost_phase2_expand_20261122 import candidates, visible_points


def run():
    b=a.load(a.D/(a.TITLE+'.bbmodel'));fx=a.load(a.D/(a.TITLE+'_骨刺预览.bbmodel'));src=a.load(a.SRC);rec=a.load(a.D/'制作记录.json')
    assert a.sha(a.SRC)==rec['source_sha256'] and a.sha(a.SRC.with_suffix('.ajblueprint'))==rec['source_aj_sha256']
    assert a.sha(a.FXSRC)==rec['preview_source_sha256'] and b['elements']==src['elements'] and b['groups'][:134]==src['groups']
    assert next(c for c in b['animations']if c['name']=='bone_volley')==next(c for c in src['animations']if c['name']=='bone_volley')
    assert all(x['source']==y['source']for x,y in zip(src['textures'],b['textures']))
    for title in [a.TITLE,a.TITLE+'_骨刺预览']:
        bb=a.load(a.D/(title+'.bbmodel'));aj=a.load(a.D/(title+'.ajblueprint'))
        assert all(bb[k]==aj[k]for k in ['elements','groups','outliner','textures','animations'])
        nodes=a.base.group_nodes(bb);gids={g['uuid']for g in bb['groups']};refs=[x for n in nodes.values()for x in n['children']if isinstance(x,str)]
        assert set(nodes)==gids and collections.Counter(refs)==collections.Counter(e['uuid']for e in bb['elements'])
        assert len(gids)==len(bb['groups']) and len({e['uuid']for e in bb['elements']})==len(bb['elements'])
        tx={t['uuid']:t for t in bb['textures']}
        for t in bb['textures']:assert(a.D/t['relative_path']).read_bytes()==base64.b64decode(t['source'].split(',',1)[1])
        for e in bb['elements']:
            assert all(z>x for x,z in zip(e['from'],e['to']))
            r=[x for x in e.get('rotation',[0]*3)if abs(x)>1e-6];assert len(r)<=1 and all(x in [-45,-22.5,22.5,45]for x in r)
            for f in e['faces'].values():
                ref=f.get('texture')
                if ref is None:continue
                t=bb['textures'][ref]if isinstance(ref,int)else tx[ref]
                assert all(0<=v<=t.get('uv_width'if j%2==0 else'uv_height',512)for j,v in enumerate(f['uv']))
        for c in bb['animations']:
            for uid,tr in c['animators'].items():
                ids=[(k['channel'],k['time'])for k in tr['keyframes']];assert uid in gids and len(ids)==len(set(ids))and all(abs(t*20-round(t*20))<1e-6 for ch,t in ids)
    sc,ss,fs=a.Scene(b),a.Scene(src),a.Scene(fx);m0=a.matrices(sc,{})
    rest_error=float(abs(sc.pose()[0]-ss.pose()[0]).max());first_error=0
    c1=next(c for c in b['animations']if c['name']=='bone_volley');c0=next(c for c in src['animations']if c['name']=='bone_volley')
    for t in [0,.5,.8,1.5,2.1,3.3]:first_error=max(first_error,float(abs(sc.pose(a.frame(sc,c1,t))[0]-ss.pose(a.frame(ss,c0,t))[0]).max()))
    arm=['bone_upper_shell_'+s for s in a.base.SIDES]+['bone_forearm_shell_'+s for s in a.base.SIDES]+['claw_'+s for s in a.base.SIDES]
    arm += [x['name']for x in rec['morph_groups']if x['kind']in['finger','thumb']]
    target=['chest','head','back_orbit','rear_staff_frame','morph_crest_left','morph_crest_right']
    pairs=[(x,y)for x in arm for y in target]+[('back_orbit',x)for x in ['chest','head','crown_frame','rear_staff_frame']]
    names=list(dict.fromkeys(arm+target+['crown_frame']));baseline={n:obbs(sc,n,m0)for n in names}
    joints=[('chest','upperarm_'+s)for s in a.base.SIDES]+[('upperarm_'+s,'forearm_'+s)for s in a.base.SIDES]+[('forearm_'+s,'claw_'+s)for s in a.base.SIDES]
    original=[g['name']for g in src['groups']if not g['name'].startswith('dissolve_patch_')]
    joint_error=0;min_det=1.;max_det=1.;floor=1e9;samples=0;collisions=[]
    feet={n:[e for e in sc.elements if sc.element_bone[e['uuid']]==n]for n in ['foot_left','foot_right']}
    for c in b['animations']:
        if c['name']=='bone_volley':continue
        for i in range(round(c['length']*120)+1):
            t=i/120;m=a.matrices(sc,a.sample(c,t));samples+=1
            for n in original:
                det=float(np.linalg.det(m[n][:3,:3]));min_det=min(min_det,det);max_det=max(max_det,det)
            for x,y in joints:joint_error=max(joint_error,abs(np.linalg.norm(m[x][:3,3]-m[y][:3,3])-np.linalg.norm(m0[x][:3,3]-m0[y][:3,3])))
            for n,es in feet.items():
                for e in es:floor=min(floor,float((sc.corners[e['uuid']]@m[n][:3,:3].T+m[n][:3,3])[:,1].min()))
            boxes={n:obbs(sc,n,m)for n in names}
            for x,y in pairs:
                ia,ib=candidates(boxes[x],boxes[y])
                if not len(ia):continue
                dep=pair_depth(boxes[x],boxes[y],ia,ib);old=pair_depth(baseline[x],baseline[y],ia,ib)
                bad=(dep>.08)&(dep-np.maximum(old,0)>.08)
                if np.any(bad):collisions.append({'clip':c['name'],'time':t,'groups':[x,y],'extra':float((dep-np.maximum(old,0))[bad].max())})
        print('Checked',c['name'],round(c['length']*120)+1,flush=True)
    idle=next(c for c in b['animations']if c['name']=='phase2_idle');trans=next(c for c in b['animations']if c['name']=='phase_transition')
    start,end=[a.matrices(sc,a.sample(idle,t))for t in [0,3]];te=a.matrices(sc,a.sample(trans,2));visible=[n for n in sc.names if not n.startswith('dissolve_patch_')]
    loop=max(float(abs(start[n]-end[n]).max())for n in visible);seam=max(float(abs(start[n]-te[n]).max())for n in visible)
    orbit=next(g for g in b['groups']if g['name']=='back_orbit');emit=[]
    for c in fx['animations']:
        if c['name']not in ['bone_volley','bone_volley_phase2']:continue
        for shot in rec['helpers']['bolts']:
            m=a.matrices(fs,a.sample(c,shot['shot']));expected=(m['back_orbit']@np.r_[np.array(shot['origin'])-orbit['origin'],1])[:3]
            error=float(np.linalg.norm(m[shot['name']][:3,3]-expected));emit.append(error)
            assert a.sample(c,shot['shot']-.001)[shot['name']]['scale']==[0]*3
    parts={};bounds=[]
    for t,c in [(0,trans),(0,idle)]:
        p=visible_points(sc,c,t);bounds.append({'min':p.min(0).tolist(),'max':p.max(0).tolist(),'size':np.ptp(p,axis=0).tolist()})
    result={'source_hashes_unchanged':True,'all_1440_source_elements_preserved':True,'added_body_cubes':0,'source_4_texture_pixels_unchanged':True,'first_phase_animation_byte_equal':True,
            'character_groups':len(b['groups']),'preview_cubes':len(fx['elements']),'preview_groups':len(fx['groups']),'morph_group_count':len(rec['morph_groups']),
            'rest_world_vertex_error':rest_error,'first_phase_world_vertex_error':first_error,'samples_120hz':samples,'joint_distance_error':joint_error,
            'protected_determinant_range':[min_det,max_det],'minimum_foot_y':floor,'loop_error':loop,'transition_to_idle_error':seam,
            'collision_group_pairs':len(pairs),'new_overlap_over_008_model_units':collisions,'maximum_emission_error':max(emit),'phase_bounds':bounds,
            'native_reopened':False,'native_exported':False,'game_tested':False,'limits':'Selected hand/arm/back-assembly OBB pairs only; opening ribs and layered garments still require visual review.'}
    result['passed']=not collisions and rest_error<1e-8 and first_error<1e-8 and joint_error<1e-8 and .999999<min_det<=max_det<1.000001 and floor>-.001 and loop<1e-5 and seam<1e-5 and max(emit)<1e-5
    a.write(a.D/'离线动作与源保护核验.json',json.dumps(result,ensure_ascii=False,indent=2))
    print(json.dumps({k:v for k,v in result.items()if k!='new_overlap_over_008_model_units'},ensure_ascii=False),flush=True)
    print('collisions',len(collisions),collisions[:5],flush=True)
    assert result['passed']


if __name__=='__main__':run()
