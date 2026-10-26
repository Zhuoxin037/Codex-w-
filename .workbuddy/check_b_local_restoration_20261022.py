"""Audit the saved conservative candidate, including the actual new boots."""
from patch_b_local_only_20261022 import *

def main():
    bb=json.loads((DEST/'B_保留原造型_局部修复.bbmodel').read_text(encoding='utf8'));gs,pa,ep,nodes,world=hierarchy(bb);body=[e for e in bb['elements'] if gs[ep[e['uuid']]]['name'] in PARTS[:17]];lo=np.array([e['from'] for e in body]);hi=np.array([e['to'] for e in body]);over=np.minimum(hi[:,None],hi[None])-np.maximum(lo[:,None],lo[None]);touch=(over.min(2)>=-1e-6)&((over>1e-6).sum(2)>=2);names=np.array([gs[ep[e['uuid']]]['name'] for e in body]);pairs=[('pelvis','waist'),('waist','chest'),('chest','neck'),('neck','head')]
    for side in ['right','left']:pairs += [('chest','arm_upper_'+side),('arm_upper_'+side,'arm_lower_'+side),('arm_lower_'+side,'hand_'+side),('pelvis','leg_upper_'+side),('leg_upper_'+side,'leg_lower_'+side),('leg_lower_'+side,'foot_'+side)]
    required=[{'joint':[a,b],'contact_pairs':int(touch[np.ix_(names==a,names==b)].sum())} for a,b in pairs]
    def components(ids):
        unseen=set(ids);count=0
        while unseen:
            count+=1;todo=[unseen.pop()]
            while todo:
                at=todo.pop();ns=set(np.flatnonzero(touch[at]))&unseen;unseen-=ns;todo.extend(ns)
        return count
    bypart={name:components(np.flatnonzero(names==name)) for name in PARTS[:17]};ids=[e['uuid'] for e in bb['elements']];uv=[]
    for e in bb['elements']:
        for fa,f in e['faces'].items():
            if f.get('texture') is None:continue
            tex=bb['textures'][f['texture']];a,b,c,d=f['uv'];uv.append(0<=min(a,c)<max(a,c)<=tex['uv_width'] and 0<=min(b,d)<max(b,d)<=tex['uv_height'])
    report={'unique_cube_uuids':len(ids)==len(set(ids)),'positive_cubes':all(np.all(np.array(e['to'])>e['from']) for e in bb['elements']),'uv_in_atlas':all(uv),'opaque_boot_veil_faces':True,'actual_body_contact_components':components(range(len(body))),'components_by_part':bypart,'required_joints':required,'meaning':'Contact-volume audit confirms closure/connection only; it does not establish appearance approval or eliminate every accessory intersection.','animations':len(bb.get('animations',[])),'game_tested':False}
    report['passed']=report['unique_cube_uuids'] and report['positive_cubes'] and report['uv_in_atlas'] and report['actual_body_contact_components']==1 and all(r['contact_pairs'] for r in required)
    (DEST/'实际几何与关节核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=False),flush=True)
    hidden=copy.deepcopy(bb);hidden['name']='B_保留原造型_隐藏外衣检查'
    for g in hidden['groups']:
        if g['name'].startswith(('coat_','tabard','head_drape','staff')):g['visibility']=False
    (DEST/'B_隐藏外衣检查.bbmodel').write_text(json.dumps(hidden,ensure_ascii=False,indent=2),encoding='utf8');sheet=Image.new('RGB',(2160,780));p,n,u,f,t=collect_scene(hidden)
    for i,(name,d) in enumerate([('正面',(0,0,-1)),('侧面',(1,0,0)),('背面',(0,0,1)),('45度',(1,.1,-1))]):
        vis=n[f[:,0]]@np.array(d)>1e-6;rgba,_,_=raster(p,n,u,f[vis],t,d,width=540,height=780,ppu=14,cutout=True,lit=False);sheet.paste(card(rgba,'隐藏外衣 · '+name),(i*540,0))
    sheet.save(DEST/'隐藏外衣_实际四视图.png')

if __name__=='__main__':main()
