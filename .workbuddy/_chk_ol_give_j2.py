# -*- coding: utf-8 -*-
"""校验批 J2 的 32 个超限石 give: lore 是合法 JSON、CMD 与表一致、正文与解析结果一致。"""
import io
import json
import re
import sys

sys.path.insert(0, 'D:/数据包/.workbuddy')
from lore_fmt import nfmt

META = json.load(io.open('D:/数据包/.workbuddy/_ol_j2.json', encoding='utf-8'))
DIR = 'D:/数据包/sweetdream/data/sweetdream/function/overlimit/item/%s.mcfunction'
bad = 0
for uid, d in META.items():
    t = io.open(DIR % uid, encoding='utf-8').read()
    i = t.find('lore=')
    j = t.find(',custom_data=', i)
    lore = json.loads(t[i + 5:j])
    k = t.find('custom_model_data={floats:[')
    cmd = int(re.match(r'\d+', t[k + 27:]).group(0))
    body = ''.join(''.join([r.get('text', '')] +
                           [v.get('text', '') for v in r.get('extra', [])]) for r in lore)
    flat_b = re.sub(r'\s+', '', body)
    flat_s = re.sub(r'\s+', '', nfmt(d['stone_body']))
    ok = flat_s in flat_b and cmd == d['cmd']
    if not ok:
        bad += 1
    print('%-16s cmd=%-3d 行=%-3d %s  %s' % (uid, cmd, len(lore), 'OK' if ok else 'XX', body[:26]))
print('bad =', bad, '/', len(META))
