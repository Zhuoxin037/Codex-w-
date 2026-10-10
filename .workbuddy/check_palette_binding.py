from pathlib import Path
import json,copy,hashlib
B=Path('D:/数据包');RP=B/'sweetdream_rp';M=RP/'assets/palette/models/item';O=B/'模型设计/调色盘_阶段三';BACK=B/'.workbuddy/backup/palette-binding-2026-10-09'
load=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
manifest=load(B/'.workbuddy/palette_deploy_manifest.json');whole=load(M/'palette.json');edited=load(O/'显示调整示例/assets/palette/models/item/palette.json')
assert whole['display']==edited['display'],'Do not replace the user pose with the concept pose'
cache={}
def resolve(ref,trail=()):
 if ref in cache:return cache[ref]
 assert ref not in trail,'Cyclic model inheritance'
 ns,path=ref.split(':');j=load(RP/'assets'/ns/'models'/(path+'.json'))
 parent=resolve(j['parent'],trail+(ref,)) if 'parent' in j else {}
 result={**parent,**j,'textures':{**parent.get('textures',{}),**j.get('textures',{})}}
 if 'elements' in j:assert j['elements'],'Never inherit a complete palette through an empty part'
 cache[ref]=result;return result
def choose(j,floats,ctx):
 t=j['type']
 if t=='minecraft:empty':return []
 if t=='minecraft:model':return [j['model']]
 if t=='minecraft:composite':return [r for m in j['models'] for r in choose(m,floats,ctx)]
 if t=='minecraft:select':
  target=next((c['model'] for c in j['cases'] if ctx in c['when']),j['fallback']);return choose(target,floats,ctx)
 if t=='minecraft:range_dispatch':
  val=floats[j.get('index',0)];target=j['fallback']
  for e in j['entries']:
   if val>=e['threshold']:target=e['model']
  return choose(target,floats,ctx)
 raise AssertionError(t)
item=load(RP/'assets/palette/items/palette.json');assert item['hand_animation_on_swap'] is False
tested=0;maxcubes=0
for frame,counts in manifest['state_counts'].items():
 for c1 in range(4):
  for c2 in range(4):
   for ctx in ['firstperson_righthand','thirdperson_lefthand','gui']:
    floats=[int(frame),c1,c2,0,int(not c1 and not c2)];refs=choose(item['model'],floats,ctx)
    models=[resolve(r) for r in refs];actual=sum(len(m['elements']) for m in models)
    cnt=counts if ctx!='gui' else manifest['state_counts']['0']
    expected=cnt['common']+(cnt['slots'][0] if c1 else 0)+(cnt['slots'][1] if c2 else 0)+(cnt['neutral'] if not c1 and not c2 else 0)
    assert actual==expected,(frame,c1,c2,ctx,actual,expected)
    assert all(m['display']==whole['display'] for m in models)
    if int(frame)>=123 and ctx!='gui':assert actual==628,'No ghost palette during recovery'
    maxcubes=max(maxcubes,actual);tested+=1
for p in M.rglob('*.json'):
 ref='palette:item/'+str(p.relative_to(M).with_suffix('')).replace('\\','/');j=resolve(ref)
 for e in j['elements']:
  assert all(-16<=v<=32 for v in e['from']+e['to']),p
  assert all(a<b for a,b in zip(e['from'],e['to'])),p
  assert e.get('rotation',{}).get('angle',0) in [-45,-22.5,0,22.5,45],p
  for f in e['faces'].values():
   assert len(f['uv'])==4 and all(0<=v<=16 for v in f['uv'])
   key=f['texture'].lstrip('#');tex=j['textures'][key];ns,path=tex.split(':')
   assert (RP/'assets'/ns/'textures'/(path+'.png')).is_file(),(p,tex)
orb=load(RP/'assets/palette/items/color.json')
for c1 in range(4):
 for c2 in range(4):
  for phase in range(8):
   refs=choose(orb['model'],[c1+4*c2,phase],'none');assert len(refs)==1
   assert len(resolve(refs[0])['elements'])==manifest['stats']['entity_cubes_max']

# Prove the new hooks do not alter the existing costs, damage, movement or lifespan.
def commands(p):return [s.strip() for s in p.read_text(encoding='utf-8').splitlines() if s.strip() and not s.lstrip().startswith('#')]
original=commands(BACK/'sweetdream/data/sweetdream/function/equipment/staff/palette/skill.mcfunction')
current=commands(B/'sweetdream/data/sweetdream/function/equipment/staff/palette/skill.mcfunction')
original=[s for s in original if not ('item.components."minecraft:item_model" set value "sweetdream:pal_orb_' in s)]
current=[s.replace('billboard:"fixed"','billboard:"center"') for s in current if '/palette/visual/' not in s]
assert current==original,'Gameplay commands changed beyond the intended visual hooks'
original=commands(BACK/'sweetdream/data/sweetdream/function/equipment/staff/palette/color_tick.mcfunction')
current=[s for s in commands(B/'sweetdream/data/sweetdream/function/equipment/staff/palette/color_tick.mcfunction') if '/palette/visual/' not in s]
assert current==original
original=commands(BACK/'sweetdream/data/sweetdream/function/equipment/staff/palette/color_body.mcfunction')
current=[s for s in commands(B/'sweetdream/data/sweetdream/function/equipment/staff/palette/color_body.mcfunction') if '/palette/visual/' not in s]
assert current==original,'Tail orientation must not alter movement, targets or damage'
assert commands(B/'sweetdream/data/sweetdream/function/equipment/staff/palette/visual/color_face.mcfunction')==['tp @s ~ ~ ~ ~ ~']
for tag in ['load','tick']:
 values=load(B/'sweetdream/data/minecraft/tags/function'/(tag+'.json'))['values'];assert values.count('sweetdream:equipment/staff/palette/visual/'+tag)==1
modifier=load(B/'sweetdream/data/sweetdream/item_modifier/palette_visual.json');assert modifier[1]['floats']['values'][3]==0
for file in manifest['files']:assert (B/file).is_file(),file
print(json.dumps({'evaluated_color_frame_context_combinations':tested,'hand_cubes_peak':maxcubes,'display_preserved':True,'no_duplicate_palette_on_empty_layers':True,'paired_crystal_color_combinations':16,'gameplay_commands_unchanged':True,'all_references_valid':True,'deploy_files':len(manifest['files'])}))
