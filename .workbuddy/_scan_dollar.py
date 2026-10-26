import os, re

root = r'D:/数据包/sweetdream/data/sweetdream/function'
bad = []
total = 0
for dp, dn, fn in os.walk(root):
    for f in fn:
        if not f.endswith('.mcfunction'):
            continue
        p = os.path.join(dp, f)
        for i, line in enumerate(open(p, encoding='utf-8'), 1):
            s = line.strip()
            if '${' in line or ' $(' in line or line.lstrip().startswith('$'):
                total += 1
            if re.search(r'\$\([A-Za-z0-9_.]+\)', line) and not s.startswith('$'):
                bad.append((p, i, line.rstrip()))
print('lines with $(...) not starting with $:', len(bad))
for b in bad[:20]:
    print('  ', b[0], b[1], b[2][:140])
print('total $-ish lines:', total)
