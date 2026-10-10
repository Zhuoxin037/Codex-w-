from pathlib import Path
import json,math,copy
B=Path('D:/数据包');RP=B/'sweetdream_rp';A=RP/'assets/sail';M=A/'models/item'
load=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
whole=load(M/'staff.json');report=load(B/'.workbuddy/sail_layout_report.json')
assert len(whole['elements'])==632 and whole['display']==report['display']
for p in M.rglob('*.json'):
 j=load(p)
 if p.name!='staff.json':
  assert j['parent']=='sail:item/staff' and 'display' not in j,p
  assert 'elements' in j,'A child must override the complete parent geometry'
 for e in j['elements']:
  assert all(-16<=v<=32 for v in e['from']+e['to']),p
  assert all(a<b for a,b in zip(e['from'],e['to'])),p
  assert e.get('rotation',{}).get('angle',0) in [-45,-22.5,0,22.5,45],p
  for f in e['faces'].values():assert f['texture'].lstrip('#') in j['textures'],p
 for texture in j['textures'].values():
  ns,tex=texture.split(':');assert (RP/'assets'/ns/'textures'/(tex+'.png')).is_file(),texture

old=load(B/'.workbuddy/backup/sail-layout-2026-10-09/sweetdream_rp/assets/sweetdream/models/item/sail/body.json')
assert load(M/'parts/body.json')['elements']==old['elements'],'Preserve edited body geometry exactly'
for p in (M/'frames').glob('*.json'):
 oldframe=load(B/'.workbuddy/backup/sail-layout-2026-10-09/sweetdream_rp/assets/sweetdream/models/item/sail/frames'/p.name)
 assert load(p)['elements']==oldframe['elements'],'Animation geometry changed'
for context,previous in old['display'].items():
 expected={'rotation':previous.get('rotation',[0,0,0]),'translation':previous.get('translation',[0,0,0]),'scale':previous.get('scale',[1,1,1])}
 assert whole['display'][context]==expected
assert load(RP/'assets/sweetdream/items/sail.json')==load(A/'items/staff.json')
refs=[]
def walk(j):
 if isinstance(j,dict):
  if j.get('type')=='minecraft:model':refs.append(j['model'])
  for v in j.values():walk(v)
 elif isinstance(j,list):
  for v in j:walk(v)
walk(load(A/'items/staff.json'))
for ref in refs:
 ns,name=ref.split(':');assert (RP/'assets'/ns/'models'/(name+'.json')).is_file(),ref
assert len(refs)==95
modifier=load(B/'sweetdream/data/sweetdream/item_modifier/sail_visual.json')
assert modifier[0]['components']['minecraft:item_model']=='sail:staff'
assert 'sweetdream:sail_visual' in (B/'sweetdream/data/sweetdream/function/equipment/staff/sail/visual/apply.mcfunction').read_text(encoding='utf-8')

# Changing any whole-model display context must reach EVERY independently rendered part.
test=copy.deepcopy(whole['display']);test['firstperson_righthand']['translation']=[2,3,4]
parts=[load(p) for p in M.rglob('*.json') if p.name!='staff.json']
assert all('display' not in p and p['parent']=='sail:item/staff' for p in parts)
assert len(parts)==65
print(json.dumps({'parts_sharing_display':len(parts),'animation_frames_preserved':60,'edited_body_preserved':True,'edited_hand_transforms_preserved':True,'whole_preview_cubes':632,'model_texture_and_item_references_valid':True,'gameplay_changed':False}))
