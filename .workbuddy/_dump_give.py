# -*- coding: utf-8 -*-
"""列出全部装备 give 的 custom_data / skill / 底材，供新增装备对照。"""
import glob, re, io, os

BASE = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'
for f in sorted(glob.glob(os.path.join(BASE, '*', '*', 'give.mcfunction'))):
    t = io.open(f, encoding='utf-8').read()
    rel = os.path.relpath(f, BASE).replace('\\', '/')
    base = re.search(r'^give @s ([a-z_]+)', t, re.M)
    cd = re.search(r'custom_data=\{zx:\[[^\]]*\]', t)
    sk = re.search(r'skill:"([^"]*)"', t)
    print('%-26s %-18s %-46s %s' % (
        os.path.dirname(rel),
        base.group(1) if base else '?',
        cd.group(0) if cd else '???',
        sk.group(1) if sk else ''))
