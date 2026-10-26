import sys,json,math,copy
from pathlib import Path
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
from native_husk_combat_20261025 import D,TITLE

def check():
 b=json.loads((D/(TITLE+'.bbmodel')).read_text(encoding='utf8'));old=json.loads((D/'已认可_接续前.bbmodel').read_text(encoding='utf8'));data=json.loads((D/'全动作_原生40Hz姿态.json').read_text(encoding='utf8'));gs={g['uuid']:g for g in b['groups']};names={g['name']:g for g in b['groups']};owner={}
 def walk(ns,p=None):
  for x in ns:
   if isinstance(x,str):owner[x]=gs[p]['name']
   else:walk(x['children'],x['uuid'])
 walk(b['outliner']);geo={}
 for e in b['elements']:
  if any(f.get('texture')is not None for f in e['faces'].values()):geo.setdefault(owner[e['uuid']],[]).append(e)
 def boxes(gn,m):
  es=geo[gn];lo=np.array([e['from']for e in es]);hi=np.array([e['to']for e in es]);basis=m[:3,:3];sc=np.linalg.norm(basis,axis=0)
  if min(sc)<1e-4:return None
  return ((lo+hi)/2-names[gn]['origin'])@basis.T+m[:3,3],(hi-lo)/2*sc,basis/sc
 def broad(a,z):
  ac,ah,ar=a;zc,zh,zr=z;ae=ah@abs(ar).T;ze=zh@abs(zr).T
  return not any(np.max(ac[:,k]+ae[:,k])<np.min(zc[:,k]-ze[:,k])or np.max(zc[:,k]+ze[:,k])<np.min(ac[:,k]-ae[:,k])for k in range(3))
 def penetration(a,z):
  ac,ah,ar=a;zc,zh,zr=z;axes=[*ar.T,*zr.T]
  for x in ar.T:
   for y in zr.T:
    q=np.cross(x,y);L=np.linalg.norm(q)
    if L>1e-7:axes.append(q/L)
  dep=np.full((len(ac),len(zc)),np.inf)
  for axis in axes:
   da=ah@abs(ar.T@axis);dz=zh@abs(zr.T@axis);ds=abs((ac@axis)[:,None]-(zc@axis)[None]);dep=np.minimum(dep,da[:,None]+dz[None]-ds)
  return float(dep.max())
 pairs=[('forearm_right','forearm_left'),('hand_right','hand_left'),('hand_right','forearm_left'),('hand_left','forearm_right'),('forearm_right','shoulder_right'),('forearm_left','shoulder_left')]
 pairs += [(a,z)for a in ['hand_right','hand_left','forearm_right','forearm_left']for z in ['chest','head','pelvis','thigh_right','thigh_left','shin_right','shin_left']]
 pairs += [('thigh_right','thigh_left'),('shin_right','shin_left'),('foot_right','foot_left'),('foot_right','shin_left'),('foot_left','shin_right')]
 effects=[gn for gn in geo if gn.startswith(('fx_arm_fire_','fx_guard_'))];body=[gn for gn in geo if not gn.startswith('fx_')];pairs +=[(a,z)for a in effects for z in body];pairs=[p for p in pairs if p[0]in geo and p[1]in geo]
 indices=set(n for p in pairs for n in p);collisions=[];worst={};frames=0;max_joint=0.;lowest_foot=1e6
 support=[];lengths={s:{'arm_upper':np.linalg.norm(np.array(names['forearm_'+s]['origin'])-names['upperarm_'+s]['origin']),'arm_lower':np.linalg.norm(np.array(names['hand_'+s]['origin'])-names['forearm_'+s]['origin']),'leg_upper':np.linalg.norm(np.array(names['shin_'+s]['origin'])-names['thigh_'+s]['origin']),'leg_lower':np.linalg.norm(np.array(names['foot_'+s]['origin'])-names['shin_'+s]['origin'])}for s in ['right','left']}
 for clip in data['clips']:
  for f in clip['frames']:
   frames+=1;ms={n:np.array(v).reshape(4,4,order='F')for n,v in f['matrices'].items()};cache={gn:boxes(gn,ms[gn])for gn in indices}
   for p in pairs:
    a,z=cache[p[0]],cache[p[1]]
    if a is None or z is None or not broad(a,z):continue
    dep=penetration(a,z)
    if str(p)not in worst or dep>worst[str(p)]['depth']:worst[str(p)]={'depth':dep,'clip':clip['name'],'time':f['time']}
    if dep>1e-4:collisions.append({'a':p[0],'b':p[1],'depth':dep,'clip':clip['name'],'time':f['time']})
   foot_heights=[]
   for s in ['right','left']:
    for a,z,k in [('upperarm_','forearm_','arm_upper'),('forearm_','hand_','arm_lower'),('thigh_','shin_','leg_upper'),('shin_','foot_','leg_lower')]:max_joint=max(max_joint,abs(np.linalg.norm(ms[a+s][:3,3]-ms[z+s][:3,3])-lengths[s][k]))
    a=boxes('foot_'+s,ms['foot_'+s]);cc,hh,rr=a;ext=hh@abs(rr).T;lowest_foot=min(lowest_foot,float(np.min(cc[:,1]-ext[:,1])));foot_heights.append(float(np.min(cc[:,1]-ext[:,1])))
   if clip['name']in['walk_start','walk','walk_stop']:support.append({'clip':clip['name'],'time':f['time'],'lowest_foot_height':min(foot_heights)})
 oldnames={a['name']for a in old['animations']};keyed=lambda d:{a['name']:{v['name']:v for v in a['animators'].values()if v.get('keyframes')}for a in d['animations']if a['name']in oldnames}
 summary={'frames':frames,'clips':len(data['clips']),'pairs_checked':len(pairs),'collision_count':len(collisions),'collisions':collisions,'worst_candidates':worst,'joint_length_max_error':max_joint,'foot_surface_min_height':lowest_foot,'walking_highest_support_foot_height':max(s['lowest_foot_height']for s in support),'geometry_exactly_preserved':b['elements']==old['elements'],'groups_exactly_preserved':b['groups']==old['groups'],'texture_pixels_exactly_preserved':[t['source']for t in b['textures']]==[t['source']for t in old['textures']],'approved_seven_keyed_animations_preserved':keyed(b)==keyed(old),'game_deployed':False,'game_tested':False}
 (D/'动作结构与穿插核对.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps({k:v for k,v in summary.items()if k not in ['collisions','worst_candidates']},ensure_ascii=False),flush=True);print('Worst body pairs:',sorted([(p,v)for p,v in worst.items()if not p.startswith("('fx_")],key=lambda x:x[1]['depth'],reverse=True)[:12],flush=True);print('First collisions:',collisions[:18],flush=True)

if __name__=='__main__':check()
