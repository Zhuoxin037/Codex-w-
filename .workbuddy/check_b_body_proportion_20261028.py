import json,itertools
import numpy as np
from b_body_proportion_20261028 import D,TITLE
b=json.loads((D/(TITLE+'.ajblueprint')).read_text(encoding='utf8'));old=json.loads((D/'修改前_当前现场.ajblueprint').read_text(encoding='utf8'));oldels={e['uuid']:e for e in old['elements']};gs={g['uuid']:g for g in b['groups']};owner={}
def walk(nodes,pa=None):
 for n in nodes:
  if isinstance(n,str):owner[n]=gs[pa]['name']
  else:walk(n['children'],n['uuid'])
walk(b['outliner']);parts=['pelvis','waist','chest','neck','head']
for side in ['right','left']:parts.extend([f'arm_upper_{side}',f'arm_lower_{side}',f'hand_{side}',f'leg_upper_{side}',f'leg_lower_{side}',f'foot_{side}'])
body=[e for e in b['elements']if owner[e['uuid']]in parts];lo=np.array([e['from']for e in body]);hi=np.array([e['to']for e in body]);names=np.array([owner[e['uuid']]for e in body]);over=np.minimum(hi[:,None],hi[None])-np.maximum(lo[:,None],lo[None]);touch=(over.min(2)>=-1e-6)&((over>1e-6).sum(2)>=2)
def components(ids):
 unseen=set(ids);count=0
 while unseen:
  count+=1;todo=[unseen.pop()]
  while todo:
   at=todo.pop();ns=set(np.flatnonzero(touch[at]))&unseen;unseen-=ns;todo.extend(ns)
 return count
pairs=[('pelvis','waist'),('waist','chest'),('chest','neck'),('neck','head')]
for s in ['right','left']:pairs += [('chest','arm_upper_'+s),('arm_upper_'+s,'arm_lower_'+s),('arm_lower_'+s,'hand_'+s),('pelvis','leg_upper_'+s),('leg_upper_'+s,'leg_lower_'+s),('leg_lower_'+s,'foot_'+s)]
joints=[{'joint':[a,z],'touching_cube_pairs':int(touch[np.ix_(names==a,names==z)].sum())}for a,z in pairs];uv_changed=[e['name']for e in b['elements']if e['faces']!=oldels[e['uuid']]['faces']]
before=json.loads((D/'修改前_原生静态姿态.json').read_text(encoding='utf8'));after=json.loads((D/'调整后_原生静态姿态.json').read_text(encoding='utf8'));cloth={g['name']for g in b['groups']if g['name'].startswith('robe_')or g['name']in ['coat_045','tabard']}
clotherr=0
for n in cloth:
 expected=np.array(before[n]);expected[13]+=2.1595;clotherr=max(clotherr,float(np.max(np.abs(expected-after[n]))))
feet=[e for e in b['elements']if owner[e['uuid']].startswith('foot_')];foot_changes=[e['name']for e in feet if any(e.get(k)!=oldels[e['uuid']].get(k)for k in ['from','to','origin','rotation','faces'])]
ids=[e['uuid']for e in b['elements']];defined=sum(f.get('texture')is not None for e in b['elements']for f in e['faces'].values());report={'cubes':len(ids),'groups':len(b['groups']),'textures':len(b['textures']),'defined_faces':defined,'animations':len(b.get('animations',[])),'unique_uuids':len(ids)==len(set(ids)),'body_parts_components':{n:components(np.flatnonzero(names==n))for n in parts},'whole_body_components':components(range(len(body))),'joints':joints,'uv_changes':uv_changed,'cloth_relative_connection_matrix_error':clotherr,'foot_geometry_changes':foot_changes,'height_before':48,'height_after':53.3095,'staff_min_y':min(e['from'][1]for e in b['elements']if owner[e['uuid']]=='staff'),'body_parts_deleted':[],'game_tested':False,'limits':'Saved static geometry contact graph and native world matrices; not an animation or all-intersection guarantee.'}
report['passed']=report['unique_uuids']and report['whole_body_components']==1 and all(x==1 for x in report['body_parts_components'].values())and all(x['touching_cube_pairs']for x in joints)and not uv_changed and not foot_changes and clotherr<1e-6
(D/'人体比例与完整性核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=True),flush=True)
assert report['passed'],'Repair disconnected body parts before delivery.'
