"""Authored A lower garment and two feet. No voxelization / source-role masks.

Explicit silhouette stations are traced from the complete normalized high GLB.
The original triangles are consulted for texture colour only, never converted
into cubes. This is a lower-body part, not a finished character.
"""
from pathlib import Path
import numpy as np,json,math,uuid,copy,base64,sys,io
from PIL import Image
R=Path('D:/数据包');P=R/'模型设计/A_骨白幽魂_GLB重建_20261022';H=P/'高模母版_20261023'
D=P/'阶段一_静态模型/手工重建_下衣与双足_20261023';D.mkdir(exist_ok=True)
sys.path.insert(0,str(R/'.workbuddy/tools/a_mesh_deps'))
from scipy.spatial.transform import Rotation
from scipy.spatial import cKDTree

TITLE='A_下衣与双足_手工分部'
VERTS={'north':[(1,1,0),(1,0,0),(0,0,0),(0,1,0)],'south':[(0,1,1),(0,0,1),(1,0,1),(1,1,1)],'east':[(1,1,1),(1,0,1),(1,0,0),(1,1,0)],'west':[(0,1,0),(0,0,0),(0,0,1),(0,1,1)],'up':[(0,1,0),(0,1,1),(1,1,1),(1,1,0)],'down':[(0,0,1),(0,0,0),(1,0,0),(1,0,1)]}
NORMAL={'north':[0,0,-1],'south':[0,0,1],'east':[1,0,0],'west':[-1,0,0],'up':[0,1,0],'down':[0,-1,0]}
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:A/manual-lower/20261023/'+s))

class Model:
 def __init__(self):
  self.bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':TITLE,'resolution':{'width':512,'height':512},'elements':[],'groups':[],'outliner':[],'textures':[],'animations':[]};self.nodes={};self.groups={};self.world={};self.faces=[];self.cubes={}
 def group(self,name,parent,pivot,rotation=None):
  rot=np.eye(3)if rotation is None else np.array(rotation,float);origin=np.array(pivot,float)
  # New groups are siblings under neutral logical parents. No accumulated
  # Euler drift and no artificial limb transformations are introduced.
  g={'name':name,'uuid':uid('g/'+name),'origin':origin.round(6).tolist(),'rotation':Rotation.from_matrix(rot).as_euler('xyz',degrees=True).round(6).tolist(),'visibility':True,'export':True,'color':5,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}}
  node={'uuid':g['uuid'],'children':[],'isOpen':False};self.nodes[name]=node;self.groups[name]=g;self.bb['groups'].append(g);(self.nodes[parent]['children']if parent else self.bb['outliner']).append(node);self.world[name]=(rot,origin)
 def box(self,name,group,a,b,role='cloth',material='surface',faces=None):
  assert name not in self.cubes,'Duplicate authored element: '+name
  a=np.array(a,float);b=np.array(b,float);assert np.all(b>a),(name,a,b)
  e={'name':name,'uuid':uid('e/'+name),'type':'cube','from':a.round(6).tolist(),'to':b.round(6).tolist(),'origin':((a+b)/2).round(6).tolist(),'rotation':[0,0,0],'rescale':False,'shade':True,'box_uv':False,'visibility':True,'export':True,'faces':{fa:{'texture':None,'uv':[0,0,1,1]}for fa in VERTS}}
  self.bb['elements'].append(e);self.nodes[group]['children'].append(e['uuid']);self.cubes[name]={'e':e,'role':role,'material':material,'group':group}
  rr,o=self.world[group]
  for fa in (faces or VERTS):
   q=(np.array(VERTS[fa])*(b-a)+a-o)@rr.T+o
   self.faces.append({'e':e,'fa':fa,'q':q,'normal':np.array(NORMAL[fa])@rr.T,'w':max(2,math.ceil(np.linalg.norm(q[3]-q[0])*4.0)),'h':max(2,math.ceil(np.linalg.norm(q[1]-q[0])*4.0)),'role':role,'material':material})
 def oriented_box(self,name,parent,center,size,matrix,role='bone',material='surface'):
  self.group(name+'_axis',parent,center,matrix);c=np.array(center,float);self.box(name,name+'_axis',c-np.array(size)/2,c+np.array(size)/2,role,material)

# Cross sections: x,z pairs, front seam -> model-right flank -> back -> left
# flank. The crease shifts and the rear hem is asymmetric; these are not polar
# samples of an ellipse. Front is -Z, the right boot is at positive X.
STATIONS=np.array([
 [[-.9,-10.0],[.25,-9.7],[1.15,-9.05],[1.65,-8.0],[1.45,-6.8],[1.1,-5.0],[.25,-4.25],[-1.05,-3.9],[-2.45,-4.15],[-3.7,-4.95],[-4.35,-6.1],[-4.0,-7.45],[-3.65,-8.5],[-2.35,-9.5]],
 [[-1.05,-10.8],[.35,-10.25],[1.75,-9.2],[2.0,-7.75],[1.8,-6.15],[1.3,-4.6],[.1,-3.45],[-1.3,-3.0],[-2.8,-3.5],[-4.3,-4.65],[-5.1,-6.4],[-4.8,-7.6],[-4.05,-9.2],[-2.7,-10.05]],
 [[-1.25,-11.65],[.4,-10.85],[2.0,-9.4],[2.3,-7.7],[1.7,-5.95],[1.0,-4.25],[-.05,-2.0],[-1.55,-1.2],[-3.2,-2.1],[-4.75,-4.0],[-5.75,-6.5],[-5.2,-8.05],[-4.45,-9.9],[-2.95,-10.9]],
 [[-1.6,-12.75],[.4,-11.55],[2.0,-9.8],[2.6,-7.9],[1.75,-5.65],[1.15,-3.65],[-.1,-.25],[-1.75,.7],[-3.45,-.7],[-5.1,-3.7],[-6.45,-6.6],[-5.6,-8.45],[-4.7,-10.55],[-3.25,-11.65]],
 [[-1.9,-13.65],[.2,-12.2],[1.8,-10.3],[2.55,-7.7],[1.8,-5.2],[1.0,-3.45],[-.3,.65],[-1.8,1.4],[-3.85,-.55],[-5.8,-3.8],[-6.85,-6.55],[-5.85,-8.65],[-4.8,-11.1],[-3.3,-12.6]],
],float)
YS=np.array([24.7,21.0,17.0,13.0,8.7])
HEM=np.array([[-2.25,1.2,-15.05],[-.65,3.2,-13.0],[1.15,5.1,-10.7],[2.15,6.4,-7.8],[1.5,5.4,-4.9],[.65,6.2,-2.95],[-.35,4.8,1.5],[-2.0,5.0,2.0],[-4.2,3.7,-.55],[-6.25,1.9,-4.0],[-6.7,1.2,-6.55],[-5.75,3.3,-8.7],[-4.65,2.2,-11.55],[-3.55,.9,-13.85]],float)

def garment(m):
 m.group('root',None,[0,0,0]);m.group('pelvis','root',[-.35,24.7,-6.9]);m.group('retained_lower_garment','pelvis',[-.35,24.7,-6.9])
 rings=np.concatenate([np.stack([STATIONS[:,:,0],np.broadcast_to(YS[:,None],STATIONS.shape[:2]),STATIONS[:,:,1]],axis=2),HEM[None]],axis=0)
 (D/'手工下衣轮廓站点.json').write_text(json.dumps({'front':'-Z','section_levels':YS.tolist(),'cross_sections_xz':STATIONS.tolist(),'hem_xyz':HEM.tolist(),'source':'complete corrected high GLB, explicit manual tracing','no_voxelization':True},ensure_ascii=False,indent=2),encoding='utf8')
 # Four stable direction groups per edge (joint budget 56 at this prototype
 # stage). Each contains several adjacent slats. Their silhouette is authored,
 # rather than rounded source voxels; gentle bends stay inside the fabric.
 for edge in range(14):
  other=(edge+1)%14
  for zone,(ra,rb)in enumerate([(0,1),(1,2),(2,3),(3,5)]):
   top=(rings[ra,edge]+rings[ra,other])/2;bottom=(rings[rb,edge]+rings[rb,other])/2
   yy=top-bottom;yy/=np.linalg.norm(yy);xx=(rings[ra,other]-rings[ra,edge]+rings[rb,other]-rings[rb,edge])/2;xx-=yy*(xx@yy);xx/=np.linalg.norm(xx);zz=np.cross(xx,yy);zz/=np.linalg.norm(zz);rr=np.column_stack([xx,yy,zz]);pivot=top
   group=f'robe_fold_{edge:02d}_span_{zone}';m.group(group,'retained_lower_garment',pivot,rr)
   # Two bands per station interval ensure the actual sloping trapezoids close.
   # Taper and curvature are expressed by coherent surfaces, not floating tips.
   for row in range(ra,rb):
    for half in range(2):
     ta=half/2;tb=(half+1)/2;al=rings[row,edge]*(1-ta)+rings[row+1,edge]*ta;ar=rings[row,other]*(1-ta)+rings[row+1,other]*ta;bl=rings[row,edge]*(1-tb)+rings[row+1,edge]*tb;br=rings[row,other]*(1-tb)+rings[row+1,other]*tb
     # Divide very wide outer flanks once across their width; this is a modelling
     # decision per cloth panel, independent of any source point density.
     cols=2 if edge in [0,6,8,9,12,13]else 1
     for col in range(cols):
      t0=col/cols;t1=(col+1)/cols
      corners=np.array([al*(1-t0)+ar*t0,al*(1-t1)+ar*t1,bl*(1-t0)+br*t0,bl*(1-t1)+br*t1]);local=(corners-pivot)@rr+pivot
      # Cuboids overlap only through narrow joining margins. One broad face
      # follows the fold; cloth always has visible thickness and a reverse face.
      lo=local.min(0);hi=local.max(0);midz=(lo[2]+hi[2])/2;thick=max(.15,min(.34,hi[2]-lo[2]+.13));lo[2]=midz-thick/2;hi[2]=midz+thick/2;lo[:2]-=.028;hi[:2]+=.028
      m.box(f'cloth_fold_{edge:02d}_{row}_{half}_{col}',group,lo,hi,'cloth')
 # The upper waistband is closed, while the bottom remains open around the
 # feet. No invented hidden human legs or solid skirt filling is added.
 m.box('waist_inner_join','retained_lower_garment',[-3.8,24.25,-8.65],[.8,25.05,-5.3],'cloth','seam')

def foot(m,side,x,z,yaw):
 parent='foot_'+side;origin=np.array([x,7.9,z]);rr=Rotation.from_euler('y',yaw,degrees=True).as_matrix();m.group(parent,'pelvis',origin,rr)
 # All coordinates below are authored around a full local sole. Toe faces -Z.
 # Source bone volumes are reduced to stable anatomical layers; no additional
 # foot columns or bases from the AI mesh are reproduced.
 def b(name,a,c,mat='surface'):
  m.box(side+'_'+name,parent,np.array(a)+origin,np.array(c)+origin,'bone',mat)
 # Sole in stepped plan; it extends under toe, ball, arch and heel.
 b('sole_center',[-1.03,-7.85,-4.8],[1.03,-7.43,1.05],'sole')
 b('sole_toe',[-.84,-7.84,-5.5],[.84,-7.40,-4.65],'sole')
 b('sole_outer_ball',[-1.24,-7.84,-3.5],[1.24,-7.41,-1.1],'sole')
 b('heel',[-1.02,-7.85,.75],[1.02,-6.5,1.85],'sole')
 b('arch',[-.97,-7.49,-1.7],[.97,-6.48,1.45])
 # Toe / instep taper: sides and rear are geometry, not texture silhouettes.
 b('toe_top',[-.79,-7.4,-5.28],[.79,-6.86,-3.82])
 b('toe_upper',[-.94,-7.37,-4.45],[.94,-6.57,-2.45])
 b('forefoot',[-1.14,-7.38,-3.48],[1.14,-6.17,-1.32])
 b('instep_low',[-1.10,-6.57,-2.9],[1.10,-5.55,-.38])
 b('instep_high',[-.94,-5.69,-1.92],[.94,-4.8,.56])
 b('ankle',[-.9,-5.0,-.9],[.9,-2.35,1.20])
 b('ankle_back',[-.73,-5.9,.45],[.73,-2.2,1.52])
 b('lower_shin',[-.78,-2.6,-.75],[.78,.15,.94])
 b('upper_shin',[-.88,-.05,-.80],[.88,1.15,.95])
 # Interleaved mineral/bone cuffs follow the foot rather than unrelated robe
 # islands. Each has a connected overlap with the closed ankle underneath.
 for i,(yy,width,depth)in enumerate([(-3.6,1.06,1.02),(-1.65,.94,.94),(.3,1.02,1.0)]):
  b(f'cuff_{i}_front',[-width,yy,-depth-.16],[width,yy+.42,-depth+.22])
  b(f'cuff_{i}_rear',[-width+.08,yy,depth-.1],[width-.08,yy+.42,depth+.22])
  b(f'cuff_{i}_side_r',[width-.24,yy,-depth],[width+.15,yy+.42,depth])
  b(f'cuff_{i}_side_l',[-width-.15,yy,-depth],[-width+.24,yy+.42,depth])
 # Small toe segments form a single complete foot rather than a boot cylinder.
 for i,(xx,w,zz)in enumerate([(-.64,.42,-5.4),(-.16,.46,-5.58),(.35,.44,-5.4),(.76,.30,-5.02)]):
  b(f'toe_segment_{i}',[xx-w/2,-7.38,zz],[xx+w/2,-6.96,zz+1.0])

def textures(m):
 # A source point colour sampler is restricted to the desired MATERIAL only;
 # it has no role in producing silhouettes, boxes, body completeness or UVs.
 z=np.load(H/'corrected_normalized.npz');p,n,u,f=z['p'],z['n'],z['uv'],z['f'];tex=np.array(Image.open(H/'source_map_1.png').convert('RGB'));rgb=tex[np.clip((u[:,1]*4096).astype(int),0,4095),np.clip((u[:,0]*4096).astype(int),0,4095)].astype(float)
 cloth=(p[:,1]>1)&(p[:,1]<25.5)&(abs(p[:,0])<7.5)&(p[:,2]<3.5)&(p[:,2]>-16)&(rgb[:,2]>rgb[:,0]+5)&(rgb.mean(1)<115)
 # Boot reference uses only the real retained forward boot. Its material is
 # reused on the completed rear foot; no pale outer frame is sampled.
 bone=(p[:,0]>1.3)&(p[:,0]<4.7)&(p[:,1]<9.8)&(p[:,2]<-7.2)&(p[:,2]>-15.4)&(abs(rgb[:,0]-rgb[:,2])<31)&(rgb.mean(1)>65)
 pts={'cloth':p[cloth],'bone':p[bone]};col={'cloth':rgb[cloth],'bone':rgb[bone]};trees={k:cKDTree(v)for k,v in pts.items()}
 def paint(ent):
  q=ent['q'];w,h=ent['w'],ent['h'];u0,v0=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);world=q[0]+u0[:,:,None]*(q[3]-q[0])+v0[:,:,None]*(q[1]-q[0]);flat=world.reshape(-1,3);kind=ent['role'];lookup=flat.copy()
  if kind=='bone'and ent['e']['name'].startswith('l_'):
   lookup[:,0]+=6.65;lookup[:,2]-=9.95
  _,ix=trees[kind].query(lookup);base=col[kind][ix].reshape(h,w,3)
  xx,yy,zz=world.transpose(2,0,1)
  if kind=='cloth':
   # Keep large folds coherent and suppress the bright ivory contamination
   # that occurred in the discarded nearest-surface body atlas.
   lumin=base.mean(2);detail=np.clip((lumin-60)*.28,-9,12)
   wave=3.2*np.sin(xx*2.8+zz*.8+yy*.05)+1.3*np.sin(xx*6.1-zz*.4)
   fade=np.clip((7-yy)/7,0,1);base=np.stack([29+detail+wave+fade*18,30+detail+wave+fade*12,45+detail+wave+fade*28],2)
   if ent['material']=='seam':base*=.83
  else:
   # Match the muted worn bone grey of the source. The pale chest and ivory
   # rear accessories are deliberately not used as foot material.
   lum=np.clip(base.mean(2),78,163);detail=(lum-120)*.37
   grain=((np.floor(xx*5)*3+np.floor(yy*5)*7+np.floor(zz*5)*5)%7-3)*.65
   base=np.stack([128+detail+grain,119+detail+grain,113+detail+grain],2)
   if ent['material']=='sole':base*=.57
  rgba=np.zeros((h,w,4),np.uint8);rgba[:,:,:3]=np.clip(base,0,255);rgba[:,:,3]=255;return rgba
 batches=[]
 for role in ['cloth','bone']:
  entries=sorted([v for v in m.faces if v['role']==role],key=lambda x:-x['h']);batch=[];x=y=rh=0
  for e in entries:
   w,h=e['w']+2,e['h']+2
   if x+w>512:x=0;y+=rh;rh=0
   if y+h>512:batches.append((role,batch));batch=[];x=y=rh=0
   e['xy']=(x+1,y+1);batch.append(e);x+=w;rh=max(rh,h)
  if batch:batches.append((role,batch))
 for ti,(role,entries)in enumerate(batches):
  atlas=Image.new('RGBA',(512,512))
  for ent in entries:
   patch=paint(ent);px,py=ent['xy'];w,h=ent['w'],ent['h'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1));ent['e']['faces'][ent['fa']]={'uv':[px,py,px+w,py+h],'texture':ti}
  name=f'a_manual_lower_{role}_{ti}_512.png';atlas.save(D/name);m.bb['textures'].append({'name':name,'id':str(ti),'uuid':uid('tex/'+name),'path':str(D/name),'relative_path':name,'width':512,'height':512,'uv_width':512,'uv_height':512,'render_mode':'default','render_sides':'auto','internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode((D/name).read_bytes()).decode()})

def save(m):
 bb=m.bb;(D/(TITLE+'.bbmodel')).write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
 # Reuse only native AJ document settings. All cubes, groups, textures, UVs,
 # UUIDs and hierarchy in this part have been authored anew above.
 aj=json.loads((H/'切换参考前_在场工程完整备份.ajblueprint').read_text(encoding='utf8'))
 for k in ['name','elements','groups','outliner','textures','resolution']:aj[k]=copy.deepcopy(bb[k])
 aj['animations']=[];aj['meta'].update(uuid=uid('project'),save_location=str(D/(TITLE+'.ajblueprint')))
 for e in aj['elements']:
  for face in e['faces'].values():
   if face['texture']is not None:face['texture']=aj['textures'][face['texture']]['uuid']
 (D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
 report={'part_only':'lower garment and two complete feet','cubes':len(bb['elements']),'groups':len(bb['groups']),'defined_faces':sum(f['texture']is not None for e in bb['elements']for f in e['faces'].values()),'textures':len(bb['textures']),'texture_dimensions':[512,512],'animations':0,'voxel_geometry':False,'old_cube_geometry_reused':0,'source_GLb_modified':False,'whole_body_finished':False,'upper_cloth_finished':False,'hard_frame_finished':False,'game_deployed':False,'game_tested':False}
 (D/'手工分部统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)

def build():
 m=Model();garment(m);foot(m,'r',3.1,-9.45,-4);foot(m,'l',-3.55,.35,8);textures(m);save(m)
if __name__=='__main__':raise SystemExit('Failed A draft. Do not regenerate or promote as an accepted model.')
