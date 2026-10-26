"""Solid saved-Cube intersection checks, not screen-space bounding boxes."""
import sys,json,math
import numpy as np
import knight_shoulder_guard_20261021 as k

def obbs(pose,bone):
 m=k.sc.matrices(pose)[bone];out=[]
 for e in k.b['elements']:
  if k.sc.element_bone[e['uuid']]!=bone:continue
  c=k.sc.corners[e['uuid']].mean(0);r=m[:3,:3]@k.rotation(e)
  out.append((e['name'],m[:3,:3]@c+m[:3,3],r,(np.array(e['to'])-e['from'])/2))
 return out

def intersects(a,b,margin=.02):
 _,ac,ar,ah=a;_,bc,br,bh=b
 axes=[ar[:,i] for i in range(3)]+[br[:,i] for i in range(3)]
 axes += [np.cross(ar[:,i],br[:,j]) for i in range(3) for j in range(3)]
 delta=bc-ac
 for ax in axes:
  length=np.linalg.norm(ax)
  if length<1e-8:continue
  ax=ax/length
  if abs(delta@ax)>=np.abs(ar.T@ax)@(ah+margin)+np.abs(br.T@ax)@(bh+margin):return False
 return True

def collisions(p):
 sword=obbs(p,'weapon_knight_sword');head=obbs(p,'head');out=[]
 for a in sword:
  amin=a[1]-abs(a[2])@a[3];amax=a[1]+abs(a[2])@a[3]
  for b in head:
   bmin=b[1]-abs(b[2])@b[3];bmax=b[1]+abs(b[2])@b[3]
   if np.any(amax+.04<=bmin) or np.any(bmax+.04<=amin):continue
   if intersects(a,b):out.append((a[0],b[0]))
 return out

if __name__=='__main__':
 records=k.load(k.E/'姿态与衔接.json');failure=[]
 for r in records:
  cs=collisions(r['pose'])
  if cs:failure.append({'key':r['key'],'frame':r['frame'],'pairs':cs[:6]})
  if len(failure)>25:break
 report={'poses_checked':len(records),'head_neck_intersections':failure}
 (k.E/'剑刃与头颈检查.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
 print(json.dumps(report,ensure_ascii=False))
 sys.exit(bool(failure))
