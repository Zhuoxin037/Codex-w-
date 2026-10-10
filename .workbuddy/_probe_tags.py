# -*- coding: utf-8 -*-
import zipfile
J = r'D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar'
z = zipfile.ZipFile(J)
ns = [n for n in z.namelist() if n.startswith('data/minecraft/tags/damage_type/')]
print('vanilla damage_type tag files:', len(ns))
for n in sorted(ns):
    print('  ', n.split('/')[-1])
print('--- bypasses_cooldown 内容 ---')
try:
    print(z.read('data/minecraft/tags/damage_type/bypasses_cooldown.json').decode())
except KeyError:
    print('(jar 里不存在该文件)')
print('--- bypasse* 名字一览 ---')
import re
print([n.split('/')[-1] for n in sorted(ns) if 'bypasse' in n])
