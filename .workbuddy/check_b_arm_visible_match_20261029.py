import json,itertools
import numpy as np
from b_arm_visible_match_20261029 import D,TITLE
b=json.loads((D/(TITLE+'.ajblueprint')).read_text(encoding='utf8'));old=json.loads((D/'修改前_当前现场.ajblueprint').read_text(encoding='utf8'));src={e['uuid']:e for e in old['elements']};gs={g['uuid']:g for g in b['groups']};ns={g['name']:g for g in b['groups']};own={}
def walk(xs,pa=None):
 for n in xs:
  if isinstance(n,str):own[n]=gs[pa]['name']
  else:walk(n['children'],n['uuid'])
walk(b['outliner']);geo={n:[e for e in b['elements']if own[e['uuid']]==n]for n in ns};data=json.loads((D/'调整后_原生静态姿态.json').read_text(encoding='utf8'));m={n:np.array(a).reshape(4,4,order='F')for n,a in data.items()}
parts=['pelvis','waist','chest','neck','head']
for s in ['left','right']:parts += [p+'_'+s for p in ['arm_upper','arm_lower','hand','leg_upper','leg_lower','foot']]
def components(n):
 lo=np.array([e['from']for e in geo[n]]);hi=np.array([e['to']for e in geo[n]]);ov=np.minimum(hi[:,None],hi[None])-np.maximum(lo[:,None],lo[None]);adj=(ov.min(2)>=-1e-5)&((ov>1e-5).sum(2)>=2);unseen=set(range(len(lo)));cnt=0
 while unseen:
  cnt+=1;todo=[unseen.pop()]
  while todo:
   near=set(np.flatnonzero(adj[todo.pop()]))&unseen;unseen-=near;todo+=list(near)
 return cnt
def boxes(n):
 lo=np.array([e['from']for e in geo[n]]);hi=np.array([e['to']for e in geo[n]]);mat=m[n];return ((lo+hi)/2-ns[n]['origin'])@mat[:3,:3].T+mat[:3,3],(hi-lo)/2,mat[:3,:3]
def depths(a,z):
 ac,ah,ar=boxes(a);zc,zh,zr=boxes(z);ds=np.full((len(ac),len(zc)),np.inf);axes=[*ar.T,*zr.T]
 for x in ar.T:
  for y in zr.T:
   q=np.cross(x,y);ln=np.linalg.norm(q)
   if ln>1e-6:axes.append(q/ln)
 for x in axes:ds=np.minimum(ds,(ah@abs(ar.T@x))[:,None]+(zh@abs(zr.T@x))[None]-abs((ac@x)[:,None]-(zc@x)[None]))
 return ds
pairs=[('pelvis','waist'),('waist','chest'),('chest','neck'),('neck','head')]
for s in ['left','right']:pairs += [('chest','arm_upper_'+s),('arm_upper_'+s,'arm_lower_'+s),('arm_lower_'+s,'hand_'+s),('pelvis','leg_upper_'+s),('leg_upper_'+s,'leg_lower_'+s),('leg_lower_'+s,'foot_'+s)]
contacts=[]
for a,z in pairs:
 ds=depths(a,z);contacts.append({'pair':[a,z],'contact_candidates':int((ds>=-1e-5).sum()),'max_SAT_contact_depth':float(ds.max())})
unallowed=[]
for e in b['elements']:
 if own[e['uuid']]not in ['arm_upper_right','arm_lower_right','hand_right','staff']and e!=src[e['uuid']]:unallowed.append(e['name'])
mapping=json.loads((D/'双臂形体对应与挂点.json').read_text(encoding='utf8'));els={e['uuid']:e for e in b['elements']};error=0
for pair in mapping['pairs']:
 a,z=els[pair['left']],els[pair['right']];alo=np.array(a['from']);ahi=np.array(a['to']);expectlo=np.array([-ahi[0],alo[1],alo[2]-1.3]);expecthi=np.array([-alo[0],ahi[1],ahi[2]-1.3]);error=max(error,float(abs(expectlo-z['from']).max()),float(abs(expecthi-z['to']).max()))
handboxes={n:(np.min([e['from']for e in geo[n]],axis=0),np.max([e['to']for e in geo[n]],axis=0))for n in ['hand_left','hand_right']};handdims={n:(h-l).tolist()for n,(l,h)in handboxes.items()}
staffpoints=[]
for e in geo['staff']:
 v=np.array(list(itertools.product(*zip(e['from'],e['to']))))-ns['staff']['origin'];staffpoints.append(v@m['staff'][:3,:3].T+m['staff'][:3,3])
lengths={s:{'upper':float(np.linalg.norm(m['arm_upper_'+s][:3,3]-m['arm_lower_'+s][:3,3])),'forearm':float(np.linalg.norm(m['arm_lower_'+s][:3,3]-m['hand_'+s][:3,3]))}for s in ['left','right']}
report={'cubes':len(b['elements']),'groups':len(b['groups']),'textures':len(b['textures']),'animations':len(b.get('animations',[])),'unchanged_other_regions':not unallowed,'unexpected_changes':unallowed,'mirrored_visible_arm_pairs':len(mapping['pairs']),'matched_geometry_error':error,'hand_box_dimensions':handdims,'part_components':{n:components(n)for n in parts},'native_posed_joint_contacts':contacts,'native_bone_lengths':lengths,'staff_world_min_y':float(np.concatenate(staffpoints)[:,1].min()),'game_tested':False,'limits':'Native static pose SAT contact candidates and matched geometry; not animation or all-collision approval.'}
report['passed']=not unallowed and error<1.1e-5 and all(x==1 for x in report['part_components'].values())and all(x['contact_candidates']for x in contacts)and abs(report['staff_world_min_y'])<1.1e-5
(D/'双臂可见形体与实际连接核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=True),flush=True)
assert report['passed'],'Repair static pose before delivery'
