# -*- coding: utf-8 -*-
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                    'sweetdream', 'data', 'sweetdream', 'function', 'equipment')

rows = []
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if f != 'give.mcfunction':
            continue
        p = os.path.join(dp, f)
        with open(p, encoding='utf-8') as fh:
            t = fh.read()
        ids = re.findall(r'zx:\["([a-z_0-9]+)"', t)
        rel = os.path.relpath(dp, ROOT).replace(os.sep, '/')
        rows.append((rel, sorted(set(ids))))

for a, b in sorted(rows):
    print('%-26s %s' % (a, b))
print('共 %d 件' % len(rows))
