"""Build a review overlay in isolation; never write the live pack or binding."""
from pathlib import Path
import json,shutil,hashlib,runpy,sys
import integrate_boss_fireaxe as base
R=Path(__file__).resolve().parents[1];O=R/'模型设计/BOSS_GLB重建_20261016/阶段六_半血转阶段与连招试做';C=O/'候选包体'
main=R/'.workbuddy/boss_fireaxe_binding.json';data=main.read_bytes();m=json.loads(data)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
snapshot={str(R/pack/rel):h(R/pack/rel) for pack,key in [('sweetdream','datapack_files'),('sweetdream_rp_完整版','resource_files')] for rel in m[key]}
for pack,key in [('sweetdream','datapack_files'),('sweetdream_rp_完整版','resource_files')]:
 for rel in m[key]+['pack.mcmeta']:
  src=R/pack/rel;dst=C/pack/rel
  if src.exists():dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
(C/'.workbuddy').mkdir(parents=True,exist_ok=True);(C/'.workbuddy/boss_fireaxe_binding.json').write_bytes(data)
base.ROOT=C;base.DP=C/'sweetdream';base.RP=C/'sweetdream_rp_完整版';base.F=base.DP/'data/sweetdream/function/boss/fireaxe'
sys.argv=['revise_boss_fireaxe_runtime.py','--stage',str(O)]
runpy.run_path(str(R/'.workbuddy/revise_boss_fireaxe_runtime.py'),run_name='__main__')
p=C/'.workbuddy/boss_fireaxe_binding.json';man=json.loads(p.read_text(encoding='utf8'))
# The runtime builder now installs approved phase-two clips after the prior fixes.
assert 'second_phase' in man
assert main.read_bytes()==data
assert all(h(Path(p))==digest for p,digest in snapshot.items())
(O/'现有包未改动核对.json').write_text(json.dumps({'main_binding_unchanged':True,'live_source_files_unchanged':len(snapshot),'game_deployed':False},indent=2),encoding='utf8')
print('Review candidate only:',len(man['datapack_files']),'datapack files; live pack unchanged')
