"""Build editable cubes and bake their textures from the actual GLB UVs."""
from dream_knight_common import *
import base64,io,uuid,time
from PIL import ImageFilter
from collections import Counter
import boss_texture_transfer as transfer
from boss_texture_transfer import VERTS,NORMAL

def rotation(e):
    x,y,z=np.radians(e.get('rotation',[0,0,0]));cx,sx=math.cos(x),math.sin(x);cy,sy=math.cos(y),math.sin(y);cz,sz=math.cos(z),math.sin(z)
    return np.array([[cz,-sz,0],[sz,cz,0],[0,0,1]])@np.array([[cy,0,sy],[0,1,0],[-sy,0,cy]])@np.array([[1,0,0],[0,cx,-sx],[0,sx,cx]])

def face_vertices(e,face):
    q=np.array(VERTS[face])*(np.array(e['to'])-e['from'])+e['from'];origin=np.array(e['origin'])
    q=(q-origin)@rotation(e).T+origin
    if e.get('cape'):
        q=(q-e['group_origin'])@np.array(e['world_rotation']).T+e['world_pivot']
    return q

def projection_sample(image,row,col):
    row=np.clip(row.astype(int),0,899);col=np.clip(col.astype(int),0,719);patch=image[row,col].copy()
    missing=patch[:,:,3]==0
    for radius in [1,2,4,8,16,32]:
        if not missing.any():break
        for dr,dc in [(-radius,0),(radius,0),(0,-radius),(0,radius),(-radius,-radius),(-radius,radius),(radius,-radius),(radius,radius)]:
            other=image[np.clip(row+dr,0,899),np.clip(col+dc,0,719)];take=missing&(other[:,:,3]>0);patch[take]=other[take];missing[take]=False
    patch[missing]=[85,75,94,255];patch[:,:,3]=255
    return patch

def smooth_projection(image):
    # Source projections are 15 px/unit; the atlas is 3-4.6 px/unit. Filtering
    # before downsampling preserves thin grooves without black aliasing specks.
    a=np.array(Image.fromarray(image).filter(ImageFilter.GaussianBlur(1.45))).astype(float)
    rgb=np.divide(a[:,:,:3]*255,a[:,:,3,None],out=np.zeros_like(a[:,:,:3]),where=a[:,:,3,None]>1)
    out=image.copy();out[:,:,:3]=np.clip(rgb,0,255).astype(np.uint8)
    return out

def part_projections():
    p,n,uv,f,texture=load();c=p[f].mean(1);labels=classify(c[:,0],c[:,1],c[:,2]);cloth=cape_faces(p,uv,f,texture)|tabard_faces(p,f)
    pp=p[:,[0,2,1]].copy();pp[:,1]+=24;nn=n[:,[0,2,1]]
    result={}
    for i,part in enumerate(PARTS,1):
        fs=f[(labels==i)&~cloth];views={}
        for name,direction in [('正面',(0,0,-1)),('背面',(0,0,1)),('右侧',(1,0,0)),('左侧',(-1,0,0))]:
            rgba,*_=raster(p,n,uv,fs,texture,direction,lit=False);views[name]=smooth_projection(rgba)
        for name,direction in [('上方',(0,0,1)),('下方',(0,0,-1))]:
            rgba,*_=raster(pp,nn,uv,fs,texture,direction,lit=False);views[name]=smooth_projection(rgba)
        result[part]=views
        print('part projection',part,len(fs),flush=True)
    return result

def layout(faces,size):
    x=y=row=0
    for f in sorted(faces,key=lambda f:-f['height']):
        w,h=f['width']+2,f['height']+2
        if x+w>size:x=0;y+=row;row=0
        if y+h>size:return False
        f['xy']=(x+1,y+1);x+=w;row=max(row,h)
    return True

def build():
    fit=json.loads((STAGE/'拟合几何.json').read_text(encoding='utf8'));cubes=fit['cubes']
    v=np.load(STAGE/'躯体体素分区.npz');labels,origin,step=v['labels'],v['origin'],float(v['step'])
    faces=[]
    for i,e in enumerate(cubes):
        density=4.6 if e['part']=='Head' else 2.5 if e.get('cape') else 3.0
        e['faces']={};e['density']=density
        visible=list(NORMAL) if e.get('cape') or e.get('tabard') else [x['name'] for x in transfer.faces(e,labels,origin,step)]
        for name in visible:
            vs=face_vertices(e,name)
            w=max(2,math.ceil(np.linalg.norm(vs[3]-vs[0])*density));h=max(2,math.ceil(np.linalg.norm(vs[1]-vs[0])*density))
            faces.append({'cube':i,'name':name,'vs':vs,'width':w,'height':h})
    tried=[]
    for size in [256,512]:
        okay=layout(faces,size);tried.append({'size':size,'fits':okay})
        if okay:break
    else:raise RuntimeError('Texture islands exceed 512; refine packing before increasing texture size')
    transfer.OUT=OUT;source=transfer.Source();atlas=Image.new('RGBA',(size,size))
    cape_front=np.load(REF/'披风_正面_分离投影.npz')['rgba'];cape_back=np.load(REF/'披风_背面_分离投影.npz')['rgba']
    tabard_front=np.load(REF/'垂布_正面_分离投影.npz')['rgba'];tabard_back=np.load(REF/'垂布_背面_分离投影.npz')['rgba']
    all_projections=part_projections()
    started=time.time()
    for i,f in enumerate(faces):
        e=cubes[f['cube']];w,h=f['width'],f['height'];vs=f['vs'];uu,vv=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h)
        points=vs[0]+uu[:,:,None]*(vs[3]-vs[0])+vv[:,:,None]*(vs[1]-vs[0])
        if e.get('cape') or e.get('tabard'):
            row=np.clip((450-(points[:,:,1]-24)*15).astype(int),0,899)
            cb=np.clip((360+points[:,:,0]*15).astype(int),0,719);cf=np.clip((360-points[:,:,0]*15).astype(int),0,719)
            back=(tabard_back if e.get('tabard') else cape_back)[row,cb];front=(tabard_front if e.get('tabard') else cape_front)[row,cf]
            patch=(front if f['name']=='north' else back).copy()
            # Use the complete back silhouette for both sides of the cloth;
            # original torn hems are represented by pixel cutout, not tiny cubes.
            missing=(patch[:,:,3]==0)&(back[:,:,3]>0);patch[missing]=back[missing]
            patch[:,:,3]=(front if e.get('tabard') else back)[:,:,3]
        else:
            projections=all_projections[e['part']]
            x,y,z=points.transpose(2,0,1);row=450-(y-24)*15
            if f['name']=='north':patch=projection_sample(projections['正面'],row,360-x*15)
            elif f['name']=='south':patch=projection_sample(projections['背面'],row,360+x*15)
            elif f['name']=='east':patch=projection_sample(projections['右侧'],row,360-z*15)
            elif f['name']=='west':patch=projection_sample(projections['左侧'],row,360+z*15)
            elif f['name']=='up':patch=projection_sample(projections['上方'],450-z*15,360+x*15)
            else:patch=projection_sample(projections['下方'],450-z*15,360-x*15)
        px,py=f['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1))
        e['faces'][f['name']]={'uv':[px,py,px+w,py+h],'texture':0}
        if i%250==0:print('baked',i,'/',len(faces),'seconds',round(time.time()-started,1),flush=True)
    texture_name=f'dream_knight_basecolor_{size}.png';atlas.save(STAGE/texture_name)
    group_specs=[
      ('Root',None,[0,0,0]),('Pelvis','Root',[0,24.8,-4.5]),('Waist','Pelvis',[0,28.2,-4.5]),('Chest','Waist',[0,30,-4.9]),('Head','Chest',[0,40.15,-4.6]),
      ('Shoulder_R','Chest',[6.6,36.5,-4.5]),('UpperArm_R','Shoulder_R',[7.8,34.5,-4.4]),('Forearm_R','UpperArm_R',[8.8,28.5,-4.8]),('Hand_R','Forearm_R',[9.6,22,-4.6]),
      ('Shoulder_L','Chest',[-6.6,36.5,-4.5]),('UpperArm_L','Shoulder_L',[-7.8,34.5,-4.4]),('Forearm_L','UpperArm_L',[-8.8,28.5,-4.8]),('Hand_L','Forearm_L',[-9.6,22,-4.6]),
      ('Thigh_R','Pelvis',[3.6,24.8,-4.4]),('Shin_R','Thigh_R',[4.3,14.7,-4.2]),('Foot_R','Shin_R',[4.6,4.3,-4.3]),
      ('Thigh_L','Pelvis',[-3.6,24.8,-4.4]),('Shin_L','Thigh_L',[-4.3,14.7,-4.2]),('Foot_L','Shin_L',[-4.6,4.3,-4.3]),
      ('Cape','Chest',[0,38.2,0]),('Cape_Upper','Cape',[0,38.2,0]),('Cape_Mid','Cape_Upper',[0,29,2]),('Cape_Lower','Cape_Mid',[0,15,6])]
    groups=[];nodes={};out=[]
    for i,(name,parent,pivot) in enumerate(group_specs):
        spec=fit.get('cape_rig',{}).get(name,{})
        pivot=spec.get('origin',pivot)
        uid=str(uuid.uuid4());groups.append({'name':name,'uuid':uid,'export':True,'visibility':True,'origin':pivot,'rotation':spec.get('rotation',[0,0,0]),
            'color':i%8,'children':[],'reset':False,'shade':True,'mirror_uv':False,'isOpen':True})
        node={'uuid':uid,'isOpen':True,'children':[]};nodes[name]=node
        (nodes[parent]['children'] if parent else out).append(node)
    elements=[]
    for i,e in enumerate(cubes):
        uid=str(uuid.uuid4());elements.append({'name':e['part']+f'_{i:03}','type':'cube','uuid':uid,
          'from':e['from'],'to':e['to'],'origin':e['origin'],'rotation':[round(v,5) for v in e['rotation']],
          'box_uv':False,'rescale':False,'shade':True,'export':True,
          'faces':{name:e['faces'].get(name,{'uv':[0,0,1,1],'texture':None}) for name in NORMAL}})
        nodes[e['part']]['children'].append(uid)
    png=io.BytesIO();atlas.save(png,format='PNG')
    bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':'坠梦骑士_阶段一_静态审阅',
      'model_identifier':'dream_knight','visible_box':[4,4,0],'resolution':{'width':size,'height':size},'elements':elements,'groups':groups,
      'outliner':out,'textures':[{'name':texture_name,'id':'0','uuid':str(uuid.uuid4()),'width':size,'height':size,'uv_width':size,'uv_height':size,
          'relative_path':texture_name,'path':str(STAGE/texture_name),'folder':'','namespace':'','render_mode':'default','render_sides':'auto',
          'internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode(png.getvalue()).decode()}],'animations':[]}
    (STAGE/'坠梦骑士_分组可编辑_静态.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
    report={'source':'52cf381414dc9bb1cec0d47decf99780.glb','cubes':len(cubes),'body_cubes':fit['body_cubes'],'cape_cubes':fit['cape_cubes'],
      'defined_faces':len(faces),'disabled_internal_faces':6*len(cubes)-len(faces),'groups':len(groups),'animations':0,
      'texture_size':[size,size],'texture_packing_attempts':tried,'counts_by_group':dict(Counter(e['part'] for e in cubes)),
      'voxel_pitch':step,'texture_method':'Six directional projections of the actual GLB base-color; no additional baked lighting.',
      'working_height_blocks':3,'pbr_note':'Only base color is used by vanilla; normal and metal/roughness maps archived as reference.',
      'cape_geometry_note':'Large draped thin cube panels; original torn silhouette cut out in both-sided pixel textures.',
      'display_entities_exported':0,'display_entity_estimate':len(groups),'datapack_exported':False,'game_tested':False}
    (STAGE/'静态结构统计.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps(report,ensure_ascii=False),flush=True)

if __name__=='__main__':build()
