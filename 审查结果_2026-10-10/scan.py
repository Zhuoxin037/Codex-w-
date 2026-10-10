"""Read-only audit of the three packs; outputs evidence only in this directory."""
import collections, hashlib, json, re, zipfile
from pathlib import Path
from PIL import Image

ROOT = Path(r'D:\数据包')
OUT = Path(__file__).parent
PACKS = ['manacore-1.0.0', 'sweetdream', 'sweetdream_rp_完整版']
JAR = Path(r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\1.21.5-Fabric 0.16.10.jar')
vanilla = set(zipfile.ZipFile(JAR).namelist()) if JAR.exists() else set()
stats, docs, funcs, issues = {}, {}, {}, collections.defaultdict(list)
for pack in PACKS:
    files = [p for p in (ROOT / pack).rglob('*') if p.is_file()]
    stats[pack] = {'files': len(files), 'bytes': sum(p.stat().st_size for p in files),
                   'extensions': dict(collections.Counter(p.suffix for p in files))}
    for p in files:
        rel = p.relative_to(ROOT).as_posix()
        if p.suffix in ('.json', '.mcmeta'):
            try:
                pairs = []
                def obj(pairs):
                    d = {}
                    for k, v in pairs:
                        if k in d: issues['duplicate_json_keys'].append([rel, k])
                        d[k] = v
                    return d
                docs[rel] = json.loads(p.read_text(encoding='utf-8-sig'), object_pairs_hook=obj)
            except Exception as e: issues['json_errors'].append([rel, str(e)])
        if p.suffix == '.mcfunction':
            parts = p.relative_to(ROOT / pack / 'data').parts
            fid = parts[0] + ':' + '/'.join(parts[2:])[:-11]
            funcs[fid] = {'path': rel, 'lines': [(i, s.strip()) for i,s in enumerate(p.read_text(encoding='utf-8-sig').splitlines(), 1) if s.strip() and not s.lstrip().startswith('#')]}
        if p.suffix == '.png':
            try:
                with Image.open(p) as im: im.verify()
            except Exception as e: issues['png_errors'].append([rel, str(e)])

rp = ROOT / PACKS[2]
def asset_exists(kind, ref, ext='.json'):
    if ref.startswith('#'): return True
    ns, rid = ref.split(':', 1) if ':' in ref else ('minecraft', ref)
    key = f'assets/{ns}/{kind}/{rid}{ext}'
    return (rp/key).exists() or key in vanilla or kind == 'models' and rid in ('builtin/generated', 'builtin/entity')
def walk(d, path):
    if isinstance(d, dict):
        for k,v in d.items():
            if k == 'model' and isinstance(v,str) and not asset_exists('models',v): issues['missing_models'].append([path,v])
            if k == 'parent' and isinstance(v,str) and not asset_exists('models',v): issues['missing_parents'].append([path,v])
            if k == 'textures' and isinstance(v,dict):
                for tk,tv in v.items():
                    if isinstance(tv,str) and not asset_exists('textures',tv,'.png'): issues['missing_textures'].append([path,tk,tv])
            walk(v,path)
    elif isinstance(d,list):
        for v in d: walk(v,path)
for rel,d in docs.items():
    if rel.startswith(PACKS[2]+'/assets/'): walk(d,rel)

models=[]
for rel,d in docs.items():
    if '/models/' not in rel or not rel.startswith(PACKS[2]+'/'): continue
    elems=d.get('elements',[])
    models.append([len(elems),rel])
    for i,e in enumerate(elems):
        if e.get('rotation',{}).get('angle',0) not in (-45,-22.5,0,22.5,45): issues['invalid_rotation'].append([rel,i,e['rotation']])
        f,t=e.get('from'),e.get('to')
        if f and t and any(a>b for a,b in zip(f,t)): issues['inverted_elements'].append([rel,i,f,t])
    if 'animation' in d: issues['model_animation_field'].append(rel)

zpath=ROOT/'sweetdream_rp_完整版.zip'
if zpath.exists():
    with zipfile.ZipFile(zpath) as z:
        names={i.filename:i for i in z.infolist() if not i.is_dir()}
        disk={p.relative_to(rp).as_posix():p for p in rp.rglob('*') if p.is_file()}
        for n in sorted(names.keys()-disk.keys()): issues['zip_only'].append(n)
        for n in sorted(disk.keys()-names.keys()): issues['folder_only'].append(n)
        for n in sorted(names.keys()&disk.keys()):
            if hashlib.sha256(z.read(n)).digest()!=hashlib.sha256(disk[n].read_bytes()).digest(): issues['zip_diff'].append(n)
        stats['zip']={'files':len(names),'bytes':zpath.stat().st_size,'corrupt_entry':z.testzip()}

fnstats=sorted([[len(v['lines']),k,v['path']] for k,v in funcs.items()],reverse=True)
tick = funcs.get('sweetdream:core/tick',{}).get('lines',[])
stats['tick']={'direct_commands':len(tick),'entity_selectors':sum('@e[' in s for _,s in tick),'player_selectors':sum('@a' in s for _,s in tick)}
stats['equipment']={c.name:len(list(c.glob('*/give.mcfunction'))) for c in (ROOT/'sweetdream/data/sweetdream/function/equipment').iterdir() if c.is_dir()}
stats['upgrade_items']=len(list((ROOT/'sweetdream/data/sweetdream/function/upgrade/item').glob('*.mcfunction')))
stats['overlimit_items']=len(list((ROOT/'sweetdream/data/sweetdream/function/overlimit/item').glob('*.mcfunction')))
summary={'stats':stats,'issues':dict(issues),'largest_models':sorted(models,reverse=True)[:30],'largest_functions':fnstats[:25]}
(OUT/'scan.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
(OUT/'functions.json').write_text(json.dumps(funcs,ensure_ascii=False),encoding='utf-8')
print(json.dumps({'stats':stats,'issue_counts':{k:len(v) for k,v in issues.items()},'issue_examples':{k:v[:8] for k,v in issues.items()},'largest_models':sorted(models,reverse=True)[:12],'largest_functions':fnstats[:12]},ensure_ascii=False,indent=2))
