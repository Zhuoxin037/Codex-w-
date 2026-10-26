from pathlib import Path
import json,sys,numpy as np
from animate_c_guard_20261025 import D,BASE,rot
b=json.loads((D/'C_抱架承伤_代表动作.bbmodel').read_text(encoding='utf8'));data=json.loads((D/'MCP原生姿态_40Hz.json').read_text(encoding='utf8'));groups={g['uuid']:g for g in b['groups']};names={g['name']:g for g in b['groups']};owner={}
def walk(ns,pa=None):
 for x in ns:
  if isinstance(x,str):owner[x]=groups[pa]['name']
  else:walk(x['children'],x['uuid'])
walk(b['outliner']);geo={}
for e in b['elements']:
 if not any(f.get('texture')is not None for f in e['faces'].values()):continue
 n=owner[e['uuid']];geo.setdefault(n,[]).append(e)
def boxes(n,m):
 es=geo[n];lo=np.array([e['from']for e in es]);hi=np.array([e['to']for e in es]);centers=((lo+hi)/2-names[n]['origin'])@m[:3,:3].T+m[:3,3];return centers,(hi-lo)/2,m[:3,:3]
def penetration(a,z):
 ac,ah,ar=a;zc,zh,zr=z;axes=[ar[:,i]for i in range(3)]+[zr[:,i]for i in range(3)]
 for x in ar.T:
  for y in zr.T:
   q=np.cross(x,y);length=np.linalg.norm(q)
   if length>1e-7:axes.append(q/length)
 dep=np.full((len(ac),len(zc)),np.inf)
 for axis in axes:
  da=ah@abs(ar.T@axis);dz=zh@abs(zr.T@axis);ds=abs((ac@axis)[:,None]-(zc@axis)[None]);dep=np.minimum(dep,da[:,None]+dz[None]-ds)
 return float(dep.max())
pairs=[('forearm_right','forearm_left'),('hand_right','hand_left'),('hand_right','forearm_left'),('hand_left','forearm_right')]+[(a,z)for a in ['forearm_right','forearm_left','hand_right','hand_left']for z in ['chest','head']]
worst={str(p):{'penetration':-1e6}for p in pairs};foot=0.;ankleRot=0.;framecount=0
for clip in data['clips']:
 for f in clip['frames']:
  matrices={n:np.array(v).reshape(4,4,order='F')for n,v in f['matrices'].items()};cache={n:boxes(n,matrices[n])for n in set(x for p in pairs for x in p)};framecount+=1
  for p in pairs:
   depth=penetration(cache[p[0]],cache[p[1]])
   if depth>worst[str(p)]['penetration']:worst[str(p)]={'penetration':depth,'clip':clip['name'],'time':f['time']}
  for s in ['right','left']:
   n='foot_'+s;m=matrices[n];foot=max(foot,float(np.linalg.norm(m[:3,3]-names[n]['origin'])));ankleRot=max(ankleRot,float(np.max(abs(m[:3,:3]-np.eye(3)))))
report={'source':'Actual native Animator.preview, 40Hz','frames':framecount,'obb_max_penetrations':worst,'foot_origin_max_drift_units':foot,'foot_rotation_matrix_error':ankleRot,'geometry_count':len(b['elements']),'game_tested':False}
(D/'动作穿插与支撑核对.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=False),flush=True)
