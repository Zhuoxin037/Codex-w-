from pathlib import Path
import json,sys,itertools,math
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
from b_staff_cast_20261028 import D,TITLE,SRC
def main():
 b=json.loads((D/(TITLE+'.ajblueprint')).read_text(encoding='utf8'));orig=json.loads(SRC.read_text(encoding='utf8'));sample=json.loads((D/'原生40Hz姿态.json').read_text(encoding='utf8'));g={x['uuid']:x for x in b['groups']};names={x['name']:x for x in b['groups']};elements={x['uuid']:x for x in b['elements']};owner={}
 def walk(nodes,par=None):
  for n in nodes:
   if isinstance(n,str):owner[n]=g[par]['name']
   else:walk(n['children'],n['uuid'])
 walk(b['outliner']);original={e['uuid']:e for e in orig['elements']};changed=[]
 for uid,e in original.items():
  if uid not in elements:changed.append([e['name'],'missing']);continue
  for k in ['from','to','origin','rotation','faces']:
   if e.get(k)!=elements[uid].get(k):changed.append([e['name'],k])
 staff=[e for e in b['elements']if owner[e['uuid']]=='staff'];corners=[];heights=[]
 for e in staff:
  if any(abs(x)>1e-9 for x in e.get('rotation',[0,0,0])):raise ValueError('Rotated staff cube needs individual transform: '+e['name'])
  corners.extend(itertools.product(*zip(e['from'],e['to'])))
 corners=np.array(corners)-names['staff']['origin'];floor=1e9;worst={};joint=0;fx=[]
 pairs=[('arm_upper_right','arm_lower_right'),('arm_lower_right','hand_right'),('hand_right','staff'),('arm_upper_left','arm_lower_left'),('arm_lower_left','hand_left')]
 selected=['staff','arm_lower_right','hand_right','arm_lower_left','hand_left','head','neck','chest','waist','pelvis','leg_upper_right','leg_upper_left','leg_lower_right','leg_lower_left','foot_right','foot_left']
 geo={n:[e for e in b['elements']if owner[e['uuid']]==n and any(v.get('texture')is not None for v in e['faces'].values())]for n in selected}
 collision_pairs=[(a,z)for a in ['arm_lower_right','hand_right','arm_lower_left','hand_left']for z in ['head','neck','chest','waist','pelvis']]+[('staff',z)for z in ['head','neck','chest','waist','pelvis','leg_upper_right','leg_upper_left','leg_lower_right','leg_lower_left','foot_right','foot_left']]
 def boxes(n,m):
  es=geo[n];lo=np.array([e['from']for e in es]);hi=np.array([e['to']for e in es]);r=m[:3,:3];return((lo+hi)/2-names[n]['origin'])@r.T+m[:3,3],(hi-lo)/2,r
 def depth(a,b):
  ac,ah,ar=a;bc,bh,br=b;out=np.full((len(ac),len(bc)),np.inf);axes=[*ar.T,*br.T]
  for x in ar.T:
   for y in br.T:
    z=np.cross(x,y);n=np.linalg.norm(z)
    if n>1e-7:axes.append(z/n)
  for axis in axes:out=np.minimum(out,(ah@abs(ar.T@axis))[:,None]+(bh@abs(br.T@axis))[None]-abs((ac@axis)[:,None]-(bc@axis)[None]))
  return float(out.max())
 initial=sample['clips'][0]['frames'][0];mat={n:np.array(v).reshape(4,4,order='F')for n,v in initial['matrices'].items()};base={p:max(0,depth(boxes(p[0],mat[p[0]]),boxes(p[1],mat[p[1]])))for p in collision_pairs};collisions=[]
 def dist(a,z):return np.linalg.norm(np.array(names[a]['origin'])-names[z]['origin'])
 for f in sample['clips'][0]['frames']:
  m={n:np.array(v).reshape(4,4,order='F')for n,v in f['matrices'].items()};t=f['time'];sp=corners@m['staff'][:3,:3].T+m['staff'][:3,3];bottom=float(sp[:,1].min())
  if bottom<floor:floor=bottom;worst={'time':t,'min_y':bottom}
  if abs(t*10-round(t*10))<1e-7:heights.append((t,round(bottom,3)))
  for a,z in pairs:joint=max(joint,abs(np.linalg.norm(m[a][:3,3]-m[z][:3,3])-dist(a,z)))
  cache={n:boxes(n,m[n])for n in selected}
  for a,z in collision_pairs:
   extra=depth(cache[a],cache[z])-base[a,z]
   if extra>.08:collisions.append({'time':t,'first':a,'second':z,'additional_depth':float(extra)})
 for t,gn in [(.7,'preview_orb_1'),(1.,'preview_orb_2'),(1.3,'preview_orb_3')]:
  f=min(sample['clips'][0]['frames'],key=lambda x:abs(x['time']-t));staffm=np.array(f['matrices']['staff']).reshape(4,4,order='F');p=staffm@np.array([0,12.05,0,1]);orb=np.array(f['matrices'][gn]).reshape(4,4,order='F')[:3,3];fx.append({'shot_time':t,'tip':p[:3].tolist(),'orb':orb.tolist(),'distance':float(np.linalg.norm(p[:3]-orb))})
 output={'source_character_cubes':len(original),'all_cubes':len(b['elements']),'preview_cubes':len(b['elements'])-len(original),'groups':len(b['groups']),'textures':len(b['textures']),'original_geometry_uv_differences':changed,'frames':len(sample['clips'][0]['frames']),'staff_bottom_min':worst,'joint_length_max_error':joint,'projectile_origin':fx,'collision_pairs':len(collision_pairs),'new_intersections':collisions,'limitations':'Checks sampled staff vertices, specified body/arm/staff pairs and start points; not all mesh intersections or live Minecraft.'}
 (D/'模型与杖尖核对.json').write_text(json.dumps(output,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps({'original_diff':len(changed),'floor':worst,'joint_error':joint,'collision_count':len(collisions),'worst_collision':sorted(collisions,key=lambda x:x['additional_depth'],reverse=True)[:5],'projectiles':fx},ensure_ascii=True),flush=True)
if __name__=='__main__':main()
