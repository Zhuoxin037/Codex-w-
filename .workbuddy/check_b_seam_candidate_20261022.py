"""Inspect actual saved UV masks, body contacts and unchanged source regions."""
from refit_b_robe_local_20261022 import DEST,unwrap
from build_b_staff_static_20261021 import *
from refine_b_headcloth_20261022 import hierarchy,face_points,collect_scene
from collections import deque
import copy

def components(mask):
    seen=set(map(tuple,np.argwhere(mask)));out=[]
    while seen:
        start=seen.pop();todo=[start];count=0
        while todo:
            y,x=todo.pop();count+=1
            for yy,xx in [(y+dy,x+dx) for dy in [-1,0,1] for dx in [-1,0,1] if dy or dx]:
                if (yy,xx) in seen:seen.remove((yy,xx));todo.append((yy,xx))
        out.append(count)
    return sorted(out,reverse=True)

def main():
    bb=json.loads((DEST/'B_原造型_局部接缝修复.bbmodel').read_text(encoding='utf8'));old=unwrap(json.loads((DEST/'改前_当前编辑器完整快照.ajblueprint').read_text(encoding='utf8')));oldmap={e['uuid']:e for e in old['elements']};gs,pa,ep,nodes,world=hierarchy(bb);body=[e for e in bb['elements'] if gs[ep[e['uuid']]]['name'] in PARTS[:17]];lo=np.array([e['from'] for e in body]);hi=np.array([e['to'] for e in body]);masks=[];collisions=[];allpts=[];tex=[np.array(Image.open(io.BytesIO(base64.b64decode(t['source'].split(',',1)[1]))).convert('RGBA')) for t in bb['textures']]
    for e in bb['elements']:
        if not e['name'].startswith('robe_'):continue
        face=e['faces']['south'];a,b,c,d=map(int,face['uv']);mask=tex[face['texture']][b:d,a:c,3]>127;masks.append({'name':e['name'],'visible_mask_components':components(mask)});h,w=mask.shape;uu,vv=np.meshgrid((np.arange(w)+.5)/w,(np.arange(h)+.5)/h);q,_=face_points(e,'south',gs,ep,world);pts=(q[0]+uu[:,:,None]*(q[3]-q[0])+vv[:,:,None]*(q[1]-q[0]))[mask];inside=((pts[:,None,:]>lo[None]+.025)&(pts[:,None,:]<hi[None]-.025)).all(2).any(1)
        if inside.any():collisions.append({'name':e['name'],'inside_body_pixels':int(inside.sum()),'total_visible':len(pts),'bounds':[pts[inside].min(0).round(3).tolist(),pts[inside].max(0).round(3).tolist()]})
        allpts.append(pts)
    removed=[e for e in old['elements'] if e['uuid'] not in {n['uuid'] for n in bb['elements']}];kept=[e for e in bb['elements'] if e['uuid'] in oldmap];geomkeys=['from','to','origin','rotation'];unchanged=sum(all(e[k]==oldmap[e['uuid']][k] for k in geomkeys) for e in kept);uvbad=[]
    for e in bb['elements']:
        for fa,f in e['faces'].items():
            if f.get('texture') is None:continue
            a,b,c,d=f['uv'];t=bb['textures'][f['texture']]
            if not(0<=min(a,c)<max(a,c)<=t['uv_width'] and 0<=min(b,d)<max(b,d)<=t['uv_height']):uvbad.append([e['name'],fa])
    report={'cube_count':len(bb['elements']),'group_count':len(bb['groups']),'texture_dimensions':[[t['uv_width'],t['uv_height']] for t in bb['textures']],'removed_original_elements':[e['name'] for e in removed],'unchanged_kept_geometry':unchanged,'kept_geometry_total':len(kept),'outer_masks':masks,'robe_body_intersections':collisions,'uv_errors':uvbad,'unique_uuids':len(bb['elements'])==len({e['uuid'] for e in bb['elements']}),'positive_cubes':all(np.all(np.array(e['to'])>e['from']) for e in bb['elements']),'animation_count':len(bb.get('animations',[])),'game_tested':False};(DEST/'保存工程局部核验.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print({k:v for k,v in report.items() if k!='outer_masks'},flush=True)
    hidden=copy.deepcopy(bb)
    for g in hidden['groups']:
        if g['name'].startswith(('coat_','tabard','head_drape','staff')):g['visibility']=False
    hidden['name']='B_局部接缝修复_隐藏外衣检查';(DEST/'B_局部接缝修复_隐藏外衣检查.bbmodel').write_text(json.dumps(hidden,ensure_ascii=False,indent=2),encoding='utf8')

if __name__=='__main__':main()
