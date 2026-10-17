"""Extend the approved saved head without regenerating its geometry or existing UV islands."""
import json,math,base64
from pathlib import Path
from collections import Counter
import numpy as np
from PIL import Image
from build_boss_fireaxe_head import BASE,VERTS,NORMAL

OUT=BASE/'阶段二_完整斧身与握柄'
NEW=[]
def cube(name,a,b,parent,material):NEW.append({'name':name,'from':a,'to':b,'parent':parent,'material':material,'box_uv':False,'origin':[0,-7,0],'faces':{}})
def octagon(name,y0,y1,cx,w,d,parent,material):
 # Three interlocking rectangles give the handle restrained, pixel-scale corner chamfers.
 cube(name+'_core',[cx-w*.36,y0,-d*.5],[cx+w*.36,y1,d*.5],parent,material)
 cube(name+'_edge_a',[cx-w*.5,y0,-d*.36],[cx-w*.36,y1,d*.36],parent,material)
 cube(name+'_edge_b',[cx+w*.36,y0,-d*.36],[cx+w*.5,y1,d*.36],parent,material)

def covered(e,face,elements):
 lo=np.array(e['from']);hi=np.array(e['to']);ax,sg=NORMAL[face];plane=(hi[ax] if sg>0 else lo[ax])+sg*.000001;uv=[i for i in range(3) if i!=ax];rects=[]
 for other in elements:
  if other is e:continue
  a=np.array(other['from']);b=np.array(other['to'])
  if not(a[ax]-1e-8<=plane<=b[ax]+1e-8):continue
  l=np.maximum(lo[uv],a[uv]);r=np.minimum(hi[uv],b[uv])
  if np.all(r-l>1e-8):rects.append((l,r))
 if not rects:return False
 cuts=[sorted(set([float(lo[t]),float(hi[t])]+[float(v[k]) for rect in rects for v in rect])) for k,t in enumerate(uv)]
 for u0,u1 in zip(cuts[0],cuts[0][1:]):
  if u1-u0<1e-8:continue
  for v0,v1 in zip(cuts[1],cuts[1][1:]):
   if v1-v0<1e-8:continue
   p=np.array([(u0+u1)/2,(v0+v1)/2])
   if not any(np.all(p>=l-1e-8) and np.all(p<=r+1e-8) for l,r in rects):return False
 return True

def color(p,mat,face):
 x,y,z=p;ix=int(math.floor(x*12));iy=int(math.floor(y*12));iz=int(math.floor(z*12));r=math.sin(ix*127.1+iy*311.7+iz*67.4)*43758.5453;noise=(r-math.floor(r)-.5)
 coarse=math.sin(math.floor(x*4)*3+math.floor(y*1.5)*7+math.floor(z*4)*5)*4
 if mat=='wood':
  across=x if face in ['north','south'] else z
  grain=math.sin(math.floor(across*24)*2.7+math.floor(y*.9)*.22)*9+math.sin(across*44+y*.18)*3
  c=np.array([132,94,58])+grain+coarse+noise*6
  if 2.4<y<6 and z<0 and abs(x-.20+math.sin(y*4)*.1)<.23 and noise<.26:c=np.array([99,43,29])+coarse+noise*7
  if -1.8<y<-.4 and z>0 and abs(x-.05)<.17 and noise<.28:c=np.array([90,40,26])+coarse
  if abs(y-12.45)<.4:c*=.80
 elif mat=='tape':
  across=x if face in ['north','south'] else z
  seam=(y+across*.45)*2.7%1
  c=np.array([40,42,42])+coarse*.4+noise*5
  if seam<.12:c-=11
  if .12<=seam<.24:c+=8
  if -10.8<y<-6.6 and abs(across-.12)<.4 and noise>.25:c+=12
 elif mat=='steel':
  c=np.array([91,87,78])+coarse+noise*10
  if face in ['up','down'] or abs(x)>.65:c+=25
  if (ix+iy*2+iz)%19<2:c+=22
 else:
  c=np.array([155,43,32])+coarse+noise*6
  if mat=='head_steel':c=np.array([162,157,145])+coarse+noise*7
 return np.r_[np.clip(c,0,255).astype(np.uint8),255]

def main():
 bb=json.loads((OUT/'消防斧_完整武器_分组可编辑.bbmodel').read_text(encoding='utf8'));heads=bb['elements'];assert len(heads)==60
 bands=[(9.0,12.62,0,1.62,1.64),(5.0,9.0,.04,1.52,1.56),(1.0,5.0,.10,1.42,1.46),(-3,1,.16,1.34,1.40),(-6.8,-3,.13,1.29,1.36),(-10.3,-6.8,.05,1.30,1.36),(-13.25,-10.3,-.06,1.43,1.43)]
 for i,(y0,y1,cx,w,d) in enumerate(bands):octagon(f'ash_shaft_{i:02}',y0,y1,cx,w,d,'木柄_连续轮廓','wood')
 for i,(y0,y1,cx,w,d) in enumerate([(-6.9,-4.8,.13,1.44,1.49),(-9.1,-6.9,.07,1.47,1.52),(-11.2,-9.1,0,1.50,1.55),(-13.08,-11.2,-.06,1.57,1.60)]):octagon(f'work_tape_{i:02}',y0,y1,cx,w,d,'防滑缠带','tape')
 octagon('butt_cap',-13.58,-13.08,-.06,1.78,1.79,'金属尾帽','steel')
 for s in [-1,1]:
  z0,z1=(-.94,-.69) if s<0 else (.69,.94)
  cube('butt_lip_'+str(s),[-.88,-13.20,z0],[.76,-12.85,z1],'金属尾帽','steel')
 all_elements=heads+NEW;head_changes=[];islands=[];restored=0;hidden=0
 for e in all_elements:
  isnew=e in NEW
  for face in VERTS:
   disabled=covered(e,face,all_elements)
   if not isnew:
    wasoff=e['faces'][face].get('texture') is None
    if wasoff and not disabled:
     restored+=1;material='head_steel' if e['name'].startswith('steel_wedge') or (e['name'].startswith('blade_') and e['from'][0]<-5.45) else 'head_red'
     if e['name'].startswith(('pin_','langet_')) or (e['name'].startswith('eye_') and not e['name'].endswith('_main')):material='steel'
     if e['name']=='ashwood_tenon':material='wood'
     islands.append((e,face,material));head_changes.append({'name':e['name'],'face':face,'kind':'restore_exposed_edge'})
    # Existing visible head faces and UVs remain untouched, including internal faces hidden by the new shaft.
   elif disabled:e['faces'][face]={'texture':None}
   else:islands.append((e,face,e['material']))
 atlas=Image.new('RGBA',(512,512));original=Image.open(BASE/'阶段一_斧头与柄座/fireaxe_head_256.png').convert('RGBA');atlas.paste(original,(0,0))
 prepared=[]
 for e,face,mat in islands:
  q=np.array(VERTS[face])*(np.array(e['to'])-e['from'])+e['from'];w=max(1,int(math.ceil(np.linalg.norm(q[3]-q[0])*10)));h=max(1,int(math.ceil(np.linalg.norm(q[1]-q[0])*10)));prepared.append((e,face,mat,q,w,h))
 px=258;py=1;row=0
 for e,face,mat,q,w,h in sorted(prepared,key=lambda t:(-t[5],-t[4])):
  if px+w+1>512:px=258;py+=row+2;row=0
  assert py+h+1<=512
  tile=np.zeros((h,w,4),np.uint8)
  for v in range(h):
   for u in range(w):
    a=(u+.5)/w;b=(v+.5)/h;p=q[0]*(1-a)*(1-b)+q[3]*a*(1-b)+q[1]*(1-a)*b+q[2]*a*b;tile[v,u]=color(p,mat,face)
  atlas.paste(Image.fromarray(np.pad(tile,((1,1),(1,1),(0,0)),mode='edge')),(px-1,py-1))
  e['faces'][face]={'uv':[px,py,px+w,py+h],'texture':'fireaxe_512.png'};px+=w+2;row=max(row,h)
 atlas.save(OUT/'fireaxe_512.png');assert np.array_equal(np.array(atlas)[:256,:256],np.array(original))
 payload={'cubes':[{k:v for k,v in e.items() if k!='material'} for e in NEW],'head_edge_faces':[{'name':e['name'],'face':f,'data':e['faces'][f]} for e,f,mat in islands if e not in NEW],'restored_head_edge_faces':restored,'head_geometry_unchanged':True,'head_existing_uv_unchanged':True,'head_atlas_pixels_unchanged':True,'texture':'data:image/png;base64,'+base64.b64encode((OUT/'fireaxe_512.png').read_bytes()).decode()}
 (OUT/'新增握柄与材质_建模参数.json').write_text(json.dumps(payload,ensure_ascii=False,separators=(',',':')),encoding='utf8')
 print(json.dumps({'head_cubes':len(heads),'new_cubes':len(NEW),'total_cubes':len(all_elements),'new_groups':dict(Counter(c['parent'] for c in NEW)),'restored_head_edge_faces':restored,'head_geometry_unchanged':True,'texture_size':[512,512]},ensure_ascii=False))

if __name__=='__main__':main()
