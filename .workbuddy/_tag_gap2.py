# -*- coding: utf-8 -*-
"""标签配合缺失 · 第二层：状态闭环 / 数值口径互斥 / 词对成熟度 / 类别内缺口。"""
import io, os, re, sys, collections, itertools

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

VOCAB, KEYS, TAGS = D.VOCAB, D.VOCAB_KEYS, D.TAGS
N = len(TAGS)
GROUP = {k: g for k, g, _, _ in VOCAB}
CN = {k: c for k, _, c, _ in VOCAB}

ROOT = r'D:\数据包\sweetdream\data\sweetdream\function'
pat = re.compile(r'zx:\s*\[\s*"([a-z0-9_]+)"\s*,\s*"([a-z0-9_]+)"')
cat_of = {}
for dirpath, _, files in os.walk(ROOT):
    for fn in files:
        if not fn.endswith('.mcfunction'):
            continue
        try:
            s = io.open(os.path.join(dirpath, fn), encoding='utf-8').read()
        except Exception:
            continue
        for m in pat.finditer(s):
            cid, c = m.group(1), m.group(2)
            if cid in TAGS and cid not in cat_of:
                cat_of[cid] = c
CAT_CN = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖',
          'helmet': '盔甲', 'chestplate': '盔甲', 'leggings': '盔甲', 'boots': '盔甲',
          'armor': '盔甲', 'tool': '副手'}
cat = {c: CAT_CN.get(cat_of.get(c, '?'), '?') for c in TAGS}

cnt = collections.Counter()
co = collections.Counter()
for cid, ts in TAGS.items():
    s = set(ts)
    for t in s:
        cnt[t] += 1
    for a, b in itertools.combinations(sorted(s), 2):
        co[(a, b)] += 1


def G(a, b):
    return co.get((a, b), co.get((b, a), 0))


def has(t, cid):
    return t in TAGS[cid]


LIVE = [k for k in KEYS if cnt[k]]

# ---------------- 一、状态闭环 ----------------
print('=' * 88)
print('一、状态闭环：能不能"施加"、能不能"消耗"、能不能"削弱"')
print('=' * 88)
print('%-9s %5s %6s %7s %6s %7s   件数分布' % ('状态', '件数', '附加', '消耗', '削弱', '闭环'))
STATUS_LIKE = list(D.STATUS_KEYS) + ['freeze', 'slow', 'timestop']   # ★ 不能用 GROUP 筛状态(闪电是机制)
for s in STATUS_LIKE:
    a, c, d = G(s, 'apply'), G(s, 'consume'), G(s, 'debuff')
    mark = '完整' if a and c else ('只施加' if a else ('只消耗' if c else '全断'))
    dist = collections.Counter(cat[i] for i in TAGS if s in TAGS[i])
    ds = ' '.join('%s%d' % (k, v) for k, v in dist.most_common())
    print('%-9s %5d %6d %7d %6d %7s   %s' % (CN[s], cnt[s], a, c, d, mark, ds))

# ---------------- 二、数值口径互斥 ----------------
NUM = [k for k in KEYS if GROUP[k] == '数值']
print('\n' + '=' * 88)
print('二、数值口径两两共现（每格实际 / 期望）—— 看有几套互不交叉的"伤害口径"')
print('=' * 88)
print('%-10s' % '' + ''.join('%-11s' % CN[m][:4] for m in NUM))
for a in NUM:
    line = '%-10s' % CN[a]
    for b in NUM:
        if a == b:
            line += '%-11s' % '-'
        else:
            line += '%-11s' % ('%d/%.1f' % (G(a, b), cnt[a] * cnt[b] / N))
    print(line)

# ---------------- 三、词对成熟度 ----------------
print('\n' + '=' * 88)
print('三、词对成熟度（351 对）')
print('=' * 88)
bucket = collections.Counter()
for a, b in itertools.combinations(LIVE, 2):
    v = G(a, b)
    bucket['0（无此配合）' if v == 0 else ('1（孤例）' if v == 1 else ('2（成对）' if v == 2 else '3+（成型套路）'))] += 1
for k in ['0（无此配合）', '1（孤例）', '2（成对）', '3+（成型套路）']:
    print('  %-16s %3d 对  %5.1f%%  %s' % (k, bucket[k], bucket[k] / 351 * 100, '█' * (bucket[k] // 2)))

# ---------------- 四、类别内缺失（期望>=1.0 的 0 共现） ----------------
print('\n' + '=' * 88)
print('四、各类别内部的 0 共现词对（期望 >= 1.0，排除跨类稀释）')
print('=' * 88)
for c in ['剑', '斧', '弩', '法杖', '盔甲', '副手']:
    mem = [i for i in TAGS if cat[i] == c]
    n = len(mem)
    cc = collections.Counter()
    for i in mem:
        for t in set(TAGS[i]):
            cc[t] += 1
    pairs = []
    for a, b in itertools.combinations([k for k in LIVE if cc[k]], 2):
        exp = cc[a] * cc[b] / n
        if exp >= 1.0 and G(a, b) == 0:
            pairs.append((exp, a, b))
    pairs.sort(reverse=True)
    print('\n  [%s] %d 件，缺失词对 %d 个' % (c, n, len(pairs)))
    for exp, a, b in pairs[:8]:
        print('     %-9s + %-9s  期望 %.2f' % (CN[a], CN[b], exp))

# ---------------- 五、每个状态词缺的机制 ----------------
print('\n' + '=' * 88)
print('五、状态词 × 机制词：整行为空的格（该状态从未与该机制同件）')
print('=' * 88)
MECH = [k for k in KEYS if GROUP[k] == '机制']
for s in D.STATUS_KEYS:
    empty = [CN[m] for m in MECH if G(s, m) == 0]
    print('  %-9s 缺失机制 %2d/15 : %s' % (CN[s], len(empty), '、'.join(empty) if empty else '无'))
