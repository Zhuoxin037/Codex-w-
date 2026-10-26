"""Build the permanent body and retained lower garment before outer layers.

Uses the actual saved rib geometry and source-constrained head, hands and feet.
The source does not expose the hidden lower anatomy: no nude legs are invented.
Rear pale structures, metal frame and detachable upper cloth are excluded.
"""
from inspect_a_body_lower_20261022 import *
from build_b_staff_static_20261021 import VERTS,NORMAL,greedy,rotation
from refine_b_headcloth_20261022 import hierarchy,face_points,collect_scene
from repair_b_saved_seams_20261022 import unwrap
from boss_texture_transfer import Source
import copy,uuid,base64,io,math,itertools,time,trimesh
from collections import Counter,defaultdict

TITLE='A_常驻身体与下衣_静态'
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:a/permanent-body/'+s))

class RegionSampler(Source):
    def __init__(self,mask):
        self.p,_,self.uv,f,self.tex=source();self.f=f[mask];self.tri=self.p[self.f];self.cell=1.;self.grid=defaultdict(list);self.cache={};self.distances=[];self.max_error=0.
        for i,t in enumerate(self.tri):
            lo=np.floor(t.min(0)).astype(int);hi=np.floor(t.max(0)).astype(int)
            for key in itertools.product(*[range(lo[a],hi[a]+1) for a in range(3)]):self.grid[key].append(i)

def main():
    native=json.loads((D/'改前_在场完整备份.ajblueprint').read_text(encoding='utf8'));old=unwrap(native)
    bb=copy.deepcopy(old);bb.update(name=TITLE,elements=[],groups=[],outliner=[],animations=[],textures=[copy.deepcopy(old['textures'][0])]);nodes={};groups={};roles={};records=[]
    def group(name,parent,pivot,angles=None):
        g={'name':name,'uuid':uid('group/'+name),'origin':list(pivot),'rotation':angles or [0,0,0],'export':True,'visibility':True,'color':5 if name.startswith('lower_') else 1,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}}
        bb['groups'].append(g);groups[name]=g;node={'uuid':g['uuid'],'children':[],'isOpen':False};nodes[name]=node
        (nodes[parent]['children'] if parent else bb['outliner']).append(node);return g
    for name,parent,pivot in [('root',None,[0,0,0]),('pelvis','root',[-.6,24,-6.0]),('waist','pelvis',[-.5,26,-6.6]),('chest','waist',[-.4,30.8,-7.6]),('neck','chest',[-.4,33.8,-7.9]),('head','neck',[-.4,37.5,-7.9])]:group(name,parent,pivot)
    for side,points in [('r',[[4.7,31,-8.0],[7.7,26.2,-13.3],[8.2,22.5,-15.2]]),('l',[[-4.9,31,-6.5],[-7.1,26.2,.1],[-8.0,22.4,5.0]])]:
        parent='chest'
        for part,point in zip(['upperarm','forearm','hand'],points):name=part+'_'+side;group(name,parent,point);parent=name
    group('retained_lower_garment','pelvis',[-.6,24,-6])
    group('foot_r','pelvis',[3.1,2.5,-4.9]);group('foot_l','pelvis',[-2.1,2.5,-4.9])
    def add(e,part,role='body',new=True):
        bb['elements'].append(e);nodes[part]['children'].append(e['uuid']);roles[e['uuid']]=role
        if new:records.append(e)
    def box(name,part,lo,hi,role='body',angles=None,exposed=None):
        e={'name':name,'uuid':uid(name),'type':'cube','from':list(map(float,lo)),'to':list(map(float,hi)),'origin':((np.array(lo)+hi)/2).tolist(),'rotation':angles or [0,0,0],'rescale':False,'shade':True,'box_uv':False,'export':True,'visibility':True,'faces':{fa:{'uv':[0,0,1,1],'texture':None} for fa in NORMAL}}
        e['_exposed']=exposed or list(NORMAL);add(e,part,role);return e
    # Retain the user's actual saved rib forms and source atlas, not the old
    # crown or the incorrectly classified rear structures.
    manifest=json.loads((S/'身体衣料分离_20261022/元素归属清单.json').read_text(encoding='utf8'))
    ribs={r['element'] for r in manifest if r['source_group']=='ribs'}
    for e in old['elements']:
        if e['uuid'] in ribs:add(copy.deepcopy(e),'chest',new=False)
    print('Preserved saved ribs',len(ribs),flush=True)
    p,n,uv,f,tex,masks,rgb=regions();q=p[f].mean(1);x,y,z=q.T
    not_metal=~((rgb[:,0]>rgb[:,2]+15)&(rgb[:,1]>rgb[:,2]+6))
    handr=(x>5.5)&(x<11.1)&(y>18.15)&(y<23.45)&(z> -20)&(z< -12.0)&not_metal
    handl=(x< -5.2)&(x> -10.5)&(y>17.2)&(y<23.1)&(z>2.9)&(z<8.4)&not_metal
    head=(y>33.35)&(y<40.55)&(abs(x+.4)<2.75)&(z> -11.6)&(z< -4.0)
    footr=masks['visible_feet']&(x>.65);footl=masks['visible_feet']&(x<=.65)
    source_parts={'head':head,'hand_r':handr,'hand_l':handl,'foot_r':footr,'foot_l':footl}
    reports=[]
    def voxel(part,mask,pitch,cliplo,cliphi):
        mesh=trimesh.Trimesh(p,f[mask],process=True);vg=mesh.voxelized(pitch).fill();occ=vg.matrix.copy();origin=vg.transform[:3,3]-pitch*.5
        coords=np.stack(np.meshgrid(*[origin[a]+(np.arange(occ.shape[a])+.5)*pitch for a in range(3)],indexing='ij'),-1);occ&=np.all((coords>=cliplo)&(coords<=cliphi),axis=-1)
        from scipy.ndimage import label
        lab,count=label(occ);sizes=np.bincount(lab.ravel());sizes[0]=0
        if count:
            # Tiny isolated scan residue is omitted; all meaningful finger
            # branches remain. No garment or rear pole is welded into a hand.
            occ &= sizes[lab]>=max(2,sizes.max()*.006)
        boxes=min((greedy(occ.astype('uint8'),o) for o in itertools.permutations(range(3))),key=len)
        for i,(lo,hi,v) in enumerate(boxes):
            a=origin+lo*pitch;b=origin+hi*pitch;a[1]=max(a[1],.16);exposed=[]
            for fa,nn in NORMAL.items():
                axis=int(np.flatnonzero(nn)[0]);k=lo[axis]-1 if nn[axis]<0 else hi[axis];sl=[slice(lo[j],hi[j]) for j in range(3)];sl[axis]=k
                if 0<=k<occ.shape[axis] and np.all(occ[tuple(sl)]):continue
                exposed.append(fa)
            box('source_'+part+'_'+str(i),part,a,b,exposed=exposed)
        reports.append({'part':part,'source_triangles':int(mask.sum()),'cubes':len(boxes),'pitch':pitch})
        print(reports[-1],flush=True)
    voxel('head',head,.5,[-3.2,33.35,-11.7],[2.4,40.55,-4.0])
    voxel('hand_r',handr,.38,[5.5,18.15,-20],[11.1,23.45,-12])
    voxel('hand_l',handl,.38,[-10.5,17.2,2.9],[-5.2,23.1,8.4])
    voxel('foot_r',footr,.55,[.65,.16,-9.8],[6.2,4.1,-1.5])
    voxel('foot_l',footl,.55,[-6.2,.16,-9.8],[.65,4.1,-1.5])
    # Continuous internal shafts and joints. Their proportions follow the
    # real shoulder/elbow/wrist landmarks, including the asymmetric arm pose.
    def rod(name,part,a,b,radius=.7):
        a=np.array(a,float);b=np.array(b,float);steps=max(2,math.ceil(np.linalg.norm(b-a)/.72));half=np.array([radius,.56,radius])
        for i,t in enumerate(np.linspace(0,1,steps)):
            c=a*(1-t)+b*t;box(name+'_'+str(i),part,c-half,c+half)
    rod('spine','chest',[-.4,26,-6.3],[-.4,33.6,-6.3],.6)
    rod('neck_support','neck',[-.4,32.8,-7.2],[-.4,35.2,-7.9],.64)
    for i,yy in enumerate([26.1,27.3,28.5,29.7,30.9,32.1,33.3]):box('vertebra_'+str(i),'chest',[-1.3,yy-.32,-7.1],[.5,yy+.32,-5.8])
    for side in ['r','l']:
        shoulder=np.array(groups['upperarm_'+side]['origin']);elbow=np.array(groups['forearm_'+side]['origin']);wrist=np.array(groups['hand_'+side]['origin'])
        rod('clavicle_'+side,'chest',[-.4,32.8,-8.0],shoulder,.6)
        rod('humerus_'+side,'upperarm_'+side,shoulder,elbow,.68)
        rod('forearm_bone_'+side,'forearm_'+side,elbow,wrist,.58)
        for tag,point,part in [('shoulder',shoulder,'upperarm_'+side),('elbow',elbow,'forearm_'+side),('wrist',wrist,'hand_'+side)]:
            h=np.array([.88,.68,.86]);box(tag+'_joint_'+side,part,point-h,point+h)
    # A permanent covered waist joins torso and the retained garment. This
    # does not claim that unseen naked pelvis/legs existed in the source GLB.
    for i,(yy,rx,rz) in enumerate([(24.5,2.45,2.1),(25.3,2.15,1.9),(26.1,1.8,1.75),(26.9,1.55,1.6),(27.7,1.7,1.6)]):
        c=np.array([-.6,yy,-7]);box('covered_waist_'+str(i),'waist',c-[rx,.47,rz],c+[rx,.47,rz],role='permanent_lower')
    # Light, opaque cloth panels: ten folded sectors rather than large filled
    # garment voxels. The flared hem follows the original navy robe footprint.
    levels=[(24.8,2.5,2.05,-6.7),(20,3.25,3.15,-5.8),(15,3.9,4.5,-4.6),(10,4.8,5.8,-3.0),(6,6.3,7.0,-1.3),(2.3,8.5,10.0,1.2),(.65,11.3,13.5,3.6)]
    for col in range(10):
        theta=col*2*math.pi/10;ang=math.degrees(theta);rr=rotation([0,ang,0]);o=np.array([-.6,24.8,-6.7]);parent='lower_fold_'+str(col);group(parent,'retained_lower_garment',o,[0,ang,0])
        for row,(aa,bbp) in enumerate(zip(levels[:-1],levels[1:])):
            ya,rxa,rza,za=aa;yb,rxb,rzb,zb=bbp
            a=np.array([-.6+math.sin(theta)*rxa,ya,za+math.cos(theta)*rza]);b=np.array([-.6+math.sin(theta)*rxb,yb,zb+math.cos(theta)*rzb]);center=(a+b)/2;delta=(b-a)@rr
            # Group bases carry legal arbitrary rest angles. Individual cubes
            # stay within vanilla's legal single-axis angle choices.
            pitch=math.degrees(math.atan2(-delta[2],-delta[1]));basis=0
            if pitch< -56.25:basis=-90
            elif pitch>56.25:basis=90
            child=parent
            if basis:
                child=parent+'_hem';
                if child not in groups:group(child,parent,o,[basis,0,0])
            angle=min([-45,-22.5,0,22.5,45],key=lambda v:abs(v-(pitch-basis)));local=o+(center-o)@rr
            if basis:local=o+(local-o)@rotation([basis,0,0])
            width=(2*math.pi/10)*((rxa+rxb)/2*abs(math.cos(theta))+(rza+rzb)/2*abs(math.sin(theta)))*1.07
            length=float(np.linalg.norm(delta))+.16;thickness=.16 if row<4 else .19
            # Three narrow slats make a shallow fold while keeping a real
            # front/back/edge volume; no alpha-masked contour card is used.
            for sl in [-1,0,1]:
                cen=local+np.array([sl*width/3,0,.035 if sl else 0]);half=np.array([width/6+.025,length/2,thickness/2]);box(f'lower_{col}_{row}_{sl+1}',child,cen-half,cen+half,role='permanent_lower',angles=[angle,0,0])
    # Bake only from each semantic source set. In particular, navy cloth UVs
    # cannot pick up the large pale rear appendages or bronze poles.
    gs,pa,ep,ns,world=hierarchy(bb);sources={'body':RegionSampler(np.logical_or.reduce(list(source_parts.values())+[masks['torso'],masks['waist']])),'permanent_lower':RegionSampler(masks['permanent_lower_robe'])}
    faces=[]
    for e in records:
        for fa in e.pop('_exposed'):
            qq,nn=face_points(e,fa,gs,ep,world);w=max(2,math.ceil(np.linalg.norm(qq[3]-qq[0])*3.5));h=max(2,math.ceil(np.linalg.norm(qq[1]-qq[0])*3.5));faces.append({'e':e,'fa':fa,'q':qq,'w':w,'h':h,'role':roles[e['uuid']]})
    batches=[]
    for role in ['body','permanent_lower']:
        items=sorted([v for v in faces if v['role']==role],key=lambda a:-a['h']);batch=[];xx=yy=rowh=0
        for item in items:
            w,h=item['w']+2,item['h']+2
            if xx+w>512:xx=0;yy+=rowh;rowh=0
            if yy+h>512:batches.append((role,batch));batch=[];xx=yy=rowh=0
            item['xy']=(xx+1,yy+1);batch.append(item);xx+=w;rowh=max(rowh,h)
        if batch:batches.append((role,batch))
    done=0
    for index,(role,batch) in enumerate(batches):
        atlas=Image.new('RGBA',(512,512));ti=len(bb['textures']);sampler=sources[role]
        for item in batch:
            qq=item['q'];w,h=item['w'],item['h'];uu,vv=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);pts=qq[0]+uu[:,:,None]*(qq[3]-qq[0])+vv[:,:,None]*(qq[1]-qq[0]);patch=sampler.sample(pts.reshape(-1,3)).reshape(h,w,4);xx,yy=item['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(xx-1,yy-1));item['e']['faces'][item['fa']]={'uv':[xx,yy,xx+w,yy+h],'texture':ti};done+=1
            if done%400==0:print('UV baked',done,'/',len(faces),flush=True)
        name=f'a_{role}_{index}_512.png';bio=io.BytesIO();atlas.save(bio,format='PNG');raw=bio.getvalue();(D/name).write_bytes(raw);t=copy.deepcopy(bb['textures'][0]);t.update(name=name,id=str(ti),uuid=uid('texture/'+name),path=str(D/name),relative_path=name,source='data:image/png;base64,'+base64.b64encode(raw).decode());bb['textures'].append(t)
    for t in bb['textures']:
        raw=base64.b64decode(t['source'].split(',',1)[1]);(D/t['name']).write_bytes(raw);t['path']=str(D/t['name']);t['relative_path']=t['name']
    bb['meta']={'format_version':'5.0','model_format':'free','box_uv':False};(D/(TITLE+'.bbmodel')).write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
    aj=copy.deepcopy(native)
    for k in ['elements','groups','outliner','textures','resolution']:aj[k]=copy.deepcopy(bb[k])
    for e in aj['elements']:
        for fv in e['faces'].values():
            if fv.get('texture') is not None:fv['texture']=aj['textures'][fv['texture']]['uuid']
    aj['animations']=[];aj['meta'].update(uuid=uid('project'),save_location=str(D/(TITLE+'.ajblueprint')));(D/(TITLE+'.ajblueprint')).write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
    count=Counter(roles.values());groupscount=Counter(gs[ep[e['uuid']]]['name'] for e in bb['elements']);report={'cubes':len(bb['elements']),'groups':len(bb['groups']),'roles':dict(count),'by_group':dict(groupscount),'defined_faces':sum(fv.get('texture') is not None for e in bb['elements'] for fv in e['faces'].values()),'textures':len(bb['textures']),'source_fitted_parts':reports,'upper_dissolvable_cloth_created':False,'rear_hard_components_created':False,'hidden_lower_anatomy_invented':False,'animations':0,'game_tested':False};(D/'常驻主体统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');(D/'常驻主体归属.json').write_text(json.dumps(roles,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
    pp,nn,uu,ff,tt=collect_scene(bb)
    sheet=Image.new('RGB',(2880,1100),'#171c23')
    for i,(label,view) in enumerate([('正面',(0,0,-1)),('侧面',(1,0,0)),('背面',(0,0,1)),('45度',(1,.08,-1))]):
        vis=nn[ff[:,0]]@np.array(view)>1e-6;rgba,_,_=raster(pp,nn,uu,ff[vis],tt,view,width=720,height=1100,ppu=21,center=(0,21,-4),cutout=True,lit=True);im=card(rgba,'实际常驻主体 · '+label);sheet.paste(im,(720*i,0));im.save(D/('常驻主体_'+label+'.png'))
    sheet.save(D/'常驻主体_实际四视图.png')

if __name__=='__main__':main()
