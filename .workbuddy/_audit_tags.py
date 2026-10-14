# -*- coding: utf-8 -*-
"""_audit_tags.py —— 标签体系全量审计（2026-10-14 一次性分析工具）。

三个视角:
  A. 词频 / 覆盖: 28 个词各被多少件装备使用, 谁零使用;
  B. 五大状态矩阵: 流火/夜火/噬心/渊海/白昼梦 各自的「附加(apply)」与「消耗(consume)」方;
  C. 反向漏标: 用关键词扫每件 give 的 lore, 推出"应该有"的标签, 与实际 tags 比对。
"""
import importlib.util
import io
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


TD = _load('_tags_data', os.path.join(ROOT, '.workbuddy', '_tags_data.py'))
GS = _load('_gen_lore_src', os.path.join(ROOT, '.workbuddy', '_gen_lore_src.py'))

VOCAB = TD.VOCAB
KEYS = TD.VOCAB_KEYS
TAGS = TD.TAGS
CAT = {v[0]: v[1] for v in VOCAB}
LABEL = {v[0]: v[2] for v in VOCAB}

STATES5 = ['liuhuo', 'yehuo', 'shixin', 'yuanhai', 'dream']

OUT = []


def p(s=''):
    OUT.append(s)


# ---------------- 装备 id -> 分类（zx[1]）
chosen, _warn = GS.build()
CAT_ZX = {}
for _id, e in chosen.items():
    zx = e.get('zx') or []
    CAT_ZX[_id] = [x for x in zx if x in (
        'sword', 'axe', 'bow', 'staff', 'helmet', 'chestplate', 'leggings',
        'boots', 'armor', 'tool', 'trinket')] or [zx[1] if len(zx) > 1 else '?']

p('=' * 72)
p('A. 词汇表覆盖（%d 词 / %d 件装备）' % (len(KEYS), len(TAGS)))
p('=' * 72)
use = defaultdict(list)
for _id, ts in TAGS.items():
    for t in ts:
        use[t].append(_id)
for grp in ['状态', '数值', '机制', '超限']:
    p('\n---- %s ----' % grp)
    for k in KEYS:
        if CAT.get(k) != grp:
            continue
        n = len(use[k])
        mark = '  ★零使用' if n == 0 else ('  ⚠ 仅 %d 件' % n if n <= 2 else '')
        p('  %-11s %-6s %2d 件%s' % (k, LABEL[k], n, mark))

p()
p('零使用词: %s' % ([k for k in KEYS if not use.get(k)] or '无'))

# ---------------- B. 五大状态矩阵
p()
p('=' * 72)
p('B. 五大状态 · 附加 / 消耗 矩阵')
p('=' * 72)
p('%-8s %-6s %s' % ('状态', '件数', '装备（标记 A=apply 附加, C=consume 消耗）'))
for st in STATES5:
    ids = use.get(st, [])
    p('\n【%s %s】共 %d 件' % (st, LABEL[st], len(ids)))
    for _id in ids:
        ts = TAGS[_id]
        mk = []
        if 'apply' in ts:
            mk.append('A')
        if 'consume' in ts:
            mk.append('C')
        p('    %-18s %-28s %s' % (_id, '/'.join(CAT_ZX.get(_id, [])), ''.join(mk) or '-'))
    has_a = any('apply' in TAGS[i] for i in ids)
    has_c = any('consume' in TAGS[i] for i in ids)
    p('    -> 附加方: %s   消耗方: %s' % ('有' if has_a else '★缺', '有' if has_c else '★缺'))

# ---------------- C. 反向漏标
RULES = [
    ('liuhuo',   ['流火']),
    ('yehuo',    ['夜火']),
    ('shixin',   ['噬心']),
    ('yuanhai',  ['渊海']),
    ('dream',    ['白昼梦']),
    ('lightning', ['闪电', '落雷', '雷击', '雷劈']),
    ('max_hp',   ['最大生命值', '生命值上限']),
    ('base_atk', ['基础攻击力', '基础伤害']),
    ('max_mana', ['最大魔力值', '魔力值上限']),
    ('cur_mana', ['当前魔力值', '当前魔力', '剩余魔力', '消耗的魔力']),
    ('true_dmg', ['真实伤害']),
    ('flat',     ['保底', '固定值', '固定伤害']),
    ('indep_mul', ['独立乘区']),
    ('field',    ['领域']),
    ('formation', ['术阵']),
    ('attract',  ['拉向', '吸引']),
    ('timestop', ['时停']),
    ('freeze',   ['冰冻']),
    ('slow',     ['缓慢']),
    ('summon',   ['“']),
    ('cd_down',  ['冷却时间 -', '冷却 -', '冷却时间-']),
    ('dash',     ['瞬移', '突进', '闪回', '跃升', '俯冲', '后撤', '击退']),
    ('heal',     ['回复生命', '恢复生命', '回复自身生命', '治疗']),
]


def lore_text(_id):
    e = chosen.get(_id)
    if not e:
        return ''
    buf = []

    def walk(v):
        if isinstance(v, dict):
            for k, x in v.items():
                if k == 'text':
                    buf.append(x if isinstance(x, str) else '')
                else:
                    walk(x)
        elif isinstance(v, list):
            for x in v:
                walk(x)
    walk(e['lore'])
    return ''.join(buf)


p()
p('=' * 72)
p('C. 反向漏标（lore 关键词命中但 tags 里没有）—— 需人工复核, 有误报')
p('=' * 72)
miss = []
for _id in sorted(TAGS):
    txt = lore_text(_id)
    if not txt:
        continue
    for tag, words in RULES:
        if tag in TAGS[_id]:
            continue
        hit = [w for w in words if w in txt]
        if hit:
            miss.append((_id, tag, hit, txt))
p('共 %d 处疑似漏标\n' % len(miss))
by_tag = defaultdict(list)
for _id, tag, hit, txt in miss:
    by_tag[tag].append(_id)
for tag in sorted(by_tag, key=lambda t: -len(by_tag[t])):
    p('  %-11s %-6s %2d 件: %s' % (tag, LABEL.get(tag, ''), len(by_tag[tag]),
                                   ', '.join(by_tag[tag])))

# ---------------- D. 组合缺口
p()
p('=' * 72)
p('D. 机制组合缺口')
p('=' * 72)
combos = {
    'apply 但无 consume': lambda ts: 'apply' in ts and 'consume' not in ts,
    'consume 但无 apply': lambda ts: 'consume' in ts and 'apply' not in ts,
    'dash 且 debuff': lambda ts: 'dash' in ts and 'debuff' in ts,
    'buff 且 heal 缺': lambda ts: 'buff' in ts,
    'true_dmg 且 flat': lambda ts: 'true_dmg' in ts and 'flat' in ts,
    'summon 且 formation': lambda ts: 'summon' in ts and 'formation' in ts,
    'freeze 且 timestop': lambda ts: 'freeze' in ts and 'timestop' in ts,
}
for name, fn in combos.items():
    ids = [i for i, ts in TAGS.items() if fn(ts)]
    p('  %-22s %2d 件: %s' % (name, len(ids), ', '.join(ids[:12]) + (' …' if len(ids) > 12 else '')))

# ---------------- E. 分类分布
p()
p('=' * 72)
p('E. 分类分布')
p('=' * 72)
cnt = defaultdict(int)
for _id in TAGS:
    for c in CAT_ZX.get(_id, ['?']):
        if c in ('helmet', 'chestplate', 'leggings', 'boots', 'armor'):
            continue
        cnt[c] += 1
for c, n in sorted(cnt.items(), key=lambda x: -x[1]):
    p('  %-10s %d 件' % (c, n))

sys.stdout.write('\n'.join(OUT) + '\n')
