# -*- coding: utf-8 -*-
"""从 give 行独立统计 tags 数量，与 _tags_data.py 对账。

只解析以 `give ` 开头的行，且 same line 里有 custom_data —— 避免把 debug/判断语句里的
`zx:["<id>"]` 误当成物品定义（第一版就是这么错成 401 件的）。
"""
import io, os, re, sys, collections

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

ROOT = r'D:\数据包\sweetdream\data\sweetdream\function'
pat_id = re.compile(r'zx:\["([a-z0-9_]+)"')
pat_tags = re.compile(r'tags:\[([^\]]*)\]')

real = {}
files = 0
for dirpath, _, fs in os.walk(ROOT):
    for fn in fs:
        if not fn.endswith('.mcfunction'):
            continue
        p = os.path.join(dirpath, fn)
        for line in io.open(p, encoding='utf-8'):
            ls = line.strip()
            if not ls.startswith('give '):
                continue
            if 'custom_data' not in ls:
                continue
            m = pat_id.search(ls)
            if not m or m.group(1) not in D.TAGS:
                continue
            cid = m.group(1)
            if cid in real:          # 同一件出现多次（超限变体等），只取第一份
                continue
            t = pat_tags.search(ls)
            body = t.group(1) if t else ''
            real[cid] = [x.strip().strip('"') for x in body.split(',') if x.strip()]
            files += 1

print('give 行里解析到 %d 件 / 真源 %d 件' % (files, len(D.TAGS)))
print('实物标签总数 %d / 真源 %d' % (sum(len(v) for v in real.values()),
                                    sum(len(v) for v in D.TAGS.values())))
bad = sorted({k for ts in real.values() for k in ts} - set(D.VOCAB_KEYS))
print('实物里词表外标签: %s' % (bad or '无'))

diff = []
for cid in D.TAGS:
    a, b = set(D.TAGS[cid]), set(real.get(cid, []))
    if a != b:
        diff.append((cid, sorted(a - b), sorted(b - a)))
print('逐件不一致 %d 件' % len(diff))
for cid, only_src, only_give in diff:
    print('  %-18s 真源独有=%s  实物独有=%s' % (cid, only_src, only_give))

missing = [c for c in D.TAGS if c not in real]
print('give 里没解析到（可能不叫 give / 无 tags 字段）: %s' % (missing or '无'))
