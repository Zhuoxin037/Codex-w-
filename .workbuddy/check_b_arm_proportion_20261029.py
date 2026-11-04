import json
import numpy as np
from b_arm_proportion_20261029 import D,TITLE
b=json.loads((D/(TITLE+'.ajblueprint')).read_text(encoding='utf8'));old=json.loads((D/'修改前_当前现场.ajblueprint').read_text(encoding='utf8'));oes={e['uuid']:e for e in old['elements']};ogs={g['uuid']:g for g in old['groups']};gs={g['uuid']:g for g in b['groups']};ns={g['name']:g for g in b['groups']};own={}
def walk(nodes,pa=None):
 for n in nodes:
  if isinstance(n,str):own[n]=gs[pa]['name']
  else:walk(n['children'],n['uuid'])
walk(b['outliner']);parts=['pelvis','waist','chest','neck','head']
for s in ['right','left']:parts.extend([f'arm_upper_{s}',f'arm_lower_{s}',f'hand_{s}',f'leg_upper_{s}',f'leg_lower_{s}',f'foot_{s}'])
body=[e for e in b['elements']if own[e['uuid']]in parts];lo=np.array([e['from']for e in body]);hi=np.array([e['to']for e in body]);names=np.array([own[e['uuid']]for e in body]);over=np.minimum(hi[:,None],hi[None])-np.maximum(lo[:,None],lo[None]);touch=(over.min(2)>=-1e-6)&((over>1e-6).sum(2)>=2)
def components(ids):
 unseen=set(ids);count=0
 while unseen:
  count+=1;todo=[unseen.pop()]
  while todo:
   i=todo.pop();near=set(np.flatnonzero(touch[i]))&unseen;unseen-=near;todo.extend(near)
 return count
pairs=[('pelvis','waist'),('waist','chest'),('chest','neck'),('neck','head')]
for s in ['right','left']:pairs.extend([('chest','arm_upper_'+s),('arm_upper_'+s,'arm_lower_'+s),('arm_lower_'+s,'hand_'+s),('pelvis','leg_upper_'+s),('leg_upper_'+s,'leg_lower_'+s),('leg_lower_'+s,'foot_'+s)])
joint=[{'joint':[a,z],'contact_pairs':int(touch[np.ix_(names==a,names==z)].sum())}for a,z in pairs]
allowed={f'{p}_{s}'for p in ['arm_upper','arm_lower','hand']for s in ['left','right']}|{'staff'}
changed=[];unexpected=[];uv=[];handshape=[]
for e in b['elements']:
 o=oes[e['uuid']];n=own[e['uuid']]
 if any(e.get(k)!=o.get(k)for k in ['from','to','origin','rotation']):
  changed.append(e['name'])
  if n not in allowed:unexpected.append(e['name'])
 if e['faces']!=o['faces']:uv.append(e['name'])
 if n.startswith('hand_')and np.max(abs((np.array(e['to'])-e['from'])-(np.array(o['to'])-o['from'])))>1.1e-6:handshape.append(e['name'])
lengths={}
for s in ['left','right']:
 shoulder=np.array(ns['arm_upper_'+s]['origin']);elbow=np.array(ns['arm_lower_'+s]['origin']);wrist=np.array(ns['hand_'+s]['origin']);lengths[s]={'upper':float(np.linalg.norm(elbow-shoulder)),'forearm':float(np.linalg.norm(wrist-elbow))}
report={'cubes':len(b['elements']),'groups':len(b['groups']),'textures':len(b['textures']),'defined_faces':sum(f.get('texture')is not None for e in b['elements']for f in e['faces'].values()),'animations':len(b.get('animations',[])),'changed_elements':len(changed),'unexpected_non_arm_changes':unexpected,'changed_uv':uv,'changed_hand_shape':handshape,'body_components':components(range(len(body))),'part_components':{n:components(np.flatnonzero(names==n))for n in parts},'joint_contacts':joint,'arm_bone_lengths':lengths,'staff_min_y':min(e['from'][1]for e in b['elements']if own[e['uuid']]=='staff'),'positive_volume':all(np.all(np.array(e['to'])>e['from'])for e in b['elements']),'game_tested':False,'limits':'Static contact graph and specified bone lengths; does not validate future animation collisions.'}
report['passed']=not(unexpected or uv or handshape)and report['body_components']==1 and all(v==1 for v in report['part_components'].values())and all(j['contact_pairs']for j in joint)and report['positive_volume']
(D/'手臂比例与连接核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=True),flush=True)
assert report['passed'],'Repair arm/body connection before delivery'
