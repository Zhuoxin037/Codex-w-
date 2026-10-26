import sys,json,re,subprocess,os,hashlib
sys.stdout.reconfigure(encoding='utf-8')
from pathlib import Path
sys.path.insert(0,str(Path(__file__).parent))
from rework_husk_motion_20261026 import D,TITLE
R=Path('D:/数据包');DP=R/'sweetdream';RP=R/'sweetdream_rp_完整版'
def main():
 manifest=json.loads((D/'原生安装清单.json').read_text(encoding='utf8'));files=set(manifest['datapack'])
 for root in ['data/sweetdream/function/boss/husk','data/sweetdream_boss/function/husk']:
  files.update(p.relative_to(DP).as_posix()for p in (DP/root).rglob('*')if p.is_file())
 vals=dict(amount='10',cap='2.5',step='.21',detour='.16',bonus='1',id='1',animation='combat_idle',args='{}',command='return 0',duration='1',frame='0',to_frame='0',export_namespace='sweetdream_boss',name='test',x='0',y='0',z='0',u0='0',u1='0',u2='0',u3='1');rows=[]
 for rel in sorted(files):
  p=DP/rel
  if p.suffix!='.mcfunction':continue
  for n,line in enumerate(p.read_text(encoding='utf8').splitlines(),1):
   if not line.strip()or line.lstrip().startswith('#'):continue
   line=line.removeprefix('$');line=re.sub(r'\$\(([^)]+)\)',lambda m:vals.get(m[1],'00000000-0000-0000-0000-000000000001'),line);line=line.replace('sweetdream:husk_ward','minecraft:protection');rows.append(f'{rel}\t{n}\t{line}')
 path=D/'原版命令样本.tsv';path.write_text('\n'.join(rows)+'\n',encoding='utf8');cp=(R/'.workbuddy/boss_server_check/classpath.txt').read_text(encoding='utf8').strip()+';'+str(R/'.workbuddy/boss_server_check/compiled')
 with (D/'原版解析.log').open('w',encoding='utf8')as log:r=subprocess.run(['C:/Users/qq303/AppData/Roaming/.minecraft/runtime/java-runtime-delta/bin/java.exe','-cp',cp,'bosscheck.ParseBoss',str(path)],stdout=log,stderr=subprocess.STDOUT)
 print({'commands':len(rows),'parser_exit':r.returncode},flush=True)
 if '--parser-only'in sys.argv:return
 env={**os.environ,'PYTHONIOENCODING':'utf-8'};out=subprocess.run([sys.executable,str(R/'.workbuddy/check.py')],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env=env);text=out.stdout.decode('utf8');(D/'包体检查.log').write_text(text,encoding='utf8');lines=text.splitlines()
 for j,l in enumerate(lines):
  if re.search(r'\] [1-9]\d* 条',l):print('\n'.join(lines[j:j+8]),flush=True)
 print(text[-160:],flush=True)
 b=json.loads((D/(TITLE+'.bbmodel')).read_text(encoding='utf8'));old=json.loads((D/'修改前_现场.bbmodel').read_text(encoding='utf8'));by={e['uuid']:e for e in old['elements']};changed=[]
 for e in b['elements']:
  o=by[e['uuid']]
  for key in ['from','to','origin','rotation','faces']:
   if e.get(key)!=o.get(key):changed.append([e['name'],key])
 manifest.update(datapack=sorted(files),source_aj=str(D/(TITLE+'.ajblueprint')),source_bb=str(D/(TITLE+'.bbmodel')),runtime_scale=1.5,base_health=1000,visual_height=4.5,animations=len(b['animations']),geometry_changed=changed,game_visual_tested=False)
 (D/'接入清单.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8');print({'geometry_differences':len(changed),'manifest_dp':len(files)},flush=True)
if __name__=='__main__':main()
