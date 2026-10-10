# -*- coding: utf-8 -*-
# 扫 1.21.5 jar 里所有 class 的常量池, 找属性注册名(含 attack_speed 的字符串)
import zipfile, struct, sys, io

J = r'D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar'
z = zipfile.ZipFile(J)

def utf8_consts(data):
    out = []
    try:
        if data[:4] != b'\xca\xfe\xba\xbe':
            return out
        p = 8
        cpc = struct.unpack('>H', data[p:p+2])[0]; p += 2
        i = 1
        while i < cpc:
            tag = data[p]
            if tag == 1:  # CONSTANT_Utf8
                ln = struct.unpack('>H', data[p+1:p+3])[0]
                out.append(data[p+3:p+3+ln].decode('utf-8', 'replace'))
                p += 3 + ln
            elif tag in (7, 8, 16, 19, 20):
                p += 3
            elif tag in (15,):
                p += 4
            elif tag in (3, 4, 9, 10, 11, 12, 17, 18):
                p += 5
            elif tag in (5, 6):
                p += 9; i += 1
            else:
                break
            i += 1
    except Exception:
        pass
    return out

hits = {}
for name in z.namelist():
    if not name.endswith('.class'):
        continue
    try:
        consts = utf8_consts(z.read(name))
    except Exception:
        continue
    for c in consts:
        if 'attack_speed' in c or 'generic.' in c:
            hits.setdefault(c, set()).add(name)

print('=== 含 attack_speed 的字符串 ===')
for k in sorted(hits):
    if 'attack_speed' in k:
        print(repr(k), '->', len(hits[k]), 'class')

print()
print('=== 属性注册相关(Attributes 类) ===')
# 找 Attributes 类: 含大量属性名的 class
attr_names = ['attack_damage','attack_speed','movement_speed','max_health','armor','knockback_resistance','luck','scale']
cand = {}
for name in z.namelist():
    if not name.endswith('.class'):
        continue
    try:
        consts = set(utf8_consts(z.read(name)))
    except Exception:
        continue
    hit = [a for a in attr_names if a in consts]
    if len(hit) >= 4:
        cand[name] = hit
print('候选 Attributes 类:', len(cand))
for n, h in list(cand.items())[:10]:
    print(' ', n, sorted(h))
    # 打印该类里所有 属性名 字符串(含带前缀)
    consts = utf8_consts(z.read(n))
    names = sorted(set(c for c in consts if any(a in c for a in attr_names)))
    for c in names:
        print('      ', repr(c))
