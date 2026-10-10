# -*- coding: utf-8 -*-
"""对 6 件'说不清差在哪'的 give 做逐字节定位。"""
import io

FILES = ["armor/furnace_core", "armor/lightless_sea", "armor/withered_garden",
         "bow/lucid_dream", "bow/sculk_echo", "staff/apocalypse"]

for rel in FILES:
    pa = 'C:/Users/qq303/AppData/Local/Temp/givebak/equipment/%s/give.mcfunction' % rel
    pb = 'sweetdream/data/sweetdream/function/equipment/%s/give.mcfunction' % rel
    a = open(pa, 'rb').read()
    b = open(pb, 'rb').read()
    print('#### %s   旧 %d 字节 / 新 %d 字节' % (rel, len(a), len(b)))
    if a == b:
        print('    字节完全相同(?)')
        continue
    # 行结构
    la = a.split(b'\n')
    lb = b.split(b'\n')
    print('    行数 旧 %d / 新 %d' % (len(la), len(lb)))
    print('    旧含 CR: %s / 新含 CR: %s' % (b'\r' in a, b'\r' in b))
    # 第一个差异行
    for i in range(max(len(la), len(lb))):
        x = la[i] if i < len(la) else None
        y = lb[i] if i < len(lb) else None
        if x != y:
            print('    首个差异行 #%d:' % i)
            print('      旧: %r' % (x[:200] if x else x))
            print('      新: %r' % (y[:200] if y else y))
            break
    print()
