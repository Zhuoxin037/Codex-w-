import sys,json,math
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
sys.path.insert(0,str(Path(__file__).parent))
import native_c_fx_20261025 as fx
from bb_local_bridge_client import script
fx.configure()
from c_guard_review_20261025 import shot,D

def capture():
 font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22)
 out=Image.new('RGB',(2400,1100),'#171c23');dr=ImageDraw.Draw(out)
 for i,(pos,target,label) in enumerate([([0,36,-46],[1,33,-1],'正面 · 护臂外缘流火'),([39,36,-27],[1,33,-1],'侧面 · 躯干前后留空'),([-39,36,-27],[1,33,-1],'另一侧 · 随护臂运动')]):
  im=shot('guard_hold',.55,pos,target,(800,1040));out.paste(im,(800*i,60),im);dr.text((i*800+15,15),label,font=font,fill='white')
 out.save(D/'防卫火焰_修订_实际近景.png')
 print('Saved guard closeups',flush=True)

def sample():
 print(script('''
 return (async()=>{
 if(Project.name!==params.title)throw new Error('Wrong project');Modes.options.animate.select();let clips=[];
 for(let a of Animation.all){Animation.all.forEach(b=>b.playing=false);a.select();a.playing=true;let count=Math.round(a.length*40),frames=[];
 for(let i=0;i<=count;i++){let t=a.length*i/count;Timeline.setTime(t);Animator.preview();Project.model_3d.updateMatrixWorld(true);
 frames.push({time:t,matrices:Object.fromEntries(Group.all.map(g=>[g.name,g.mesh.matrixWorld.toArray()]))});}
 clips.push({name:a.name,length:a.length,frames});}
 await new Promise(r=>Blockbench.writeFile(params.path,{content:JSON.stringify({source:'Native Animator.preview at 40Hz, updated bracer effects',clips}),savetype:'text'},r));
 return {clips:clips.length,frames:clips.reduce((s,a)=>s+a.frames.length,0)};})();
 ''',{'title':fx.FXTITLE,'path':str(D/'防卫火焰_修订_原生姿态40Hz.json')},timeout=60),flush=True)

def verify():
 b=json.loads((D/(fx.FXTITLE+'.bbmodel')).read_text(encoding='utf8'));groups={g['uuid']:g for g in b['groups']};names={g['name']:g for g in b['groups']};owner={}
 def walk(nodes,pa=None):
  for x in nodes:
   if isinstance(x,str):owner[x]=groups[pa]['name']
   else:walk(x['children'],x['uuid'])
 walk(b['outliner']);geo={}
 for e in b['elements']:
  if any(f.get('texture') is not None for f in e['faces'].values()):geo.setdefault(owner[e['uuid']],[]).append(e)
 def boxes(name,m):
  es=geo[name];lo=np.array([e['from'] for e in es]);hi=np.array([e['to'] for e in es]);basis=m[:3,:3];scale=np.linalg.norm(basis,axis=0)
  if min(scale)<1e-4:return None
  centers=((lo+hi)/2-names[name]['origin'])@basis.T+m[:3,3]
  return centers,(hi-lo)/2*scale,basis/scale
 def penetration(a,z):
  ac,ah,ar=a;zc,zh,zr=z;axes=[*ar.T,*zr.T]
  for x in ar.T:
   for y in zr.T:
    q=np.cross(x,y);length=np.linalg.norm(q)
    if length>1e-7:axes.append(q/length)
  dep=np.full((len(ac),len(zc)),np.inf)
  for axis in axes:
   da=ah@abs(ar.T@axis);dz=zh@abs(zr.T@axis);ds=abs((ac@axis)[:,None]-(zc@axis)[None]);dep=np.minimum(dep,da[:,None]+dz[None]-ds)
  return float(dep.max())
 pairs=[('fx_arm_fire_'+s,z) for s in ['right','left'] for z in ['forearm_right','forearm_left','hand_right','hand_left','chest','head','upperarm_right','upperarm_left','shoulder_right','shoulder_left'] if z in geo]
 pairs += [('fx_arm_fire_right','fx_arm_fire_left')]
 data=json.loads((D/'防卫火焰_修订_原生姿态40Hz.json').read_text(encoding='utf8'));worst={str(p):{'penetration':-1e6} for p in pairs};count=0;active=0
 for clip in data['clips']:
  for frame in clip['frames']:
   count+=1;matrices={n:np.array(v).reshape(4,4,order='F') for n,v in frame['matrices'].items()};cache={n:boxes(n,matrices[n]) for n in set(n for p in pairs for n in p)}
   if any(cache['fx_arm_fire_'+s] is not None for s in ['right','left']):active+=1
   for p in pairs:
    a,z=cache[p[0]],cache[p[1]]
    if a is None or z is None:continue
    dep=penetration(a,z)
    if dep>worst[str(p)]['penetration']:worst[str(p)]={'penetration':dep,'clip':clip['name'],'time':frame['time']}
 backup=Path((D/'防卫火焰_修订前快照路径.txt').read_text(encoding='utf8'));old=json.loads((backup/(fx.FXTITLE+'.bbmodel')).read_text(encoding='utf8'))
 body=lambda d:sorted((e for e in d['elements'] if not e['name'].startswith('fx_')),key=lambda e:e['uuid'])
 untouched=lambda d:sorted((e for e in d['elements'] if e['name'].startswith('fx_') and not e['name'].startswith(('fx_charge_','fx_bracer_stream_'))),key=lambda e:e['uuid'])
 bodyids={g['uuid'] for g in b['groups'] if not g['name'].startswith('fx_')}
 bodynames={g['name'] for g in b['groups'] if not g['name'].startswith('fx_')}
 # Native reopening can resolve an animator's old UUID by bone name.
 # Compare the actual keyed channels by name, ignoring empty editor tracks.
 tracks=lambda d:{a['name']:{v['name']:v for v in a['animators'].values() if v.get('name') in bodynames and v.get('keyframes')} for a in d['animations']}
 report={'sampled_frames':count,'visible_fire_frames':active,'coil_group_removed':not any(g['name']=='fx_charge_stream' for g in b['groups']),'removed_coil_cubes':len(old['elements'])-len(b['elements']),'body_geometry_exactly_preserved':body(b)==body(old),'body_keyed_animation_tracks_exactly_preserved':tracks(b)==tracks(old),'release_geometry_exactly_preserved':untouched(b)==untouched(old),'original_body_texture_sources_preserved':[t['source'] for t in b['textures'][:3]]==[t['source'] for t in old['textures'][:3]],'obb_max_penetrations':worst,'counts':{'cubes':len(b['elements']),'groups':len(b['groups']),'effect_cubes':len(b['elements'])-len(body(b))},'game_tested':False}
 (D/'防卫火焰_修订核对.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(report,ensure_ascii=False),flush=True)

def demo():
 font=ImageFont.truetype('C:/Windows/Fonts/msyh.ttc',22);frames=[];seq=[]
 for name,length,label in [('combat_idle',.25,'拳架'),('guard_enter',.85,'进入防卫'),('guard_hold',.75,'护臂流火'),('guard_absorb',.4,'承伤'),('guard_hold',.65,'保持防卫'),('guard_cancel',1.2,'收势')]:
  seq += [(name,float(t),label) for t in np.arange(0,length,.05)]
 for i,(name,t,label) in enumerate(seq):
  im=shot(name,t,[34,36,-51],[1,33,-1],(900,940));bg=Image.new('RGB',(900,1000),'#171c23');bg.paste(im,(0,60),im);ImageDraw.Draw(bg).text((20,16),'防卫修订 · '+label+' · 实际模型',font=font,fill='white');frames.append(bg)
  if i%20==0:print(f'Defense preview {i+1}/{len(seq)}',flush=True)
 frames[0].save(D/'防卫火焰_修订_实际动效.gif',save_all=True,append_images=frames[1:],duration=50,loop=0,optimize=False)
 print('Saved defense detail GIF',flush=True)

if __name__=='__main__':{'capture':capture,'sample':sample,'verify':verify,'demo':demo}[sys.argv[1]]()
