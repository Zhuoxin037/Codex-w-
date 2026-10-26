# -*- coding: utf-8 -*-
"""部署后核对: 源 -> 存档 逐文件 SHA256 是否一致(批 K10 卡顿修复)。"""
import hashlib
import os
import re

SRC_ROOT = r'D:/数据包/sweetdream'
DST_ROOT = r'D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/saves/测试包体/datapacks'

log = open(r'D:/数据包/.workbuddy/_deploy_k10.txt', encoding='utf-8').read()
paths = []
for line in log.split('\n'):
    m = re.match(r'\s+(覆盖|新增|删除)\s+(\S.*?)\s*$', line)
    if m and m.group(1) != '删除':
        paths.append(m.group(2).replace('\\', '/'))

# 定位存档里的 sweetdream 包
pack = None
for name in os.listdir(DST_ROOT):
    if name.startswith('sweetdream'):
        pack = os.path.join(DST_ROOT, name)
        break
if pack is None:
    print('找不到存档里的 sweetdream 包; DST_ROOT =', DST_ROOT)
    raise SystemExit(1)

bad = 0
for rel in paths:
    src = os.path.join(SRC_ROOT, rel)
    dst = os.path.join(pack, rel)
    if not os.path.exists(dst):
        print('缺  ', rel)
        bad += 1
        continue
    h1 = hashlib.sha256(open(src, 'rb').read()).hexdigest()
    h2 = hashlib.sha256(open(dst, 'rb').read()).hexdigest()
    if h1 != h2:
        print('不一致', rel)
        bad += 1
print('核对 %d 个文件, 不一致/缺失 %d' % (len(paths), bad))
