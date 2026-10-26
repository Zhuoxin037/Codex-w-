# -*- coding: utf-8 -*-
"""版图盘点：装备 × 阶段(铁/钻/下界) × 机制(标签词)"""
import os, re, glob, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

ROOT = 'D:/数据包/sweetdream/data/sweetdream/function/equipment'
TYPES = ['sword', 'axe', 'bow', 'staff', 'armor', 'tool']
CN = {v[0]: v[2] for v in D.VOCAB}
GROUP = {v[0]: v[1] for v in D.VOCAB}

MAT_TIER = {
    'iron_sword': 1, 'iron_axe': 1,
    'diamond_sword': 2, 'diamond_axe': 2,
    'netherite_sword': 3, 'netherite_axe': 3,
    'iron_helmet': 1, 'iron_chestplate': 1, 'iron_leggings': 1, 'iron_boots': 1,
    'diamond_helmet': 2, 'diamond_chestplate': 2, 'diamond_leggings': 2, 'diamond_boots': 2,
    'netherite_helmet': 3, 'netherite_chestplate': 3, 'netherite_leggings': 3, 'netherite_boots': 3,
}

rows = []
for t in TYPES:
    for f in sorted(glob.glob('%s/%s/*/give.mcfunction' % (ROOT, t))):
        eid = os.path.basename(os.path.dirname(f))
        txt = open(f, encoding='utf-8').read()
        m = re.search(r'^give @s (\w+)', txt, re.M)
        item = m.group(1) if m else '?'
        tier = MAT_TIER.get(item, 0)
        tm = re.search(r'custom_data=\{[^}]*?tags:\[([^\]]*)\]', txt, re.S)
        tags = re.findall(r'"(\w+)"', tm.group(1)) if tm else []
        # 魔力 / 冷却 / 最大倍率
        manas = [int(x) for x in re.findall(r'"text":"(\d+)"', txt)]
        cds = [int(x) for x in re.findall(r'"text":"(\d+) 秒"', txt)]
        muls = [float(x) for x in re.findall(r'×\s*([0-9.]+)', txt)]
        rows.append(dict(id=eid, type=t, item=item, tier=tier,
                         tags=tags, mana=manas, cd=cds, mul=muls,
                         has_active='✦ 主动技能' in txt,
                         has_passive='✦ 被动技能' in txt or '✦ 普攻' in txt))

print('总件数', len(rows))
print()
print('=== 1. 阶段 × 类型 ===')
hdr = '%-10s %5s %5s %5s %5s' % ('类型', '铁/低', '钻/中', '下界/高', '未分档')
print(hdr)
for t in TYPES:
    sub = [r for r in rows if r['type'] == t]
    c = [0, 0, 0, 0]
    for r in sub:
        c[r['tier']] += 1
    print('%-10s %5d %5d %5d %5d' % (t, c[1], c[2], c[3], c[0]))
print()
print('=== 2. 未分档(法杖/弩/副手)明细 ===')
for t in ['bow', 'staff', 'tool']:
    sub = [r for r in rows if r['type'] == t and r['tier'] == 0]
    print('--', t, len(sub))
    for r in sub:
        print('   %-16s 魔力%-18s 冷却%-10s' % (r['id'], r['mana'][:3], r['cd'][:2]))
print()
print('=== 3. 机制 × 阶段 覆盖 ===')
allkeys = [v[0] for v in D.VOCAB]
print('%-14s %-4s %4s %4s %4s %4s %s' % ('机制', '组', '铁', '钻', '下界', '未分档', '总'))
for k in allkeys:
    c = [0, 0, 0, 0]
    for r in rows:
        if k in r['tags']:
            c[r['tier']] += 1
    tot = sum(c)
    flag = ''
    if tot == 0:
        flag = '  <<< 零'
    elif c[1] == 0 and c[2] == 0 and c[3] == 0:
        flag = '  <<< 只靠未分档'
    elif (c[1] + c[2] + c[3]) > 0 and c[1] == 0:
        flag = '  < 无开局'
    elif c[3] == 0 and (c[1] + c[2]) > 0:
        flag = '  < 无终端'
    print('%-14s %-4s %4d %4d %4d %4d %4d%s' % (k, GROUP[k], c[1], c[2], c[3], c[0], tot, flag))

json.dump(rows, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '_board.json'), 'w', encoding='utf-8'), ensure_ascii=False)
