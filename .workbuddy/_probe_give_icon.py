# -*- coding: utf-8 -*-
"""普查 12 件剑的所有物品串产出点, 看是否都带了 item_model="sweetdream:<id>"。

只读, 不写任何文件。用于验收 _ins_sword_icon.py 的注入是否完整。
"""
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'sweetdream', 'data', 'sweetdream', 'function')
IDS = ['everfrost', 'hengdao', 'hush', 'liaoyuan', 'liuguang', 'myriad',
       'qiansan', 'rebound', 'remelt', 'rogue_star', 'shadow_blade', 'verdict']

ZX = re.compile(r'custom_data=\{zx:\["(\w+)"')

n = 0
bad = []
rows = []
for r, d, fs in os.walk(ROOT):
    for fn in fs:
        if not fn.endswith('.mcfunction'):
            continue
        p = os.path.join(r, fn)
        rel = os.path.relpath(p, ROOT).replace('\\', '/')
        for ln, s in enumerate(open(p, encoding='utf-8'), 1):
            m = ZX.search(s)
            if not m or m.group(1) not in IDS:
                continue
            st = s.strip()
            if not (st.startswith('give') or 'item replace' in s):
                continue
            n += 1
            want = 'item_model="sweetdream:%s"' % m.group(1)
            ok = want in s
            rows.append((ok, m.group(1), rel, ln, st[:38]))
            if not ok:
                bad.append((rel, ln, m.group(1)))

print('物品串 %d 处, 未注入 item_model 的 %d 处' % (n, len(bad)))
for ok, wid, rel, ln, head in sorted(rows, key=lambda x: (x[1], x[2])):
    print('  %s %-12s %-58s L%-4d %s' % ('✓' if ok else '✗', wid, rel, ln, head))
if bad:
    print()
    print('!! 缺失:')
    for b in bad:
        print('   ', b)
