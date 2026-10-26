# -*- coding: utf-8 -*-
"""标签「配合缺失」统计：共现矩阵 + 期望vs实际 + 语义组交叉覆盖 + 类别缺口。

判据：
  lift = 实际共现 / 独立假设期望      （1.0 = 与随机同频，<0.5 明显互斥，>2 明显绑定）
  缺失 = 实际 0 且 期望 >= 1.5        （统计上"该出现"却一件没有）
  稀薄 = 实际 >0 且 lift < 0.6 且 期望 >= 2.5
"""
import io, os, re, sys, collections, itertools

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

VOCAB = D.VOCAB
KEYS = D.VOCAB_KEYS
TAGS = D.TAGS
N = len(TAGS)
GROUP = {k: g for k, g, _, _ in VOCAB}
CN = {k: c for k, _, c, _ in VOCAB}

# ---------------- 类别（从 give 里的 zx[1]） ----------------
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
            cid, cat = m.group(1), m.group(2)
            if cid in TAGS and cid not in cat_of:
                cat_of[cid] = cat

CAT_CN = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖',
          'helmet': '盔甲', 'chestplate': '盔甲', 'leggings': '盔甲', 'boots': '盔甲',
          'armor': '盔甲', 'tool': '副手'}
cat = {c: CAT_CN.get(cat_of.get(c, '?'), '?') for c in TAGS}
CATS = ['剑', '斧', '弩', '法杖', '盔甲', '副手']

# ---------------- 频次与共现 ----------------
cnt = collections.Counter()
co = collections.Counter()
for cid, ts in TAGS.items():
    s = set(ts)
    for t in s:
        cnt[t] += 1
    for a, b in itertools.combinations(sorted(s), 2):
        co[(a, b)] += 1


def get_co(a, b):
    return co[(a, b)] if (a, b) in co else co[(b, a)]


LIVE = [k for k in KEYS if cnt[k] > 0]          # overlimit 静态恒 0，排除
print('=' * 90)
print('标签配合缺失统计 · %d 件装备 · %d 词（%d 词在用）' % (N, len(KEYS), len(LIVE)))
print('=' * 90)

# ---------------- 1. 缺失对（0 共现但期望高） ----------------
rows = []
for a, b in itertools.combinations(LIVE, 2):
    exp = cnt[a] * cnt[b] / N
    obs = get_co(a, b)
    rows.append((exp, obs, a, b))

missing = sorted([r for r in rows if r[1] == 0], reverse=True)
print('\n### 一、零共现词对（按"独立假设下应出现件数"降序，前 20）')
print('%-4s %-10s %-10s %6s %6s' % ('#', '词A', '词B', '期望', '实际'))
for i, (exp, obs, a, b) in enumerate(missing[:20], 1):
    print('%-4d %-10s %-10s %6.2f %6d' % (i, '%s/%s' % (a, CN[a]), '%s/%s' % (b, CN[b]), exp, obs))
print('零共现词对合计 %d / %d 对（%.0f%%）' % (len(missing), len(rows), len(missing) / len(rows) * 100))

# ---------------- 2. 强绑定 / 明显互斥 ----------------
print('\n### 二、强绑定（lift >= 2.5 且共现 >= 4）')
binds = []
for exp, obs, a, b in rows:
    if obs >= 4 and exp > 0 and obs / exp >= 2.5:
        binds.append((obs / exp, obs, exp, a, b))
for lift, obs, exp, a, b in sorted(binds, reverse=True):
    print('  %-9s + %-9s 共现 %2d  期望 %5.1f  lift %.2f' % (CN[a], CN[b], obs, exp, lift))

print('\n### 三、明显互斥（lift <= 0.35 且共现 >= 1、期望 >= 2.5）')
excl = []
for exp, obs, a, b in rows:
    if exp >= 2.5 and 1 <= obs and obs / exp <= 0.35:
        excl.append((obs / exp, obs, exp, a, b))
for lift, obs, exp, a, b in sorted(excl):
    print('  %-9s + %-9s 共现 %2d  期望 %5.1f  lift %.2f' % (CN[a], CN[b], obs, exp, lift))

# ---------------- 3. 状态 × 机制 覆盖矩阵 ----------------
STATUS = list(D.STATUS_KEYS)   # ★ 状态有且只有五个(2026-10-22 用户定); 闪电 lightning 属机制, 不是状态
MECH = [k for k in KEYS if GROUP[k] == '机制']
print('\n### 四、状态 × 机制 覆盖（每格 = 同时含该状态与该机制的件数）')
print('%-9s' % '' + ''.join('%-7s' % CN[m][:3] for m in MECH))
for s in STATUS:
    line = '%-9s' % CN[s]
    for m in MECH:
        v = get_co(s, m)
        line += '%-7s' % (v if v else '·')
    print(line)
print('%-9s' % '(词频)' + ''.join('%-7d' % cnt[m] for m in MECH))

# ---------------- 4. 类别 × 机制 ≠ 0 覆盖 ----------------
print('\n### 五、类别 × 机制（每格 = 该类里含该机制的件数；· = 整个类别零覆盖）')
print('%-6s' % '' + ''.join('%-6s' % CN[m][:2] for m in MECH))
for c in CATS:
    mem = [i for i in TAGS if cat[i] == c]
    line = '%-6s' % ('%s(%d)' % (c, len(mem)))
    for m in MECH:
        v = sum(1 for i in mem if m in TAGS[i])
        line += '%-6s' % (v if v else '·')
    print(line)

# ---------------- 5. 缺失的机制搭配（每组内 15 机制两两 0 共现） ----------------
print('\n### 六、机制词之间的零共现对（按期望降序，前 15）')
mm = sorted([r for r in rows if GROUP[r[2]] == '机制' and GROUP[r[3]] == '机制' and r[1] == 0], reverse=True)
for i, (exp, obs, a, b) in enumerate(mm[:15], 1):
    print('  %2d. %-9s + %-9s 期望 %.2f' % (i, CN[a], CN[b], exp))

# ---------------- 6. 每词"搭配宽度" ----------------
print('\n### 七、每词搭配宽度（与多少个词曾在同一件出现 / 平均件数）')
width = {}
for k in LIVE:
    partners = [p for p in LIVE if p != k and get_co(k, p) > 0]
    avg = sum(get_co(k, p) for p in partners) / len(partners) if partners else 0
    width[k] = (len(partners), avg)
for k, (w, avg) in sorted(width.items(), key=lambda x: (x[1][0], -cnt[x[0]])):
    print('  %-10s %-6s 件数%3d  伙伴%2d/27  平均共现%.2f' % (k, CN[k], cnt[k], w, avg))

# ---------------- 7. 单状态饱和件（同一状态词的唯一机制载体） ----------------
print('\n### 八、单一机制独占的状态（该状态全部共现都只来自 1 个机制词）')
for s in STATUS:
    bymech = [(m, get_co(s, m)) for m in MECH if get_co(s, m) > 0]
    bymech.sort(key=lambda x: -x[1])
    tot = sum(v for _, v in bymech)
    if bymech and bymech[0][1] / tot >= 0.6:
        print('  %-9s 共现 %2d 次，其中 %-8s 占 %d 次（%.0f%%）'
              % (CN[s], tot, CN[bymech[0][0]], bymech[0][1], bymech[0][1] / tot * 100))
