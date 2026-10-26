# -*- coding: utf-8 -*-
"""装备标签使用情况统计（只读 _tags_data.py + give 文件里的 zx[1] 类别）。"""
import io, os, re, sys, json, collections

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

VOCAB = D.VOCAB            # (key, cat_group, cn, desc)
KEYS = D.VOCAB_KEYS
TAGS = D.TAGS
CN = {k: (g, c) for k, g, c, _ in VOCAB}

ROOT = r'D:\数据包\sweetdream\data\sweetdream\function'

# ---- 从 give 文件挖 zx:["<id>", "<cat>", ...] ----
cat_of = {}
pat = re.compile(r'zx:\s*\[\s*"([a-z0-9_]+)"\s*,\s*"([a-z0-9_]+)"')
for dirpath, _, files in os.walk(ROOT):
    for fn in files:
        if not fn.endswith('.mcfunction'):
            continue
        p = os.path.join(dirpath, fn)
        try:
            s = io.open(p, encoding='utf-8').read()
        except Exception:
            continue
        for m in pat.finditer(s):
            cid, cat = m.group(1), m.group(2)
            if cid in TAGS and cid not in cat_of:
                cat_of[cid] = cat

CAT_CN = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖',
          'armor': '盔甲', 'tool': '副手', 'helmet': '盔甲', 'chestplate': '盔甲',
          'leggings': '盔甲', 'boots': '盔甲'}

missing = [c for c in TAGS if c not in cat_of]
cat_groups = collections.Counter()
for c in TAGS:
    cat = cat_of.get(c, '?')
    cat_groups[CAT_CN.get(cat, cat)] += 1

print('=' * 78)
print('装备 %d 件 / 词表 %d 词%s' % (
    len(TAGS), len(KEYS),
    '' if not missing else '  [类别缺失 %d 件: %s]' % (len(missing), ','.join(missing))))
print('=' * 78)
print('按大类件数: %s' % dict(cat_groups))
print('按细槽位件数: %s' % dict(collections.Counter(cat_of.values())))

# ---- 每词使用次数 ----
cnt = collections.Counter()
by_group = collections.defaultdict(collections.Counter)
for cid, ts in TAGS.items():
    cat = CAT_CN.get(cat_of.get(cid, '?'), '?')
    for t in ts:
        cnt[t] += 1
        by_group[t][cat] += 1

print('\n---- 词频（降序）----')
order = sorted(KEYS, key=lambda k: (-cnt[k], KEYS.index(k)))
print('%-12s %-6s %-8s %5s %7s  %s' % ('key', '组', '中文', '件数', '占比', '分布'))
for k in order:
    g, cn = CN[k]
    share = cnt[k] / len(TAGS) * 100
    dist = ' '.join('%s%d' % (c, n) for c, n in by_group[k].most_common())
    print('%-12s %-6s %-8s %5d %6.1f%%  %s' % (k, g, cn, cnt[k], share, dist))

zero = [k for k in KEYS if cnt[k] == 0]
print('\n零使用词: %s' % ('无' if not zero else '、'.join('%s(%s)' % (k, CN[k][1]) for k in zero)))

# ---- 每件标签数分布 ----
sizes = {c: len(t) for c, t in TAGS.items()}
dist = collections.Counter(sizes.values())
print('\n---- 每件标签数分布 ----')
for n in sorted(dist):
    print('  %2d 词: %3d 件  %s' % (n, dist[n], '#' * dist[n]))
tot = sum(sizes.values())
print('  合计 %d 个标签 / 平均 %.2f 词每件' % (tot, tot / len(TAGS)))

print('\n---- 标签最多的 10 件 ----')
for c, n in sorted(sizes.items(), key=lambda x: (-x[1], x[0]))[:10]:
    print('  %-18s %2d  %s' % (c, n, ' '.join(TAGS[c])))

print('\n---- 标签最少的 10 件 ----')
for c, n in sorted(sizes.items(), key=lambda x: (x[1], x[0]))[:10]:
    print('  %-18s %2d  %s' % (c, n, ' '.join(TAGS[c]) or '(空)'))

# ---- 每个大类平均 ----
print('\n---- 各大类标签密度 ----')
agg = collections.defaultdict(list)
for c, ts in TAGS.items():
    agg[CAT_CN.get(cat_of.get(c, '?'), '?')].append(len(ts))
for cat, arr in sorted(agg.items(), key=lambda x: -len(x[1])):
    print('  %-4s %2d 件  平均 %.2f 词  最高 %d  最低 %d'
          % (cat, len(arr), sum(arr) / len(arr), max(arr), min(arr)))

# ---- 细槽位（盔甲四分）----
print('\n---- 细槽位标签密度 ----')
agg2 = collections.defaultdict(list)
for c, ts in TAGS.items():
    agg2[cat_of.get(c, '?')].append(len(ts))
for cat, arr in sorted(agg2.items(), key=lambda x: -len(x[1])):
    print('  %-12s %2d 件  平均 %.2f 词' % (cat, len(arr), sum(arr) / len(arr)))

# ---- 共现最多的词对 ----
pair = collections.Counter()
for cid, ts in TAGS.items():
    s = sorted(set(ts))
    for i in range(len(s)):
        for j in range(i + 1, len(s)):
            pair[(s[i], s[j])] += 1
print('\n---- 共现最多 12 对 ----')
for (a, b), n in pair.most_common(12):
    print('  %-12s + %-12s %3d 件' % (a, b, n))

# ---- 词的大类集中度 ----
print('\n---- 词的大类集中度 ----')
for k in order:
    d = by_group[k]
    if not d:
        continue
    top, n = d.most_common(1)[0]
    print('  %-12s %-6s 最集中 %s %d/%d' % (k, CN[k][1], top, n, cnt[k]))

json.dump({'cnt': dict(cnt), 'sizes': sizes,
           'cat': {c: cat_of.get(c, '?') for c in TAGS},
           'by_group': {k: dict(v) for k, v in by_group.items()},
           'pairs': [['%s|%s' % p, n] for p, n in pair.most_common(30)],
           'vocab': [[k, g, cn] for k, g, cn, _ in VOCAB]},
          io.open(r'D:\数据包\.workbuddy\_tag_stats.json', 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)
print('\n[已写 _tag_stats.json]')
