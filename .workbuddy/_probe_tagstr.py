# -*- coding: utf-8 -*-
"""在 jar 里搜标签 ID 字符串，确认判据引用的到底是哪个 tag。"""
import zipfile, re
J = r'D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar'
z = zipfile.ZipFile(J)
WORDS = [b'bypasses_cooldown', b'bypasses_invulnerability', b'is_player_attack']
hits = {w: [] for w in WORDS}
n = 0
for name in z.namelist():
    if not name.endswith('.class'):
        continue
    n += 1
    try:
        b = z.read(name)
    except Exception:
        continue
    for w in WORDS:
        if w in b:
            hits[w].append(name)
print('scanned classes:', n)
for w in WORDS:
    print('%-28s -> %d hit(s)' % (w.decode(), len(hits[w])))
    for h in hits[w][:8]:
        print('      ', h)
