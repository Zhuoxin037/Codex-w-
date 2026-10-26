"""A first review section: source-fitted upper body, not the full character.

Only real positive-volume Cubes; no source GLB mesh or poster planes are
embedded. The lower robe/hands will be made after this section is reviewed.
"""
from analyze_a_boss_static_20261022 import R,O,REF,S,source
from build_b_staff_static_20261021 import greedy,layout,card,VERTS,NORMAL
from boss_texture_transfer import Source
from refine_b_headcloth_20261022 import collect_scene
from boss_glb_utils import raster
from PIL import Image
from collections import defaultdict,Counter
import numpy as np,math,json,base64,io,uuid,itertools,time,copy

def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:a_ghost/upper-static/'+s))

class ASampler(Source):
    def __init__(self):
        self.p,_,self.uv,f,self.tex=source();self.f=f[self.p[f].mean(1)[:,1]>26.8];self.tri=self.p[self.f];self.cell=.9;self.grid=defaultdict(list);self.cache={};self.max_error=0.;self.distances=[]
        for i,t in enumerate(self.tri):
            lo=np.floor(t.min(0)/self.cell).astype(int);hi=np.floor(t.max(0)/self.cell).astype(int)
            for key in itertools.product(*[range(lo[a],hi[a]+1) for a in range(3)]):self.grid[key].append(i)

def main():
    data=np.load(REF/'voxel_0.65.npz');occ=data['labels'].copy();origin=data['origin'];step=float(data['step']);x,y,z=np.meshgrid(*[origin[a]+(np.arange(occ.shape[a])+.5)*step for a in range(3)],indexing='ij');occ[y<28]=0
    # The first delivered section has an explicit horizontal work boundary.
    # The model is not presented as a complete or amputated final character.
    parts=['torso_upper','neck_drape','head_crown','shoulder_right','shoulder_left','frame_front','frame_back']
    labels=np.ones_like(occ);labels[(x>4.4)&(y<40)]=4;labels[(x< -4.4)&(y<40)]=5;labels[(z< -11.8)&(y<39.3)]=6;labels[(z>1.2)&(y>33.5)&(y<40)]=7;labels[(abs(x)<3.8)&(y>=33.4)&(y<40)&(z< -3.8)&(z> -10.8)]=2;labels[y>=40]=3;labels*=occ
    fits=[]
    for order in itertools.permutations(range(3)):fits.append((len(a:=greedy(labels,order)),order,a))
    _,order,boxes=min(fits,key=lambda a:a[0]);print('source-fitted boxes',len(boxes),'order',order,flush=True)
    roots={'root':([0,0,0],None),'torso_upper':([0,30,-3], 'root'),'neck_drape':([-.4,33.4,-7.2],'torso_upper'),'head_crown':([-.4,40,-7.8],'neck_drape'),'shoulder_right':([5.5,32,-3],'torso_upper'),'shoulder_left':([-5.5,32,-3],'torso_upper'),'frame_front':([5.8,34,-11.8],'torso_upper'),'frame_back':([5.8,34,1.2],'torso_upper')}
    groups=[];nodes={};out=[]
    for name,(pivot,par) in roots.items():
        g={'name':name,'uuid':uid('group/'+name),'origin':pivot,'rotation':[0,0,0],'export':True,'visibility':True,'color':len(groups)%8,'configs':{'default':{},'variants':{}},'onSummonFunction':'','itemModelProperties':{'tints':[]}};groups.append(g);node={'uuid':g['uuid'],'children':[],'isOpen':True};nodes[name]=node
        if par:nodes[par]['children'].append(node)
        else:out.append(node)
    elements=[];faces=[];culled=0
    for i,(lo,hi,label) in enumerate(boxes):
        name=parts[label-1];low=origin+lo*step;high=origin+hi*step;e={'name':name+'_'+str(i).zfill(3),'uuid':uid('cube/'+str(i)),'type':'cube','from':low.round(6).tolist(),'to':high.round(6).tolist(),'origin':((low+high)/2).round(6).tolist(),'rotation':[0,0,0],'rescale':False,'shade':False,'box_uv':False,'export':True,'visibility':True,'faces':{fa:{'uv':[0,0,1,1],'texture':None} for fa in NORMAL}};elements.append(e);nodes[name]['children'].append(e['uuid'])
        for fa,nn in NORMAL.items():
            axis=int(np.flatnonzero(nn)[0]);sign=nn[axis];index=lo[axis]-1 if sign<0 else hi[axis];neighbor=None
            if 0<=index<labels.shape[axis]:
                sel=[slice(lo[a],hi[a]) for a in range(3)];sel[axis]=index;neighbor=labels[tuple(sel)]
            if neighbor is not None and np.all(neighbor==label):culled+=1;continue
            q=np.array(VERTS[fa])*(high-low)+low;w=max(2,math.ceil(np.linalg.norm(q[3]-q[0])*4));h=max(2,math.ceil(np.linalg.norm(q[1]-q[0])*4));faces.append({'e':e,'name':fa,'q':q,'width':w,'height':h})
    size=512
    if not layout(faces,size):
        for f in faces:f['width']=max(2,math.ceil(f['width']*.8));f['height']=max(2,math.ceil(f['height']*.8))
        assert layout(faces,size),'UV must fit, never clip silently'
    atlas=Image.new('RGBA',(size,size));sampler=ASampler();started=time.time()
    for i,face in enumerate(faces):
        q=face['q'];w,h=face['width'],face['height'];u,v=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);pts=q[0]+u[:,:,None]*(q[3]-q[0])+v[:,:,None]*(q[1]-q[0]);patch=sampler.sample(pts.reshape(-1,3)).reshape(h,w,4);px,py=face['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1));face['e']['faces'][face['name']]={'uv':[px,py,px+w,py+h],'texture':0}
        if i%300==0:print('source color transferred',i,'/',len(faces),'seconds',round(time.time()-started,1),flush=True)
    texname='a_upper_source_basecolor_512.png';atlas.save(S/texname);bio=io.BytesIO();atlas.save(bio,format='PNG');texture={'name':texname,'id':'0','uuid':uid('texture'),'width':512,'height':512,'uv_width':512,'uv_height':512,'path':str(S/texname),'relative_path':texname,'render_mode':'default','render_sides':'auto','internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode(bio.getvalue()).decode()}
    bb={'meta':{'format_version':'4.10','model_format':'free','box_uv':False},'name':'A_头胸与悬架_第一批静态','resolution':{'width':512,'height':512},'elements':elements,'groups':groups,'outliner':out,'textures':[texture],'animations':[]}
    (S/'A_头胸与悬架_第一批静态.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
    template=R/'模型设计/B_白蓝覆面持杖_GLB重建_20261021/阶段一_静态模型/局部修补三_胸带与垂饰_20261022/B_原造型_胸带垂饰独立修复.ajblueprint';aj=json.loads(template.read_text(encoding='utf8'))
    for key in ['elements','groups','outliner','textures','resolution']:aj[key]=copy.deepcopy(bb[key])
    for e in aj['elements']:
        for f in e['faces'].values():
            if f.get('texture') is not None:f['texture']=texture['uuid']
    aj['meta'].update(uuid=uid('project'),save_location=str(S/'A_头胸与悬架_第一批静态.ajblueprint'),last_used_blueprint_id='sweetdream_boss:a_ghost');aj['blueprint_settings'].update(blueprint_id='sweetdream_boss:a_ghost',resource_pack_export_mode='none',data_pack_export_mode='none',target_minecraft_version='1.21.5');aj['variants']['default'].update(uuid=uid('variant'),slot_textures={},excluded_nodes=[]);aj['variants']['list']=[];aj.pop('animations',None)
    (S/'A_头胸与悬架_第一批静态.ajblueprint').write_text(json.dumps(aj,ensure_ascii=False,indent=2),encoding='utf8')
    report={'stage':'Static section 1: actual upper source y>=28. Lower robe and hands not yet built; this is not the complete character.','cubes':len(elements),'groups':len(groups),'faces':len(faces),'culled_internal_faces':culled,'texture':[512,512],'source_triangles':len(source()[3]),'fit_pitch':step,'counts_by_part':dict(Counter(parts[b[2]-1] for b in boxes)),'texture_transfer_distance_percentiles':np.percentile(sampler.distances,[50,95,100]).tolist(),'animations':0,'game_exported':False,'game_tested':False};(S/'第一批静态结构统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(report,flush=True)
    p,n,u,f,t=collect_scene(bb);sheet=Image.new('RGB',(2560,900),'#171c23')
    for i,(name,d) in enumerate([('正面',(0,0,-1)),('侧面',(1,0,0)),('背面',(0,0,1)),('45度',(1,.08,-1))]):
        vis=n[f[:,0]]@np.array(d)>1e-6;rgba,_,_=raster(p,n,u,f[vis],t,d,width=640,height=900,ppu=28,center=(0,37.7,-4),cutout=True,lit=False);im=card(rgba,'第一批实际Cube · '+name);im.save(S/('第一批_'+name+'.png'));sheet.paste(im,(i*640,0))
    sheet.save(S/'第一批实际模型_四视图.png')

if __name__=='__main__':main()
