import hashlib, json, sys
from pathlib import Path

R = Path('D:/数据包/sweetdream_rp_完整版/assets/sweetdream')
pats = ['models/item/burst_dawn', 'models/item/burst_dawn_ballistics_v1',
        'textures/item/burst_dawn', 'textures/item/burst_dawn_ballistics_v1']
files = []
for p in pats:
    files += [q for q in (R / p).rglob('*') if q.is_file()]
files += [R / 'items' / n for n in ['crossbow_burst_dawn.json', 'burst_dawn_shoulders.json',
                                    'burst_dawn_back.json', 'burst_dawn_arrow.json',
                                    'burst_dawn_muzzle.json', 'burst_dawn_impact.json']]
out = {}
for q in sorted(set(files)):
    out[str(q.relative_to(R)).replace('\\', '/')] = hashlib.sha256(q.read_bytes()).hexdigest()
tag = sys.argv[1] if len(sys.argv) > 1 else 'before'
Path('D:/数据包/.workbuddy/_snap_bd_%s.json' % tag).write_text(
    json.dumps(out, ensure_ascii=False, indent=0), encoding='utf8')
print(tag, 'files:', len(out))
