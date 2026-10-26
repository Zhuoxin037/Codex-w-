"""Append explicitly authored bone anatomy to the saved native lower part.

This never consumes any discarded voxel geometry or segmentation cache.
"""
from build_a_manual_lower_20261023 import Model,VERTS,NORMAL,uid,H,P,R,Rotation
from pathlib import Path
from PIL import Image
import numpy as np,json,copy,math,base64,hashlib,sys

SRC=P/'阶段一_静态模型/手工重建_下衣与双足_20261023/A_下衣与双足_手工分部.bbmodel'
D=P/'阶段一_静态模型/手工重建_骨质常驻主体_20261023';D.mkdir(exist_ok=True)
TITLE='A_骨质常驻主体_手工重建'

def start():
 m=Model();m.bb=json.loads(SRC.read_text(encoding='utf8'));m.bb['name']=TITLE
 gs={g['uuid']:g for g in m.bb['groups']}
 def walk(ns):
  for v in ns:
   if isinstance(v,dict):m.nodes[gs[v['uuid']]['name']]=v;walk(v['children'])
 walk(m.bb['outliner']);m.groups={g['name']:g for g in m.bb['groups']}
 for name,g in m.groups.items():m.world[name]=(Rotation.from_euler('xyz',g.get('rotation',[0,0,0]),degrees=True).as_matrix(),np.array(g['origin'],float))
 # Embedded originals are copied to this project folder with repaired relative
 # references, so the new editable part remains movable as a single directory.
 for t in m.bb['textures']:
  raw=base64.b64decode(t['source'].split(',',1)[1]);(D/t['name']).write_bytes(raw);t['path']=str(D/t['name']);t['relative_path']=t['name']
 return m

def localbox(m,name,group,origin,a,b,mat='ivory'):
 o=np.array(origin,float);m.box(name,group,o+np.array(a,float),o+np.array(b,float),'upper_bone',mat)

def beam(m,name,parent,a,b,width,depth=None,mat='ivory',family=None):
 a=np.array(a,float);b=np.array(b,float);yy=b-a;length=np.linalg.norm(yy);yy/=length
 xx=np.cross(yy,[0,0,1]);
 if np.linalg.norm(xx)<.1:xx=np.cross(yy,[1,0,0])
 xx/=np.linalg.norm(xx);zz=np.cross(xx,yy);matrix=np.column_stack([xx,yy,zz]);center=(a+b)/2
 # Discrete hand-authored ribs, spurs and fingers. Groups are explicit and
 # editable; performance is reported as an unfinished static-stage cost.
 m.oriented_box(name,parent,center,[width,length+.055,depth or width],matrix,'upper_bone',mat)

def torso(m):
 for name,parent,o in [('waist','pelvis',[-.35,25.5,-6.9]),('chest','waist',[-.35,30.3,-6.7]),('neck','chest',[-.35,33.45,-7.25]),('head','neck',[-.35,34.0,-7.7])]:m.group(name,parent,o)
 # Narrow retained dark tissue behind the open rib cage. These are actual
 # closed volumes with sides/back, not a texture plane filling every rib gap.
 for i,(a,b)in enumerate([
  ([-1.0,24.75,-7.3],[.5,27.0,-5.5]),
  ([-1.15,26.6,-6.8],[.45,29.2,-5.3]),
  ([-1.3,28.9,-6.3],[.6,32.3,-4.85]),
  ([-.95,32.0,-7.0],[.2,35.1,-5.8])]):m.box(f'dark_spinal_tissue_{i}','chest',a,b,'upper_bone','marrow')
 # Source chest obliquity: the model-right side is farther forward than left.
 outline=np.array([[-.35,-.18,-9.45],[1.45,.05,-9.25],[3.50,.5,-8.7],[4.5,.62,-7.55],[3.55,.05,-5.75],[-.35,-.2,-4.8],[-3.15,.0,-4.0],[-4.7,.55,-4.65],[-4.2,.5,-6.5],[-2.35,.1,-8.45]],float)
 ctr=np.array([-.35,0,-6.85]);levels=[(32.15,1.0),(31.18,.98),(30.21,.90),(29.24,.82),(28.27,.72),(27.36,.59)]
 for edge in range(len(outline)):
  va=outline[edge]-ctr;vb=outline[(edge+1)%len(outline)]-ctr;xx=vb-va;xx/=np.linalg.norm(xx);yy=np.array([0,1.,0]);yy-=xx*(xx@yy);yy/=np.linalg.norm(yy);zz=np.cross(xx,yy);rr=np.column_stack([xx,yy,zz]);origin=np.array([ctr[0],30.0,ctr[2]]);group=f'rib_curve_{edge:02d}';m.group(group,'chest',origin,rr)
  for row,(y,scale)in enumerate(levels):
   aa=ctr+va*scale;bb=ctr+vb*scale;q=np.array([aa+[0,y,0],bb+[0,y,0]]);q=(q-origin)@rr+origin;lo=q.min(0);hi=q.max(0);lo[1]-=.19;hi[1]+=.19;lo[2]-=.20;hi[2]+=.20;lo[0]-=.055;hi[0]+=.055;m.box(f'rib_{row}_{edge}',group,lo,hi,'upper_bone','ivory')
 # Continuous sternum and spine are slender, with ribs touching through bone
 # thickness. Large spaces remain visible between each pair of ribs.
 beam(m,'sternum_upper','chest',[-.35,33.15,-9.4],[-.35,29.4,-9.25],.46,.43)
 beam(m,'sternum_lower','chest',[-.35,29.45,-9.25],[-.35,26.45,-8.2],.42,.40)
 for i in range(7):
  y=25.2+i*1.27;z=-5.15+(y-30)*.10;m.box(f'back_vertebra_{i}','chest',[-.78,y,z-.4],[.12,y+.78,z+.43],'upper_bone','aged')
 for side,sgn in [('r',1),('l',-1)]:
  x0=-.35;z0=-7.1
  # A restrained pelvic crest anchors the robe and waist without inventing
  # naked legs beneath the unknown lower clothing.
  beam(m,f'pelvic_crest_{side}_a','waist',[x0+sgn*.6,25.5,z0-1.15],[x0+sgn*2.0,26.0,z0-1.0],.49,.40,'aged')
  beam(m,f'pelvic_crest_{side}_b','waist',[x0+sgn*2.0,26.0,z0-1],[x0+sgn*3.0,25.1,z0+.1],.50,.45,'aged')
  beam(m,f'collar_{side}','chest',[-.35,33.1,-7.4],[4.65 if sgn>0 else -4.65,31.8,-7.45 if sgn>0 else -3.8],.59,.58)

def head(m):
 # Actual head/neck core tapers at the middle and flares near the cheek roots
 # and crown connection. No human face, eyes, hood cylinder or crown bar.
 o=np.array([-.35,34,-7.7]);m.group('head_dark_core','head',o)
 for i,(a,b)in enumerate([([-1.15,-.05,-.5],[1.0,1.65,1.75]),([-.79,1.5,-.13],[.65,3.8,1.76]),([-.68,3.65,.35],[.57,6.3,2.05])]):localbox(m,f'head_inner_{i}','head_dark_core',o,a,b,'marrow')
 # Four peripheral pale surfaces: each is a volumetric cheek/trunk band with
 # a deliberate opening instead of a solid wall across the whole skull.
 paths={
 'right_front':[[2.4,0,-1.1],[1.45,1.4,-.85],[.7,3.1,-.2],[1.25,4.7,.25],[2.7,6.0,.65]],
 'left_front':[[-2.55,.1,-.9],[-1.55,1.6,-.65],[-.85,3.2,-.1],[-1.45,4.65,.55],[-2.6,5.7,1.15]],
 'right_back':[[2.5,0,1.9],[1.6,1.55,1.8],[.95,3.2,1.85],[1.55,4.8,2.2],[2.6,6.05,2.5]],
 'left_back':[[-2.4,0,1.8],[-1.55,1.6,1.85],[-1.0,3.2,1.95],[-1.65,4.8,2.4],[-2.6,5.8,2.7]],
 }
 for name,points in paths.items():
  for i,(a,b)in enumerate(zip(points[:-1],points[1:])):beam(m,f'head_{name}_{i}','head',o+a,o+b,.53 if i<2 else .67,.42)
 # Back membranes are thick enough to give a three-dimensional covered trunk,
 # but leave two long side gaps between their bony supports.
 for side,sgn in [('r',1),('l',-1)]:
  beam(m,'head_side_edge_'+side,'head',o+[sgn*1.0,2.0,1.4],o+[sgn*.7,5.3,2.1],.72,.62,'ivory')
 beam(m,'head_front_midline','head',o+[-.13,.1,-1.4],o+[-.15,4.9,.55],.27,.30,'aged')
 # Low cheek returns and tapered upper prongs follow source landmarks, not
 # arbitrary facial ornaments. The independent top apparatus is still absent.
 for side,sgn in [('r',1),('l',-1)]:
  beam(m,'head_jaw_return_'+side,'head',o+[sgn*2.35,.1,-.8],o+[sgn*1.35,.65,.05],.49,.42)
  beam(m,'head_prong_'+side,'head',o+[sgn*2.65,5.7,1.0],o+[sgn*2.7,6.85,1.35],.38,.33)
 # Continuous side/back covering over the retained core. The previous wire-only
 # study was too skeletal: the source is a stretched covered neck/head volume.
 # Four sided bands follow a hand-traced hourglass profile, with real thickness.
 head_sections=[(0,2.32,-.8,1.75),(1.5,1.40,-.5,1.7),(3.1,.87,.0,1.85),(4.65,1.40,.5,2.25),(5.75,2.55,.9,2.65)]
 for side,sgn in [('r',1),('l',-1)]:
  for row,(a,b)in enumerate(zip(head_sections[:-1],head_sections[1:])):
   ya,wa,za,ba=a;yb,wb,zb,bb=b
   # A narrow lower opening remains on each cheek; the rest is a coherent
   # covered side that cannot be mistaken for detached horns or wire anatomy.
   fronta=o+[sgn*wa,ya,za+.3];frontb=o+[sgn*wb,yb,zb+.3];backa=o+[sgn*wa*.83,ya,ba];backb=o+[sgn*wb*.83,yb,bb]
   q=np.array([fronta,frontb,backa,backb]);up=(frontb-fronta+backb-backa)/2;up/=np.linalg.norm(up);across=(backa-fronta+backb-frontb)/2;across-=up*(across@up);across/=np.linalg.norm(across);normal=np.cross(across,up);rr=np.column_stack([across,up,normal]);pivot=q.mean(0);g=f'head_cover_{side}_{row}';m.group(g,'head',pivot,rr);local=(q-pivot)@rr+pivot;lo=local.min(0);hi=local.max(0);lo[2]-=.105;hi[2]+=.105
   if row==0:lo[1]+=.40
   m.box(g+'_surface',g,lo,hi,'upper_bone','ivory')
 # Central back membrane joins the two side coverings without closing the
 # dark front groove or adding eyes/face features not present in the source.
 for row,(a,b)in enumerate(zip(head_sections[:-1],head_sections[1:])):
  ya,wa,za,ba=a;yb,wb,zb,bb=b;center=o+[0,(ya+yb)/2,(ba+bb)/2];m.oriented_box(f'head_back_cover_{row}','head',center,[(wa+wb)*.77,yb-ya+.06,.22],Rotation.from_euler('x',math.degrees(math.atan2(bb-ba,yb-ya)),degrees=True).as_matrix(),'upper_bone','ivory')
 # Front covering is a continuous tapered surface too. The dark, stretched
 # central groove is painted on it, following the source's covered face/trunk.
 # Leaving only four perimeter beams produced a wire X, not the actual head.
 for row,(a,b)in enumerate(zip(head_sections[:-1],head_sections[1:])):
  ya,wa,za,ba=a;yb,wb,zb,bb=b;rr=Rotation.from_euler('x',math.degrees(math.atan2(zb-za,yb-ya)),degrees=True).as_matrix();pivot=o+[0,(ya+yb)/2,(za+zb)/2-.10];g=f'head_front_cover_{row}';m.group(g,'head',pivot,rr)
  for half in range(2):
   ta=half/2;tb=(half+1)/2;w0=wa*(1-ta)+wb*ta;w1=wa*(1-tb)+wb*tb;z0=za*(1-ta)+zb*ta;z1=za*(1-tb)+zb*tb;y0=ya*(1-ta)+yb*ta;y1=ya*(1-tb)+yb*tb
   for col in range(3):
    u0=col/3*2-1;u1=(col+1)/3*2-1;q=np.array([o+[w0*u0,y0,z0-.10],o+[w0*u1,y0,z0-.10],o+[w1*u0,y1,z1-.10],o+[w1*u1,y1,z1-.10]]);local=(q-pivot)@rr+pivot;lo=local.min(0);hi=local.max(0);lo[0]-=.02;hi[0]+=.02;lo[1]-=.025;hi[1]+=.025;lo[2]-=.11;hi[2]+=.11;m.box(f'head_front_surface_{row}_{half}_{col}',g,lo,hi,'upper_bone','head_cover')
 # The narrow retained neck has no loose frame rods attached to the head group.
 localbox(m,'neck_base','neck',o,[-.85,-.5,.05],[.75,.55,1.65],'aged')

def arm_frame(s,e):
 yy=np.array(s)-e;yy/=np.linalg.norm(yy);xx=np.cross(yy,[0,0,1]);xx/=np.linalg.norm(xx);zz=np.cross(xx,yy);return np.column_stack([xx,yy,zz])

def arm(m,side,s,e,w):
 s,e,w=map(lambda x:np.array(x,float),(s,e,w));upper='upperarm_'+side;fore='forearm_'+side;hand='hand_'+side
 for name,parent,o in [(upper,'chest',s),(fore,upper,e),(hand,fore,w)]:m.group(name,parent,o)
 ru=arm_frame(s,e);rf=arm_frame(e,w);lu=np.linalg.norm(s-e);lf=np.linalg.norm(e-w)
 m.group(upper+'_shaft',upper,s,ru);m.group(fore+'_shaft',fore,e,rf)
 # Narrow closed limb volumes. The shell is distinct from the central shaft;
 # the overall bone guard diameter is approximately 2.6, not the old thick arm.
 for part,o,rr,ll,g in [('upper',s,ru,lu,upper+'_shaft'),('fore',e,rf,lf,fore+'_shaft')]:
  for j in range(3):
   ya=-ll*(j+1)/3;yb=-ll*j/3+.07;rad=[.58,.66,.50][j]if part=='upper'else[.60,.53,.45][j]
   localbox(m,f'{part}_{side}_core_{j}',g,o,[-rad,ya,-rad*.86],[rad,yb,rad*.86],'aged')
   localbox(m,f'{part}_{side}_side_r_{j}',g,o,[rad-.15,ya+.12,-rad*.5],[rad+.11,yb-.05,rad*.5])
   localbox(m,f'{part}_{side}_side_l_{j}',g,o,[-rad-.11,ya+.12,-rad*.5],[-rad+.15,yb-.05,rad*.5])
 # Spiral guard plates: one stable direction group per radial face, reused for
 # all three turns. The spaces between turns remain open in actual geometry.
 for k in range(8):
  theta=45*k;rm=Rotation.from_euler('y',theta,degrees=True).as_matrix();g=f'guard_{side}_radial_{k}';m.group(g,fore,e,rf@rm)
  for row,(y,radius)in enumerate([(-.65,1.28),(-2.35,1.08),(-4.15,.88)]):
   # A gap in the far rear rim is intentional and corresponds to the open
   # C-shaped bone scrolls; a continuous slender shaft supports them inside.
   if(row==0 and k==4)or(row==1 and k==1):continue
   yy=y-.26*math.sin(math.radians(theta+row*40));ww=radius*.43
   localbox(m,f'guard_{side}_scroll_{row}_{k}',g,e,[-ww,yy-.23,radius-.14],[ww,yy+.23,radius+.14])
  # A thin, coherent long plate joins two neighboring C-scrolls on one flank.
  if k in [2,3,4]:
   localbox(m,f'guard_{side}_long_plate_{k}',g,e,[-.44,-3.5,.84],[.44,-.9,1.04])
 # Tapered hooked bone on the outer forearm; attached to the guard, never cloth.
 outer=1 if side=='r'else -1
 hook=[np.array([outer*.9,-2.6,.4]),np.array([outer*1.45,-2.1,.5]),np.array([outer*1.5,-1.3,.45])]
 for i,(a,b)in enumerate(zip(hook[:-1],hook[1:])):beam(m,f'guard_{side}_hook_{i}',fore,e+rf@a,e+rf@b,.30 if i else .43,.32)
 # Thin bony upper-arm bands and a genuine elbow bulb, rather than heavy cloth
 # or a solid limb/coat capsule.
 for part,org,rr,rad,y in [('upper',s,ru,.85,-1.5),('upperlow',s,ru,.75,-3.4)]:
  for k in [0,2,4,6]:
   g=f'{part}_{side}_rim_{k}';rot=rr@Rotation.from_euler('y',k*45,degrees=True).as_matrix();m.group(g,upper,org,rot);localbox(m,g+'_bone',g,org,[-rad*.9,y-.21,rad-.16],[rad*.9,y+.21,rad+.12])
 localbox(m,f'elbow_{side}',fore+'_shaft',e,[-.71,-.42,-.62],[.71,.38,.66],'aged')
 # Closed palm; the claws are separate branches with connected knuckles.
 m.group(hand+'_palm',hand,w,rf);localbox(m,f'palm_{side}',hand+'_palm',w,[-.94,-1.25,-.38],[.94,.1,.56],'aged')
 for k,xx in enumerate([-.78,-.25,.28,.79]):
  localbox(m,f'knuckle_{side}_{k}',hand+'_palm',w,[xx-.20,-1.48,-.48],[xx+.20,-.85,.34])
  length=[3.45,4.05,3.85,3.2][k]
  pts=[np.array([xx,-1.25,-.1]),np.array([xx*1.35,-2.18,-1.0]),np.array([xx*1.56,-length+.45,-.8]),np.array([xx*1.35,-length,.10])]
  for j,(a,b)in enumerate(zip(pts[:-1],pts[1:])):beam(m,f'claw_{side}_{k}_{j}',hand,w+rf@a,w+rf@b,[.29,.25,.15][j],[.34,.26,.16][j],'aged')
 thumb=[np.array([-1.,-.25,.1]),np.array([-1.65,-1.25,-.3]),np.array([-1.5,-2.25,-.9]),np.array([-1.13,-2.8,-.75])]
 for j,(a,b)in enumerate(zip(thumb[:-1],thumb[1:])):beam(m,f'thumb_{side}_{j}',hand,w+rf@a,w+rf@b,[.35,.27,.16][j],None,'aged')

def paint(m):
 # Model-space pixel painting: broad ivory structure with restrained worn seams.
 # No normal/PBR image is mislabeled as a Minecraft texture.
 faces=sorted(m.faces,key=lambda x:-x['h']);batches=[];batch=[];x=y=rh=0
 for ent in faces:
  ww,hh=ent['w']+2,ent['h']+2
  if x+ww>512:x=0;y+=rh;rh=0
  if y+hh>512:batches.append(batch);batch=[];x=y=rh=0
  ent['xy']=(x+1,y+1);batch.append(ent);x+=ww;rh=max(rh,hh)
 if batch:batches.append(batch)
 for batch in batches:
  ti=len(m.bb['textures']);atlas=Image.new('RGBA',(512,512))
  for e in batch:
   q=e['q'];w,h=e['w'],e['h'];uu,vv=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);points=q[0]+uu[:,:,None]*(q[3]-q[0])+vv[:,:,None]*(q[1]-q[0]);xx,yy,zz=points.transpose(2,0,1)
   grain=((np.floor(xx*4)*13+np.floor(yy*4)*7+np.floor(zz*4)*11)%9-4)*.50
   var=2.8*np.sin(xx*1.4+yy*.7+zz*1.2)+1.5*np.cos(yy*1.9+xx*.8)
   # Seams are painted as restrained, irregular thin mineral striations,
   # not thick black stripes masquerading as missing model geometry.
   vein=np.sin(xx*2.4+zz*2+yy*.3)+.32*np.sin(yy*2.2+xx*3.1)
   crack=np.maximum(0,.08-np.abs(vein))*85
   base=np.array([203,195,181])if e['material']in ['ivory','head_cover']else np.array([155,143,129])
   rgb=base[None,None,:]+(grain+var-crack)[:,:,None]
   edge=(np.minimum.reduce([uu,1-uu,vv,1-vv])<.06);rgb[edge]-=3
   if e['material']=='marrow':
    wav=4*np.sin(xx*7+zz*2.2+yy*.1)+grain*.5;rgb=np.stack([32+wav,29+wav,31+wav],2)
   if e['material']=='head_cover':
    groove_width=np.maximum(.12,(38.6-yy)*.23);groove=np.exp(-((xx+.45+.08*np.sin(yy*1.4))/groove_width)**4);striations=8*np.sin(xx*9+yy*.34+zz*2)+grain
    shadow=np.stack([47+striations,39+striations,37+striations],2);rgb=rgb*(1-groove[:,:,None]) +shadow*groove[:,:,None]
   patch=np.zeros((h,w,4),np.uint8);patch[:,:,:3]=np.clip(rgb,0,255);patch[:,:,3]=255;px,py=e['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1));e['e']['faces'][e['fa']]={'uv':[px,py,px+w,py+h],'texture':ti}
  name=f'a_manual_body_bone_{ti}_512.png';atlas.save(D/name);m.bb['textures'].append({'name':name,'id':str(ti),'uuid':uid('tex/'+name),'path':str(D/name),'relative_path':name,'width':512,'height':512,'uv_width':512,'uv_height':512,'render_mode':'default','render_sides':'auto','internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode((D/name).read_bytes()).decode()})

def save(m):
 bb=m.bb;(D/(TITLE+'.bbmodel')).write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8');aj=json.loads((H/'切换参考前_在场工程完整备份.ajblueprint').read_text(encoding='utf8'))
 for k in ['name','elements','groups','outliner','textures','resolution']:aj[k]=copy.deepcopy(bb[k])
 aj['animations']=[];aj['meta'].update(uuid=uid('manual-body-project'),save_location=str(D/(TITLE+'.ajblueprint')))
 for e in aj['elements']:
  for face in e['faces'].values():
   if face['texture']is not None:face['texture']=aj['textures'][face['texture']]['uuid']
 (D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
 original=json.loads(SRC.read_text(encoding='utf8'));old={e['uuid']:e for e in original['elements']};now={e['uuid']:e for e in bb['elements']};assert all(now[k]==e for k,e in old.items())
 report={'source_lower_project':str(SRC),'lower_project_sha256':hashlib.sha256(SRC.read_bytes()).hexdigest(),'source_lower_elements_preserved':len(old),'cubes':len(bb['elements']),'groups':len(bb['groups']),'defined_faces':sum(face['texture']is not None for e in bb['elements']for face in e['faces'].values()),'textures':len(bb['textures']),'texture_dimensions':[512,512],'animations':0,'voxelization':False,'discarded_voxel_cubes_reused':0,'body_stage_draft':True,'upper_dissolvable_cloth_created':False,'rear_hard_frame_created':False,'whole_static_finished':False,'game_deployed':False,'game_tested':False}
 (D/'手工主体统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
def build():
 m=start();torso(m);head(m);arm(m,'r',[4.7,31,-7.5],[6.6,27,-9.2],[8.2,22.5,-12]);arm(m,'l',[-4.8,31,-3.4],[-7.4,27,.1],[-8.5,22.5,3.9]);paint(m);save(m)
if __name__=='__main__':raise SystemExit('Failed A draft. Generic ribs / head / guards did not reproduce the actual source. Do not regenerate.')
