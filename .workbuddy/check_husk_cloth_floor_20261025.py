"""Check native sampled cloth contacts and the floor, with rest contacts separate."""
import sys,json,itertools
from pathlib import Path
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
from native_husk_combat_20261025 import D,TITLE

b=json.loads((D/(TITLE+'.bbmodel')).read_text(encoding='utf8'))
data=json.loads((D/'全动作_原生40Hz姿态.json').read_text(encoding='utf8'))
groups={g['uuid']:g for g in b['groups']};names={g['name']:g for g in b['groups']};owner={}
def walk(ns,parent=None):
 for node in ns:
  if isinstance(node,str):owner[node]=groups[parent]['name']
  else:walk(node['children'],node['uuid'])
walk(b['outliner']);geo={}
for e in b['elements']:
 if not owner[e['uuid']].startswith('fx_') and any(f.get('texture')is not None for f in e['faces'].values()):geo.setdefault(owner[e['uuid']],[]).append(e)
local={}
for name,es in geo.items():
 lo=np.array([e['from']for e in es]);hi=np.array([e['to']for e in es]);local[name]=((lo+hi)/2-names[name]['origin'],(hi-lo)/2)
def boxes(name,m):
 c,h=local[name];r=m[:3,:3];s=np.linalg.norm(r,axis=0);c=c@r.T+m[:3,3];h=h*s;r=r/s
 ext=h@abs(r).T
 return c,h,r,np.min(c-ext,axis=0),np.max(c+ext,axis=0)
def depth(a,b):
 if np.any(a[4]<b[3])or np.any(b[4]<a[3]):return -100.
 ac,ah,ar=a[:3];bc,bh,br=b[:3];axes=[*ar.T,*br.T]
 for u in ar.T:
  for v in br.T:
   q=np.cross(u,v);d=np.linalg.norm(q)
   if d>1e-7:axes.append(q/d)
 dep=np.full((len(ac),len(bc)),np.inf)
 for v in axes:
  dep=np.minimum(dep,(ah@abs(ar.T@v))[:,None]+(bh@abs(br.T@v))[None]-abs((ac@v)[:,None]-(bc@v)[None]))
 return float(dep.max())
cloth=[n for n in geo if n.startswith(('waist_coat_','front_tabard_fabric_','cape_'))]
limbs=[n for n in geo if n.startswith(('hand_','forearm_','thigh_','shin_','foot_'))]
pairs=list(itertools.product(cloth,limbs))
rest=next(c for c in data['clips']if c['name']=='combat_idle')['frames'][0]
def frame_boxes(f):return {n:boxes(n,np.array(f['matrices'][n]).reshape(4,4,order='F'))for n in geo}
neutral=frame_boxes(rest);baseline={p:max(0.,depth(neutral[p[0]],neutral[p[1]]))for p in pairs}
contacts={};floor={};n=0
for clip in data['clips']:
 for f in clip['frames']:
  n+=1;cache=frame_boxes(f)
  for name,z in cache.items():
   y=float(z[3][1]);key=clip['name']+' / '+name
   if key not in floor or y<floor[key]['min_y']:floor[key]={'clip':clip['name'],'group':name,'min_y':y,'time':f['time']}
  for p in pairs:
   d=depth(cache[p[0]],cache[p[1]])
   if d<=.025:continue
   key=clip['name']+' / '+p[0]+' / '+p[1]
   if key not in contacts or d>contacts[key]['depth']:contacts[key]={'clip':clip['name'],'cloth':p[0],'limb':p[1],'depth':d,'neutral_depth':baseline[p],'increase':d-baseline[p],'time':f['time']}
 if n%100<80:print(clip['name'],n,flush=True)
new=sorted([v for v in contacts.values()if v['increase']>.03],key=lambda v:v['increase'],reverse=True)
below=sorted([v for v in floor.values()if v['min_y']<-.06],key=lambda v:v['min_y'])
result={'source':'Blockbench native 40Hz matrices, actual visible cube OBBs','frames':n,'clips':len(data['clips']),'cloth_limb_pairs':len(pairs),'new_contact_candidates':new,'floor_below_minus_0_06':below,'all_floor_minima':list(floor.values()),'neutral_overlaps':[{'cloth':a,'limb':z,'depth':v}for(a,z),v in baseline.items()if v>.025],'note':'OBB contacts are candidates, including legitimate draping/contact; review actual poses. Rest contacts are listed separately, not erased. Thresholds are model units (16 per block).'}
(D/'衣物与地面_原生补查.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({'frames':n,'pairs':len(pairs),'new_contacts':len(new),'floor_candidates':len(below),'worst_contacts':new[:20],'worst_floor':below[:15]},ensure_ascii=False),flush=True)
