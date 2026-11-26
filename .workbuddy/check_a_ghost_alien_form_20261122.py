"""Check the new alien-form project and write a whole-geometry Display editor."""
import base64, collections, copy, json
import numpy as np
import a_ghost_alien_form_20261122 as a


def run():
    b=a.load(a.D/(a.TITLE+'.bbmodel'));aj=a.load(a.D/(a.TITLE+'.ajblueprint'));r=a.load(a.D/'制作记录.json')
    assert a.sha(a.SRC)==r['source_sha256'] and a.sha(a.SRC.with_suffix('.ajblueprint'))==r['source_aj_sha256']
    assert all(b[k]==aj[k]for k in ['elements','groups','outliner','textures','animations'])
    nodes=a.old.group_nodes(b);gids={g['uuid']for g in b['groups']};refs=[x for n in nodes.values()for x in n['children']if isinstance(x,str)]
    assert len(gids)==len(b['groups']) and set(nodes)==gids and collections.Counter(refs)==collections.Counter(e['uuid']for e in b['elements'])
    assert len({e['uuid']for e in b['elements']})==len(b['elements'])
    tx={t['uuid']:t for t in b['textures']}
    for t in b['textures']:assert(a.D/t['relative_path']).read_bytes()==base64.b64decode(t['source'].split(',',1)[1])
    for e in b['elements']:
        assert all(v>u for u,v in zip(e['from'],e['to']))
        assert not any(e.get('rotation',[0,0,0]))
        for f in e['faces'].values():
            ref=f.get('texture')
            if ref is None:continue
            t=b['textures'][ref]if isinstance(ref,int)else tx[ref]
            assert all(0<=v<=t.get('uv_width'if i%2==0 else'uv_height',512)for i,v in enumerate(f['uv']))
    c=b['animations'][0]
    for u,tr in c['animators'].items():
        ids=[(k['channel'],k['time'])for k in tr['keyframes']];assert u in gids and len(ids)==len(set(ids)) and all(abs(t*20-round(t*20))<1e-6 for ch,t in ids)
    sc=a.Scene(b);m0=a.matrices(sc,{})
    connections=[]
    for tier in ['upper','lower']:
        for side in ['left','right']:connections +=[(tier+'_humerus_'+side,tier+'_forearm_'+side),(tier+'_radius_'+side,tier+'_claw_'+side)]
    joints=0.;loop=0.;minimum=1e9;bounds=[]
    linkmap={x['name']:x for x in r['links']}
    for i in range(361):
        m=a.matrices(sc,a.sample(c,i/120))
        for mesh,joint in connections:
            tip=m[mesh]@np.array([0,linkmap[mesh]['length'],0,1]);joints=max(joints,float(np.linalg.norm(tip[:3]-m[joint][:3,3])))
        if i%6==0:
            f={'matrices':{n:v.T.reshape(-1).tolist()for n,v in m.items()}};points=sc.pose(f)[0];minimum=min(minimum,float(points[:,1].min()));bounds.append([points.min(0).tolist(),points.max(0).tolist()])
    first,last=[a.matrices(sc,a.sample(c,t))for t in [0,3]];loop=max(float(abs(first[n]-last[n]).max())for n in sc.names)
    assert joints<1e-8 and loop<1e-6 and minimum>0
    # Editor-only exact bind-pose snapshot. Runtime export remains per-bone.
    display=copy.deepcopy(b);display['name']='A_异形态整体Display调整';display['meta']['model_format']='java_block';display['animations']=[]
    original=sc.pose()[0];lo=original.min(0);hi=original.max(0);size=hi-lo;factor=min(.625,42/max(size));shift=np.array([8,8,8])-(lo+hi)/2*factor
    root=copy.deepcopy(b['groups'][0]);root.update({'name':'整体Display','origin':[8,8,8],'rotation':[0,0,0]});display['groups']=[root];display['outliner']=[{'uuid':root['uuid'],'children':[e['uuid']for e in display['elements']],'isOpen':True}]
    gs={g['name']:g for g in b['groups']}
    for e in display['elements']:
        name=sc.element_bone[e['uuid']];g=gs[name];rotation=a.old.core.rotation(e);mid=(np.array(e['from'])+e['to'])/2;half=(np.array(e['to'])-e['from'])/2
        local=rotation@(mid-e['origin'])+e['origin']-g['origin'];center=(m0[name][:3,:3]@local+m0[name][:3,3])*factor+shift
        e['from']=(center-half*factor).tolist();e['to']=(center+half*factor).tolist();e['origin']=center.tolist();e['rotation']=a.old.core.euler(m0[name][:3,:3]@rotation).tolist()
    display['display']={n:{'rotation':[0,0,0],'translation':[0,0,0],'scale':[1/factor]*3}for n in ['thirdperson_righthand','thirdperson_lefthand','firstperson_righthand','firstperson_lefthand','ground','fixed','head','gui']}
    display['display']['gui']={'rotation':[20,135,0],'translation':[0,0,0],'scale':[.45]*3}
    path=a.D/'A_异形态整体Display调整.bbmodel';assert not path.exists(),'Preserve Display edits';a.write(path,json.dumps(display,ensure_ascii=False,indent=2))
    ds=a.Scene(a.load(path));display_error=float(abs((ds.pose()[0]-shift)/factor-original).max());assert display_error<1e-8
    geom={sc.element_bone[e['uuid']]for e in b['elements']if any(f.get('texture')is not None for f in e['faces'].values())}
    report={'first_form_source_unchanged':True,'character_cubes':len(b['elements']),'groups':len(b['groups']),'textured_geometry_groups':len(geom),'textures':len(b['textures']),
            'animations':['alien_idle'],'samples_120hz':361,'eight_limb_joint_error':joints,'loop_error':loop,'minimum_y':minimum,'bounds':{'min':lo.tolist(),'max':hi.tolist(),'size':size.tolist()},
            'whole_Display_cubes':len(display['elements']),'Display_reconstruction_error':display_error,'single_Java_Display_export_legal':False,
            'native_reopened':False,'native_exported':False,'game_tested':False,'passed':True,'limits':'Asset, UV, hierarchy, saved keyframes and eight limb joints. Shape candidate only; not a full collision, coplanarity or game performance certification.'}
    a.write(a.D/'工程与基础动效核验.json',json.dumps(report,ensure_ascii=False,indent=2));print(json.dumps(report,ensure_ascii=False),flush=True)


if __name__=='__main__':run()
