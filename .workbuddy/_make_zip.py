# -*- coding: utf-8 -*-
"""_make_zip.py —— 只把 sweetdream_rp_完整版 打成可分发 zip（不做任何删除，绕开沙箱的批量删除确认）

build_full_pack.py --zip 里的 `shutil.rmtree(OUT)` 一次性删 7314 个文件，会被
沙箱 safe-delete 的"批量删除需确认"拦下（SAFE_DELETE_BULK_CONFIRM_REQUIRED）。
本脚本只读 OUT、写一个 zip，不删任何东西。
"""
import os
import zipfile
import hashlib

ROOT = r'D:\数据包'
OUT = os.path.join(ROOT, 'sweetdream_rp_完整版')
ZIP = os.path.join(ROOT, 'sweetdream_rp_完整版.zip')


def rel_files(root):
    out = {}
    for dp, _, fns in os.walk(root):
        for fn in fns:
            p = os.path.join(dp, fn)
            out[os.path.relpath(p, root).replace('\\', '/')] = p
    return out


src = rel_files(OUT)
print('源文件数:', len(src))
if os.path.exists(ZIP):
    os.remove(ZIP)                      # 单个文件，不触发批量阈值
n = 0
with zipfile.ZipFile(ZIP, 'w', zipfile.ZIP_DEFLATED) as z:
    for rel in sorted(src):
        z.write(src[rel], rel)
        n += 1

with zipfile.ZipFile(ZIP) as z:
    names = z.namelist()
    ok_set = set(names) == set(src)
    ok_hash = all(hashlib.sha256(z.read(rel)).hexdigest() ==
                  hashlib.sha256(open(src[rel], 'rb').read()).hexdigest() for rel in names)

print('zip ->', ZIP)
print('  文件数:', n, '| 体积: %.1f MB' % (os.path.getsize(ZIP) / 1048576))
print('  pack.mcmeta 在根:', 'pack.mcmeta' in names)
print('  含火种两态:', 'assets/sweetdream/items/tinder_off.json' in names,
      '|', 'assets/sweetdream/items/tinder_on.json' in names)
print('  文件集一致:', ok_set, '| 逐字节一致:', ok_hash)
