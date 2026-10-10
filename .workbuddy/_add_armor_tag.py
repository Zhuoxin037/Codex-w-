# -*- coding: utf-8 -*-
"""给所有盔甲 give 的 custom_data.zx 追加通用类别词 armor"""
import glob, io, os

BASE = "D:/数据包/sweetdream/data/sweetdream/function/equipment/armor"
n = 0
for p in sorted(glob.glob(BASE + "/*/give.mcfunction")):
    s = io.open(p, encoding="utf-8").read()
    if '"armor"' in s:
        continue
    out = []
    i = 0
    key = 'custom_data={zx:['
    changed = False
    while True:
        j = s.find(key, i)
        if j < 0:
            out.append(s[i:])
            break
        k = s.find(']}', j)
        if k < 0:
            out.append(s[i:])
            break
        inner = s[j + len(key):k]
        out.append(s[i:j] + key + inner + ',"armor"' + ']}')
        i = k + 2
        changed = True
    if changed:
        io.open(p, "w", encoding="utf-8").write("".join(out))
        n += 1
        print("patched", os.path.basename(os.path.dirname(p)))
print("total:", n)
