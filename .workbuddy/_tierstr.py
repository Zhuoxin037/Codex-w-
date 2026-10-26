# -*- coding: utf-8 -*-
"""按阶段看强度：每件的主动魔力/冷却/最大倍率 + 被动数值"""
import os, re, glob, json

ROOT = 'D:/数据包/sweetdream/data/sweetdream/function/equipment'
MAT_TIER = {'iron': 1, 'diamond': 2, 'netherite': 3}
TN = {1: '铁', 2: '钻', 3: '下界', 0: '未分档'}

def parse(f):
    txt = open(f, encoding='utf-8').read()
    item = re.search(r'^give @s (\w+)', txt, re.M).group(1)
    tier = 0
    for k, v in MAT_TIER.items():
        if item.startswith(k):
            tier = v
    lore = ' '.join(re.findall(r'"text":"([^"]*)"', txt))
    lore = re.sub(r'\s+', '', lore)
    muls = [float(x) for x in re.findall(r'×([0-9.]+)', lore)]
    # 只取主动段倍数
    act = lore.split('✦主动技能')
    actmul = [float(x) for x in re.findall(r'×([0-9.]+)', act[1])] if len(act) > 1 else []
    mana = [int(x) for x in re.findall(r'魔力(\d+)', lore)]
    cd = [int(x) for x in re.findall(r'冷却(\d+)秒', lore)]
    return dict(id=os.path.basename(os.path.dirname(f)), item=item, tier=tier,
                muls=muls, actmul=actmul, mana=mana, cd=cd, active='✦主动技能' in lore,
                alen=len(lore))

for t in ['sword', 'axe', 'armor']:
    print('=' * 72)
    print('##', t)
    groups = {1: [], 2: [], 3: []}
    for f in sorted(glob.glob('%s/%s/*/give.mcfunction' % (ROOT, t))):
        d = parse(f)
        if d['tier']:
            groups[d['tier']].append(d)
    for k in (1, 2, 3):
        g = groups[k]
        if not g:
            continue
        am = [max(x['actmul']) for x in g if x['actmul']]
        actn = sum(1 for x in g if x['active'])
        print('-- %s %d 件  有主动 %d 件' % (TN[k], len(g), actn))
        print('   主动最大倍率: %s → 中位 %.2f' % (
            sorted(['%.1f' % v for v in am]), sorted(am)[len(am)//2] if am else 0))
        row = []
        for x in sorted(g, key=lambda y: -(max(y['actmul']) if y['actmul'] else 0)):
            mm = max(x['actmul']) if x['actmul'] else 0
            row.append('%s(%.1f)' % (x['id'], mm) if mm else x['id'])
        print('   ', ' '.join(row))
