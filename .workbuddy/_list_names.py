# -*- coding: utf-8 -*-
import glob, io, re, os
rows = []
for p in sorted(glob.glob(r'D:\数据包\sweetdream\data\sweetdream\function\equipment\*\*\give.mcfunction')):
    s = io.open(p, encoding='utf-8').read()
    m = re.search(r'item_name=\{text:"([^"]+)"', s)
    cn = m.group(1) if m else '?'
    cid = os.path.basename(os.path.dirname(p))
    cat = os.path.basename(os.path.dirname(os.path.dirname(p)))
    rows.append((cat, cid, cn))
print(len(rows))
by = {}
for cat, cid, cn in rows:
    by.setdefault(cat, []).append(cn)
for cat, arr in by.items():
    print()
    print('== %s (%d) ==' % (cat, len(arr)))
    print(' / '.join(arr))
