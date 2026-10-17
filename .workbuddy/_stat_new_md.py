# -*- coding: utf-8 -*-
"""统计 D:\\download\\NEW\\NEW.md 内的装备条目：稀有度 / 类型 / 技能构成 / 五状态供需 / 数值档，并核对章节自述件数。"""
import io, re, sys, json

P = r'D:\download\NEW\NEW.md'
txt = io.open(P, encoding='utf-8').read()
lines = txt.splitlines()

RARITY = ['传说', '史诗', '稀有', '罕见']
STATUS = ['流火', '夜火', '噬心', '渊海', '白昼梦']
SUPPLY_KW = ['附加', '转化为', '使其', '残留', '供']
CONSUME_KW = ['消耗', '清除', '解除', '消费']

items = []          # 每个 ### 或 #### 条目
section = None
cur = None
for ln in lines:
    if ln.startswith('## '):
        section = ln[3:].strip()
        cur = None
        continue
    m = re.match(r'^(#{3,4})\s+(.*)$', ln)
    if m:
        title = m.group(2).strip()
        cur = {'sec': section, 'title': title, 'body': []}
        items.append(cur)
        continue
    if cur is not None:
        cur['body'].append(ln)

def rarity_of(t):
    for r in RARITY:
        if r in t:
            return r
    return '未标注'

def name_of(t):
    # 去掉 （稀有）、（史诗 · 候选）、" — 可以通过" 等后缀
    n = re.split(r'（|—|--', t)[0].strip()
    return n

def type_of(body):
    for l in body:
        m = re.match(r'^类型[：:]\s*(.+?)\s*$', l)
        if m:
            return re.split(r'[；;]', m.group(1))[0].strip()
    m = re.search(r'成员：([^\n]+)', '\n'.join(body))
    return '(套装行)' if m else '?'

rows = []
for it in items:
    t = '\n'.join(it['body'])
    rows.append({
        'sec': it['sec'],
        'raw': it['title'],
        'name': name_of(it['title']),
        'rarity': rarity_of(it['title']),
        'type': type_of(it['body']),
        'has_pu': '✦ 普攻' in t,
        'has_zhu': '✦ 主动技能' in t,
        'has_bei': '✦ 被动技能' in t,
        'has_she': '✦ 射击效果' in t,
        'special': re.findall(r'✦ (?!普攻|主动技能|被动技能)([^\n*]+)', t),
        'mana': re.findall(r'魔力\s*(\d+)', t),
        'cd': re.findall(r'冷却(?:时间)?\s*[：:·]?\s*(\d+)', t),
        'text': t,
    })

print('=' * 78)
print('条目总数: %d' % len(rows))
print('=' * 78)

# --- 章节核对 ---
print('\n【A. 章节构成 vs 标题自述件数】')
from collections import OrderedDict, Counter
secs = OrderedDict()
for r in rows:
    secs.setdefault(r['sec'], []).append(r)
for s, rs in secs.items():
    nums = re.findall(r'(\d+)\s*件', s or '')
    claim = ('标题自述 %s 件' % nums[0]) if nums else '标题无件数'
    flag = ''
    if nums and int(nums[0]) != len(rs):
        flag = '   <<<< 不符!'
    print('  %-40s 实得 %2d 件 | %s%s' % ((s or '(无章节)')[:40], len(rs), claim, flag))

print('\n【B. 稀有度分布】')
c = Counter(r['rarity'] for r in rows)
for k in RARITY + ['未标注']:
    if c.get(k):
        print('  %-5s %2d 件  %s' % (k, c[k], '、'.join(r['name'] for r in rows if r['rarity'] == k)))

print('\n【C. 类型分布】')
c = Counter(r['type'] for r in rows)
for k, v in c.most_common():
    print('  %-5s %2d 件  %s' % (k, v, '、'.join(r['name'] for r in rows if r['type'] == k)))

print('\n【D. 技能构成】')
for key, lab in [('has_pu', '✦ 普攻'), ('has_zhu', '✦ 主动技能'), ('has_bei', '✦ 被动技能'), ('has_she', '✦ 射击效果')]:
    n = sum(1 for r in rows if r[key])
    print('  带 %-10s %2d 件' % (lab, n))
n = sum(1 for r in rows if len([k for k in ('has_pu', 'has_zhu', 'has_bei', 'has_she') if r[k]]) >= 2)
print('  同时有 ≥2 个技能段的: %d 件' % n)
n = sum(1 for r in rows if not any(r[k] for k in ('has_pu', 'has_zhu', 'has_bei', 'has_she')))
print('  无标准技能段(仅被动式描述): %d 件  %s' % (n, '、'.join(r['name'] for r in rows if not any(r[k] for k in ('has_pu', 'has_zhu', 'has_bei', 'has_she')))))
sp = Counter(x.strip() for r in rows for x in r['special'])
print('  专属段(✦ 非三件套标题): %s' % ('、'.join('%s×%d' % (k, v) for k, v in sp.most_common()) or '无'))

print('\n【E. 五状态：谁供给 / 谁消费】')
for st in STATUS:
    sup, con = [], []
    for r in rows:
        hit = False
        for m in re.finditer(st, r['text']):
            a, b = max(0, m.start() - 22), m.end() + 14
            ctx = r['text'][a:b]
            if any(k in ctx for k in CONSUME_KW):
                if r['name'] not in con:
                    con.append(r['name'])
                hit = True
            elif any(k in ctx for k in SUPPLY_KW):
                if r['name'] not in sup:
                    sup.append(r['name'])
                hit = True
    print('  【%s】供给 %d 件: %s' % (st, len(sup), '、'.join(sup) or '—'))
    print('        消费 %d 件: %s' % (len(con), '、'.join(con) or '—'))

print('\n【F. 伤害口径（出现即计一次）】')
buckets = OrderedDict([
    ('最大魔力值×', r'最大魔力值\s*[×*]'),
    ('当前魔力值×', r'当前魔力值\s*[×*]'),
    ('基础攻击力×', r'基础攻击力\s*[×*]'),
    ('最大生命值×', r'最大生命值\s*[×*]'),
    ('固定伤害', r'固定(?:真实)?伤害|点固定'),
    ('真实伤害', r'真实伤害'),
    ('独立乘区', r'独立乘区'),
])
for lab, pat in buckets.items():
    hits = [r['name'] for r in rows if re.search(pat, r['text'])]
    print('  %-9s %2d 件: %s' % (lab, len(hits), '、'.join(hits) or '—'))

print('\n【G. 治疗 / 回魔 / 护盾等生存项】')
heal = [r['name'] for r in rows if re.search(r'恢复[^\n]{0,12}生命|回复[^\n]{0,12}生命', r['text'])]
mana = [r['name'] for r in rows if re.search(r'回复[^\n]{0,10}魔力|回复\s*\d+\s*魔力|返还', r['text'])]
print('  治疗(恢复生命) %d 件: %s' % (len(heal), '、'.join(heal)))
print('  回魔/返还     %d 件: %s' % (len(mana), '、'.join(mana)))

print('\n【H. 魔力上限加成的防具】')
mm = [(r['name'], re.findall(r'魔力值上限\s*\+(\d+)', r['text'])) for r in rows]
mm = [(n, v[0]) for n, v in mm if v]
print('  %d 件: %s' % (len(mm), '、'.join('%s+%s' % x for x in mm)))

print('\n【I. 坐标/数值明细表】')
print('  %-4s %-8s %-6s %-5s %-6s %s' % ('#', '名称', '稀有度', '类型', '技能', '魔力/冷却'))
for i, r in enumerate(rows, 1):
    sk = ''.join(k for k, lab in [('has_pu', '普'), ('has_zhu', '主'), ('has_bei', '被'), ('has_she', '射')] if r[k]) or '—'
    print('  %-4d %-8s %-6s %-5s %-6s 魔力%s 冷却%s' % (
        i, r['name'], r['rarity'], r['type'], sk,
        '/'.join(r['mana']) or '—', '/'.join(r['cd']) or '—'))
