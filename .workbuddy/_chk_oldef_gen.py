# -*- coding: utf-8 -*-
"""守住 "oldef 生成器的 line() 输出 == 磁盘上的那一行"。

【为什么要它】`_gen_oldef_*.py` 与 `_fix_oldef.py` 都是**追加/整行替换**式生成器,
  不是"跑一遍重写整个文件"。一旦有人在磁盘上手改了某条(比如改颜色、改数值),
  生成器就悄悄和磁盘**漂移**了 —— 下次谁再跑一次生成器(或照它的样子复制新条目),
  就会把旧内容带回来。这类漂移完全静默: 游戏照跑, check.py 也看不出来
  (它只查结构, 不查"和生成器是否一致")。

【怎么查】把每个生成器 import 进来, 手动调它的 `line(...)`, 和磁盘逐字比。
  ★ 顺带守住"生成器必须带颜色表 OL_COLOR" —— 漏了 KeyError, 直接暴露。

重跑: python .workbuddy/_chk_oldef_gen.py
"""
import importlib.util
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LOAD = os.path.join(HERE, '..', 'sweetdream', 'data', 'sweetdream', 'function',
                    'overlimit', 'def', 'load.mcfunction')

sys.path.insert(0, HERE)


def load_mod(fn):
    spec = importlib.util.spec_from_file_location(
        os.path.splitext(fn)[0], os.path.join(HERE, fn))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def disk_lines():
    out = {}
    for ln in io.open(LOAD, encoding='utf-8').read().split('\n'):
        if ln.lstrip().startswith('#') or ' set value ' not in ln:
            continue
        mid = re.search(r'oldef\."([^"]+)"', ln)
        if mid:
            out[mid.group(1)] = ln
    return out


bad = []
disk = disk_lines()

# ---- 6 个批量生成器: DEFS = [(uid, label, note, items)] + line(uid,label,note,items) ----
for fn in ('_gen_oldef_e1.py', '_gen_oldef_e2.py',
           '_gen_oldef_f1.py', '_gen_oldef_f2.py', '_gen_oldef_gh.py',
           '_gen_oldef_i1.py'):
    mod = load_mod(fn)
    for (uid, label, note, items) in mod.DEFS:
        want = mod.line(uid, label, note, items).rstrip('\n')
        got = disk.get(uid)
        if got is None:
            bad.append('%s: oldef."%s" 磁盘上没有这一条' % (fn, uid))
        elif got != want:
            bad.append('%s: oldef."%s" 与磁盘不一致\n   生成器: %s\n   磁盘  : %s'
                       % (fn, uid, want[:110], got[:110]))
        else:
            print('[ok] %-20s oldef."%s"' % (fn, uid))

# ---- _fix_oldef.py: NEW = {id: 整行}; ★ 它写的是**折行前**的 lore, 跑完还要过
#      `lore_fmt.py --write`, 所以整行必然和磁盘不等 —— 这里只比 **name 组件**
#      (也就是"超限名怎么显示", 含颜色), 这才是它真正管的东西。 ----
_NAME = re.compile(r'name:\{[^}]*\}')


def name_of(line):
    m = _NAME.search(line)
    return m.group(0) if m else None


mod = load_mod('_fix_oldef.py')
for uid, want in mod.NEW.items():
    got = disk.get(uid)
    if got is None:
        bad.append('_fix_oldef.py: oldef."%s" 磁盘上没有这一条' % uid)
    elif name_of(got) != name_of(want):
        bad.append('_fix_oldef.py: oldef."%s" 的 name 组件与磁盘不一致\n   生成器: %s\n   磁盘  : %s'
                   % (uid, name_of(want), name_of(got)))
    else:
        print('[ok] %-20s oldef."%s"  (只比 name 组件, 它的 lore 是折行前的)'
              % ('_fix_oldef.py', uid))

# ---- 未被任何生成器覆盖的条目: 只提示(手写的), 不算问题 ----
covered = set()
for fn in ('_gen_oldef_e1.py', '_gen_oldef_e2.py',
           '_gen_oldef_f1.py', '_gen_oldef_f2.py', '_gen_oldef_gh.py',
           '_gen_oldef_i1.py'):
    covered |= {d[0] for d in load_mod(fn).DEFS}
covered |= set(load_mod('_fix_oldef.py').NEW)
manual = sorted(set(disk) - covered)
if manual:
    print('[注意] 以下条目是手写的(没有生成器守着): %s' % ', '.join(manual))

print('---- 问题 %d 条' % len(bad))
for b in bad:
    print('[x] ' + b)
sys.exit(1 if bad else 0)
