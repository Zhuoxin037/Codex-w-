# -*- coding: utf-8 -*-
"""_verify_24.py —— 总稿（批一 10 + 批二 14 = 24 件）的唯一核对脚本。

用户 10-20 判定：冰棺不要、钩沉不做（只做钩丝）。
⇒ 这两组缺口（增益+冰冻、基础攻击力+吸引）**明确不做**，覆盖记 15/17。
"""
import sys, os, json, itertools, collections

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

HERE = os.path.dirname(os.path.abspath(__file__))
rows = json.load(open(os.path.join(HERE, '_board.json'), encoding='utf-8'))
VOCAB = {v[0] for v in D.VOCAB}
CN = {v[0]: v[2] for v in D.VOCAB}

# ── 批一：阶段补全 10 件（id, 中文, 类型, 档位 1铁/2钻/3下界/0未分档, 标签）
BATCH1 = {
    'yebu':      ('曳步',   'sword', 1, ['slow', 'debuff']),
    'xiugou':    ('锈犬',   'axe',   1, ['summon', 'base_atk']),
    'zhuzu':     ('驻足',   'armor', 1, ['field', 'flat', 'debuff']),
    'gousi':     ('钩丝',   'sword', 2, ['attract', 'slow', 'debuff', 'indep_mul']),
    'lianshi':   ('连矢',   'bow',   0, ['cur_mana', 'base_atk']),
    'tiejili':   ('铁蒺藜', 'bow',   0, ['slow', 'debuff', 'field']),
    'lvshuang':  ('履霜',   'armor', 2, ['slow', 'debuff', 'buff']),
    'dongtu':    ('冻土',   'armor', 2, ['heal', 'buff', 'max_hp']),
    'huilan':    ('回澜',   'armor', 3, ['heal', 'max_hp']),
    'chengxing': ('秤星',   'sword', 3, ['flat', 'base_atk']),
}

# ── 批二：押后 14 件（原 16 件，删钩沉 + 冰棺）
BATCH2 = {
    'profane':        ('剖心',   'sword', 3, ['shixin', 'base_atk', 'consume', 'indep_mul', 'cd_down']),
    'burst_bank':     ('决堤',   'staff', 2, ['cur_mana', 'dash', 'debuff']),
    'bind_ember':     ('缚烬',   'axe',   1, ['liuhuo', 'apply', 'slow', 'debuff', 'cd_down']),
    'breathing_soil': ('息土',   'armor', 2, ['heal', 'formation', 'field', 'max_hp']),
    'cage_day':       ('囚昼',   'staff', 2, ['dream', 'apply', 'base_atk', 'debuff', 'max_mana']),
    'grave_tablet':   ('断碑',   'axe',   3, ['true_dmg', 'base_atk', 'cd_down']),
    'night_bind':     ('夜缚',   'bow',   1, ['yehuo', 'slow', 'debuff']),
    'way_back':       ('归途',   'sword', 2, ['summon', 'dash', 'heal']),
    'sip_frost':      ('饮霜',   'tool',  0, ['heal', 'slow', 'debuff']),
    'sunken_weight':  ('沉砣',   'axe',   1, ['flat', 'slow', 'debuff']),
    'stop_needle':    ('停针',   'staff', 2, ['timestop', 'cd_down']),
    'pour_sack':      ('倾囊',   'staff', 1, ['cur_mana', 'flat']),
    'empty_seat':     ('虚位',   'sword', 2, ['flat', 'formation', 'debuff']),
    'retro_shine':    ('反照',   'tool',  1, ['true_dmg']),
}
# 已否，不进合计（只用于说明这两组缺口为什么空）
DROPPED = {
    'hook_sink': ('钩沉', 'bow',  1, ['attract', 'base_atk', 'debuff']),
    'ice_coffin': ('冰棺', 'armor', 3, ['freeze', 'buff', 'max_hp']),
}
ALL = {**BATCH1, **BATCH2}

print('=== 0. 词表校验 ===')
bad = [(k, w) for k, v in ALL.items() for w in v[3] if w not in VOCAB]
for k, w in bad:
    print('  !! %s 用了不存在的词 %s' % (k, w))
print('  24 件 / 未定义词 %d / 重复 id %d' % (len(bad), len(BATCH1) + len(BATCH2) - len(ALL)))

BASE = {k: list(v) for k, v in D.TAGS.items()}
A1 = {k: list(v) for k, v in BASE.items()}
A1.update({k: v[3] for k, v in BATCH1.items()})
A2 = dict(A1)
A2.update({k: v[3] for k, v in BATCH2.items()})

# ── 17 组目标缺口；后两组已明确不做
TARGET = [
    ('shixin', 'base_atk', 5.85), ('cur_mana', 'dash', 3.00),
    ('liuhuo', 'slow', 2.97), ('liuhuo', 'cd_down', 2.60),
    ('yehuo', 'slow', 2.40), ('shixin', 'cd_down', 2.10),
    ('flat', 'debuff', 1.76), ('true_dmg', 'cd_down', 1.70),
    ('cd_down', 'indep_mul', 1.60), ('heal', 'formation', 1.57),
    ('cur_mana', 'flat', 1.43), ('heal', 'slow', 1.35),
    ('summon', 'dash', 1.33), ('timestop', 'cd_down', 1.27),
    ('buff', 'freeze', 1.22), ('base_atk', 'attract', 1.14),
    ('flat', 'formation', 1.06),
]
WONT = {('buff', 'freeze'), ('base_atk', 'attract')}
f = lambda d, a, b: sum(1 for t in d.values() if a in t and b in t)

print()
print('=' * 88)
print('一、17 组目标缺口（现有 140 → 批一 10 后 → 24 件后）')
print('=' * 88)
print('  %-9s + %-9s %5s %4s %4s %4s  %s' % ('A', 'B', '期望', '现', '+10', '+24', '补的件'))
ok = 0
skip = 0
for a, b, exp in TARGET:
    who = [v[0] for k, v in ALL.items() if a in v[3] and b in v[3]]
    done = f(A2, a, b) > 0
    wont = (a, b) in WONT
    if done:
        ok += 1
    elif wont:
        skip += 1
    print('  %-9s + %-9s %5.2f %4d %4d %4d  %-6s %s'
          % (CN[a], CN[b], exp, f(BASE, a, b), f(A1, a, b), f(A2, a, b),
             'OK' if done else ('不做' if wont else '!!空'), '、'.join(who)))
print('  ⇒ 覆盖 %d / %d；另 %d 组明确不做（冰棺 / 钩沉 已否）' % (ok, len(TARGET), skip))

# ── 批一阶段矩阵
print()
print('=' * 88)
print('二、批一：机制 × 阶段（补前 → 补后，格式 铁/钻/下/未）')
print('=' * 88)
T1 = ['slow', 'summon', 'field', 'attract', 'heal', 'flat']
B = {k: [0, 0, 0, 0] for k in T1}
A = {k: [0, 0, 0, 0] for k in T1}
for r in rows:
    for k in T1:
        if k in r['tags']:
            B[k][r['tier']] += 1
            A[k][r['tier']] += 1
for k, v in BATCH1.items():
    for w in v[3]:
        if w in T1:
            A[w][v[2]] += 1
for k in T1:
    print('  %-9s %-14s → %-14s' % (CN[k], '/'.join(map(str, B[k])), '/'.join(map(str, A[k]))))

def slot(lst, s, extra):
    c = [0, 0, 0, 0]
    for r in lst:
        if r['type'] == 'armor' and s in r['item']:
            c[r['tier']] += 1
    a = list(c)
    for k, tier in extra.items():
        a[tier] += 1
    return c, a
print()
for s, cn, extra in [('boots', '靴', {'lvshuang': 2, 'dongtu': 2}),
                     ('chestplate', '胸', {'zhuzu': 1, 'huilan': 3})]:
    c, a = slot(rows, s, extra)
    print('  %-9s %-14s → %-14s' % (cn, '/'.join(map(str, c)), '/'.join(map(str, a))))

# ── 词数
print()
print('=' * 88)
print('三、词数（防万能件）')
print('=' * 88)
n1 = sum(len(v[3]) for v in BATCH1.values()) / len(BATCH1)
n2 = sum(len(v[3]) for v in BATCH2.values()) / len(BATCH2)
print('  现有 140 件平均 %.2f 词' % (sum(len(t) for t in BASE.values()) / len(BASE)))
print('  批一 %d 件：%d 词，平均 %.2f' % (len(BATCH1), sum(len(v[3]) for v in BATCH1.values()), n1))
print('  批二 %d 件：%d 词，平均 %.2f' % (len(BATCH2), sum(len(v[3]) for v in BATCH2.values()), n2))
tot = sum(len(t) for t in A2.values())
print('  24 件合计 %d 件 / %d 标签 / 平均 %.2f' % (len(A2), tot, tot / len(A2)))
print('  批一单件：' + ' '.join('%s%d' % (v[0], len(v[3])) for v in BATCH1.values()))
print('  批二单件：' + ' '.join('%s%d' % (v[0], len(v[3])) for v in BATCH2.values()))
print('  批二最多 %d 词（%s）'
      % (max(len(v[3]) for v in BATCH2.values()),
         max(BATCH2.values(), key=lambda v: len(v[3]))[0]))
print('  现有最多的 5 件：')
for c, n in sorted(((c, len(t)) for c, t in BASE.items()), key=lambda x: -x[1])[:5]:
    print('    %-18s %2d 词' % (c, n))

# ── 剩余缺口
print()
print('=' * 88)
print('四、仍为空的有效缺口（期望 > 0.9 的前 8 组，假缺口已剔除）')
print('=' * 88)
FAKE = {('lightning', 'apply'), ('lightning', 'consume'), ('apply', 'field'),
        ('buff', 'field'), ('apply', 'freeze'), ('liuhuo', 'field'),
        ('buff', 'freeze'), ('base_atk', 'attract')}
cnt = collections.Counter()
for t in A2.values():
    for x in set(t):
        cnt[x] += 1
rows2 = []
for a, b in itertools.combinations(D.VOCAB_KEYS, 2):
    if cnt[a] == 0 or cnt[b] == 0 or (a, b) in FAKE or (b, a) in FAKE:
        continue
    if f(A2, a, b) == 0:
        rows2.append((cnt[a] * cnt[b] / len(A2), a, b))
rows2.sort(reverse=True)
for exp, a, b in rows2[:8]:
    print('  %.2f  %s + %s' % (exp, CN[a], CN[b]))
print('  有效空缺口合计 %d 组（最高 %.2f）' % (len(rows2), rows2[0][0] if rows2 else 0))
