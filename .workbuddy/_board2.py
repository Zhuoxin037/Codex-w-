# -*- coding: utf-8 -*-
"""盔甲 4 槽 × 3 阶段 + 法杖/弩按消耗分档"""
import os, re, glob, json, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

ROOT = 'D:/数据包/sweetdream/data/sweetdream/function/equipment'
CN = {v[0]: v[2] for v in D.VOCAB}
rows = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '_board.json'), encoding='utf-8'))

def slot_of(item):
    for s in ['helmet', 'chestplate', 'leggings', 'boots']:
        if s in item:
            return s
    return '?'

def tier_of(item):
    for k, v in [('iron', 1), ('diamond', 2), ('netherite', 3)]:
        if item.startswith(k):
            return v
    return 0

print('=== A. 盔甲 4 槽 × 3 阶段 ===')
SL = ['helmet', 'chestplate', 'leggings', 'boots']
SN = {'helmet': '头', 'chestplate': '胸', 'leggings': '腿', 'boots': '靴'}
grid = {}
armors = [r for r in rows if r['type'] == 'armor']
for r in armors:
    grid[(slot_of(r['item']), tier_of(r['item']))] = grid.get((slot_of(r['item']), tier_of(r['item'])), 0) + 1
print('%-6s %5s %5s %5s %5s' % ('', '铁', '钻', '下界', '合计'))
for s in SL:
    c = [grid.get((s, t), 0) for t in (1, 2, 3)]
    print('%-6s %5d %5d %5d %5d' % (SN[s], c[0], c[1], c[2], sum(c)))
c = [grid.get((s, t), 0) for t in (1, 2, 3) for s in ['x']]
print()
print('=== B. 每个槽位的机制清单（看过渡期有没有可用的） ===')
for s in SL:
    print('--', SN[s])
    for t in (1, 2, 3):
        sub = [r for r in armors if slot_of(r['item']) == s and tier_of(r['item']) == t]
        print('   %-3s %d 件: %s' % ({1: '铁', 2: '钻', 3: '下界'}[t], len(sub),
              ' '.join('%s[%s]' % (r['id'], ','.join(r['tags'])) for r in sub)))

print()
print('=== C. 法杖/弩：按主力消耗分档 ===')
for t in ['staff', 'bow']:
    sub = [r for r in rows if r['type'] == t]
    print('--', t, len(sub))
    def key(r):
        m = r['mana']
        return max(m) if m else 0
    for r in sorted(sub, key=key):
        m = r['mana']
        mx = max(m) if m else 0
        band = '低' if mx <= 200 else ('中' if mx < 400 else '高')
        print('   %-18s %-3s 魔力%-16s 冷却%-6s' % (r['id'], band, m, r['cd']))
    b = {'低': 0, '中': 0, '高': 0}
    for r in sub:
        m = r['mana']
        mx = max(m) if m else 0
        b['低' if mx <= 200 else ('中' if mx < 400 else '高')] += 1
    print('   →', b)

print()
print('=== D. 机制 × 阶段 完整矩阵（含未分档） ===')
print('%-14s %4s %4s %4s %4s' % ('机制', '铁', '钻', '下界', '未分'))
holes = []
for v in D.VOCAB:
    k = v[0]
    c = [0, 0, 0, 0]
    for r in rows:
        if k in r['tags']:
            c[r['tier']] += 1
    print('%-14s %4d %4d %4d %4d' % (k, c[1], c[2], c[3], c[0]))
    if c[1] == 0:
        holes.append((k, '缺开局', c))
    elif c[3] == 0:
        holes.append((k, '缺终端', c))
print()
print('=== E. 结论 ===')
for k, w, c in holes:
    print('  %-12s %s  铁%d/钻%d/下界%d/未分%d' % (k, w, c[1], c[2], c[3], c[0]))
