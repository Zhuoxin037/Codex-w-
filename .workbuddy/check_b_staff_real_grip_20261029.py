import json,itertools
import numpy as np
from b_staff_real_grip_20261029 import D,TITLE
b=json.loads((D/(TITLE+'.ajblueprint')).read_text(encoding='utf8'));old=json.loads((D/'修改前_当前现场.ajblueprint').read_text(encoding='utf8'));gs={g['uuid']:g for g in b['groups']};ns={g['name']:g for g in b['groups']};own={}
def walk(xs,pa=None):
 for n in xs:
  if isinstance(n,str):own[n]=gs[pa]['name']
  else:walk(n['children'],n['uuid'])
walk(b['outliner']);geo={n:[e for e in b['elements']if own[e['uuid']]==n]for n in ns};native=json.loads((D/'调整后_原生静态姿态.json').read_text(encoding='utf8'));m={n:np.array(a).reshape(4,4,order='F')for n,a in native.items()}
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
def components(n):
 lo=np.array([e['from']for e in geo[n]]);hi=np.array([e['to']for e in geo[n]]);ov=np.minimum(hi[:,None],hi[None])-np.maximum(lo[:,None],lo[None]);adj=(ov.min(2)>=-1e-5)&((ov>1e-5).sum(2)>=2);unseen=set(range(len(lo)));cnt=0
 while unseen:
  cnt+=1;todo=[unseen.pop()]
  while todo:
   near=set(np.flatnonzero(adj[todo.pop()]))&unseen;unseen-=near;todo+=list(near)
 return cnt
parts=['pelvis','waist','chest','neck','head']
for s in ['left','right']:parts += [p+'_'+s for p in ['arm_upper','arm_lower','hand','leg_upper','leg_lower','foot']]
pairs=[('pelvis','waist'),('waist','chest'),('chest','neck'),('neck','head')]
for s in ['left','right']:pairs += [('chest','arm_upper_'+s),('arm_upper_'+s,'arm_lower_'+s),('arm_lower_'+s,'hand_'+s),('pelvis','leg_upper_'+s),('leg_upper_'+s,'leg_lower_'+s),('leg_lower_'+s,'foot_'+s)]
contacts=[{'pair':[a,z],'contact_candidates':int((depths(a,z)>=-1e-5).sum()),'maximum_contact_depth':float(depths(a,z).max())}for a,z in pairs]
staff_collision=[]
for n in parts+[n for n in geo if n.startswith('robe_')or n in ['coat_045','tabard']]:
 if n=='hand_right':continue
 d=depths('staff',n)
 if d.max()>1e-5:staff_collision.append({'group':n,'depth':float(d.max())})
hp=geo['hand_right'];sp=geo['staff'];hl=np.array([e['from']for e in hp]);hh=np.array([e['to']for e in hp]);sl=np.array([e['from']for e in sp]);sh=np.array([e['to']for e in sp]);ov=np.minimum(hh[:,None],sh[None])-np.maximum(hl[:,None],sl[None]);volume=np.maximum(ov,0).prod(2);contact=(ov.min(2)>=-1e-5)&((ov>1e-5).sum(2)>=2)
touches=[e['name']for i,e in enumerate(hp)if contact[i].any()];pen=float(volume.max());staffpoints=[]
for e in sp:
 v=np.array(list(itertools.product(*zip(e['from'],e['to']))))-ns['staff']['origin'];staffpoints.append(v@m['staff'][:3,:3].T+m['staff'][:3,3])
protected={p for p in parts if not p.startswith('arm_')and p!='hand_right'};olds={e['uuid']:e for e in old['elements']};changed=[e['name']for e in b['elements']if own[e['uuid']]in protected and e!=olds.get(e['uuid'])]
report={'cubes':len(b['elements']),'groups':len(b['groups']),'textures':len(b['textures']),'animations':len(b.get('animations',[])),'part_components':{n:components(n)for n in parts},'joint_contacts':contacts,'staff_hand_positive_overlap_volume':pen,'hand_contacting_shaft':touches,'staff_body_or_cloth_intersections':staff_collision,'protected_regions_changed':changed,'staff_world_min_y':float(np.concatenate(staffpoints)[:,1].min()),'game_tested':False,'limits':'Native saved static pose and specified OBB pairs; does not validate all future animation poses.'}
report['passed']=all(v==1 for v in report['part_components'].values())and all(x['contact_candidates']for x in contacts)and not changed and not staff_collision and pen<1e-8 and all(any(name.startswith('grip_finger_'+str(i))for name in touches)for i in range(1,5))and any(n.startswith('grip_thumb')for n in touches)
(D/'手臂连续与握持核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=True),flush=True)
assert report['passed'],'Repair grip or sleeve connection before delivery'
