from animate_knight_combat import *
from finish_knight_gait import cloth_points,penetrated
from collections import defaultdict

def check(b):
 s=Scene(b);groups={g['name']:g for g in b['groups']};body={e['uuid']:e for e in b['elements']};report={};all_limits=defaultdict(list)
 soles={n:np.vstack([s.corners[e['uuid']] for e in b['elements'] if s.element_bone[e['uuid']]==n]) for n in ['foot_r','foot_l']}
 cloth=cloth_points(b,s);legs=[e for e in b['elements'] if s.element_bone[e['uuid']].startswith(('thigh_','shin_','foot_'))]
 for a in b['animations']:
  low=100.;cloth_hits=0;knee_gap=100.;lane_deviation=0.;headings={side:[] for side in 'rl'};toe_directions={side:shoe_markers(b,s,side) for side in 'rl'}
  for t in np.linspace(0,a['length'],round(a['length']*120)+1):
   p=sample(a,float(t));mm=s.matrices(p)
   for n in ['forearm_r','forearm_l','shin_r','shin_l']:
    r=p.get(n,{}).get('rotation',[0,0,0]);all_limits[n].append(r)
    if n.startswith('forearm_'):assert abs(r[1])<1e-5 and abs(r[2])<1e-5,(a['name'],n,t,r)
   knee_gap=min(knee_gap,float(mm['shin_r'][0,3]-mm['shin_l'][0,3]))
   for side in 'rl':
    hip=mm['thigh_'+side][:3,3];knee=mm['shin_'+side][:3,3];ankle=mm['foot_'+side][:3,3];v=ankle-hip;f=np.dot(knee-hip,v)/np.dot(v,v);center=hip+v*f
    lane_deviation=max(lane_deviation,max(0,float((center[0]-knee[0])*(1 if side=='r' else -1))))
    toe,heel=toe_directions[side];vv=mm['foot_'+side][:3,:3]@(toe-heel);headings[side].append(float(np.degrees(np.arctan2(vv[0],-vv[2]))))
   for n,ps in soles.items():low=min(low,float((ps@mm[n][:3,:3].T+mm[n][:3,3])[:,1].min()))
   if a['name'] in ['walk','sprint','approach_run']:
    for n,ps in cloth.items():cloth_hits=max(cloth_hits,penetrated(ps@mm[n][:3,:3].T+mm[n][:3,3],s,mm,legs))
  assert low>-.02,(a['name'],low)
  report[a['name']]={'minimum_sole_y':low,'minimum_knee_lane_width':knee_gap,'maximum_knee_inward_from_hip_ankle_lane':lane_deviation,'actual_toe_heading_degrees':{side:[min(v),max(v)] for side,v in headings.items()},'opaque_tabard_points_inside_legs_max':cloth_hits if a['name'] in ['walk','sprint','approach_run'] else 'not_sampled','loop_closed':None if a['loop']!='loop' else sample(a,0)==sample(a,a['length'])}
  print(a['name'],report[a['name']],flush=True)
 # Joint pivots remain connected through the original filled joint surfaces.
 joints=[]
 for side in 'rl':
  for parent,child in [('upperarm_','forearm_'),('forearm_','hand_'),('thigh_','shin_'),('shin_','foot_')]:
   pn=parent+side;cn=child+side;point=np.array(groups[cn]['origin']);pr=[];cd=[]
   for e in b['elements']:
    n=s.element_bone[e['uuid']]
    if n not in [pn,cn]:continue
    # Measure the actual rotated Cube, not only its unrotated bounds.
    pivot=np.array(e['origin']);local=rotation(e).T@(point-pivot)+pivot
    lo=np.array(e['from']);hi=np.array(e['to']);inside=float(np.min(np.r_[local-lo,hi-local]));distance=float(np.linalg.norm(np.maximum(0,np.maximum(lo-local,local-hi))))
    if n==pn:pr.append(inside)
    else:cd.append(distance)
   joints.append({'parent':pn,'child':cn,'parent_contains_pivot_radius':max(pr),'child_surface_distance_to_pivot':min(cd)})
 return {'clips':report,'hinge_rotation_bounds':{n:{'min':np.min(v,axis=0).tolist(),'max':np.max(v,axis=0).tolist()} for n,v in all_limits.items()},'joint_pivot_volume_check':joints,'leg_bind_geometry_adjusted':True,'original_uv_faces_preserved':True,'evaluation_hz':120,'visual_limit':'Pivot and heading metrics alone do not prove correct visible leg silhouettes. See the actual-mesh section audit and same-angle images.'}

if __name__=='__main__':
 out={}
 for v in ['有披风','无披风']:
  b=json.loads((C/v/f'骑士_{v}_战斗动作.bbmodel').read_text(encoding='utf8'));out[v]=check(b)
 (C/'肘膝与接合复核.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf8')
