"""Authored Cube / Group reconstruction from the actual C GLB.
No mesh export, voxel fill, old character geometry or invented weapon is used.
"""
from pathlib import Path
import json,math,uuid,base64,sys,copy
import numpy as np
from PIL import Image
R=Path('D:/数据包');P=R/'模型设计/C_红披风铠甲_GLB重建_20261024';H=P/'母版分析';D=P/'阶段一_静态模型';D.mkdir(exist_ok=True)
sys.path.insert(0,str(R/'.workbuddy/tools/a_mesh_deps'))
from scipy.interpolate import PchipInterpolator
from scipy.spatial import cKDTree
from scipy.spatial.transform import Rotation
TITLE='C_红披风铠甲_静态'
src=np.load(H/'source.npz');sp,sn,su,sf,st=[src[k]for k in ['p','n','uv','f','texture']]
V={'north':[(1,1,0),(1,0,0),(0,0,0),(0,1,0)],'south':[(0,1,1),(0,0,1),(1,0,1),(1,1,1)],'east':[(1,1,1),(1,0,1),(1,0,0),(1,1,0)],'west':[(0,1,0),(0,0,0),(0,0,1),(0,1,1)],'up':[(0,1,0),(0,1,1),(1,1,1),(1,1,0)],'down':[(0,0,1),(0,0,0),(1,0,0),(1,0,1)]}
N={'north':[0,0,-1],'south':[0,0,1],'east':[1,0,0],'west':[-1,0,0],'up':[0,1,0],'down':[0,-1,0]}
def uid(v):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream/C/20261024/'+v))
class Model:
 def __init__(self):
  self.bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':TITLE,'resolution':{'width':512,'height':512},'elements':[],'groups':[],'outliner':[],'textures':[],'animations':[]};self.nodes={};self.trans={};self.geo=[];self.mat=[]
 def group(self,name,parent,origin,matrix=None):
  o=np.array(origin,float);r=np.eye(3)if matrix is None else matrix
  g={'name':name,'uuid':uid('g/'+name),'origin':o.tolist(),'rotation':Rotation.from_matrix(r).as_euler('xyz',degrees=True).round(6).tolist(),'visibility':True,'export':True,'color':4,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}};self.bb['groups'].append(g);node={'uuid':g['uuid'],'children':[],'isOpen':False};self.nodes[name]=node;(self.nodes[parent]['children']if parent else self.bb['outliner']).append(node);self.trans[name]=(r,o)
 def box(self,name,g,lo,hi,mat):
  lo,hi=np.array(lo,float),np.array(hi,float);assert np.all(hi>lo),(name,lo,hi)
  e={'name':name,'uuid':uid('e/'+name),'type':'cube','from':lo.round(5).tolist(),'to':hi.round(5).tolist(),'origin':((lo+hi)/2).round(5).tolist(),'rotation':[0,0,0],'rescale':False,'shade':True,'box_uv':False,'visibility':True,'export':True,'faces':{f:{'texture':None,'uv':[0,0,1,1]}for f in V}}
  self.bb['elements'].append(e);self.nodes[g]['children'].append(e['uuid']);self.geo.append((lo,hi,g));self.mat.append(mat)
 def curve(self,name,g,pts,widths,mat,step=.9):
  p=np.array(pts,float);w=np.array(widths,float)
  if w.ndim==0:w=np.full((len(p),3),w)
  elif w.ndim==1:w=np.repeat(w[:,None],3,axis=1)if len(w)==len(p)else np.tile(w,(len(p),1))
  t=np.r_[0,np.cumsum(np.linalg.norm(np.diff(p,axis=0),axis=1))];fp=PchipInterpolator(t,p,axis=0);fw=PchipInterpolator(t,w,axis=0);ss=np.linspace(0,t[-1],max(2,math.ceil(t[-1]/step)+1));q=fp(ss);ww=fw(ss)
  for i,(a,b)in enumerate(zip(q[:-1],q[1:])):
   h=(ww[i]+ww[i+1])/4;lo=np.minimum(a,b)-h;hi=np.maximum(a,b)+h;ax=np.argmax(abs(b-a));lo[ax]=min(a[ax],b[ax]);hi[ax]=max(a[ax],b[ax]);self.box(f'{name}_{i:02}',g,lo,hi,mat)
 def volume(self,name,g,rows,mat,step=1.25,bevel=.28):
  a=np.array(rows,float);a=a[np.argsort(a[:,0])];f=PchipInterpolator(a[:,0],a[:,1:],axis=0);ys=np.linspace(a[0,0],a[-1,0],math.ceil((a[-1,0]-a[0,0])/step)+1)
  for i,(y0,y1)in enumerate(zip(ys[:-1],ys[1:])):
   x,z,w,d=f((y0+y1)/2);b=min(w,d)*bevel;self.box(f'{name}_{i}_center',g,[x-w/2+b,y0,z-d/2],[x+w/2-b,y1,z+d/2],mat)
   for sg in [-1,1]:
    l,r=(x-w/2,x-w/2+b)if sg<0 else(x+w/2-b,x+w/2);self.box(f'{name}_{i}_edge_{sg}',g,[l,y0,z-d/2+b],[r,y1,z+d/2-b],mat)
 def surface(self,name,parent,rows,mat,thickness=.22,step=1.35,segments=3,holes=None):
  # Rows are y / left-x / left-z / right-x / right-z. Thickness is normal
  # to each cloth segment rather than a thick world-axis box.
  a=np.array(rows,float);a=a[np.argsort(a[:,0])];f=PchipInterpolator(a[:,0],a[:,1:],axis=0)
  def lr(y):
   l,zl,r,zr=f(y);return np.array([l,y,zl]),np.array([r,y,zr])
  cuts=np.linspace(a[0,0],a[-1,0],segments+1)
  for j,(yb,yt)in enumerate(zip(cuts[:-1],cuts[1:])):
   bl,br=lr(yb);al,ar=lr(yt);o=(al+ar+bl+br)/4;yy=(al+ar-bl-br)/2;yy/=np.linalg.norm(yy);xx=(ar-al+br-bl)/2;xx-=yy*(xx@yy);xx/=np.linalg.norm(xx);zz=np.cross(xx,yy);rr=np.column_stack([xx,yy,zz]);g=f'{name}_segment_{j}';self.group(g,parent,o,rr)
   length=np.linalg.norm((al+ar-bl-br)/2);ys=np.linspace(yb,yt,max(2,math.ceil(length/step)+1))
   for k,(b,t)in enumerate(zip(ys[:-1],ys[1:])):
    bl,br=lr(b);al,ar=lr(t);spans=[(0,1)];mid=(b+t)/2
    if holes:
     h0,h1,u,v=holes
     if h0<mid<h1:
      w=math.sin(math.pi*(mid-h0)/(h1-h0));c=(u+v)/2;rad=(v-u)*w/2;spans=[(0,c-rad),(c+rad,1)]
    for n,(u,v)in enumerate(spans):
     q=np.array([al*(1-u)+ar*u,al*(1-v)+ar*v,bl*(1-u)+br*u,bl*(1-v)+br*v]);q=(q-o)@rr+o;lo=q.min(0);hi=q.max(0);z=(lo[2]+hi[2])/2;lo[2]=z-thickness/2;hi[2]=z+thickness/2;lo[:2]-=.018;hi[:2]+=.018;self.box(f'{name}_{j}_{k}_{n}',g,lo,hi,mat)

def skeleton(m):
 for n,p,o in [('root',None,[1.1,0,0]),('pelvis','root',[1.1,25.1,-.3]),('waist','pelvis',[1.1,29,-.3]),('chest','waist',[1.1,35.0,0]),('neck','chest',[.9,40.0,.7]),('head','neck',[.8,42.5,.6]),('scarf','chest',[.9,40.4,.5]),('scarf_front','scarf',[-2.0,38,-3.1]),('belt','pelvis',[1.1,27.3,-.3]),('cape','chest',[1.1,39.7,4.4]),('front_tabard','pelvis',[1.1,25.5,-4.1])]:m.group(n,p,o)
 for side,s,e,w,h,k,a in [
 ('right',[7.0,37.5,.2],[9.0,30.7,-1.0],[9.4,24.7,-2.7],[4.0,25,-.4],[5.0,14.0,-3.4],[5.1,5.6,-1.7]),
 ('left',[-4.7,37.7,1.1],[-6.3,31.0,.1],[-7.3,24.7,-.7],[-1.8,25,-.2],[-3.0,14.2,-2.7],[-3.1,5.6,-1.1])]:
  for n,p,o in [('shoulder','chest',s),('upperarm','shoulder_'+side,s),('forearm','upperarm_'+side,e),('hand','forearm_'+side,w),('thigh','pelvis',h),('shin','thigh_'+side,k),('foot','shin_'+side,a)]:m.group(n+'_'+side,p,o)

def body(m):
 m.volume('pelvis_complete','pelvis',[(23.4,1.1,-.5,8.3,6.0),(25,1.1,-.25,9.0,6.5),(27.4,1.1,-.2,8.3,6.0)],'undercloth',1.3)
 m.volume('waist_complete','waist',[(27.1,1.1,-.2,8.1,5.9),(29.1,1.1,-.1,8.0,5.8),(31.1,1.0,.0,8.6,6.4)],'undercloth',1.3)
 m.volume('chest_complete','chest',[(30.8,1.0,.0,8.5,6.4),(34,1.0,.0,9.5,6.9),(37,1.0,.1,10.8,6.7),(38.9,.9,.5,8.0,5.7),(40.2,.9,.6,4.3,4.2)],'undercloth',1.35)
 # Solid front/back cuirass over a continuous dark inner torso.
 m.surface('cuirass_front','chest',[(29.7,-1.5,-3.05,3.9,-2.4),(31.5,-2.9,-3.7,5.0,-2.8),(34.2,-3.4,-3.95,5.9,-2.4),(37.6,-3.0,-3.1,5.7,-1.85),(38.3,-1.7,-2.5,4.9,-1.7)],'steel_chest',.7,1.0,1)
 m.surface('cuirass_back','chest',[(29.9,-2.2,2.65,4.7,2.65),(33.8,-3.1,3.2,5.5,3.2),(37.8,-3.6,3.3,5.7,3.3),(38.5,-2.6,2.8,4.5,2.8)],'steel',.65,1.3,1)
 m.volume('neck_complete','neck',[(39,.9,.65,3.0,3.4),(42.8,.9,.65,2.8,3.2)],'undercloth',1.3)
 # Closed black face beneath the characteristic pointed lower white visor.
 m.volume('helmet_dark_face','head',[(41.3,.9,-.1,1.9,2.6),(42.6,.85,.05,3.6,4.2),(44.6,.85,.25,4.8,5.1)],'face',.7,.20)
 m.volume('helmet_white_shell','head',[(44.3,.85,.40,5.1,5.35),(46.4,.85,.34,5.45,5.8),(47.5,.85,.18,4.85,5.15),(48.0,.85,.1,3.45,3.9)],'helmet',.62,.18)
 for i,(b,t,w,z)in enumerate([(43.2,43.65,.85,-2.60),(43.65,44.15,2.15,-2.72),(44.15,44.65,3.8,-2.71)]):m.box('helmet_pointed_face_'+str(i),'head',[.85-w/2,b,z-.18],[.85+w/2,t,z+.30],'helmet')
 # Paired articulated body volumes; the coat is not used to hide omissions.
 for side,s,e,w,sgn,hip,knee,ank in [
 ('right',[7.0,37.5,.2],[9.0,30.7,-1.0],[9.4,24.7,-2.7],1,[4.0,25,-.4],[5.0,14,-3.4],[5.1,5.6,-1.7]),
 ('left',[-4.7,37.7,1.1],[-6.3,31,.1],[-7.3,24.7,-.7],-1,[-1.8,25,-.2],[-3.0,14.2,-2.7],[-3.1,5.6,-1.1])]:
  s,e,w,hip,knee,ank=map(lambda q:np.array(q,float),(s,e,w,hip,knee,ank))
  upper='upperarm_'+side;fore='forearm_'+side;hand='hand_'+side
  m.volume('upperarm_complete_'+side,upper,[(e[1]-.6,*[e[0],e[2],3.2,3.5]),(34.5,(s[0]+e[0])/2,(s[2]+e[2])/2,3.8,4.0),(s[1]+.5,s[0],s[2],4.0,4.5)],'undercloth',1.35,.18)
  m.volume('forearm_complete_'+side,fore,[(w[1]-.35,w[0],w[2],2.7,3.0),(27.5,(e[0]+w[0])/2,(e[2]+w[2])/2,3.0,3.3),(e[1]+.25,e[0],e[2],3.0,3.3)],'undercloth',1.35,.18)
  for mat,zdelta,label in [('steel',-1.85,'front'),('steel',1.35,'back')]:
   m.surface('bracer_'+side+'_'+label,fore,[(24.55,w[0]-1.25,w[2]+zdelta,w[0]+1.25,w[2]+zdelta),(27.3,(e[0]+w[0])/2-1.55,(e[2]+w[2])/2+zdelta,(e[0]+w[0])/2+1.55,(e[2]+w[2])/2+zdelta),(30.35,e[0]-1.45,e[2]+zdelta,e[0]+1.45,e[2]+zdelta)],mat,.54,1.2,1)
  for j,y in enumerate([25.1,28.3]):
   t=(y-w[1])/(e[1]-w[1]);x=w[0]*(1-t)+e[0]*t;z=w[2]*(1-t)+e[2]*t;m.volume('bracer_strap_'+side+str(j),fore,[(y-.18,x,z,3.05,3.55),(y+.18,x,z,3.05,3.55)],'leather',1,.08)
  m.volume('glove_palm_'+side,hand,[(21.8,w[0]-.1*sgn,w[2]-.55,2.7,2.5),(23.2,w[0],w[2]-.2,3.05,2.9),(24.8,w[0],w[2],2.55,2.8)],'glove',1.0,.17)
  for j in range(4):
   xx=w[0]+(j-1.5)*.63;m.box(f'glove_finger_{side}_{j}',hand,[xx-.29,21.5,w[2]-1.5],[xx+.29,22.4,w[2]-.20],'glove')
  xx=w[0]-sgn*1.45;m.box('glove_thumb_'+side,hand,[xx-.38,22.35,w[2]-.95],[xx+.38,23.5,w[2]+.2],'glove')
  m.volume('thigh_complete_'+side,'thigh_'+side,[(13.7,knee[0],knee[2],3.45,4.0),(19.7,(hip[0]+knee[0])/2,(hip[2]+knee[2])/2,4.1,5.0),(25.6,hip[0],hip[2],4.55,5.5)],'undercloth',1.65,.20)
  m.volume('shin_complete_'+side,'shin_'+side,[(4.95,ank[0],ank[2],2.65,3.6),(9.5,(ank[0]+knee[0])/2,(ank[2]+knee[2])/2,3.0,3.8),(14.5,knee[0],knee[2],3.45,4.1)],'undercloth',1.5,.18)
  # Continuous U-shaped knee/shin armour with side returns, not white marks.
  m.surface('knee_shin_front_'+side,'shin_'+side,[(8.0,ank[0]-.75,ank[2]-1.9,ank[0]+.75,ank[2]-1.9),(10.6,knee[0]-1.2,knee[2]-1.8,knee[0]+1.2,knee[2]-1.8),(13.0,knee[0]-1.7,knee[2]-2.0,knee[0]+1.7,knee[2]-2.0),(14.5,knee[0]-1.3,knee[2]-1.5,knee[0]+1.3,knee[2]-1.5)],'steel',.58,1.1,1)
  for sg in [-1,1]:
   x=knee[0]+sg*1.35;m.box('knee_side_return_'+side+str(sg),'shin_'+side,[x-.28,12.15,knee[2]-1.5],[x+.28,14.0,knee[2]+.8],'steel')
  # Thigh plates stay on the thigh and stop above the separate knee.
  m.surface('thigh_plate_'+side,'thigh_'+side,[(15.8,knee[0]-.85,knee[2]-1.95,knee[0]+1.0,knee[2]-1.95),(19.5,hip[0]-1.65,hip[2]-2.7,hip[0]+1.65,hip[2]-2.7),(23.0,hip[0]-1.8,hip[2]-2.4,hip[0]+1.8,hip[2]-2.4)],'steel',.42,1.3,1)
  m.volume('boot_complete_'+side,'foot_'+side,[(.3,ank[0]+sgn*.20,ank[2]-.35,3.65,6.2),(1.4,ank[0]+sgn*.2,ank[2]-.40,3.65,6.15),(3.0,ank[0],ank[2]-.15,3.25,5.15),(5.9,ank[0],ank[2]+.1,2.85,3.8)],'boot',1.1,.16)
  m.box('boot_sole_'+side,'foot_'+side,[ank[0]-1.7,.0,ank[2]-3.5],[ank[0]+1.9,.4,ank[2]+2.8],'boot')
  m.box('boot_toecap_'+side,'foot_'+side,[ank[0]-1.35,.55,ank[2]-3.57],[ank[0]+1.5,1.15,ank[2]-2.6],'steel')

def shoulders(m):
 for side,sgn,cx,cz in [('right',1,7.0,.45),('left',-1,-4.8,1.1)]:
  for layer,(off,span,depth)in enumerate([(0,5.9,6.9),(-1.7,5.3,6.3),(-3.15,4.6,5.7)]):
   # Five larger plates form each arch; inner/outer edges turn down naturally.
   for j in range(5):
    u=(j+.5)/5;xx=cx+sgn*((u-.5)*span+.15);top=39.8+off-2.55*u**1.5;y=top-.75
    dep=depth*(.85+.15*np.sin(np.pi*u));m.box(f'pauldron_{side}_{layer}_{j}','shoulder_'+side,[xx-span/10,y,cz-dep/2],[xx+span/10,top,cz+dep/2],'steel')
  # A small attached clasp matches the cuirass fastening in the reference.
  xx=cx-sgn*2.4;m.box('pauldron_clasp_'+side,'chest',[xx-.35,37.6,cz-3.35],[xx+.35,38.5,cz-2.95],'steel')

def cloth_and_belt(m):
 # Folded neck wraps; lower front points drop onto the chest.
 for k,(y,rx,rz)in enumerate([(41.25,3.2,2.9),(40.35,4.1,3.4),(39.5,5.15,3.75)]):
  pts=[]
  for a in np.linspace(0,2*np.pi,13):
   x=.9+np.cos(a)*rx;z=.7+np.sin(a)*rz;yy=y-.8*max(0,-np.sin(a))+.30*np.cos(a);pts.append([x,yy,z])
  m.curve('scarf_fold_'+str(k),'scarf',pts,[[.68,.72,.70]]*len(pts),'scarf',1.25)
 m.surface('scarf_hanging_front','scarf_front',[(29.8,-2.6,-3.9,-1.0,-3.5),(33,-3.0,-4.05,-.8,-3.55),(36,-3.25,-3.95,-.6,-3.3),(39.4,-3.45,-3.2,-.2,-2.9)],'scarf',.30,.95,2)
 # Belt is an opaque wrap over a closed pelvis. Buckle and diagonal strap
 # are actual connected pieces; torso texture cannot claim them.
 m.volume('belt_wrap','belt',[(26.4,1.1,-.25,9.2,7.1),(28.3,1.1,-.2,9.1,6.9)],'leather',.9,.10)
 m.box('belt_buckle_frame','belt',[.45,26.75,-3.98],[2.2,28.2,-3.57],'leather')
 m.box('belt_buckle_inner','belt',[.8,27.0,-4.05],[1.85,27.95,-3.99],'steel')
 m.curve('waist_diagonal_sash','belt',[[-2.9,25.3,-3.8],[.2,24.7,-4.25],[3.6,23.0,-4.2],[5.25,22.7,-2.9]],[[.6,.95,.30],[.7,.95,.32],[.65,1.0,.33],[.55,.8,.33]],'leather',1.2)
 m.surface('front_tabard_fabric','front_tabard',[(11.3,-.2,-5.95,.2,-5.95),(13.7,-1.7,-5.8,3.3,-5.8),(19,-1.9,-4.8,4.25,-4.8),(24.0,-1.75,-4.05,4.1,-4.05),(25.7,-1.5,-3.8,4.0,-3.8)],'tabard',.24,1.2,3)
 # The cape's shared edges are traced from the same measured stations.
 ys=[5.8,10,16,24,32,39.8]
 xs=[[-9.5,-3.7,7.7,19.4,26.7],[-7.6,-1.0,7.1,16.0,20.7],[-5.4,-1.8,5.5,11.3,14.3],[-5.2,-1.8,3.2,7.2,8.6],[-4.2,-1.7,1.7,5.6,6.2],[-2.8,-1.0,1.2,3.6,5.0]]
 zs=[[4.3,13.8,17.2,19.6,20.4],[6.1,12.9,15.3,17,17],[6.6,11.0,13.4,13.5,11.5],[6.5,10,10.6,10.2,8.5],[5.8,7.7,8.0,7.8,6.8],[4.4,5.5,5.7,5.3,4.5]]
 for col in range(4):
  rows=[(y,x[col],z[col],x[col+1],z[col+1])for y,x,z in zip(ys,xs,zs)]
  hole=[(9,16,.35,.65),(18,25,.33,.65),(12,18,.43,.64),(9,14,.25,.52)][col]
  m.surface('cape_panel_'+str(col),'cape',rows,'cape',.20,1.5,4,hole)
 # Unequal tapering ends break the lower hem while sharing the main sheet.
 for name,rows in [
 ('cape_torn_l',[(3.6,-7.3,5.0,-7.05,5.1),(6.0,-8.2,5.7,-4.7,10.5),(9.5,-6.1,7.8,-3.1,10.3)]),
 ('cape_torn_middle',[(3.2,.2,15.1,.45,15.2),(6.4,-1.5,14.9,4.8,16.2),(9.7,.0,13.4,5.3,15.3)]),
 ('cape_torn_outer',[(5.05,26.6,20.8,26.8,20.9),(7.6,20.0,18.6,25.2,20.3),(10.8,16.0,16.2,19.8,17.1)])]:m.surface(name,'cape',rows,'cape',.17,1.2,1)

def texture_and_save(m,texture_prefix='c_basecolor',extra_masks=None):
 # Sample inside original triangles instead of UV seam vertices; the latter
 # can hit atlas gutters and incorrectly darken otherwise silver armour.
 bary=np.array([[1/3]*3,[.60,.20,.20],[.20,.60,.20],[.20,.20,.60]])
 qp=np.einsum('ki,fij->fkj',bary,sp[sf]).reshape(-1,3);qn=np.einsum('ki,fij->fkj',bary,sn[sf]).reshape(-1,3);qn/=np.maximum(1e-9,np.linalg.norm(qn,axis=1)[:,None]);qu=np.einsum('ki,fij->fkj',bary,su[sf]).reshape(-1,2);co=st[np.clip((qu[:,1]*4096).astype(int),0,4095),np.clip((qu[:,0]*4096).astype(int),0,4095),:3].astype(float)
 red=(co[:,0]>co[:,1]*1.42)&(co[:,0]>co[:,2]*1.30)&(co[:,0]>28);steel=(co.mean(1)>58)&~red&(abs(co[:,0]-co[:,2])<45)
 masks={'steel':steel,'steel_chest':steel&(qp[:,1]>29)&(qp[:,1]<39)&(qp[:,0]>-4)&(qp[:,0]<7)&(qp[:,2]<1),'helmet':(qp[:,1]>43.1)&~red,'face':(qp[:,1]>40.8)&(qp[:,1]<44.4)&~red,'undercloth':(co.mean(1)<58)&~red&(qp[:,2]<4)&(qp[:,1]<40.5),'leather':(qp[:,1]>22)&(qp[:,1]<30)&(qp[:,2]<3)&~red&(co.mean(1)<80),'scarf':red&(qp[:,1]>29),'tabard':red&(qp[:,1]<27)&(qp[:,2]<-.5)&(abs(qp[:,0]-1.1)<5),'cape':(qp[:,2]>4)&(qp[:,1]<40.5),'boot':(qp[:,1]<6)&~red,'glove':(qp[:,1]>20)&(qp[:,1]<25)&(abs(qp[:,0]-1.1)>5)&(co.mean(1)<62)&~red}
 if extra_masks:
  for k,predicate in extra_masks.items():
   masks[k]=predicate(qp,co,red)
   assert masks[k].any(),k
 trees={k:cKDTree(np.c_[qp[v],qn[v]*.85])for k,v in masks.items()};colors={k:co[v]for k,v in masks.items()}
 lo=np.array([q[0]for q in m.geo]);hi=np.array([q[1]for q in m.geo]);gs=np.array([q[2]for q in m.geo]);faces=[];culled=0
 for i,e in enumerate(m.bb['elements']):
  a,b,g=m.geo[i];rr,origin=m.trans[g];other=gs==g;other[i]=False
  for name,v in V.items():
   q=np.array(v)*(b-a)+a;normal=np.array(N[name]);pp=np.array([q[0]+u*(q[3]-q[0])+v*(q[1]-q[0])+normal*.004 for u in [.03,.5,.97]for v in [.03,.5,.97]])
   inside=((pp[:,None]>=lo[None]-1e-6)&(pp[:,None]<=hi[None]+1e-6)).all(2)&other[None]
   if inside.any(1).all():culled+=1;continue
   world=(q-origin)@rr.T+origin;wn=normal@rr.T;w=max(2,math.ceil(np.linalg.norm(q[3]-q[0])*5));h=max(2,math.ceil(np.linalg.norm(q[1]-q[0])*5));faces.append({'e':e,'name':name,'q':world,'n':wn,'w':w,'h':h,'mat':m.mat[i]})
 pages=[];page=[];x=y=rh=0
 for face in sorted(faces,key=lambda e:-e['h']):
  w,h=face['w']+2,face['h']+2
  if x+w>512:x=0;y+=rh;rh=0
  if y+h>512:pages.append(page);page=[];x=y=rh=0
  face['xy']=(x+1,y+1);page.append(face);x+=w;rh=max(rh,h)
 if page:pages.append(page)
 for ti,page in enumerate(pages):
  atlas=Image.new('RGBA',(512,512))
  for f in page:
   w,h=f['w'],f['h'];q=f['q'];u,v=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);world=q[0]+u[:,:,None]*(q[3]-q[0])+v[:,:,None]*(q[1]-q[0]);query=np.c_[world.reshape(-1,3),np.tile(f['n']*.85,(w*h,1))];dist,ix=trees[f['mat']].query(query,k=3);weights=1/(dist+.035)**2;weights/=weights.sum(1)[:,None];rgb=(colors[f['mat']][ix]*weights[:,:,None]).sum(1).reshape(h,w,3);rgba=np.full((h,w,4),255,np.uint8);rgba[:,:,:3]=np.clip(rgb,0,255);xx,yy=f['xy'];atlas.paste(Image.fromarray(np.pad(rgba,((1,1),(1,1),(0,0)),mode='edge')),(xx-1,yy-1));f['e']['faces'][f['name']]={'uv':[xx,yy,xx+w,yy+h],'texture':ti}
  name=f'{texture_prefix}_{ti}_512.png';path=D/name;atlas.save(path);m.bb['textures'].append({'name':name,'id':str(ti),'uuid':uid('t/'+name),'path':str(path),'relative_path':name,'width':512,'height':512,'uv_width':512,'uv_height':512,'render_mode':'default','render_sides':'auto','internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode()})
 (D/(TITLE+'.bbmodel')).write_text(json.dumps(m.bb,ensure_ascii=False,indent=2),encoding='utf8')
 aj=copy.deepcopy(m.bb);aj['meta']={'format':'animated-java:format/blueprint','format_version':'1.11.0','uuid':uid('project'),'save_location':str(D/(TITLE+'.ajblueprint')),'last_used_blueprint_id':'sweetdream_boss:c_red_cape'};aj['blueprint_settings']={'blueprint_id':'sweetdream_boss:c_red_cape','auto_render_box':False,'render_box':[4,4],'resource_pack_export_mode':'none','data_pack_export_mode':'none','target_minecraft_version':'1.21.5'};aj['texture_groups']=[];aj['variants']={'default':{'name':'default','display_name':'Default','uuid':uid('variant/default'),'slot_textures':{},'excluded_nodes':[],'is_default':True},'list':[]}
 for e in aj['elements']:
  for f in e['faces'].values():
   if f.get('texture')is not None:f['texture']=aj['textures'][f['texture']]['uuid']
 (D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
 stats={'cubes':len(m.bb['elements']),'groups':len(m.bb['groups']),'visible_faces':len(faces),'culled_internal_faces':culled,'textures':len(pages),'texture_size':[512,512],'animations':0,'appearance_approved':False,'game_tested':False};(D/'初建统计.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf8');print(stats,flush=True)
if __name__=='__main__':
 m=Model();skeleton(m);body(m);shoulders(m);cloth_and_belt(m);texture_and_save(m)
