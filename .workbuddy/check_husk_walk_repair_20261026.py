from pathlib import Path
import json,itertools
import numpy as np
P=Path('D:/数据包/模型设计/C_红披风铠甲_GLB重建_20261024');D=P/'阶段五_游戏接入_20261025/修复_储能爆发与步行_20261026'
def main():
 b=json.loads((D/'空壳_修复后现场.bbmodel').read_text(encoding='utf8'));data=json.loads((D/'步行_原生40Hz姿态.json').read_text(encoding='utf8'));gs={g['uuid']:g for g in b['groups']};names={g['name']:g for g in b['groups']};owner={}
 def tree(ns,pa=None):
  for n in ns:
   if isinstance(n,str):owner[n]=gs[pa]['name']
   else:tree(n['children'],n['uuid'])
 tree(b['outliner']);geo={}
 for e in b['elements']:
  if any(f.get('texture')is not None for f in e['faces'].values()):geo.setdefault(owner[e['uuid']],[]).append(e)
 def boxes(n,m):
  es=geo[n];lo=np.array([e['from']for e in es]);hi=np.array([e['to']for e in es]);r=m[:3,:3];return((lo+hi)/2-names[n]['origin'])@r.T+m[:3,3],(hi-lo)/2,r
 def dep(a,b):
  ac,ah,ar=a;bc,bh,br=b;out=np.full((len(ac),len(bc)),np.inf);axes=[*ar.T,*br.T]
  for x in ar.T:
   for y in br.T:
    z=np.cross(x,y);L=np.linalg.norm(z)
    if L>1e-7:axes.append(z/L)
  for axis in axes:out=np.minimum(out,(ah@abs(ar.T@axis))[:,None]+(bh@abs(br.T@axis))[None]-abs((ac@axis)[:,None]-(bc@axis)[None]))
  return float(out.max())
 pairs=[(a,z)for a in['forearm_right','forearm_left','hand_right','hand_left']for z in geo if z in['chest','waist','head','pelvis','thigh_right','thigh_left']or z.startswith('waist_coat_')];worst=[];length_error=0
 for clip in data['clips']:
  for f in clip['frames']:
   ms={n:np.array(v).reshape(4,4,order='F')for n,v in f['matrices'].items()};cache={n:boxes(n,ms[n])for n in set(n for p in pairs for n in p)}
   for a,z in pairs:
    d=dep(cache[a],cache[z])
    if d>.08:worst.append({'clip':clip['name'],'time':f['time'],'arm':a,'body':z,'depth':d})
   for side in['right','left']:
    for a,z in[('upperarm_','forearm_'),('forearm_','hand_')]:length_error=max(length_error,abs(np.linalg.norm(ms[a+side][:3,3]-ms[z+side][:3,3])-np.linalg.norm(np.array(names[a+side]['origin'])-names[z+side]['origin'])))
 out={'frames':sum(len(c['frames'])for c in data['clips']),'pairs':len(pairs),'joint_length_max_error':length_error,'candidates':worst};(D/'步行穿插核对.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf8');print({'frames':out['frames'],'joint_error':length_error,'collisions':len(worst),'worst':sorted(worst,key=lambda x:x['depth'],reverse=True)[:5]},flush=True)
if __name__=='__main__':main()
