"""Continue the user's preferred old solid Cube version, using actual GLB surfaces.

Surface voxelization is used without filling the large source cavities. All new
elements are closed positive-volume Cubes with real front, side and back faces;
no contour billboard is substituted for the head or skeletal structure.
"""
from analyze_a_boss_static_20261022 import *
from build_b_staff_static_20261021 import layout,VERTS,NORMAL,greedy,rotation
from repair_b_saved_seams_20261022 import unwrap
from refine_b_headcloth_20261022 import hierarchy,face_points,collect_scene
from boss_texture_transfer import Source
from bb_local_bridge_client import script,call
import copy,uuid,base64,io,itertools,math,trimesh,time
from collections import defaultdict,Counter

D=S/'旧版立体修形_20261022';D.mkdir(exist_ok=True)
OLD=S/'薄层肩颈修正_20261022/改前_编辑器完整快照.ajblueprint'
TITLE='A_旧版立体优化_完整静态'
UNIFORM='--uniform-cube' in sys.argv
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:a/full-old-volume/'+s))

class FullSampler(Source):
    def __init__(self):
        self.p,_,self.uv,self.f,self.tex=source();self.tri=self.p[self.f];self.cell=1.1;self.grid=defaultdict(list);self.cache={};self.max_error=0.;self.distances=[]
        for i,t in enumerate(self.tri):
            lo=np.floor(t.min(0)/self.cell).astype(int);hi=np.floor(t.max(0)/self.cell).astype(int)
            for key in itertools.product(*[range(lo[a],hi[a]+1) for a in range(3)]):self.grid[key].append(i)

def main():
    native=json.loads(OLD.read_text(encoding='utf8'));bb=unwrap(native);bb['name']=TITLE;bb['animations']=[]
    # The saved old head frame and ribs are retained; only the old poorly
    # fitted shoulder/head core is replaced. No thin-surface trial is a base.
    removed={e['uuid'] for e in bb['elements'] if e['name'].startswith('core_')};bb['elements']=[e for e in bb['elements'] if e['uuid'] not in removed]
    gs,pa,ep,nodes,world=hierarchy(bb);byname={g['name']:g for g in bb['groups']}
    for node in nodes.values():node['children']=[x for x in node['children'] if not isinstance(x,str) or x not in removed]
    def group(name,parent,pivot):
        if name in byname:return byname[name]
        g={'name':name,'uuid':uid('g/'+name),'origin':pivot,'rotation':[0,0,0],'export':True,'visibility':True,'color':len(bb['groups'])%8,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}};bb['groups'].append(g);byname[name]=g;node={'uuid':g['uuid'],'children':[],'isOpen':False};nodes[g['uuid']]=node;nodes[byname[parent]['uuid']]['children'].append(node);return g
    for name,par,pivot in [
        ('back_ring_frame','chest',[0,31,1]),('shoulder_arch_R','chest',[5.5,32,-3]),('shoulder_arch_L','chest',[-5.5,32,-3]),
        ('arm_upper_R','chest',[5.5,29,-4]),('arm_upper_L','chest',[-5.5,29,-4]),
        ('arm_lower_R','arm_upper_R',[7,25,-6]),('arm_lower_L','arm_upper_L',[-7,25,-6]),
        ('claws_R','arm_lower_R',[8,22,-8]),('claws_L','arm_lower_L',[-8,22,-8]),
        ('waist_bones','chest',[0,26,-2]),('robe_inner','waist_bones',[0,25,0]),('robe_front_R','waist_bones',[3,24,-5]),('robe_front_L','waist_bones',[-3,24,-5]),
        ('robe_back','waist_bones',[0,25,3]),('robe_side_R','waist_bones',[5,23,0]),('robe_side_L','waist_bones',[-5,23,0]),('hem','robe_inner',[0,4,0])]:group(name,par,pivot)
    p,n,u,f,tex=source();new=[];uvfaces=[];part_counts=Counter();grid_reports=[]
    def add_grid(occ,o,step,assign,label):
        xx,yy,zz=np.meshgrid(*[o[a]+(np.arange(occ.shape[a])+.5)*step for a in range(3)],indexing='ij');names=[None];labels=np.zeros_like(occ,dtype=np.uint8)
        for name,mask in assign(xx,yy,zz):
            if name not in names:names.append(name)
            labels[(occ>0)&mask]=names.index(name)
        assert not np.any((occ>0)&(labels==0))
        best=min((greedy(labels,order) for order in itertools.permutations(range(3))),key=len);grid_reports.append({'part':label,'step':step,'voxels':int(occ.sum()),'cubes':len(best),'fill_used':False})
        for i,(lo,hi,lab) in enumerate(best):
            part=names[lab];low=o+lo*step;high=o+hi*step;low[1]=max(0.,low[1]);
            if high[1]<=low[1]+1e-6:continue
            name=f'{label}_{part}_{i:04}';e={'name':name,'uuid':uid(name),'type':'cube','from':low.tolist(),'to':high.tolist(),'origin':((low+high)/2).tolist(),'rotation':[0,0,0],'rescale':False,'shade':True,'box_uv':False,'export':True,'visibility':True,'faces':{fa:{'uv':[0,0,1,1],'texture':None} for fa in NORMAL}};bb['elements'].append(e);new.append(e);nodes[byname[part]['uuid']]['children'].append(e['uuid']);part_counts[part]+=1
            for fa,nn in NORMAL.items():
                axis=int(np.flatnonzero(nn)[0]);idx=lo[axis]-1 if nn[axis]<0 else hi[axis]
                if 0<=idx<labels.shape[axis]:
                    sl=[slice(lo[j],hi[j]) for j in range(3)];sl[axis]=idx
                    if np.all(labels[tuple(sl)]==lab):continue
                q=np.array(VERTS[fa],float)*(high-low)+low;w=max(2,math.ceil(np.linalg.norm(q[3]-q[0])*4));h=max(2,math.ceil(np.linalg.norm(q[1]-q[0])*4));uvfaces.append({'e':e,'fa':fa,'q':q,'width':w,'height':h})
    # Head, neck and shoulder bone shell: genuine .65-unit solid geometry,
    # with the source holes left open. It is not the previous .08 sheet bake.
    a=np.load(D/'曲面实体体素_0.65.npz');occ=a['labels'].copy();o=a['origin'];step=float(a['step'])
    add_grid(occ,o,step,lambda x,y,z:[('chest',np.ones_like(y,dtype=bool)),('neck_web',y>=33.5)],'head_shoulders')
    # Curved external framework and hands remain real solid Cubes. Garment
    # folds use their own source surfaces below, rather than thick stair blocks.
    cache=D/('完整余部曲面_基准.npz' if UNIFORM else '骨架余部_0.8.npz')
    a=np.load(cache);occ=a['labels'].copy();o=a['origin'];step=float(a['step']);xx,yy,zz=np.meshgrid(*[o[i]+(np.arange(occ.shape[i])+.5)*step for i in range(3)],indexing='ij')
    if not UNIFORM:occ[(yy<28)&(abs(xx)<5.5)]=0
    def body_parts(x,y,z):
        whole=np.ones_like(y,dtype=bool);out=[('robe_inner',whole),('robe_back',z>2),('robe_front_R',(x>0)&(z< -2)),('robe_front_L',(x<=0)&(z< -2)),('robe_side_R',(x>5)&(y<22)),('robe_side_L',(x< -5)&(y<22)),('waist_bones',(y>=24)&(y<28)&(abs(x)<5.5)),('hem',y<3.2)]
        out += [('back_ring_frame',y>=28)]
        for side,sgn in [('R',1),('L',-1)]:
            arm=(x*sgn>5.5)&((z< -3.2) if sgn==1 else (z<8))&(y>17)&(y<29)
            out += [('shoulder_arch_'+side,(x*sgn>5.5)&(y>=28)&((z< -3.2) if sgn==1 else (z<8))),('arm_upper_'+side,arm),('arm_lower_'+side,arm&(y<25.5)),('claws_'+side,arm&(y<22.8))]
        return out
    add_grid(occ,o,step,body_parts,'solid_frame_arms')
    # The only contour surfaces in this version are the actual lower fabric.
    # Head, neck, shoulder shell, framework and claws never use these patches.
    controls=np.load(D/'衣层控制_300.npz');vv=controls['v'];ff=np.empty((0,3),int) if UNIFORM else controls['f'];patches=vv[ff];cross=np.cross(patches[:,1]-patches[:,0],patches[:,2]-patches[:,0]);areas=np.linalg.norm(cross,axis=1);normals=cross/np.maximum(areas[:,None],1e-10)
    legal=[([0,0,0],np.eye(3))]+[(ang,rotation(ang)) for axis in [0,1] for a in [-45,-22.5,22.5,45] for ang in [[a if k==axis else 0 for k in range(3)]]];bases=[];cloth_records={};plane_errors=[]
    for i in np.argsort(-areas):
        if areas[i]<.002:continue
        q=patches[i];center=q.mean(0);nn=normals[i]
        if center[2]>2:part='robe_back'
        elif center[0]>5:part='robe_side_R'
        elif center[0]<-5:part='robe_side_L'
        elif center[2]< -2:part='robe_front_R' if center[0]>0 else 'robe_front_L'
        else:part='robe_inner'
        best=None
        for basis in bases:
            if basis['part']!=part:continue
            if np.max(abs((center-basis['center'])@basis['r']))>12:continue
            for angles,rc in legal:
                r=basis['r']@rc;er=float(np.max(abs((q-center)@r[:,2])))
                if nn@r[:,2]>.85 and er<.35 and (best is None or er<best[0]):best=(er,basis,angles,r)
        if best is None:
            xx=np.cross([0.,1.,0.],nn)
            if np.linalg.norm(xx)<1e-4:xx=np.cross([1.,0.,0.],nn)
            xx/=np.linalg.norm(xx);r=np.stack([xx,np.cross(nn,xx),nn],1);angles=np.degrees([math.atan2(r[2,1],r[2,2]),math.asin(np.clip(-r[2,0],-1,1)),math.atan2(r[1,0],r[0,0])]).tolist();name=f'fabric_fold_basis_{len(bases):03}';g=group(name,part,center.tolist());g['rotation']=angles;basis={'r':r,'g':g,'part':part,'center':center};bases.append(basis);angles=[0,0,0];plane_errors.append(0.)
        else:er,basis,angles,r=best;g=basis['g'];plane_errors.append(er)
        loc=(q-center)@r;lo=loc.min(0);hi=loc.max(0);go=np.array(g['origin']);cl=go+(center-go)@basis['r'];low=cl+[lo[0]-.06,lo[1]-.06,-.16];high=cl+[hi[0]+.06,hi[1]+.06,0];name=f'fabric_surface_{i:03}';e={'name':name,'uuid':uid(name),'type':'cube','from':low.tolist(),'to':high.tolist(),'origin':cl.tolist(),'rotation':angles,'rescale':False,'shade':True,'box_uv':False,'export':True,'visibility':True,'faces':{fa:{'uv':[0,0,1,1],'texture':None} for fa in NORMAL}};bb['elements'].append(e);new.append(e);nodes[g['uuid']]['children'].append(e['uuid']);part_counts[part]+=1;cloth_records[e['uuid']]=(center,r,loc[:,:2])
    gs,pa,ep,nd,world=hierarchy(bb)
    for e in new:
        if e['uuid'] not in cloth_records:continue
        q,nn=face_points(e,'south',gs,ep,world);w=max(3,math.ceil(np.linalg.norm(q[3]-q[0])*5));h=max(3,math.ceil(np.linalg.norm(q[1]-q[0])*5));uvfaces.append({'e':e,'fa':'south','q':q,'width':w,'height':h})
    # Keep the old atlas byte-for-byte. New islands are packed into separate
    # 512 textures so original source UVs never move.
    for t in bb['textures']:
        blob=base64.b64decode(t['source'].split(',',1)[1]);(D/t['name']).write_bytes(blob);t['path']=str(D/t['name']);t['relative_path']=t['name']
    batches=[];todo=sorted(uvfaces,key=lambda x:-x['height'])
    while todo:
        batch=[];rest=[]
        for item in todo:
            if layout(batch+[item],512):batch.append(item)
            else:rest.append(item)
        assert batch,'UV item exceeds 512 atlas';assert layout(batch,512);batches.append(batch);todo=rest
    sampler=FullSampler();ts=time.time();done=0
    for i,batch in enumerate(batches):
        atlas=Image.new('RGBA',(512,512));ti=len(bb['textures'])
        for item in batch:
            q=item['q'];w,h=item['width'],item['height'];uu,vv=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);pts=q[0]+uu[:,:,None]*(q[3]-q[0])+vv[:,:,None]*(q[1]-q[0]);patch=sampler.sample(pts.reshape(-1,3)).reshape(h,w,4)
            if item['e']['uuid'] in cloth_records:
                center,rr,poly=cloth_records[item['e']['uuid']];loc=(pts-center)@rr;inside=np.ones((h,w),bool)
                for a,b in zip(poly,np.roll(poly,-1,axis=0)):
                    edge=b-a;cross=edge[0]*(loc[:,:,1]-a[1])-edge[1]*(loc[:,:,0]-a[0]);inside &= cross>=-.075*np.linalg.norm(edge)
                patch[:,:,3]=inside.astype(np.uint8)*255
            px,py=item['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1));item['e']['faces'][item['fa']]={'uv':[px,py,px+w,py+h],'texture':ti};done+=1
            if done%500==0:print('actual source UV',done,'/',len(uvfaces),'seconds',round(time.time()-ts,1),flush=True)
        name=f'a_volume_source_{i+1}_512.png';atlas.save(D/name);bio=io.BytesIO();atlas.save(bio,format='PNG');t=copy.deepcopy(bb['textures'][0]);t.update(name=name,id=str(ti),uuid=uid('texture/'+str(i)),path=str(D/name),relative_path=name,source='data:image/png;base64,'+base64.b64encode(bio.getvalue()).decode());bb['textures'].append(t)
    bb['meta']={'format_version':'5.0','model_format':'free','box_uv':False};(D/(TITLE+'.bbmodel')).write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
    aj=copy.deepcopy(native)
    for key in ['elements','groups','outliner','textures','resolution']:aj[key]=copy.deepcopy(bb[key])
    for e in aj['elements']:
        for face in e['faces'].values():
            if face.get('texture') is not None:face['texture']=aj['textures'][face['texture']]['uuid']
    aj['meta'].update(uuid=uid('project'),save_location=str(D/(TITLE+'.ajblueprint')));aj['animations']=[];(D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
    report={'cubes':len(bb['elements']),'groups':len(bb['groups']),'new_cubes':len(new),'old_preserved_crown_rib_cubes':len(bb['elements'])-len(new),'new_visible_faces':len(uvfaces),'textures':len(bb['textures']),'texture_size':512,'animations':0,'new_cubes_by_group':dict(part_counts),'surface_grids':grid_reports,'fabric_surface_cubes':len(cloth_records),'fabric_direction_groups':len(bases),'max_fabric_plane_error_units':max(plane_errors,default=0),'uniform_cube_style':UNIFORM,'source_distance_percentiles':np.percentile(sampler.distances,[50,95,100]).tolist(),'game_exported':False,'game_tested':False};(D/'完整立体静态统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
    pp,nn,uu,ff,tt=collect_scene(bb);sheet=Image.new('RGB',(2880,1100),'#171c23')
    for i,(label,view) in enumerate([('正面',(0,0,-1)),('侧面',(1,0,0)),('背面',(0,0,1)),('45度',(1,.08,-1))]):
        vis=nn[ff[:,0]]@np.array(view)>1e-6;rgba,_,_=raster(pp,nn,uu,ff[vis],tt,view,width=720,height=1100,ppu=19.5,center=(0,24,0),cutout=True,lit=True);im=card(rgba,'实际Cube完整静态 · '+label);im.save(D/f'完整静态_{label}.png');sheet.paste(im,(i*720,0))
    sheet.save(D/'完整静态_实际四视图.png')

if __name__=='__main__':main()
