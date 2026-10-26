# -*- coding: utf-8 -*-
"""把「以 $ 开头但已经不含 $(...)」的宏行还原成普通行。

背景: 2026-10-23 把 `@a[nbt={UUID:[I;$(u0),...]}]` 换成 `@a[tag=zx.ub]` 之后,
很多宏行里的 $(u0).. 被移走了, 但行首的 $ 还在 —— _chk_mcf_syntax 判为
"宏行不含 $(", 是包内的硬约定(说明这行本来就该是普通行)。这里统一摘掉。
"""
import os
import re
import sys

ROOT = r'D:/数据包/sweetdream/data/sweetdream/function'
VAR = re.compile(r'\$\([A-Za-z0-9_.]+\)')

write = '--write' in sys.argv
n = 0
files = 0
for dp, dn, fn in os.walk(ROOT):
    for f in sorted(fn):
        if not f.endswith('.mcfunction'):
            continue
        p = os.path.join(dp, f)
        lines = open(p, encoding='utf-8').read().split('\n')
        out = []
        hit = 0
        for line in lines:
            s = line.strip()
            if s.startswith('$') and not VAR.search(line):
                out.append(line.replace('$', '', 1))
                hit += 1
            else:
                out.append(line)
        if hit:
            files += 1
            n += hit
            print('%s  %d' % (os.path.relpath(p, ROOT), hit))
            if write:
                open(p, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
print('---- %d 个文件 / %d 行 ----' % (files, n))
