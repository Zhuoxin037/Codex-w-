"""Source-constrained static Cube rebuild for GLB B. No game files modified."""
from pathlib import Path
import sys,json,math,io,base64,uuid,itertools,time,hashlib
import numpy as np
from PIL import Image,ImageDraw,ImageFont,ImageFilter
from inspect_new_glbs_20261021 import read
from boss_glb_utils import raster

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'模型设计/B_白蓝覆面持杖_GLB重建_20261021'
REF=OUT/'母版分析';STAGE=OUT/'阶段一_静态模型'
for d in [REF,STAGE]:d.mkdir(parents=True,exist_ok=True)
SOURCE=ROOT/'02d4337d49650cc9e93c4904b90f2f2e.glb'
FONT=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',19)
SMALL=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',14)
VERTS={'north':[(1,1,0),(1,0,0),(0,0,0),(0,1,0)],'south':[(0,1,1),(0,0,1),(1,0,1),(1,1,1)],'east':[(1,1,1),(1,0,1),(1,0,0),(1,1,0)],'west':[(0,1,0),(0,0,0),(0,0,1),(0,1,1)],'up':[(0,1,0),(0,1,1),(1,1,1),(1,1,0)],'down':[(0,0,1),(0,0,0),(1,0,0),(1,0,1)]}
NORMAL={'north':[0,0,-1],'south':[0,0,1],'east':[1,0,0],'west':[-1,0,0],'up':[0,1,0],'down':[0,-1,0]}

def source():
    f=REF/'source.npz'
    if not f.exists():
        p,n,uv,t,tex,report=read(SOURCE)
        np.savez_compressed(f,p=p,n=n,uv=uv,f=t,texture=tex)
        Image.fromarray(tex).save(REF/'source_basecolor_4096.png')
        (REF/'GLB分析.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    d=np.load(f);return [d[k] for k in ['p','n','uv','f','texture']]

def card(rgba,label):
    im=Image.new('RGB',(rgba.shape[1],rgba.shape[0]),'#171c23');im.paste(Image.fromarray(rgba),mask=Image.fromarray(rgba[:,:,3]));ImageDraw.Draw(im).text((15,12),label,font=FONT,fill='#ece7db');return im

CX=-2.5;CZ=-2.6
PARTS=['pelvis','waist','chest','neck','head','arm_upper_right','arm_lower_right','hand_right','arm_upper_left','arm_lower_left','hand_left','leg_upper_right','leg_lower_right','foot_right','leg_upper_left','leg_lower_left','foot_left','staff','coat','tabard','head_drape_front','head_drape_back']

def classify(points):
    x,y,z=np.asarray(points).T;xx=x-CX;zz=z-CZ
    side=np.where(xx>=0,0,3)
    result=11+side+np.where(y<3.5,2,np.where(y<11.8,1,0))
    result=np.where(y>=25.2,np.where(y<29.4,0,np.where(y<31.8,1,2)),result)
    # Bent right forearm is in front of the torso. No broad hand bounding box
    # is allowed to claim coat tails, straps, or the pelvis.
    arms=(y>21)&(y<39.7)&(abs(xx)>np.interp(y,[21,29,35,40],[7.6,6.9,6.0,6.7]))
    arm=5+side+np.where(xx>=0,np.where((z<-6.5)&(y<32.5),2,np.where(y<33.1,1,0)),np.where(y<24.3,2,np.where(y<29.2,1,0)))
    result=np.where(arms,arm,result)
    result=np.where((y>40.0)&(abs(xx)<4.5),4,result)
    result=np.where((y>38.5)&(y<=40)&(abs(xx)<3.2),3,result)
    # The shaft's actual lean and depth are taken from the source bands.
    sx=8.2+y*.041
    staff=((x-sx)**2+(z+7.5)**2<1.12**2)&((y<28.8)|(y>32.4))
    staff|=(x>7.8)&(y>36.8)&(y<43.2)&(z<-6.5)
    result=np.where(staff,17,result)
    # Independent original cloth surfaces, rather than a solid skirt hull.
    rx=np.interp(y,[7,29.4],[13.0,6.0]);rz=np.interp(y,[7,29.4],[12.0,5.0])
    r=((xx/rx)**2+((z-CZ)/rz)**2)**.5
    coat=(y>=6.5)&(y<29.3)&(r>.73)&~arms&~staff
    result=np.where(coat,18,result)
    tab=(y>7.5)&(y<29.2)&(x>-5.8)&(x<-.4)&(z<-5.65)
    result=np.where(tab,19,result)
    front=(y>35.5)&(y<44.4)&(x>-5.7)&(x<-2.6)&(z<-5.5)
    back=(y>30.5)&(y<44.4)&(x>-4.4)&(x<-1.2)&(z>-.4)
    result=np.where(front,20,np.where(back,21,result))
    return result.astype(int)

def separation():
    p,n,uv,f,tex=source();labels=classify(p[f].mean(1))
    cc=p[f].mean(1);tu=uv[f].mean(1);rgb=tex[np.clip((tu[:,1]*4096).astype(int),0,4095),np.clip((tu[:,0]*4096).astype(int),0,4095),:3].astype(float)
    fabric=(rgb.mean(1)>66)|((rgb[:,2]>rgb[:,0]*1.3)&(rgb[:,2]>rgb[:,1]*1.08))
    # Reject dark charcoal trouser triangles caught by a spatial outer envelope.
    pants=(labels==18)&~fabric
    labels[pants]=np.where(cc[pants,0]>CX,11,14)
    # White robe triangles below the belt remain cloth even when the flap
    # passes in front of a thigh. Charcoal trousers remain actual body.
    low_cloth=(cc[:,1]>11.8)&(cc[:,1]<29.3)&fabric&~np.isin(labels,[5,6,7,8,9,10,17,19])
    labels[low_cloth]=18
    # Save regions for texture transfer, avoiding projected robe paint on legs.
    np.save(REF/'triangle_parts.npy',labels)
    cloth=np.isin(labels,[18,19]);colors=np.array([[225,203,153],[68,112,196],[204,112,96],[106,177,130]])
    tri_color=np.zeros((len(p),4),dtype=np.uint8)
    ims=[]
    for tag,mask in [('衣摆',cloth),('躯体',~cloth&(labels!=17)),('法杖',labels==17)]:
        print(tag,int(mask.sum()),flush=True)
        for name,d in [('正面',(0,0,-1)),('右侧',(1,0,0)),('背面',(0,0,1))]:
            rgba,_,_=raster(p,n,uv,f[mask],tex,d,width=540,height=760,ppu=14,lit=False)
            ims.append(card(rgba,f'{tag} · {name}'))
    sheet=Image.new('RGB',(540*3,760*3))
    for i,im in enumerate(ims):sheet.paste(im,((i%3)*540,(i//3)*760))
    sheet.save(REF/'部件分离检查.png')

def projections():
    p,n,uv,f,tex=source();labels=np.load(REF/'triangle_parts.npy')
    body=~np.isin(labels,[17,18,19,20,21])|(np.isin(labels,[20,21])&(p[f].mean(1)[:,1]>=40))
    for name,d in [('north',(0,0,-1)),('south',(0,0,1)),('east',(1,0,0)),('west',(-1,0,0)),('up',(0,1,0)),('down',(0,-1,0))]:
        rgba,dep,ids=raster(p,n,uv,f[body],tex,d,width=720,height=900,ppu=15,lit=False)
        np.savez_compressed(REF/f'body_{name}.npz',rgba=rgba,depth=dep)
    print('BODY PROJECTIONS COMPLETE',flush=True)

def greedy(labels,order):
    a=labels.transpose(order).copy();boxes=[]
    for i,j,k in np.argwhere(a):
        value=a[i,j,k]
        if not value:continue
        k1=k+1
        while k1<a.shape[2] and a[i,j,k1]==value:k1+=1
        j1=j+1
        while j1<a.shape[1] and np.all(a[i,j1,k:k1]==value):j1+=1
        i1=i+1
        while i1<a.shape[0] and np.all(a[i1,j:j1,k:k1]==value):i1+=1
        a[i:i1,j:j1,k:k1]=0
        lo=np.empty(3,int);hi=np.empty(3,int);lo[list(order)]=[i,j,k];hi[list(order)]=[i1,j1,k1]
        boxes.append((lo,hi,int(value)))
    return boxes

def occupancy(step):
    lo=np.array([-14.25,0,-10.5]);hi=np.array([14.25,48.3,10.5]);shape=np.ceil((hi-lo)/step).astype(int)
    x,y,z=np.meshgrid(*[lo[i]+(np.arange(shape[i])+.5)*step for i in range(3)],indexing='ij')
    row=np.clip((450-(y-24)*15).astype(int),0,899)
    depth={k:np.load(REF/f'body_{k}.npz')['depth'] for k in ['north','south','east','west']}
    nf=depth['north'][row,np.clip((360-x*15).astype(int),0,719)];sf=depth['south'][row,np.clip((360+x*15).astype(int),0,719)]
    ef=depth['east'][row,np.clip((360-z*15).astype(int),0,719)];wf=depth['west'][row,np.clip((360+z*15).astype(int),0,719)]
    occ=(nf>-1e6)&(sf>-1e6)&(ef>-1e6)&(wf>-1e6)&(z>=-nf-step*.08)&(z<=sf+step*.08)&(x>=-wf-step*.08)&(x<=ef+step*.08)
    labels=classify(np.stack([x.ravel(),y.ravel(),z.ravel()],1)).reshape(x.shape)
    # Voxel classifiers for anatomy, not thin cloth labels.
    labels=np.where(labels>=17,np.where(y>35,4,np.where(y>25.2,0,np.where(x>CX,11,14))),labels)
    labels=(labels+1)*occ
    head=(((x-CX)/2.7)**2+((z+3.0)/3.1)**2<=1)&(y>=40.0)&(y<46.4)&(labels==0)
    labels[head]=5
    # Continuous hidden trouser volume. This is fitted within the original
    # exposed pants outline, never inferred from a coat silhouette.
    for sign,part in [(1,11),(-1,14)]:
        cx=CX+sign*np.interp(y,[3.5,12,25.2],[5.1,4.9,2.8])
        radius_x=np.interp(y,[3.5,11.8,25.2],[1.7,2.55,2.8]);radius_z=np.interp(y,[3.5,11.8,25.2],[2.0,3.0,3.15])
        pants=((x-cx)/radius_x)**2+((z-(CZ+.25))/radius_z)**2<=1
        add=pants&(y>=3.5)&(y<25.2)&(labels==0)
        label=np.where(y<11.8,part+1,part)+1;labels[add]=label[add]
    # Hips join the two legs beneath the belt; no isolated crotch plug.
    core=(((x-CX)/5.5)**2+((z-CZ)/3.1)**2<=1)&(y>=23)&(y<29.2)&(labels==0)
    labels[core]=1
    # A visual hull built after removing a front/back drape can leave an
    # artificial tunnel through the chest. Complete the clothed torso itself.
    rx=np.interp(y,[25.2,29.4,31.8,36,38.25,39.75,40.5],[5.45,5.0,5.7,6.0,4.9,2.6,2.65])
    rz=np.interp(y,[25.2,29.4,31.8,36,38.25,39.75,40.5],[3.05,3.05,3.65,3.6,3.25,2.7,2.9])
    torso=(((x-CX)/rx)**2+((z-CZ)/rz)**2<=1)&(y>=25.2)&(y<40.5)
    owner=np.where(y<29.4,1,np.where(y<31.8,2,np.where(y<38.5,3,np.where(y<40,4,5))))
    labels[torso&(labels==0)]=owner[torso&(labels==0)]
    # Complete the left elbow inside the sleeve. The separated source sleeve
    # otherwise leaves only a two-voxel contact strip at this joint.
    elbow=(((x+11.0)/1.35)**2+((y-29.2)/1.35)**2+((z+1.0)/1.4)**2<=1)
    elbow_owner=np.where(y<29.2,10,9)
    missing=elbow&(labels==0);labels[missing]=elbow_owner[missing]
    # Small detached projection residues are stitched into their actual rigid
    # part instead of being left as floating cubes. No body region is deleted.
    from collections import deque
    def components(mask):
        unseen=set(map(tuple,np.argwhere(mask)));found=[]
        while unseen:
            seed=unseen.pop();q=deque([seed]);cells=[seed]
            while q:
                c=q.popleft()
                for ax in range(3):
                    for sg in [-1,1]:
                        d=list(c);d[ax]+=sg;d=tuple(d)
                        if d in unseen:unseen.remove(d);q.append(d);cells.append(d)
            found.append(np.array(cells,int))
        return sorted(found,key=len,reverse=True)
    for value in range(1,18):
        comps=components(labels==value)
        if len(comps)<2:continue
        main=comps[0]
        for component in comps[1:]:
            dd=((component[:,None,:]-main[None,:,:])**2).sum(-1);a,b=np.unravel_index(dd.argmin(),dd.shape);start=component[a].copy();end=main[b]
            # Axis stepping keeps a face-connected path, unlike a diagonal
            # sequence that only meets at edges or corners.
            current=start.copy();path_cells=[]
            while not np.array_equal(current,end):
                delta=end-current;axis=int(abs(delta).argmax());current=current.copy();current[axis]+=int(np.sign(delta[axis]));key=tuple(current)
                if labels[key]==0:labels[key]=value;path_cells.append(current.copy())
                elif labels[key]!=value:
                    # An already solid adjacent joint is not overwritten.
                    pass
            main=np.vstack([main,component,np.array(path_cells).reshape(-1,3)])
    # A tiny collar/cuff remnant that is connected only through the adjoining
    # rigid bone belongs to that bone. Transfer ownership; keep all geometry.
    for _ in range(5):
        changed=False
        main_sets={i:set(map(tuple,components(labels==i)[0])) for i in range(1,18) if np.any(labels==i)}
        for value in range(1,18):
            for component in components(labels==value)[1:]:
                touches={}
                for c in component:
                    for ax in range(3):
                        for sg in [-1,1]:
                            d=c.copy();d[ax]+=sg
                            if np.any(d<0) or np.any(d>=labels.shape):continue
                            other=int(labels[tuple(d)])
                            if other>0 and other!=value and tuple(d) in main_sets.get(other,set()):touches[other]=touches.get(other,0)+1
                if touches and len(component)<=32:
                    target=max(touches,key=touches.get)
                    labels[tuple(component.T)]=target;changed=True
        if not changed:break
    # Fill enclosed sampling pinholes, while preserving real exterior spaces
    # between limbs and beneath the coat.
    air=labels==0;seen=np.zeros_like(air);boundary=np.zeros_like(air)
    boundary[[0,-1],:,:]=True;boundary[:,[0,-1],:]=True;boundary[:,:,[0,-1]]=True
    seeds=np.argwhere(air&boundary);queue=deque(map(tuple,seeds));seen[tuple(seeds.T)]=True
    while queue:
        c=queue.popleft()
        for ax in range(3):
            for sg in [-1,1]:
                d=list(c);d[ax]+=sg
                if d[ax]<0 or d[ax]>=labels.shape[ax]:continue
                d=tuple(d)
                if air[d] and not seen[d]:seen[d]=True;queue.append(d)
    for c in np.argwhere(air&~seen):
        neighbors=[]
        for ax in range(3):
            for sg in [-1,1]:
                d=c.copy();d[ax]+=sg;v=int(labels[tuple(d)])
                if v:neighbors.append(v)
        if neighbors:labels[tuple(c)]=max(set(neighbors),key=neighbors.count)
    return labels,lo

def fit():
    options=[]
    for pitch in [.65,.7,.75,.8,.85]:
        labels,origin=occupancy(pitch);choices=[greedy(labels,o) for o in itertools.permutations(range(3))]
        boxes=min(choices,key=len);options.append((pitch,labels,origin,boxes));print('FIT',pitch,len(boxes),flush=True)
    viable=[o for o in options if len(o[3])<605]
    pitch,labels,origin,boxes=(viable or options)[0]
    cubes=[{'name':PARTS[v-1]+f'_{i:03}','part':PARTS[v-1],'from':(lo*pitch+origin).round(5).tolist(),'to':(hi*pitch+origin).round(5).tolist(),'origin':[0,0,0],'rotation':[0,0,0],'kind':'body'} for i,(lo,hi,v) in enumerate(boxes)]
    np.savez_compressed(STAGE/'body_voxels.npz',labels=labels,origin=origin,step=pitch)
    p,n,uv,f,tex=source();src_labels=np.load(REF/'triangle_parts.npy');c=p[f].mean(1);bodycloth=src_labels==18
    source_normals=n[f].mean(1);source_radial=c-[CX,0,CZ];source_radial[:,1]=0
    source_radial/=np.maximum(np.linalg.norm(source_radial,axis=1)[:,None],1e-9)
    area=np.linalg.norm(np.cross(p[f[:,1]]-p[f[:,0]],p[f[:,2]]-p[f[:,0]]),axis=1)
    groups=[]
    # Seven radial coat panels, each split into upper and lower editable groups.
    # Fitted from the actual cloth, not a closed conical skirt.
    for degrees in [-135,-90,-45,0,45,90,135]:
        angular=np.degrees(np.arctan2(c[:,0]-CX,c[:,2]-CZ));diff=(angular-degrees+180)%360-180
        selection=bodycloth&(abs(diff)<27)
        outward=selection&((source_normals*source_radial).sum(1)>.4)
        panel_degrees=float(degrees)
        if outward.any():
            nn=np.average(source_normals[outward],axis=0,weights=area[outward]);facing=math.degrees(math.atan2(nn[0],nn[2]));delta=(facing-degrees+180)%360-180
            panel_degrees=degrees+float(np.clip(delta,-24,24))
        theta=math.radians(panel_degrees);sn,cs=math.sin(theta),math.cos(theta)
        center=np.array([CX,0,CZ]);rot=np.array([[cs,0,sn],[0,1,0],[-sn,0,cs]])
        local=(c-center)@rot
        if not selection.any():continue
        group=f'coat_{degrees+180:03}'
        groups.append({'name':group,'parent':'pelvis','origin':[CX,29,CZ],'rotation':[0,panel_degrees,0]})
        # One continuous meridian plane, split once for later cloth articulation.
        # All subpanels share a plane so adjacent sections cannot open cracks.
        allq=local[selection];yy=18.5
        slope,intercept=np.linalg.lstsq(np.c_[allq[:,1]-yy,np.ones(len(allq))],allq[:,2],rcond=None)[0]
        angle=min([-45,-22.5,0,22.5,45],key=lambda x:abs(math.tan(math.radians(x))-slope))
        width_lo,width_hi=np.percentile(allq[:,0],[.2,99.8]);middle=(width_lo+width_hi)/2
        radial_mid=float(np.median(allq[:,2]-math.tan(math.radians(angle))*(allq[:,1]-yy)))
        for idx,(y0,y1) in enumerate([(7.6,18.5),(18.5,29.2)]):
            at=selection&(c[:,1]>=y0)&(c[:,1]<y1)
            q=local[at]
            if len(q)<15:continue
            py=(y0+y1)/2;rad=radial_mid+math.tan(math.radians(angle))*(py-yy)
            h=(y1-y0)/math.cos(math.radians(angle));w=width_hi-width_lo+.2;pivot=np.array([CX+middle,py,CZ+rad])
            cubes.append({'name':group+f'_{idx}','part':group,'from':(pivot-[w/2,h/2,.06]).tolist(),'to':(pivot+[w/2,h/2,.06]).tolist(),'origin':pivot.tolist(),'rotation':[angle,0,0],'kind':'coat','sector':degrees})
    # Long front tabard and front/back head wraps, kept separate from the body.
    for part,mask,ys in [('tabard',src_labels==19,[(8,18),(18,29.2)]),('head_drape_front',src_labels==20,[(35.8,40)]),('head_drape_back',src_labels==21,[(30.8,35.8),(35.8,40)])]:
        for i,(y0,y1) in enumerate(ys):
            q=c[mask&(c[:,1]>y0)&(c[:,1]<y1)]
            if not len(q):continue
            low,high=np.percentile(q,[1,99],axis=0);width=high[0]-low[0]+.06;center=np.array([(low[0]+high[0])/2,(y0+y1)/2,np.median(q[:,2])])
            h=y1-y0+.08
            lower=center-[width/2,h/2,.14];upper=center+[width/2,h/2,.14]
            if part=='head_drape_back' and i==0:lower[1]+=.12
            cubes.append({'name':part+str(i),'part':part,'from':lower.tolist(),'to':upper.tolist(),'origin':center.tolist(),'rotation':[0,0,0],'kind':part})
    # The staff shaft and fork are low-cost source-fitted cuboids.
    for i,(y0,y1,r) in enumerate([(0,.45,.68),(.45,1.5,.55),(1.5,2.6,.7),(2.6,3.1,.49),(3.1,9.5,.46),(9.5,16,.46),(16,22.5,.46),(22.5,28.8,.46),(28.8,32.5,.46),(32.5,36.8,.46),(36.8,37.4,.61),(37.4,38.2,.46)]):
        yy=(y0+y1)/2;center=np.array([8.2+yy*.041,yy,-7.5]);hh=y1-y0
        cubes.append({'name':f'staff_shaft_{i}','part':'staff','from':(center-[r,hh/2,r]).tolist(),'to':(center+[r,hh/2,r]).tolist(),'origin':center.tolist(),'rotation':[0,0,0],'kind':'staff'})
    # Source fork: rectangular open U, rather than an invented gem or emblem.
    for name,lo,hi in [('foot',[9.45,38.0,-8.58],[11.25,38.85,-7.72]),('bridge',[9.0,38.7,-8.52],[11.9,39.2,-7.78]),('right',[11.36,39.0,-8.48],[11.94,42.25,-7.83]),('left',[8.75,39.1,-8.48],[9.33,42.05,-7.83]),('left_tip',[8.62,41.9,-8.5],[9.45,42.5,-7.72]),('right_tip',[11.25,42.1,-8.5],[12.08,42.65,-7.72])]:
        cubes.append({'name':'staff_fork_'+name,'part':'staff','from':lo,'to':hi,'origin':[0,0,0],'rotation':[0,0,0],'kind':'staff'})
    for e in cubes:
        if e['kind']=='staff':
            for key in ['from','to','origin']:e[key][0]+=.08
    data={'pitch':pitch,'body_cubes':len(boxes),'cloth_groups':groups,'cubes':cubes}
    (STAGE/'拟合几何.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf8')
    print('SELECTED',pitch,len(cubes),flush=True)

def rotation(angles):
    x,y,z=np.radians(angles);cx,sx=math.cos(x),math.sin(x);cy,sy=math.cos(y),math.sin(y);cz,sz=math.cos(z),math.sin(z)
    return np.array([[cz,-sz,0],[sz,cz,0],[0,0,1]])@np.array([[cy,0,sy],[0,1,0],[-sy,0,cy]])@np.array([[1,0,0],[0,cx,-sx],[0,sx,cx]])

def vertices(e,face,cloth_groups):
    q=np.array(VERTS[face],float)*(np.array(e['to'])-e['from'])+e['from'];o=np.array(e['origin']);q=(q-o)@rotation(e['rotation']).T+o
    gg=cloth_groups.get(e['part'])
    if gg:
        origin=np.array(gg['origin']);q=(q-origin)@rotation(gg['rotation']).T+origin
    return q

def layout(faces,size):
    x=y=row=0
    for f in sorted(faces,key=lambda f:(-f['height'],-f['width'])):
        w,h=f['width']+2,f['height']+2
        if x+w>size:x=0;y+=row;row=0
        if y+h>size:return False
        f['xy']=(x+1,y+1);x+=w;row=max(row,h)
    return True

def bake():
    from collections import defaultdict,Counter
    from boss_texture_transfer import Source as TransferSource
    data=json.loads((STAGE/'拟合几何.json').read_text(encoding='utf8'));cubes=data['cubes'];cloth_groups={g['name']:g for g in data['cloth_groups']}
    p,n,uv,f,tex=source();src_labels=np.load(REF/'triangle_parts.npy');tri_cent=p[f].mean(1);tuv=uv[f].mean(1)
    rgb=tex[np.clip((tuv[:,1]*4096).astype(int),0,4095),np.clip((tuv[:,0]*4096).astype(int),0,4095),:3].astype(float)
    class Sampler(TransferSource):
        def __init__(self,mask):
            self.p=p;self.uv=uv;self.f=f[mask];self.tex=tex;self.tri=self.p[self.f];self.cell=1.1;self.grid=defaultdict(list);self.cache={};self.max_error=0.;self.distances=[]
            for i,t in enumerate(self.tri):
                lo=np.floor(t.min(0)/self.cell).astype(int);hi=np.floor(t.max(0)/self.cell).astype(int)
                for key in itertools.product(*[range(lo[a],hi[a]+1) for a in range(3)]):self.grid[key].append(i)
        def candidates(self,key):
            ids=super().candidates(key)
            if not len(ids):
                # A hidden end cap can be remote from visible original cloth.
                # Use the nearest available triangles of this same region only.
                q=(np.array(key)+.5)*self.cell
                ids=np.argsort(((self.tri.mean(1)-q)**2).sum(1))[:128];self.cache[key]=ids
            return ids
    samplers={};cloth_projections={};normals=n[f].mean(1)
    body_projections={k:np.load(REF/f'body_{k}.npz') for k in NORMAL}
    def projected_sample(points,rgba,direction,fallback):
        direction=np.array(direction,float);direction/=np.linalg.norm(direction);up=np.array([0.,1,0])
        if abs(direction[1])>.99:up=np.array([0.,0,-1])
        right=np.cross(up,direction);right/=np.linalg.norm(right);up=np.cross(direction,right)
        rel=points-[0,24,0];row=np.clip((450-(rel@up)*15).astype(int),0,899);col=np.clip((360+(rel@right)*15).astype(int),0,719)
        patch=rgba[row,col].copy();missing=patch[:,:,3]==0
        for radius in [1,2,4,8,16,32]:
            if not missing.any():break
            for dr,dc in [(-radius,0),(radius,0),(0,-radius),(0,radius)]:
                other=rgba[np.clip(row+dr,0,899),np.clip(col+dc,0,719)];take=missing&(other[:,:,3]>0);patch[take]=other[take];missing[take]=False
        patch[missing]=fallback[missing];patch[:,:,3]=255
        return patch
    v=np.load(STAGE/'body_voxels.npz');labels,origin,step=v['labels'],v['origin'],float(v['step'])
    faces=[]
    for i,e in enumerate(cubes):
        density=4.0 if e['part'] in ['head','head_drape_front','head_drape_back','staff'] else 3.0 if e['kind']=='coat' or e['kind']=='tabard' else 2.8
        names=list(NORMAL)
        if e['kind']=='coat':names=['north','south']
        if e['kind']=='body':
            lo=np.rint((np.array(e['from'])-origin)/step).astype(int);hi=np.rint((np.array(e['to'])-origin)/step).astype(int);own=labels[tuple(lo)]
            names=[]
            for face,normal in NORMAL.items():
                axis=int(np.argmax(abs(np.array(normal))));sg=normal[axis];index=lo[axis]-1 if sg<0 else hi[axis]
                if 0<=index<labels.shape[axis]:
                    slices=[slice(lo[a],hi[a]) for a in range(3)];slices[axis]=index
                    if np.all(labels[tuple(slices)]==own):continue
                names.append(face)
        for name in names:
            q=vertices(e,name,cloth_groups);w=max(2,math.ceil(np.linalg.norm(q[3]-q[0])*density));h=max(2,math.ceil(np.linalg.norm(q[1]-q[0])*density))
            faces.append({'cube':i,'name':name,'vs':q,'width':w,'height':h})
    tried=[]
    print('ATLAS FACE AREA',len(faces),sum((f['width']+2)*(f['height']+2) for f in faces),flush=True)
    for size in [256,512]:
        okay=layout(faces,size);tried.append([size,okay])
        if okay:break
    else:raise ValueError('Atlas exceeds 512; revise density/packing')
    atlas=Image.new('RGBA',(size,size));started=time.time()
    for e in cubes:e['faces']={name:{'uv':[0,0,1,1],'texture':None} for name in NORMAL}
    for i,face in enumerate(faces):
        e=cubes[face['cube']];part=e['part'];key=part+'_'+face['name']
        normal_world=np.cross(face['vs'][3]-face['vs'][0],face['vs'][1]-face['vs'][0]);normal_world/=np.linalg.norm(normal_world)
        # VERTS are clockwise when viewed from outside; use the known normal
        # rather than triangle winding to keep outer cream and inner navy apart.
        normal_world=np.array(NORMAL[face['name']])@rotation(e['rotation']).T
        if part in cloth_groups:normal_world=normal_world@rotation(cloth_groups[part]['rotation']).T
        if key not in samplers:
            if e['kind']=='coat':
                angle=np.degrees(np.arctan2(tri_cent[:,0]-CX,tri_cent[:,2]-CZ));diff=(angle-e['sector']+180)%360-180
                mask=(src_labels==18)&(abs(diff)<36)
            elif part.startswith('leg_upper'):
                side=1 if part.endswith('right') else -1
                mask=(tri_cent[:,1]>10)&(tri_cent[:,1]<28)&((tri_cent[:,0]-CX)*side>0)&(rgb.mean(1)<62)&(rgb[:,2]<rgb[:,0]*1.35)
            elif part=='head':mask=(src_labels==4)|(np.isin(src_labels,[20,21])&(tri_cent[:,1]>=40))
            else:mask=src_labels==PARTS.index(part)
            base_mask=mask.copy();mask&=(normals@normal_world)>.15
            if mask.sum()<8:mask=base_mask
            if not mask.any():mask=~np.isin(src_labels,[17,18,19])
            samplers[key]=Sampler(mask)
        w,h=face['width'],face['height'];q=face['vs'];xx,yy=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h)
        points=q[0]+xx[:,:,None]*(q[3]-q[0])+yy[:,:,None]*(q[1]-q[0]);patch=samplers[key].sample(points.reshape(-1,3)).reshape(h,w,4)
        if e['kind']=='body':
            projection=body_projections[face['name']];rgba=projection['rgba']
            if face['name'] in ['north','south','east','west']:
                patch=projected_sample(points,rgba,NORMAL[face['name']],patch)
            # Hidden stair faces and newly completed anatomy have no unique
            # source texel. Give them the same local fabric, never a nearby
            # coat strip or a shin buckle copied across the whole leg.
            cap_color=None
            if part.startswith('leg_upper'):cap_color=[31,31,34]
            elif part.startswith('leg_lower') or part.startswith('foot') or part.startswith('hand'):cap_color=[22,29,48]
            elif part=='head':cap_color=[20,26,44]
            elif part.startswith('arm_upper'):cap_color=[184,176,158]
            elif part=='waist':cap_color=[23,29,45]
            if cap_color is not None:
                d=np.array(NORMAL[face['name']],float);up=np.array([0.,1,0])
                if abs(d[1])>.99:up=np.array([0.,0,-1])
                right=np.cross(up,d);right/=np.linalg.norm(right);up=np.cross(d,right);rel=points-[0,24,0]
                row=np.clip((450-(rel@up)*15).astype(int),0,899);col=np.clip((360+(rel@right)*15).astype(int),0,719)
                remote=(abs(projection['depth'][row,col]-(rel@d))>1.15)|(rgba[row,col,3]==0)
                if face['name'] in ['up','down']:remote[:]=True
                color=np.zeros_like(patch);color[:,:,:3]=cap_color;color[:,:,3]=255
                if part.startswith('leg_lower'):
                    yy=points[:,:,1];bands=((yy>3.4)&(yy<3.95))|((yy>4.6)&(yy<5.15));color[bands,:3]=[181,172,150]
                    gold=(yy>9.0)&(yy<10.5);color[gold,:3]=[127,105,59]
                if part.startswith('foot'):
                    sole=points[:,:,1]<.65;color[sole,:3]=[94,77,48]
                patch[remote]=color[remote]
        elif e['kind'] in ['tabard','head_drape_front','head_drape_back'] and face['name'] in ['north','south']:
            projection_key=(part,face['name'])
            if projection_key not in cloth_projections:
                mask=src_labels==PARTS.index(part)
                rgba,_,_=raster(p,n,uv,f[mask],tex,NORMAL[face['name']],width=720,height=900,ppu=15,lit=False);cloth_projections[projection_key]=rgba
            patch=projected_sample(points,cloth_projections[projection_key],NORMAL[face['name']],patch)
        if e['kind']=='coat' and face['name'] in ['north','south']:
            sign=1 if face['name']=='south' else -1;projection_key=(e['sector'],sign)
            theta=math.radians(cloth_groups[e['part']]['rotation'][1]);direction=sign*np.array([math.sin(theta),0,math.cos(theta)])
            if projection_key not in cloth_projections:
                angular=np.degrees(np.arctan2(tri_cent[:,0]-CX,tri_cent[:,2]-CZ));diff=(angular-e['sector']+180)%360-180
                mask=(src_labels==18)&(abs(diff)<32)
                rgba,_,_=raster(p,n,uv,f[mask],tex,direction,width=720,height=900,ppu=15,lit=False)
                cloth_projections[projection_key]=rgba
            rgba=cloth_projections[projection_key];right=np.cross([0,1,0],direction);up=np.array([0,1,0]);rel=points-[0,24,0]
            row=np.clip((450-(rel@up)*15).astype(int),0,899);col=np.clip((360+(rel@right)*15).astype(int),0,719)
            patch=rgba[row,col].copy()
        px,py=face['xy'];atlas.paste(Image.fromarray(np.pad(patch,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1));e['faces'][face['name']]={'uv':[px,py,px+w,py+h],'texture':0}
        if i%250==0:print('BAKE',i,'/',len(faces),'seconds',round(time.time()-started,1),flush=True)
    atlas_name='b_staff_basecolor_512.png';atlas.save(STAGE/atlas_name)
    specs=[('root',None,[CX,0,CZ]),('pelvis','root',[CX,25.2,CZ]),('waist','pelvis',[CX,29.4,CZ]),('chest','waist',[CX,31.8,CZ]),('neck','chest',[CX,39.4,CZ]),('head','neck',[CX,40.4,CZ]),
        ('arm_upper_right','chest',[4.8,38.5,-2.4]),('arm_lower_right','arm_upper_right',[7.4,33.1,-3.3]),('hand_right','arm_lower_right',[9.25,30.6,-6.5]),
        ('arm_upper_left','chest',[-9.2,38.5,-2.3]),('arm_lower_left','arm_upper_left',[-11.1,29.2,-1.8]),('hand_left','arm_lower_left',[-11.6,24.3,-1.65]),
        ('leg_upper_right','pelvis',[.3,25.2,CZ]),('leg_lower_right','leg_upper_right',[2.5,11.8,CZ]),('foot_right','leg_lower_right',[2.6,3.5,CZ]),
        ('leg_upper_left','pelvis',[-5.3,25.2,CZ]),('leg_lower_left','leg_upper_left',[-7.4,11.8,CZ]),('foot_left','leg_lower_left',[-7.4,3.5,CZ]),
        ('staff','hand_right',[10.25,30.6,-8.12]),('tabard','pelvis',[-3.7,29.1,-6.2]),('head_drape_front','head',[-2.7,44.2,-6.4]),('head_drape_back','head',[-2.7,44.2,.7])]
    for g in data['cloth_groups']:specs.append((g['name'],g['parent'],g['origin']))
    offset=np.array([CX,0,CZ]);groups=[];nodes={};out=[]
    for i,(name,parent,pivot) in enumerate(specs):
        uid=str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:b_staff/'+name));rotation_angles=cloth_groups.get(name,{}).get('rotation',[0,0,0]);node={'uuid':uid,'isOpen':False,'children':[]};nodes[name]=node
        groups.append({'name':name,'uuid':uid,'origin':(np.array(pivot)-offset).tolist(),'rotation':rotation_angles,'export':True,'visibility':True,'color':i%8,'shade':True,'reset':False,'children':[]})
        (nodes[parent]['children'] if parent else out).append(node)
    elements=[]
    for i,e in enumerate(cubes):
        uid=str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:b_staff/cube/'+e['name']));elements.append({'name':e['name'],'type':'cube','uuid':uid,'from':(np.array(e['from'])-offset).round(6).tolist(),'to':(np.array(e['to'])-offset).round(6).tolist(),'origin':(np.array(e['origin'])-offset).round(6).tolist(),'rotation':e['rotation'],'box_uv':False,'rescale':False,'shade':True,'export':True,'faces':e['faces']})
        nodes[e['part']]['children'].append(uid)
    png=io.BytesIO();atlas.save(png,format='PNG')
    bb={'meta':{'format_version':'5.0','model_format':'free','box_uv':False},'name':'B_白蓝覆面持杖_静态审阅','model_identifier':'b_staff_static','resolution':{'width':size,'height':size},'elements':elements,'groups':groups,'outliner':out,'textures':[{'name':atlas_name,'id':'0','uuid':str(uuid.uuid5(uuid.NAMESPACE_URL,'sweetdream:b_staff/texture')),'width':size,'height':size,'uv_width':size,'uv_height':size,'relative_path':atlas_name,'path':str(STAGE/atlas_name),'render_mode':'default','render_sides':'auto','internal':True,'saved':True,'source':'data:image/png;base64,'+base64.b64encode(png.getvalue()).decode()}],'animations':[]}
    (STAGE/'B_分组可编辑_静态.bbmodel').write_text(json.dumps(bb,ensure_ascii=False,indent=2),encoding='utf8')
    stats={'source':str(SOURCE),'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'cubes':len(cubes),'body_cubes':data['body_cubes'],'defined_faces':len(faces),'disabled_internal_faces':6*len(cubes)-len(faces),'groups':len(groups),'animations':0,'texture_dimensions':[size,size],'texture_packing_attempts':tried,'cubes_by_part':dict(Counter(e['part'] for e in cubes)),'actual_display_entities':0,'estimate_display_entities':sum(any(e['part']==g['name'] for e in cubes) for g in groups),'target_version':'1.21.5','game_exported':False,'game_tested':False,'bake_distance_percentiles':{k:np.percentile(v.distances,[50,95,100]).round(4).tolist() for k,v in samplers.items()}}
    (STAGE/'静态结构统计.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf8');print('BAKE COMPLETE',len(cubes),len(faces),len(groups),flush=True)

def scene(bb):
    groups={g['uuid']:g for g in bb['groups']};ep={};parents={};world={}
    def walk(nodes,parent=None):
        for node in nodes:
            if isinstance(node,str):ep[node]=parent
            else:parents[node['uuid']]=parent;walk(node['children'],node['uuid'])
    walk(bb['outliner'])
    for g in bb['groups']:
        par=parents[g['uuid']];local=np.eye(4);local[:3,:3]=rotation(g['rotation']);local[:3,3]=np.array(g['origin'])-(np.array(groups[par]['origin']) if par else 0)
        world[g['uuid']]=world[par]@local if par else local
    p=[];n=[];uv=[];f=[]
    for e in bb['elements']:
        if e.get('visibility') is False:continue
        ancestor=ep[e['uuid']];visible=True
        while ancestor:
            if groups[ancestor].get('visibility') is False:visible=False;break
            ancestor=parents[ancestor]
        if not visible:continue
        g=groups[ep[e['uuid']]];mat=world[g['uuid']];rr=rotation(e['rotation']);o=np.array(e['origin'])
        for name,face in e['faces'].items():
            if face.get('texture') is None:continue
            q=np.array(VERTS[name],float)*(np.array(e['to'])-e['from'])+e['from'];q=(q-o)@rr.T+o;q=(q-g['origin'])@mat[:3,:3].T+mat[:3,3]
            a,b,c,d=face['uv'];coords=np.array([(a,b),(a,d),(c,d),(c,b)])/bb['resolution']['width'];nn=np.array(NORMAL[name])@rr.T@mat[:3,:3].T;start=len(p)
            p.extend(q);n.extend([nn]*4);uv.extend(coords);f.extend([(start,start+1,start+2),(start,start+2,start+3)])
    return [np.array(v) for v in [p,n,uv,f]]

def render():
    bb=json.loads((STAGE/'B_分组可编辑_静态.bbmodel').read_text(encoding='utf8'));p,n,uv,f=scene(bb);tex=np.array(Image.open(STAGE/bb['textures'][0]['name']).convert('RGBA'));gp,gn,gu,gf,gt=source();gp=gp-[CX,0,CZ]
    metrics={};ims=[];refs=[]
    for name,d in [('正面',(0,0,-1)),('侧面',(1,0,0)),('背面',(0,0,1)),('45度',(1,.1,-1))]:
        visible=n[f[:,0]]@np.array(d)>1e-6
        rgba,_,_=raster(p,n,uv,f[visible],tex,d,width=540,height=780,ppu=14,lit=True,cutout=True)
        im=card(rgba,f'B · 实际Cube模型 · {name}');im.save(STAGE/f'模型_{name}.png');Image.fromarray(rgba).save(STAGE/f'模型_{name}_透明.png');ims.append(im)
        gr,_,_=raster(gp,gn,gu,gf,gt,d,width=540,height=780,ppu=14,lit=True);refs.append(card(gr,f'原始GLB · {name}'))
        a,b=rgba[:,:,3]>127,gr[:,:,3]>127;metrics[name]={'silhouette_iou':round(float((a&b).sum()/(a|b).sum()),5),'missing':round(float((b&~a).sum()/b.sum()),5),'extra':round(float((a&~b).sum()/a.sum()),5)}
    sheet=Image.new('RGB',(1080,1560));compare=Image.new('RGB',(2160,1560))
    for i,im in enumerate(ims):sheet.paste(im,((i%2)*540,(i//2)*780));compare.paste(refs[i],(i*540,0));compare.paste(im,(i*540,780))
    sheet.save(STAGE/'B_实际模型_四视图.png');compare.save(STAGE/'GLB与Cube_四视图对照.png');(STAGE/'轮廓对照.json').write_text(json.dumps(metrics,ensure_ascii=False,indent=2),encoding='utf8');print('RENDER',json.dumps(metrics,ensure_ascii=False),flush=True)

def analyze():
    p,n,uv,f,tex=source();c=p[f].mean(1)
    print('BOUNDS',p.min(0).round(3),p.max(0).round(3))
    print('BODY BANDS:')
    for y in range(0,49,2):
        q=c[abs(c[:,1]-y)<.4]
        if len(q):print(y,len(q),q.min(0).round(2),q.max(0).round(2))
    cards=[]
    for name,d in [('正面',(0,0,-1)),('右侧',(1,0,0)),('背面',(0,0,1)),('45度',(1,.1,-1))]:
        rgba,_,_=raster(p,n,uv,f,tex,d,width=660,height=880,ppu=15,lit=False)
        Image.fromarray(rgba).save(REF/f'原型_{name}_透明.png');im=card(rgba,f'B · GLB实际网格 · {name}')
        draw=ImageDraw.Draw(im)
        if name in ['正面','背面','右侧']:
            for y in range(0,49,4):
                v=440-(y-24)*15;draw.line((40,v,620,v),fill='#5b646a',width=1);draw.text((8,v-9),str(y),font=SMALL,fill='#f0ba76')
            for x in range(-16,17,4):
                h=330+x*15;draw.line((h,65,h,825),fill='#454b50',width=1);draw.text((h+2,825),str(x),font=SMALL,fill='#f0ba76')
        im.save(REF/f'坐标_{name}.png');cards.append(im)
    sheet=Image.new('RGB',(660*4,880))
    for i,im in enumerate(cards):sheet.paste(im,(660*i,0))
    sheet.save(REF/'母版坐标四视图.png')

if __name__=='__main__':
    if '--separate' in sys.argv:separation()
    elif '--projections' in sys.argv:projections()
    elif '--fit' in sys.argv:fit()
    elif '--bake' in sys.argv:bake()
    elif '--render' in sys.argv:render()
    else:analyze()
