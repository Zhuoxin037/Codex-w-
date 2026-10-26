from analyze_a_boss_static_20261022 import S
from bb_local_bridge_client import script

print(script("let d=Codecs.project.compile({raw:true});if(typeof d==='string')d=JSON.parse(d);return {keys:Object.keys(d),meta:d.meta,groups:d.groups?d.groups.length:null,outliner_first:typeof d.outliner[0],elements:d.elements.length};"),flush=True)
