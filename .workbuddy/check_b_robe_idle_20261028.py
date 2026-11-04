from pathlib import Path
import sys,json,itertools
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
from b_staff_robe_idle_20261028 import D,S,TITLE
def main():
 src=json.loads((D/'修改前_现场快照.ajblueprint').read_text(encoding='utf8'));b=json.loads((D/(TITLE+'.ajblueprint')).read_text(encoding='utf8'));data=json.loads((D/'后摆_原生40Hz姿态.json').read_text(encoding='utf8'));old_default=json.loads((D/'修改前_原生默认姿态.json').read_text(encoding='utf8'));default=data['default_matrices'];changed=[];els={e['uuid']:e for e in b['elements']}
 for e in src['elements']:
  for k in ['from','to','origin','rotation','faces']:
   if e.get(k)!=els[e['uuid']].get(k):changed.append([e['name'],k])
 rest_error=max(float(np.max(np.abs(np.array(v)-default[n])))for n,v in old_default.items())
 group={g['uuid']:g for g in b['groups']};names={g['name']:g for g in b['groups']};owner={}
 def walk(nodes,pa=None):
  for n in nodes:
   if isinstance(n,str):owner[n]=group[pa]['name']
   else:walk(n['children'],n['uuid'])
 walk(b['outliner']);geo={}
 for e in b['elements']:
  if any(f.get('texture')is not None for f in e['faces'].values()):geo.setdefault(owner[e['uuid']],[]).append(e)
 setup=json.loads((D/'后摆待机_原生导入.json').read_text(encoding='utf8'));moving={x['name']for x in setup['moving']};cloth=[n for n in geo if n.startswith('robe_')or n in ['coat_045','tabard']];legs=['pelvis','leg_upper_right','leg_upper_left','leg_lower_right','leg_lower_left','foot_right','foot_left']
 def box(n,m):
  es=geo[n];lo=np.array([e['from']for e in es]);hi=np.array([e['to']for e in es]);r=m[:3,:3];return((lo+hi)/2-names[n]['origin'])@r.T+m[:3,3],(hi-lo)/2,r
 def dep(a,b):
  ac,ah,ar=a;bc,bh,br=b;out=np.full((len(ac),len(bc)),np.inf);axes=[]
  # Non-uniform inherited cloth scale produces parallelepipeds, so use face
  # normals rather than assuming that the three edge directions stay orthogonal.
  for r in [ar,br]:
   for i in range(3):
    normal=np.cross(r[:,(i+1)%3],r[:,(i+2)%3]);axes.append(normal/np.linalg.norm(normal))
  for x in ar.T:
   for y in br.T:
    z=np.cross(x,y);L=np.linalg.norm(z)
    if L>1e-7:axes.append(z/L)
  for axis in axes:out=np.minimum(out,(ah@abs(ar.T@axis))[:,None]+(bh@abs(br.T@axis))[None]-abs((ac@axis)[:,None]-(bc@axis)[None]))
  return float(out.max())
 dm={n:np.array(v).reshape(4,4,order='F')for n,v in default.items()};ob={n:box(n,dm[n])for n in cloth+legs};pairs=[(a,z)for a in moving for z in legs];base={(a,z):max(0,dep(ob[a],ob[z]))for a,z in pairs}
 seams=[]
 for i,a in enumerate(cloth):
  for z in cloth[i+1:]:
   if a not in moving and z not in moving:continue
   d=dep(ob[a],ob[z])
   if d>=-.04:seams.append((a,z,d))
 candidates=[];gaps=[];floor=100;maxmotion=0;loop=0;cast_error=0;source_cast=json.loads((S/'原生40Hz姿态.json').read_text(encoding='utf8'))['clips'][0]['frames'];body=['chest','head','arm_upper_right','arm_lower_right','hand_right','staff','arm_upper_left','arm_lower_left','hand_left']
 for clip in data['clips']:
  fs=clip['frames'];loop=max(loop,max(float(np.max(abs(np.array(fs[0]['matrices'][n])-fs[-1]['matrices'][n])))for n in [g['name']for g in setup['groups']]))
  for f in fs:
   t=f['time'];ms={n:np.array(v).reshape(4,4,order='F')for n,v in f['matrices'].items()};cache={n:box(n,ms[n])for n in cloth+legs}
   for n in moving:
    for e in geo[n]:
     v=np.array(list(itertools.product(*zip(e['from'],e['to']))))-names[n]['origin'];p=v@ms[n][:3,:3].T+ms[n][:3,3];rest=v@dm[n][:3,:3].T+dm[n][:3,3];floor=min(floor,float(p[:,1].min()));maxmotion=max(maxmotion,float(np.linalg.norm(p-rest,axis=1).max()))
   for a,z in pairs:
    extra=dep(cache[a],cache[z])-base[a,z]
    if extra>.08:candidates.append({'clip':clip['name'],'time':t,'cloth':a,'body':z,'extra_depth':extra})
   for a,z,bd in seams:
    sep=-dep(cache[a],cache[z])
    if sep>max(.12,-bd+.08):gaps.append({'clip':clip['name'],'time':t,'a':a,'b':z,'separation_axis_gap':sep,'baseline':-bd})
   if clip['name']=='idle_cast'and t<=2:
    ref=min(source_cast,key=lambda q:abs(q['time']-t))
    for n in body:cast_error=max(cast_error,float(np.max(abs(np.array(f['matrices'][n])-ref['matrices'][n]))))
 out={'cube_count':len(b['elements']),'groups':len(b['groups']),'geometry_uv_changes':changed,'default_world_matrix_max_difference':rest_error,'moving_cloth_surfaces':len(moving),'new_helper_groups':len(setup['groups']),'sampled_frames':sum(len(c['frames'])for c in data['clips']),'loop_matrix_max_difference':loop,'minimum_moving_cloth_y':floor,'max_vertex_motion':maxmotion,'cast_body_matrix_max_difference':cast_error,'body_pair_count':len(pairs),'seam_pair_count':len(seams),'extra_body_intersections':candidates,'new_seam_gap_candidates':gaps,'limits':'Specified OBB pairs relative to original pose; does not include all geometry, opacity masks, or Minecraft gameplay.'}
 (D/'后摆连接与穿插核对.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps({k:v for k,v in out.items()if k not in ['extra_body_intersections','new_seam_gap_candidates']},ensure_ascii=True),flush=True);print('collisions',len(candidates),'gaps',len(gaps),'worst',sorted(gaps,key=lambda q:q['separation_axis_gap'],reverse=True)[:4],flush=True)
if __name__=='__main__':main()
