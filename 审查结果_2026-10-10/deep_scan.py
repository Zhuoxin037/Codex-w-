import collections, json, re, zipfile
from PIL import Image
from pathlib import Path
ROOT=Path(r'D:\数据包'); OUT=Path(__file__).parent; RP=ROOT/'sweetdream_rp_完整版'
jar=zipfile.ZipFile(Path(r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\1.21.5-Fabric 0.16.10.jar'))
models={}; items={}; allfiles={}; problems=collections.defaultdict(list)
for p in RP.rglob('*'):
    if not p.is_file(): continue
    rel=p.relative_to(RP).as_posix(); allfiles[rel]=p
    if p.suffix!='.json': continue
    d=json.loads(p.read_text(encoding='utf-8-sig'))
    a=rel.split('/')
    if len(a)>3 and a[2]=='models': models[a[1]+':'+ '/'.join(a[3:])[:-5]]=d
    if len(a)>3 and a[2]=='items': items[a[1]+':'+ '/'.join(a[3:])[:-5]]=d

def refs(d,key):
    if isinstance(d,dict):
        for k,v in d.items():
            if k==key and isinstance(v,str): yield v
            yield from refs(v,key)
    elif isinstance(d,list):
        for v in d: yield from refs(v,key)

def vanilla_model(k):
    ns,id=k.split(':',1) if ':' in k else ('minecraft',k)
    p=f'assets/{ns}/models/{id}.json'
    return json.loads(jar.read(p)) if p in jar.namelist() else {}
def model(k): return models.get(k,vanilla_model(k))
def texture_table(k,seen=None):
    seen=set() if seen is None else seen
    if k in seen: return {}
    seen.add(k); d=model(k); t=texture_table(d['parent'],seen) if 'parent' in d else {}
    return {**t,**d.get('textures',{})}
for k,d in models.items():
    t=texture_table(k)
    for i,e in enumerate(d.get('elements',[])):
        for c in e.get('from',[])+e.get('to',[]):
            if not -16<=c<=32: problems['element_bounds'].append([k,i,c])
        for f,fd in e.get('faces',{}).items():
            if 'uv' in fd and (len(fd['uv'])!=4 or any(not isinstance(v,(int,float)) for v in fd['uv'])): problems['face_uv'].append([k,i,f])
            tex=fd.get('texture',''); seen=set()
            while tex.startswith('#') and tex not in seen:
                seen.add(tex); tex=t.get(tex[1:],'')
            if not tex or tex.startswith('#'): problems['unresolved_texture'].append([k,i,f,fd.get('texture')])

roots=set(v for d in items.values() for v in refs(d,'model'))
visited=set(); queue=list(roots)
while queue:
    k=queue.pop()
    if k in visited: continue
    visited.add(k)
    if k in models and models[k].get('parent') in models: queue.append(models[k]['parent'])
unused=set(models)-visited
unusedpaths=[f'assets/{k.split(":")[0]}/models/{k.split(":")[1]}.json' for k in unused]
group=collections.defaultdict(lambda: {'files':0,'bytes':0,'elements':0})
for k,d in models.items():
    ns=k.split(':')[0]; group[ns]['files']+=1; group[ns]['elements']+=len(d.get('elements',[]))
    group[ns]['bytes']+=allfiles[f'assets/{ns}/models/{k.split(":")[1]}.json'].stat().st_size
summary={'model_count':len(models),'item_definitions':len(items),'unused_models':len(unused),
         'unused_model_bytes':sum(allfiles[p].stat().st_size for p in unusedpaths),
         'unused_examples':sorted(unused)[:30],'namespace_models':dict(group),
         'validation_counts':{k:len(v) for k,v in problems.items()},'validation_examples':{k:v[:10] for k,v in problems.items()},
         'static_items':{k:d.get('model') for k,d in items.items() if k in ['angelcore:axe','sail:staff','sweetdream:aurora_dream','sweetdream:look']},
         'extra_files':[{ 'path':p,'bytes':allfiles[p].stat().st_size} for p in allfiles if p.endswith('.py') or '.bak' in p or '.broken-' in p]}
vanilla_names=set(jar.namelist())
for rel,p in allfiles.items():
    if '/equipment/' in rel and rel.endswith('.json'):
        d=json.loads(p.read_text(encoding='utf-8-sig'))
        for kind,layers in d.get('layers',{}).items():
            for layer in layers:
                ns,rid=layer['texture'].split(':',1) if ':' in layer['texture'] else ('minecraft',layer['texture'])
                tex=f'assets/{ns}/textures/entity/equipment/{kind}/{rid}.png'
                if tex not in allfiles and tex not in vanilla_names: problems['equipment_texture'].append([rel,tex])
    if rel.endswith('.png.mcmeta'):
        d=json.loads(p.read_text(encoding='utf-8-sig')).get('animation',{})
        img=allfiles.get(rel[:-7])
        if img:
            with Image.open(img) as im: w,h=im.size
            fw=d.get('width',min(w,h)); fh=d.get('height',min(w,h))
            if fw<=0 or fh<=0 or w%fw or h%fh: problems['animation_dimensions'].append([rel,w,h,fw,fh])
            else:
                count=(w//fw)*(h//fh)
                for f in d.get('frames',[]):
                    index=f.get('index',-1) if isinstance(f,dict) else f
                    if not 0<=index<count: problems['animation_index'].append([rel,index,count])
                if d.get('frametime',1)<=0: problems['animation_time'].append(rel)
asset_dir=Path(r'D:\PCL 正式版 2.10.0\.minecraft\assets')
asset_index=json.loads((asset_dir/'indexes/24.json').read_text(encoding='utf-8'))
sound_hash=asset_index['objects']['minecraft/sounds.json']['hash']
sound_ids=set(json.loads((asset_dir/'objects'/sound_hash[:2]/sound_hash).read_text(encoding='utf-8')))
funcs=json.loads((OUT/'functions.json').read_text(encoding='utf-8'))
for k,v in funcs.items():
    for n,s in v['lines']:
        m=re.search(r'\bplaysound (?:minecraft:)?([a-z0-9_.]+)\s',s)
        if m and m[1] not in sound_ids: problems['unknown_vanilla_sound'].append([k,n,m[1]])
summary['validation_counts']={k:len(v) for k,v in problems.items()}
summary['validation_examples']={k:v[:10] for k,v in problems.items()}
(OUT/'resource_details.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))

funcs=json.loads((OUT/'functions.json').read_text(encoding='utf-8'))
for k,d in funcs.items():
    if not (k.endswith('/cast') or k.endswith('/skill')): continue
    checks=[n for n,s in d['lines'] if 'function manacore:api/skill/check' in s]
    if not checks: continue
    candidates=[(n,s) for n,s in d['lines'] if n<checks[0] and re.search(r'scoreboard players (?:reset|set) @s',s)]
    if candidates: print('PRECHECK_WRITES',k,candidates)
