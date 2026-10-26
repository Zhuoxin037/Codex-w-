"""Actual voxel/component audit and saved under-clothing inspection views."""
from build_b_staff_static_20261021 import *
from collections import deque
import copy

def components(mask):
    unseen=set(map(tuple,np.argwhere(mask)));found=[]
    while unseen:
        seed=unseen.pop();queue=deque([seed]);cells=[seed]
        while queue:
            c=queue.popleft()
            for axis in range(3):
                for sign in [-1,1]:
                    q=list(c);q[axis]+=sign;q=tuple(q)
                    if q in unseen:unseen.remove(q);queue.append(q);cells.append(q)
        found.append(np.array(cells,int))
    return sorted(found,key=len,reverse=True)

def main():
    data=np.load(STAGE/'body_voxels.npz');labels=data['labels'];origin=data['origin'];step=float(data['step'])
    bb=json.loads((STAGE/'B_分组可编辑_静态.bbmodel').read_text(encoding='utf8'))
    fit=json.loads((STAGE/'拟合几何.json').read_text(encoding='utf8'));cloth_groups={g['name']:g for g in fit['cloth_groups']}
    body=[e for e in fit['cubes'] if e['kind']=='body'];lo=np.array([e['from'] for e in body]);hi=np.array([e['to'] for e in body])
    body_components=components(labels>0);part_components={p:[len(v) for v in components(labels==i)] for i,p in enumerate(PARTS[:17],1)}
    # Flood the air from every boundary; any unreached air would be a sealed
    # artificial cavity in a solid anatomical component.
    air=labels==0;visited=np.zeros_like(air);boundary=np.zeros_like(air);boundary[[0,-1],:,:]=True;boundary[:,[0,-1],:]=True;boundary[:,:,[0,-1]]=True
    seeds=np.argwhere(air&boundary);queue=deque(map(tuple,seeds));visited[tuple(seeds.T)]=True
    while queue:
        c=queue.popleft()
        for axis in range(3):
            for sign in [-1,1]:
                q=list(c);q[axis]+=sign
                if q[axis]<0 or q[axis]>=labels.shape[axis]:continue
                q=tuple(q)
                if air[q] and not visited[q]:visited[q]=True;queue.append(q)
    enclosed_air=int((air&~visited).sum())
    attachments=[]
    for e in fit['cubes']:
        if e['kind']!='coat' or not e['name'].endswith('_1'):continue
        q=vertices(e,'south',cloth_groups);points=q[0]+np.linspace(.2,.8,61)[:,None]*(q[3]-q[0])+(q[1]-q[0])*.03
        delta=np.maximum(lo[None]-points[:,None],np.maximum(points[:,None]-hi[None],0));gap=float(np.linalg.norm(delta,axis=-1).min())
        attachments.append({'part':e['part'],'attachment_gap_model_units':round(gap,6)})
    # Contact graph of actual body voxels, including every anatomical joint.
    contacts={}
    for axis in range(3):
        a=np.take(labels,range(labels.shape[axis]-1),axis=axis);b=np.take(labels,range(1,labels.shape[axis]),axis=axis)
        m=(a>0)&(b>0)&(a!=b)
        for x,y in zip(a[m].tolist(),b[m].tolist()):
            pair=tuple(sorted([PARTS[x-1],PARTS[y-1]]));contacts[pair]=contacts.get(pair,0)+1
    required=[('pelvis','waist'),('waist','chest'),('chest','neck'),('neck','head')]
    for side in ['right','left']:
        required.extend([('chest','arm_upper_'+side),('arm_upper_'+side,'arm_lower_'+side),('arm_lower_'+side,'hand_'+side),('pelvis','leg_upper_'+side),('leg_upper_'+side,'leg_lower_'+side),('leg_lower_'+side,'foot_'+side)])
    joint_results=[{'joint':list(pair),'contact_faces':contacts.get(tuple(sorted(pair)),0)} for pair in required]
    report={'date':'2026-10-22','user_requirement':'完整建模，遮挡处也要有形体，不能支离破碎','body_connected_components':len(body_components),'body_occupied_voxels':int((labels>0).sum()),'connected_components_by_anatomical_part':part_components,'enclosed_empty_voxels':enclosed_air,'anatomical_joints':joint_results,'coat_attachments':attachments,'deleted_body_regions':0,'texture_note':'身体与关节边界实建封口；同部位内面才关闭。外衣隐藏仅用于验收。'}
    report['passed']=len(body_components)==1 and all(len(c)==1 for c in part_components.values()) and enclosed_air==0 and all(x['contact_faces']>0 for x in joint_results) and all(x['attachment_gap_model_units']<1e-5 for x in attachments)
    (STAGE/'完整性与连接检查.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps(report,ensure_ascii=False),flush=True)
    assert report['passed'],'Complete-body inspection failed; repair geometry before delivery.'
    inspection=copy.deepcopy(bb);inspection['name']='B_隐藏外衣_完整性检查'
    hidden=['coat_','tabard','head_drape','staff']
    for g in inspection['groups']:
        if any(g['name'].startswith(prefix) for prefix in hidden):g['visibility']=False
    (STAGE/'B_隐藏外衣_完整性检查.bbmodel').write_text(json.dumps(inspection,ensure_ascii=False,indent=2),encoding='utf8')
    p,n,uv,f=scene(inspection);texture=np.array(Image.open(STAGE/bb['textures'][0]['name']).convert('RGBA'));images=[]
    for name,d in [('正面',(0,0,-1)),('侧面',(1,0,0)),('背面',(0,0,1)),('45度',(1,.1,-1))]:
        selected=n[f[:,0]]@np.array(d)>1e-6
        rgba,_,_=raster(p,n,uv,f[selected],texture,d,width=540,height=780,ppu=14,cutout=True)
        im=card(rgba,'隐藏外衣 · 实际形体 · '+name);im.save(STAGE/f'完整性检查_{name}.png');images.append(im)
    sheet=Image.new('RGB',(2160,780))
    for i,im in enumerate(images):sheet.paste(im,(i*540,0))
    sheet.save(STAGE/'隐藏外衣_完整形体四视图.png')
    print('Saved actual under-clothing inspection model and four views.',flush=True)

if __name__=='__main__':main()
