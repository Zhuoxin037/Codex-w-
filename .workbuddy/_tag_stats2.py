# -*- coding: utf-8 -*-
"""标签体系健康度补充统计：类别词汇覆盖、稀有词、冗余词对。"""
import io, os, sys, json, collections, math

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

TAGS, KEYS = D.TAGS, D.VOCAB_KEYS
CN = {k: (g, c) for k, g, c, _ in D.VOCAB}
CAT = json.load(io.open(r'D:\数据包\.workbuddy\_tag_stats.json', encoding='utf-8'))['cat']
NAMES = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖', 'tool': '副手',
         'helmet': '头盔', 'chestplate': '胸甲', 'leggings': '护腿', 'boots': '靴子'}

by_cat = collections.defaultdict(list)
for cid, ts in TAGS.items():
    by_cat[CAT.get(cid, '?')].append(ts)

print('---- 大类词汇覆盖（该类用到多少种词 / 28）----')
for cat, arr in sorted(by_cat.items(), key=lambda x: -len(x[1])):
    used = set()
    for ts in arr:
        used |= set(ts)
    print('  %-10s %2d 件  用词 %2d 种' % (NAMES.get(cat, cat), len(arr), len(used)))

print('\n---- 只在该大类出现的词（专属词）----')
for cat, arr in sorted(by_cat.items(), key=lambda x: -len(x[1])):
    mine = set()
    for ts in arr:
        mine |= set(ts)
    others = set()
    for c2, arr2 in by_cat.items():
        if c2 == cat:
            continue
        for ts in arr2:
            others |= set(ts)
    only = sorted(mine - others)
    if only:
        print('  %-10s %s' % (NAMES.get(cat, cat), '、'.join('%s(%s)' % (k, CN[k][1]) for k in only)))

cnt = collections.Counter()
for ts in TAGS.values():
    cnt.update(ts)
print('\n---- 稀有词（<=10 件，筛选价值最高）----')
for k in sorted(KEYS, key=lambda x: cnt[x]):
    if 0 < cnt[k] <= 10:
        print('  %-12s %-8s %2d 件' % (k, CN[k][1], cnt[k]))

print('\n---- 冗余词对（共现 / 较少一方 > 70%，语义高度绑定）----')
pair = collections.Counter()
for ts in TAGS.values():
    s = sorted(set(ts))
    for i in range(len(s)):
        for j in range(i + 1, len(s)):
            pair[(s[i], s[j])] += 1
rows = []
for (a, b), n in pair.items():
    base = min(cnt[a], cnt[b])
    if base and n / base > 0.70 and n >= 4:
        rows.append((n / base, n, a, b))
for r, n, a, b in sorted(rows, reverse=True):
    print('  %-12s + %-12s %3d 件  = 较少一方的 %2.0f%%' % (a, b, n, r * 100))

print('\n---- 若用某词做随机抽卡筛选，池子大小 ----')
for k in ['max_mana', 'base_atk', 'apply', 'debuff', 'heal', 'attract', 'freeze', 'lightning', 'field']:
    print('  %-12s 池 %3d / 140 件（用于随机抽时池子%s）'
          % (k, cnt[k], '几乎不缩小' if cnt[k] > 60 else ('适中' if cnt[k] > 15 else '很紧')))

# 每件平均词数的中位数
sizes = sorted(len(t) for t in TAGS.values())
mid = sizes[len(sizes) // 2]
print('\n每件词数 中位数 %d / 平均 %.2f / 众数 %d'
      % (mid, sum(sizes) / len(sizes), collections.Counter(sizes).most_common(1)[0][0]))
