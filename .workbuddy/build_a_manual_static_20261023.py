"""Complete static-layer candidate from the saved, editable manual body.

Anatomy / dissolvable shoulder cloth / permanent lower robe / rear hard
apparatus remain separate. Source untouched; no animation or game deployment.
"""
from build_a_manual_lower_20261023 import Model,uid,H,P,R,Rotation
from build_a_manual_body_20261023 import beam
from pathlib import Path
from PIL import Image
import numpy as np,json,base64,copy,math,hashlib

SRC=P/'阶段一_静态模型/手工重建_骨质常驻主体_20261023/A_骨质常驻主体_手工重建.bbmodel'
D=P/'阶段一_静态模型/手工重建_整件静态候选_20261023';D.mkdir(exist_ok=True)
TITLE='A_手工重建_整件静态候选'

def start():
 m=Model();m.bb=json.loads(SRC.read_text(encoding='utf8'));m.bb['name']=TITLE;gs={g['uuid']:g for g in m.bb['groups']}
 def walk(ns):
  for v in ns:
   if isinstance(v,dict):m.nodes[gs[v['uuid']]['name']]=v;walk(v['children'])
 walk(m.bb['outliner']);m.groups={g['name']:g for g in m.bb['groups']}
 for name,g in m.groups.items():m.world[name]=(Rotation.from_euler('xyz',g.get('rotation',[0,0,0]),degrees=True).as_matrix(),np.array(g['origin'],float))
 for t in m.bb['textures']:
  (D/t['name']).write_bytes(base64.b64decode(t['source'].split(',',1)[1]));t['path']=str(D/t['name']);t['relative_path']=t['name']
 return m

def ribbon(m,name,parent,points,widths,thickness,material,hint=(1,0,0)):
 pts=np.array(points,float)
 for i,(a,b)in enumerate(zip(pts[:-1],pts[1:])):
  yy=b-a;length=np.linalg.norm(yy);yy/=length;xx=np.array(hint,float);xx-=yy*(xx@yy)
  if np.linalg.norm(xx)<.05:xx=np.cross(yy,[0,0,1.])
  xx/=np.linalg.norm(xx);zz=np.cross(xx,yy);rr=np.column_stack([xx,yy,zz]);pivot=(a+b)/2;g=f'{name}_section_{i:02d}';m.group(g,parent,pivot,rr)
  # Two overlapping bands follow the taper instead of a single large slab.
  for row in range(2):
   ta=row/2;tb=(row+1)/2;wa=widths[i]*(1-ta)+widths[i+1]*ta;wb=widths[i]*(1-tb)+widths[i+1]*tb;mid=(ta+tb)/2;wide=(wa+wb)/2
   c=pivot+np.array([0,length*(mid-.5),0]);lo=c+[-wide/2,-length/4-.025,-thickness/2];hi=c+[wide/2,length/4+.025,thickness/2]
   m.box(f'{name}_{i:02d}_{row}',g,lo,hi,'layer',material)

def cloth(m):
 m.group('upper_dissolvable_cloth','chest',[-.35,32.2,-6.7])
 # Lightweight shoulder coverings. Broad folds bridge the neck to the arms;
 # their thin section is independent of all permanent rib/guard geometry.
 for side,pts,w in [
  ('r',[[-.5,33.1,-7.1],[2.0,33.15,-7.5],[4.7,32.4,-7.7],[5.9,30.2,-8.25],[6.05,28.1,-8.7]],[1.25,1.65,2.2,1.55,.75]),
  ('l',[[-.2,33.15,-5.8],[-2.6,33.0,-4.6],[-5.15,32.1,-3.25],[-6.45,29.9,-2.0],[-6.8,27.8,-.8]],[1.3,1.7,2.25,1.5,.7])]:
  ribbon(m,'shoulder_cloth_'+side,'upper_dissolvable_cloth',pts,w,.18,'cloth',(0,0,1))
 # A few long hanging folds around the upper arms; no thick robe capsule.
 for side,pts in [
  ('r',[[5.3,31.5,-7.0],[6.4,29.8,-7.45],[6.55,27.4,-8.4],[6.3,25.6,-9.4]]),
  ('l',[[-5.7,31.4,-2.6],[-7.05,29.5,-.9],[-7.3,27.1,.3],[-7.05,25.3,.9]])]:
  g='dissolvable_upperarm_cloth_'+side;m.group(g,'upperarm_'+side,pts[0]);ribbon(m,'upperarm_outer_fold_'+side,g,pts,[1.4,1.3,.95,.3],.14,'cloth',(1,0,0))
  offset=np.array([-.55 if side=='r'else .55,0,-.25]);p=np.array(pts)+offset;ribbon(m,'upperarm_inner_fold_'+side,g,p.tolist(),[.6,.58,.38,.14],.14,'cloth',(1,0,0))

def framework(m):
 m.group('independent_hard_apparatus','chest',[-.35,32,-3.8]);m.group('rear_bone_scaffold','independent_hard_apparatus',[-.35,32,-3.8]);m.group('crown_and_counterweights','independent_hard_apparatus',[-.35,40.5,-4.8])
 # Permanent long pale structures: their gaps are real, their lower flares are
 # not assigned to the dissolving cloth. These are explicit traced paths.
 paths=[
  ('rear_main_r',[[3.0,33,-3.9],[5.4,32.0,-1.9],[6.0,28.3,.2],[5.7,23.1,1.5],[6.5,17.0,3.2],[7.5,10.0,6.4],[9.5,4.1,10.5],[13.9,1.1,14.8]],[1.4,2.0,2.15,1.8,2.1,2.6,2.1,.25]),
  ('rear_main_l',[[-3.0,32.8,-3.3],[-5.3,31.5,-1.7],[-6.1,27.8,.8],[-6.2,22.4,2.9],[-7.0,16.2,5.2],[-8.0,9.7,8.8],[-11.0,3.4,12.5],[-15.4,1.0,15.4]],[1.5,2.1,2.2,1.9,2.15,2.6,2.2,.22]),
  ('front_bone_r',[[3.4,32.1,-8.5],[4.5,28.5,-8.8],[4.3,23.3,-8.3],[4.7,17.9,-8.6],[5.1,12.3,-9.8],[5.8,7.0,-11.5],[7.6,2.1,-12.9]],[1.2,1.25,.95,1.15,1.3,1.1,.18]),
  ('front_bone_l',[[-3.8,32.1,-5.1],[-4.75,28.1,-6.9],[-4.75,22.9,-8.9],[-5.5,17.0,-10.7],[-6.6,11.2,-11.9],[-8.5,5.6,-12.8],[-11.4,1.3,-13.9]],[1.3,1.35,1.0,1.15,1.35,1.0,.20]),
  ('rear_inner_r',[[1.8,30.5,-1.7],[3.4,27.5,.7],[3.1,22.0,2.5],[3.7,17.3,4.8],[2.7,12.3,7.1],[4.5,6.0,9.4],[6.2,1.1,10.7]],[.85,1.1,.95,.75,.9,1.15,.12]),
  ('rear_inner_l',[[-2.1,30.2,-1.2],[-3.7,26.9,1.2],[-3.3,21.6,3.9],[-3.8,16.5,6.1],[-4.2,11.1,8.3],[-3.6,5.1,10.2],[-2.2,1.3,12.2]],[.9,1.15,.85,.75,1.0,1.15,.12])]
 for name,pts,widths in paths:ribbon(m,name,'rear_bone_scaffold',pts,widths,.29,'hard')
 # Short bridges create the recognizable open, branching back structure.
 for side,points in [
  ('r',[[5.4,30.9,-1.4],[4.1,28.2,.1],[2.8,24.5,1.9],[3.1,21.4,3.3],[4.8,19.4,4.6],[6.1,20.6,3.7],[5.8,24.9,2.1],[5.4,30.9,-1.4]]),
  ('l',[[-5.3,30.5,-1.1],[-4.0,27.8,.8],[-2.8,24.0,3.0],[-3.0,20.8,4.6],[-4.8,18.8,5.9],[-6.2,20.0,4.7],[-6.1,24.2,2.7],[-5.3,30.5,-1.1]])]:ribbon(m,'rear_open_web_'+side,'rear_bone_scaffold',points,[1.25,.95,.62,.58,.88,.85,.72,1.25],.28,'hard')
 # Thin forked lower ends, all attached to a main ribbon. Their different
 # lengths retain the source's ragged silhouette without disconnected scraps.
 for i,(pts,widths)in enumerate([
  ([[5.2,12.2,-9.8],[7.0,9.0,-9.5],[8.8,6.1,-9.8]],[.80,.6,.10]),
  ([[-6.5,11.4,-11.9],[-7.9,9.1,-10.0],[-8.2,6.2,-9.2]],[.8,.55,.10]),
  ([[7.5,10.1,6.3],[9.2,7.3,7.5],[10.8,5.4,8.3]],[.9,.6,.10]),
  ([[-8.0,9.7,8.8],[-10.3,7.1,8.8],[-12.2,5.7,9.2]],[.9,.6,.10])]):ribbon(m,f'branch_tip_{i}','rear_bone_scaffold',pts,widths,.20,'hard')
 # Separate bronze orbit; this is never treated as a filled shoulder shell.
 ring=[[10.7,35.4,-8.3],[12.3,35.6,-4.0],[10.6,35.0,.4],[6.4,34.1,4.1],[.3,33.1,6.8],[-5.5,32.2,6.0],[-9.5,31.4,2.0],[-10.6,31.2,-2.8],[-8.0,32.2,-6.8],[-3.2,33.4,-9.9],[3.4,34.5,-11.0],[8.8,35.0,-10.1]]
 for i,(a,b)in enumerate(zip(ring,ring[1:]+ring[:1])):beam(m,f'bronze_orbit_{i:02d}','independent_hard_apparatus',a,b,.32,.30,'metal')
 # Main crown stem, open annulus and front crossbar measured at crown height.
 beam(m,'crown_stem','crown_and_counterweights',[-.2,39.9,-4.85],[-.2,48.0,-4.85],.28,.26,'metal')
 center=np.array([-.2,45.6,-4.85]);pts=[center+[1.7*math.sin(i*math.pi/6),1.85*math.cos(i*math.pi/6),0]for i in range(12)]
 for i,(a,b)in enumerate(zip(pts,pts[1:]+pts[:1])):beam(m,f'crown_open_ring_{i}','crown_and_counterweights',a,b,.19,.22,'metal')
 beam(m,'crown_inner_cross_vertical','crown_and_counterweights',center+[0,-1.15,-.08],center+[0,1.15,-.08],.21,.25,'metal')
 beam(m,'crown_inner_cross_horizontal','crown_and_counterweights',center+[-1.25,0,-.08],center+[1.25,0,-.08],.20,.25,'metal')
 beam(m,'crown_crossbar','crown_and_counterweights',[-5.3,42.5,-5.4],[5.5,42.7,-5.4],.25,.40,'metal')
 # Independent suspended side rods: they are not head tissue or arm geometry.
 rods=[('r_front',[5.2,43.7,-5.4],[5.2,36.8,-5.4]),('l_front',[-5.0,43.1,-5.4],[-5.0,37.4,-5.4]),('r_rear',[11.5,41.8,-1.8],[11.5,30.2,-1.8]),('l_rear',[-10.1,40.5,4.5],[-10.1,29.8,4.5]),('r_low',[9.6,34.2,-9.2],[9.6,25.1,-9.2])]
 for name,a,b in rods:
  beam(m,'rod_'+name,'crown_and_counterweights',a,b,.21,.21,'metal')
  # Collars and pointed ends belong to the same physical rod.
  for k,t in enumerate([.18,.55,.85]):
   c=np.array(a)*(1-t)+np.array(b)*t;beam(m,f'rod_{name}_collar_{k}','crown_and_counterweights',c+[0,-.22,0],c+[0,.22,0],.51,.50,'metal')
  beam(m,'rod_'+name+'_finial','crown_and_counterweights',np.array(b)+[0,.0,0],np.array(b)+[0,-.85,0],.15,.16,'metal')
  if name in ['r_rear','l_rear']:
   c=np.array(a);g='rod_'+name+'_top_cap';m.group(g,'crown_and_counterweights',c)
   for k,(w,d)in enumerate([(2.1,.55),(1.7,.90),(1.0,1.15)]):m.box(g+'_'+str(k),g,c+[-w/2,-.1+k*.012,-d/2],c+[w/2,.1+k*.012,d/2],'layer','metal')
 for i in [0,2,4,6,8,10]:
  c=np.array(ring[i]);out=c-np.array([.2,33.5,-2.0]);out[1]=.4;out/=np.linalg.norm(out);beam(m,'orbit_thorn_'+str(i),'independent_hard_apparatus',c,c+out*.85,.19,.20,'metal')
 # Horizontal lateral arcs, unlike extra weapons, remain with the apparatus.
 for side,sgn,z in [('r',1,-1.8),('l',-1,4.5)]:
  a=[sgn*4.6,39.1,z];b=[sgn*9,39.5,z+.2];c=[sgn*12.2,39.1,z+.25]
  beam(m,'rear_bar_'+side+'_a','crown_and_counterweights',a,b,.34,.33,'metal');beam(m,'rear_bar_'+side+'_b','crown_and_counterweights',b,c,.31,.30,'metal')
 # Purple mineral counterweights present on the reference, kept muted.
 for i,c in enumerate([[11.5,38.4,-1.8],[-10.1,37.4,4.5],[9.6,31.0,-9.2]]):
  c=np.array(c,float);g=f'violet_counterweight_{i}';m.group(g,'crown_and_counterweights',c)
  m.box(g+'_middle',g,c+[-.40,-.40,-.33],c+[.40,.45,.33],'layer','violet');m.box(g+'_upper',g,c+[-.25,.4,-.22],c+[.25,.78,.22],'layer','violet');m.box(g+'_lower',g,c+[-.24,-.9,-.20],c+[.24,-.35,.20],'layer','violet');m.box(g+'_tip',g,c+[-.10,-1.4,-.09],c+[.10,-.85,.09],'layer','violet')

def paint(m):
 entries=sorted(m.faces,key=lambda x:-x['h']);batches=[];batch=[];x=y=rh=0
 for ent in entries:
  w,h=ent['w']+2,ent['h']+2
  if x+w>512:x=0;y+=rh;rh=0
  if y+h>512:batches.append(batch);batch=[];x=y=rh=0
  ent['xy']=(x+1,y+1);batch.append(ent);x+=w;rh=max(rh,h)
 if batch:batches.append(batch)
 for batch in batches:
  ti=len(m.bb['textures']);atlas=Image.new('RGBA',(512,512))
  for ent in batch:
   q=ent['q'];w,h=ent['w'],ent['h'];uu,vv=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);p=q[0]+uu[:,:,None]*(q[3]-q[0])+vv[:,:,None]*(q[1]-q[0]);xx,yy,zz=p.transpose(2,0,1);grain=((np.floor(xx*4)*11+np.floor(yy*4)*7+np.floor(zz*4)*13)%7-3)*.50;mat=ent['material']
   if mat=='metal':
    base=[119,104,78];detail=grain+3*np.sin(xx*4+yy*.5+zz*1.5);edge=np.minimum.reduce([uu,1-uu,vv,1-vv]);detail+=np.where(edge<.10,6,0)
   elif mat=='violet':base=[87,73,116];detail=grain+5*np.cos(xx*3+yy*.8-zz*2)
   elif mat=='cloth':base=[196,190,181];detail=grain*.45+4*np.sin(yy*.55+xx*1.3+zz*2);detail-=4*np.exp(-((uu-.12)/.1)**2)
   else:
    fade=np.clip((10-yy)/9,0,1);base=np.stack([200-fade*54,195-fade*64,184-fade*16],2);detail=grain+3*np.sin(xx*1.5+yy*.8+zz*.9)
   rgb=np.array(base)[None,None,:]+detail[:,:,None]if np.array(base).ndim==1 else base+detail[:,:,None];rgba=np.zeros((h,w,4),np.uint8);rgba[:,:,:3]=np.clip(rgb,0,255);rgba[:,:,3]=255;px,py=ent['xy'];atlas.paste(Image.fromarray(np.pad(rgba,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1));ent['e']['faces'][ent['fa']]={'uv':[px,py,px+w,py+h],'texture':ti}
  name=f'a_manual_static_layers_{ti}_512.png';atlas.save(D/name);m.bb['textures'].append({'name':name,'id':str(ti),'uuid':uid('tex/'+name),'path':str(D/name),'relative_path':name,'width':512,'height':512,'uv_width':512,'uv_height':512,'render_mode':'default','render_sides':'auto','internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode((D/name).read_bytes()).decode()})

def save(m):
 bb=m.bb;(D/(TITLE+'.bbmodel')).write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8');aj=json.loads((H/'切换参考前_在场工程完整备份.ajblueprint').read_text(encoding='utf8'))
 for k in ['name','elements','groups','outliner','textures','resolution']:aj[k]=copy.deepcopy(bb[k])
 aj['animations']=[];aj['meta'].update(uuid=uid('manual-static-project'),save_location=str(D/(TITLE+'.ajblueprint')))
 for e in aj['elements']:
  for face in e['faces'].values():
   if face['texture']is not None:face['texture']=aj['textures'][face['texture']]['uuid']
 (D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
 old=json.loads(SRC.read_text(encoding='utf8'));byid={e['uuid']:e for e in bb['elements']};assert all(byid[e['uuid']]==e for e in old['elements'])
 report={'source_body_project':str(SRC),'source_body_sha256':hashlib.sha256(SRC.read_bytes()).hexdigest(),'body_elements_unchanged':len(old['elements']),'cubes':len(bb['elements']),'groups':len(bb['groups']),'defined_faces':sum(f['texture']is not None for e in bb['elements']for f in e['faces'].values()),'textures':len(bb['textures']),'texture_dimensions':[512,512],'animations':0,'voxelization':False,'old_rejected_cubes_used':0,'static_candidate_only':True,'appearance_approved':False,'body_cloth_hard_parts_separate':True,'performance_optimized':False,'game_deployed':False,'game_tested':False}
 (D/'整件静态统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
def build():
 m=start();cloth(m);framework(m);paint(m);save(m)
if __name__=='__main__':raise SystemExit('Failed A draft. Do not regenerate, deploy or mark appearance approved.')
