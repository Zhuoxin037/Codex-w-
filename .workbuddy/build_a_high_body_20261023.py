"""REJECTED IN FULL BY THE USER: do not use this voxel build as a model source.

No whole-character fill, no synthetic thick limb core, no conical robe.
"""
from a_high_body_source_20261023 import D,H,ROOT,regions
import sys,json,numpy as np,math,uuid,copy,itertools,io,base64,time
from PIL import Image
sys.path.insert(0,str(ROOT/'.workbuddy/tools/a_mesh_deps'))
import trimesh
from scipy.ndimage import binary_fill_holes,label,binary_closing,generate_binary_structure
from scipy.spatial.transform import Rotation
from scipy.spatial import cKDTree
from build_b_staff_static_20261021 import greedy,VERTS,NORMAL
from repair_b_saved_seams_20261022 import unwrap

TITLE='A_高模还原_常驻主体';ID='sweetdream:a/high-body/20261023/'
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,ID+s))
def orientation(part):
    if not part.get('end'):return np.eye(3)
    yy=np.array(part['pivot'])-part['end'];yy/=np.linalg.norm(yy);xx=np.cross(yy,[0,0,1]);xx/=np.linalg.norm(xx);zz=np.cross(xx,yy);return np.column_stack([xx,yy,zz])

def prepared(part,p,n,u,f,labels,i):
    ids=np.flatnonzero(labels==i);ff=f[ids];verts,inv=np.unique(ff,return_inverse=True);pp=p[verts].copy();nn=n[verts].copy();uu=u[verts].copy();localf=inv.reshape(-1,3)
    # Reorient the rear foot's existing complete boot, rather than leaving the
    # toe pointing backward inside the robe. Its calf and proportions remain.
    if part['name']=='foot_l':
        o=np.array([-3.5,7.7,.5]);pp=(pp-o)*[-1,1,-1]+o;nn*=np.array([-1,1,-1])
    mesh=trimesh.Trimesh(pp,localf,process=False)
    # Weld UV duplicate positions only for component selection; retain the
    # original per-corner UV arrays for the texture bake.
    _,weld=np.unique(np.round(pp,5),axis=0,return_inverse=True);wf=weld[localf]
    from scipy.sparse import coo_matrix
    from scipy.sparse.csgraph import connected_components
    ed=np.concatenate([wf[:,[0,1]],wf[:,[1,2]],wf[:,[2,0]]]);nc=int(weld.max())+1;gr=coo_matrix((np.ones(len(ed),np.uint8),(ed[:,0],ed[:,1])),shape=(nc,nc)).tocsr();_,cl=connected_components(gr,directed=False);fl=cl[wf[:,0]];sizes=np.bincount(fl)
    threshold=max(8,int(sizes.max()*(.035 if part['name']in ['head','foot_r','foot_l'] else .012)))
    good=sizes[fl]>=threshold;localf=localf[good];ids=ids[good]
    return pp,nn,uu,localf,ids

def geometry():
    p,n,u,f,t,parts,labels=regions();items=[];stats=[];cache={}
    for i,part in enumerate(parts):
        if part['triangles']<5:continue
        name=part['name'];pp,nn,uu,ff,ids=prepared(part,p,n,u,f,labels,i);cache[name]=(pp,nn,uu,ff)
        rr=orientation(part);pivot=np.array(part['pivot']);lp=(pp-pivot)@rr
        mesh=trimesh.Trimesh(lp,ff,process=True);st=part['pitch'];vg=mesh.voxelized(st);occ=vg.matrix.copy();origin=vg.transform[:3,3]-st/2
        if part['fill_enclosed_part_only']:occ=binary_fill_holes(occ)
        if name=='lower_garment':occ=binary_closing(np.pad(occ,1),structure=generate_binary_structure(3,1))[1:-1,1:-1,1:-1]
        # Do not leave source residue floating as new blocks. Significant claw
        # branches are kept; a local connection audit follows the native view.
        cc,nc=label(occ,structure=np.ones((3,3,3),bool));size=np.bincount(cc.ravel());size[0]=0;occ&=size[cc]>=max(2,int(size.max()*.004))
        best=None
        for order in itertools.permutations(range(3)):
            boxes=greedy(occ.astype('uint8'),order)
            if best is None or len(boxes)<len(best):best=boxes
        if name=='lower_garment':
            # Each vertical section is short enough for a native 1.21.5 model.
            bins=origin[1]+(np.arange(occ.shape[1])+.5)*st+pivot[1];yy=np.digitize(bins,[6.5,13,19.5]);lab=occ*(yy[None,:,None]+1);best=min((greedy(lab,o)for o in itertools.permutations(range(3))),key=len)
        for k,(lo,hi,value)in enumerate(best):
            a=origin+lo*st+pivot;b=origin+hi*st+pivot
            if name in ['foot_r','foot_l']and a[1]+pivot[1]-pivot[1]<0:a[1]=0
            visible=[]
            for fa,normal in NORMAL.items():
                axis=int(np.flatnonzero(normal)[0]);at=lo[axis]-1 if normal[axis]<0 else hi[axis];sl=[slice(lo[j],hi[j])for j in range(3)];sl[axis]=at
                if 0<=at<occ.shape[axis] and np.all(occ[tuple(sl)]):continue
                visible.append(fa)
            items.append({'name':f'{name}_{k:03d}','part':name,'from':a.tolist(),'to':b.tolist(),'pivot':pivot.tolist(),'matrix':rr.tolist(),'visible':visible,'section':int(value)-1 if name=='lower_garment'else None})
        stat={'part':name,'source_triangles':len(ff),'pitch':st,'cubes':len(best),'surface_cells':int(occ.sum()),'fill_used_only_on_closed_head_or_boot':part['fill_enclosed_part_only'],'bounds':[mesh.bounds[0].tolist(),mesh.bounds[1].tolist()]};stats.append(stat);print(stat,flush=True)
    np.savez(D/'prepared_source.npz',**{name+'_'+k:arr for name,data in cache.items()for k,arr in zip(['p','n','uv','f'],data)})
    (D/'source_fitted_cubes.json').write_text(json.dumps(items,ensure_ascii=False),encoding='utf8');(D/'部位拟合统计.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf8');print('TOTAL',len(items),flush=True)

class Sampler:
    def __init__(self,data,tex):
        self.p,self.n,self.uv,self.f=data;self.tex=tex;self.tri=self.p[self.f];self.tree=cKDTree(self.tri.mean(1));self.errors=[]
    def sample(self,points):
        result=[]
        for start in range(0,len(points),4096):
            pts=points[start:start+4096];_,ids=self.tree.query(pts,k=min(16,len(self.f)));ids=np.atleast_2d(ids);tri=self.tri[ids];q=pts[:,None,:];a,b,c=tri[:,:,0],tri[:,:,1],tri[:,:,2];ab=b-a;ac=c-a;ap=q-a
            d00=(ab*ab).sum(-1);d01=(ab*ac).sum(-1);d11=(ac*ac).sum(-1);d20=(ap*ab).sum(-1);d21=(ap*ac).sum(-1);den=np.maximum(d00*d11-d01*d01,1e-20);v=(d11*d20-d01*d21)/den;w=(d00*d21-d01*d20)/den;wa=1-v-w;bary=np.stack([wa,v,w],-1);cp=a+v[:,:,None]*ab+w[:,:,None]*ac;dist=((cp-q)**2).sum(-1);dist[(wa<0)|(v<0)|(w<0)]=np.inf
            for aa,bb,ai,bi in [(a,b,0,1),(b,c,1,2),(c,a,2,0)]:
                edge=bb-aa;ss=np.clip(((q-aa)*edge).sum(-1)/np.maximum((edge*edge).sum(-1),1e-20),0,1);dd=((aa+ss[:,:,None]*edge-q)**2).sum(-1);better=dd<dist;dist[better]=dd[better];ba=np.zeros_like(bary);ba[:,:,ai]=1-ss;ba[:,:,bi]=ss;bary[better]=ba[better]
            at=dist.argmin(1);row=np.arange(len(pts));tuv=(self.uv[self.f[ids[row,at]]]*bary[row,at,:,None]).sum(1);tx=np.clip((tuv[:,0]*self.tex.shape[1]).astype(int),0,self.tex.shape[1]-1);ty=np.clip((tuv[:,1]*self.tex.shape[0]).astype(int),0,self.tex.shape[0]-1);col=self.tex[ty,tx].copy();col[:,3]=255;result.append(col);self.errors.extend(np.sqrt(dist[row,at]).tolist())
        return np.concatenate(result)

def build():
    items=json.loads((D/'source_fitted_cubes.json').read_text(encoding='utf8'));parts=json.loads((D/'源部位边界.json').read_text(encoding='utf8'));byname={r['name']:r for r in parts};z=np.load(D/'prepared_source.npz');tex=np.array(Image.open(H/'source_map_1.png').convert('RGBA'));samplers={name:Sampler([z[name+'_'+k]for k in ['p','n','uv','f']],tex)for name in byname if name+'_p'in z}
    native=json.loads((H/'切换参考前_在场工程完整备份.ajblueprint').read_text(encoding='utf8'));bb=unwrap(copy.deepcopy(native));bb.update(name=TITLE,elements=[],groups=[],outliner=[],textures=[],animations=[]);nodes={};groups={}
    def group(name,parent,pivot,angles=None):
        g={'name':name,'uuid':uid('g/'+name),'origin':list(pivot),'rotation':angles or[0,0,0],'visibility':True,'export':True,'color':5 if name.startswith('lower')else 1,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}};node={'uuid':g['uuid'],'children':[],'isOpen':False};bb['groups'].append(g);groups[name]=g;nodes[name]=node;(nodes[parent]['children']if parent else bb['outliner']).append(node)
    group('root',None,[0,0,0]);group('pelvis','root',[-.35,24.8,-6.9]);group('waist','pelvis',byname['waist']['pivot']);group('chest','waist',byname['chest']['pivot']);group('neck','chest',byname['neck']['pivot']);group('head','neck',byname['head']['pivot'])
    for side in ['r','l']:
        parent='chest'
        for a in ['upperarm','forearm','hand']:
            name=a+'_'+side;group(name,parent,byname[name]['pivot']);parent=name
            if a!='hand':
                rot=Rotation.from_matrix(orientation(byname[name])).as_euler('xyz',degrees=True).tolist();group(name+'_source_axis',name,byname[name]['pivot'],rot)
    for side in ['r','l']:group('foot_'+side,'pelvis',byname['foot_'+side]['pivot'])
    group('retained_lower_garment','pelvis',[-.35,25,-6.9])
    for k,y in enumerate([3.2,9.7,16.2,22.7]):group('lower_section_'+str(k),'retained_lower_garment',[-.35,y,-1])
    faces=[]
    for item in items:
        name=item['part'];owner=('lower_section_'+str(item['section']))if name=='lower_garment'else(name+'_source_axis'if byname[name].get('end')else name)
        a=np.array(item['from']);b=np.array(item['to']);e={'name':item['name'],'uuid':uid('e/'+item['name']),'type':'cube','from':a.tolist(),'to':b.tolist(),'origin':((a+b)/2).tolist(),'rotation':[0,0,0],'rescale':False,'shade':True,'box_uv':False,'visibility':True,'export':True,'faces':{fa:{'texture':None,'uv':[0,0,1,1]}for fa in NORMAL}};bb['elements'].append(e);nodes[owner]['children'].append(e['uuid']);rr=np.array(item['matrix']);pivot=np.array(item['pivot'])
        for fa in item['visible']:
            q=(np.array(VERTS[fa])*(b-a)+a-pivot)@rr.T+pivot;w=max(2,math.ceil(np.linalg.norm(q[3]-q[0])*5));h=max(2,math.ceil(np.linalg.norm(q[1]-q[0])*5));faces.append({'e':e,'fa':fa,'q':q,'w':w,'h':h,'part':name})
    batches=[]
    for role in ['bone','robe']:
        entries=sorted([v for v in faces if(v['part']=='lower_garment')==(role=='robe')],key=lambda v:-v['h']);batch=[];x=y=rh=0
        for entry in entries:
            w,h=entry['w']+2,entry['h']+2
            if x+w>512:x=0;y+=rh;rh=0
            if y+h>512:batches.append((role,batch));batch=[];x=y=rh=0
            entry['xy']=(x+1,y+1);batch.append(entry);x+=w;rh=max(rh,h)
        if batch:batches.append((role,batch))
    for i,(role,batch)in enumerate(batches):
        atlas=Image.new('RGBA',(512,512));total=sum(e['w']*e['h']for e in batch);print('Baking',role,i,len(batch),total,flush=True)
        # Batch source queries across all faces of each part for speed.
        for part in sorted(set(v['part']for v in batch)):
            entries=[v for v in batch if v['part']==part];samples=[]
            for e in entries:
                q=e['q'];uu,vv=np.meshgrid((np.arange(e['w'])+.5)/e['w'],(np.arange(e['h'])+.5)/e['h']);samples.append((q[0]+uu[:,:,None]*(q[3]-q[0])+vv[:,:,None]*(q[1]-q[0])).reshape(-1,3))
            colors=samplers[part].sample(np.vstack(samples));offset=0
            for e in entries:
                w,h=e['w'],e['h'];patch=colors[offset:offset+w*h].reshape(h,w,4);offset+=w*h;x,y=e['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(x-1,y-1));e['e']['faces'][e['fa']]={'texture':i,'uv':[x,y,x+w,y+h]}
        file=f'a_high_body_{role}_{i}_512.png';atlas.save(D/file);raw=(D/file).read_bytes();texture=copy.deepcopy(native['textures'][0]);texture.update(name=file,id=str(i),uuid=uid('tex/'+file),path=str(D/file),relative_path=file,source='data:image/png;base64,'+base64.b64encode(raw).decode());bb['textures'].append(texture)
    bb['meta']={'format_version':'5.0','model_format':'free','box_uv':False};bb['resolution']={'width':512,'height':512};(D/(TITLE+'.bbmodel')).write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
    aj=copy.deepcopy(native)
    for k in ['name','elements','groups','outliner','textures','resolution']:aj[k]=copy.deepcopy(bb[k])
    aj['animations']=[];aj['meta'].update(uuid=uid('project'),save_location=str(D/(TITLE+'.ajblueprint')))
    for e in aj['elements']:
        for face in e['faces'].values():
            if face.get('texture')is not None:face['texture']=aj['textures'][face['texture']]['uuid']
    (D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
    report={'cubes':len(items),'groups':len(bb['groups']),'defined_faces':len(faces),'textures':len(bb['textures']),'animations':0,'source':'new actual high GLB corrected-foot working reference','body_draft_only':True,'upper_dissolvable_cloth_created':False,'rear_frame_created':False,'rear_foot_reoriented':True,'bake_distances':{n:{'median':float(np.median(s.errors)),'p95':float(np.percentile(s.errors,95))}for n,s in samplers.items()if s.errors}}
    (D/'常驻主体统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
if __name__=='__main__':
    raise SystemExit('Rejected in full: silhouette, robe, feet, head and limbs did not match the GLB. Do not regenerate or promote this draft.')
