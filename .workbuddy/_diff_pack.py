# -*- coding: utf-8 -*-
"""诊断：对比 BASE / OUT / DEPLOY 的文件集，找出合并包多出/缺失的文件。"""
import os
import sys

ROOT = r'D:\数据包'
BASE = os.path.join(ROOT, 'sweetdream_rp_完整版')
OUT = os.path.join(ROOT, 'sweetdream_rp_完整版')
DEP = r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\resourcepacks\sweetdream_rp_完整版'
OVL = os.path.join(ROOT, 'sweetdream_rp_原版风')


def rl(root):
    s = set()
    for dp, _, fns in os.walk(root):
        for fn in fns:
            s.add(os.path.relpath(os.path.join(dp, fn), root).replace(os.sep, '/'))
    return s


def show(title, items, limit=200):
    items = sorted(items)
    print('%s  (%d)' % (title, len(items)))
    for x in items[:limit]:
        print('    ' + x)
    if len(items) > limit:
        print('    ... 还有 %d 个' % (len(items) - limit))


b, o = rl(BASE), rl(OUT)
ov = rl(OVL)
print('BASE=%d  OUT=%d  OVERLAY=%d  DEPLOY=%s' %
      (len(b), len(o), len(ov), len(rl(DEP)) if os.path.isdir(DEP) else '不存在'))
print()
show('OUT 独有（不在老包）', o - b)
print()
show('老包独有（OUT 缺）', b - o)
print()
show('覆盖层里 OUT 没有的', ov - o)
