"""Validate the saved humanoid project and its independent Display editor."""
import base64,collections,copy,json
import numpy as np
import a_ghost_sacred_humanoid_20261123 as a


def run():
    b=a.load(a.D/(a.TITLE+'.bbmodel'));aj=a.load(a.D/(a.TITLE+'.ajblueprint'));rec=a.load(a.D/'制作记录.json')
    assert a.sha(a.SRC)==rec['source_sha256'] and a.sha(a.SRC.with_suffix('.ajblueprint'))==rec['source_aj_sha256']
    assert all(b[k]==aj[k]for k in ['elements','groups','outliner','textures','animations'])
    nodes=a.old.group_nodes(b);gids={g['uuid']for g in b['groups']};refs=[x for n in nodes.values()for x in n['children']if isinstance(x,str)]
    assert len(gids)==len(b['groups']) and set(nodes)==gids and len({e['uuid']for e in b['elements']})==len(b['elements'])
    assert collections.Counter(refs)==collections.Counter(e['uuid']for e in b['elements'])
    tx={t['uuid']:t for t in b['textures']}
    for t in b['textures']:assert(a.D/t['relative_path']).read_bytes()==base64.b64decode(t['source'].split(',',1)[1])
    for e in b['elements']:
        assert all(v>u for u,v in zip(e['from'],e['to'])) and not any(e.get('rotation',[0]*3))
        for f in e['faces'].values():
            ref=f.get('texture')
            if ref is None:continue
            tex=b['textures'][ref]if isinstance(ref,int)else tx[ref]
            assert all(0<=v<=tex.get('uv_width'if i%2==0 else'uv_height',512)for i,v in enumerate(f['uv']))
    c=b['animations'][0]
    for u,tr in c['animators'].items():
        ids=[(k['channel'],k['time'])for k in tr['keyframes']];assert u in gids and len(ids)==len(set(ids)) and all(abs(t*20-round(t*20))<1e-6 for ch,t in ids)
    sc=a.Scene(b);m0=a.matrices(sc,{})
    assert all(n in sc.names for n in ['upperarm_left','upperarm_right','thigh_left','thigh_right','foot_left','foot_right'])
    assert not any('tail'in n or 'lower_arm'in n or 'alien'in n for n in sc.names)
    pairs=[]
    for side in ['left','right']:pairs += [('chest','upperarm_'+side),('upperarm_'+side,'forearm_'+side),('forearm_'+side,'hand_'+side),('thigh_'+side,'shin_'+side),('shin_'+side,'foot_'+side)]
    max_joint=0.;minimum=1e9;bounds=[]
    for i in range(481):
        m=a.matrices(sc,a.sample(c,i/120))
        for x,y in pairs:max_joint=max(max_joint,abs(np.linalg.norm(m[x][:3,3]-m[y][:3,3])-np.linalg.norm(m0[x][:3,3]-m0[y][:3,3])))
        if i%6==0:
            f={'matrices':{n:v.T.reshape(-1).tolist()for n,v in m.items()}};p=sc.pose(f)[0];minimum=min(minimum,float(p[:,1].min()));bounds.append([p.min(0).tolist(),p.max(0).tolist()])
    first,last=[a.matrices(sc,a.sample(c,t))for t in [0,4]];loop=max(float(abs(first[n]-last[n]).max())for n in sc.names)
    assert max_joint<1e-8 and loop<1e-6 and minimum>-.001,(max_joint,loop,minimum)
    src=a.Scene(a.load(a.SRC));p1=src.pose()[0];p2=sc.pose()[0]
    # Exact whole-geometry editor; multi-axis rotation is retained, not exported.
    display=copy.deepcopy(b);display['name']='A_祭服人形整体Display调整';display['meta']['model_format']='java_block';display['animations']=[]
    lo,hi=p2.min(0),p2.max(0);factor=min(.625,42/max(hi-lo));shift=np.array([8,8,8])-(lo+hi)/2*factor
    root=copy.deepcopy(b['groups'][0]);root.update({'name':'整体Display','origin':[8,8,8],'rotation':[0,0,0]});display['groups']=[root];display['outliner']=[{'uuid':root['uuid'],'children':[e['uuid']for e in b['elements']],'isOpen':True}]
    gs={g['name']:g for g in b['groups']}
    for e in display['elements']:
        n=sc.element_bone[e['uuid']];g=gs[n];mid=(np.array(e['from'])+e['to'])/2;half=(np.array(e['to'])-e['from'])/2
        center=(m0[n][:3,:3]@(mid-g['origin'])+m0[n][:3,3])*factor+shift
        e['from']=(center-half*factor).tolist();e['to']=(center+half*factor).tolist();e['origin']=center.tolist();e['rotation']=a.old.core.euler(m0[n][:3,:3]).tolist()
    display['display']={n:{'rotation':[0,0,0],'translation':[0,0,0],'scale':[1/factor]*3}for n in ['thirdperson_righthand','thirdperson_lefthand','firstperson_righthand','firstperson_lefthand','ground','fixed','head','gui']}
    display['display']['gui']={'rotation':[20,135,0],'translation':[0,0,0],'scale':[.45]*3}
    path=a.D/'A_祭服人形整体Display调整.bbmodel';assert not path.exists(),'Preserve Display adjustments';a.write(path,json.dumps(display,ensure_ascii=False,indent=2))
    ds=a.Scene(a.load(path));err=float(abs((ds.pose()[0]-shift)/factor-p2).max());assert err<1e-8
    geo={sc.element_bone[e['uuid']]for e in b['elements']if any(f.get('texture')is not None for f in e['faces'].values())}
    result={'source_first_form_unchanged':True,'character_cubes':len(b['elements']),'groups':len(b['groups']),'textured_geometry_groups':len(geo),'textures':len(b['textures']),
            'two_arms_two_legs':True,'alien_tail_or_extra_arm_used':False,'samples_120hz':481,'ten_joint_distance_error':max_joint,'loop_matrix_error':loop,'minimum_y':minimum,
            'original_bounds':{'min':p1.min(0).tolist(),'max':p1.max(0).tolist(),'size':np.ptp(p1,axis=0).tolist()},'new_bounds':{'min':lo.tolist(),'max':hi.tolist(),'size':(hi-lo).tolist()},
            'height_ratio':float((hi[1]-lo[1])/np.ptp(p1,axis=0)[1]),'Display_reconstruction_error':err,'native_reopened':False,'native_exported':False,'game_tested':False,
            'single_Java_Display_export_legal':False,'passed':True,'limits':'Saved geometry, UV, hierarchy, 10 joint distances and idle loop only. No claim of full collision or coplanarity validation or game performance.'}
    a.write(a.D/'工程与基础动效核验.json',json.dumps(result,ensure_ascii=False,indent=2));print(json.dumps(result,ensure_ascii=False),flush=True)


if __name__=='__main__':run()
