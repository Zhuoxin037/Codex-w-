# -*- coding: utf-8 -*-
"""字符级 diff: 精确定位 give 行里增删的字。"""
import io, difflib

FILES = ["armor/furnace_core", "armor/lightless_sea", "armor/withered_garden",
         "bow/lucid_dream", "bow/sculk_echo", "staff/apocalypse"]


def give_line(p):
    for ln in io.open(p, encoding='utf-8').read().split('\n'):
        if ln.startswith('give @s '):
            return ln.rstrip('\r')
    return None


for rel in FILES:
    pa = 'C:/Users/qq303/AppData/Local/Temp/givebak/equipment/%s/give.mcfunction' % rel
    pb = 'sweetdream/data/sweetdream/function/equipment/%s/give.mcfunction' % rel
    a, b = give_line(pa), give_line(pb)
    print('=' * 78)
    print('#### %s' % rel)
    print('=' * 78)
    if a is None or b is None:
        print('  (没找到 give 行)')
        continue
    if a == b:
        print('  give 行完全相同')
        # 那么差异在注释行
        A = io.open(pa, encoding='utf-8').read().replace('\r\n', '\n').split('\n')
        B = io.open(pb, encoding='utf-8').read().replace('\r\n', '\n').split('\n')
        d = difflib.unified_diff(A, B, lineterm='', n=0)
        for ln in list(d)[2:]:
            print('  ' + ln)
        print()
        continue
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == 'equal':
            continue
        old = a[i1:i2]
        new = b[j1:j2]
        ctx_l = a[max(0, i1 - 14):i1]
        ctx_r = a[i2:i2 + 14]
        print('  ...%s【%s】%s...' % (ctx_l, ('旧:' + old + ' ⇒ 新:' + new), ctx_r))
    print()
