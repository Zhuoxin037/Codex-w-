# -*- coding: utf-8 -*-
"""列出某个 equipment 分类下所有武器的：底物 / custom_data.zx / 现有 item_model / 显示名。

用法: python _probe_cat.py <category>     例: python _probe_cat.py axe
只读。
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# 已有独立建模（老包 sweetdream_rp 里 items 定义齐全）的名单
MODELED = {
    'axe': ['angelcore'],
    'sword': ['deepseaecho', 'flameremnant', 'aurora_dream'],
}


def main(cat):
    d = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment', cat)
    rows = []
    for name in sorted(os.listdir(d)):
        g = os.path.join(d, name, 'give.mcfunction')
        if not os.path.isfile(g):
            rows.append((name, '(无 give)', '', '', ''))
            continue
        s = open(g, encoding='utf-8').read()
        base = re.search(r'^give @s (\S+?)\[', s, re.M)
        zx = re.search(r'custom_data=\{zx:\["(\w+)"', s)
        im = re.search(r'item_model="([^"]+)"', s)
        nm = re.search(r'item_name=\{?"?([^",}]*)', s)
        rows.append((name,
                     base.group(1) if base else '?',
                     zx.group(1) if zx else '(无)',
                     im.group(1) if im else '—',
                     nm.group(1)[:22] if nm else ''))

    mod = set(MODELED.get(cat, []))
    print('%-18s %-20s %-18s %-26s %s' % ('id', '底物', 'zx', 'item_model', '名'))
    print('-' * 100)
    for r in rows:
        tag = '  [已有建模]' if r[0] in mod else ''
        print('%-18s %-20s %-18s %-26s %-24s%s' % (r[0], r[1], r[2], r[3], r[4], tag))
    print('-' * 100)
    print('共 %d 件, 其中已有独立建模 %d 件' % (len(rows), len(mod)))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else 'axe')
