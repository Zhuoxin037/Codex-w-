from pathlib import Path
import json,re,subprocess,sys,os
R=Path('D:/数据包');S=R/'模型设计/C_红披风铠甲_GLB重建_20261024/阶段五_游戏接入_20261025';DP=R/'sweetdream';RP=R/'sweetdream_rp_完整版'
def main():
 os.environ['PYTHONIOENCODING']='utf-8';t0=R/'.workbuddy/tmp/husk_checks';t0.mkdir(parents=True,exist_ok=True);os.environ['TMP']=str(t0);os.environ['TEMP']=str(t0)
 m=json.loads((S/'接入清单.json').read_text(encoding='utf8'));rows=[];uuid='00000000-0000-0000-0000-000000000001'
 v=dict(amount='10',cap='2.5',step='0.14',id='1',animation='combat_idle',args='{}',command='return 0',duration='1',frame='0',to_frame='0',export_namespace='sweetdream_boss',name='test',x='0',y='0',z='0',u0='0',u1='0',u2='0',u3='1')
 for rel in m['datapack']:
  p=DP/rel
  if p.suffix!='.mcfunction':continue
  for n,line in enumerate(p.read_text(encoding='utf8').splitlines(),1):
   if not line.strip() or line.lstrip().startswith('#'):continue
   line=line.removeprefix('$');line=re.sub(r'\$\(([^)]+)\)',lambda x:v.get(x[1],uuid),line)
   # Offline dispatcher has only built-in registries; the real server tests husk_ward.
   line=line.replace('sweetdream:husk_ward','minecraft:protection')
   rows.append(f'{rel}\t{n}\t{line}')
 t=S/'原版命令样本.tsv';t.write_text('\n'.join(rows)+'\n',encoding='utf8')
 cp=(R/'.workbuddy/boss_server_check/classpath.txt').read_text(encoding='utf8').strip()+';'+str(R/'.workbuddy/boss_server_check/compiled')
 with (S/'原版解析.log').open('w',encoding='utf8')as log:
  r=subprocess.run(['C:/Users/qq303/AppData/Roaming/.minecraft/runtime/java-runtime-delta/bin/java.exe','-cp',cp,'bosscheck.ParseBoss',str(t)],stdout=log,stderr=subprocess.STDOUT)
 print({'parsed_samples':len(rows),'parser_exit':r.returncode},flush=True)
 checks=[]
 for p in sorted((R/'.workbuddy').glob('_chk_*.py')):
  with (S/('守门_'+p.stem+'.log')).open('w',encoding='utf8')as log:
   q=subprocess.run([sys.executable,str(p)],cwd=R,stdout=log,stderr=subprocess.STDOUT)
  checks.append({'name':p.name,'exit':q.returncode})
 (S/'守门检查.json').write_text(json.dumps(checks,ensure_ascii=False,indent=2),encoding='utf8');print(json.dumps(checks),flush=True)
if __name__=='__main__':main()
