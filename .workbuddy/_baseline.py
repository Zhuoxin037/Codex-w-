# -*- coding: utf-8 -*-
"""各阶段现件的(魔力, 冷却, 倍率)三元组，作为补件的数值基准"""
import os, re, glob, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

ROOT = 'D:/数据包/sweetdream/data/sweetdream/function/equipment'

def parse(f):
    txt = open(f, encoding='utf-8').read()
    item = re.search(r'^give @s (\w+)', txt, re.M).group(1)
    tier = 0
    for k, v in [('iron', 1), ('diamond', 2), ('netherite', 3)]:
        if item.startswith(k):
            tier = v
    lore = re.sub(r'\s+', '', ' '.join(re.findall(r'"text":"([^"]*)"', txt)))
    seg = lore.split('✦主动技能')
    act = seg[1] if len(seg) > 1 else ''
    mul = [float(x) for x in re.findall(r'×([0-9.]+)', act)]
    mana = [int(x) for x in re.findall(r'魔力(\d+)', act)]
    cd = [int(x) for x in re.findall(r'冷却(\d+)秒', act)]
    return dict(id=os.path.basename(os.path.dirname(f)), item=item, tier=tier,
                mul=max(mul) if mul else 0, mana=mana[0] if mana else 0,
                cd=cd[0] if cd else 0)

print('%-14s %-3s %-16s %6s %6s %6s %10s' % ('id', '档', '材质', '魔力', '冷却', '倍率', '倍率/(魔力/100)'))
for t in ['sword', 'axe']:
    print('=' * 74, t)
    for tier in (1, 2, 3):
        sub = []
        for f in sorted(glob.glob('%s/%s/*/give.mcfunction' % (ROOT, t))):
            d = parse(f)
            if d['tier'] == tier:
                sub.append(d)
        sub.sort(key=lambda x: -x['mul'])
        for d in sub:
            eff = (d['mul'] / (d['mana'] / 100.0)) if d['mana'] else 0
            print('%-14s %-3s %-16s %6d %6d %6.1f %10.2f' % (
                d['id'], {1: '铁', 2: '钻', 3: '下界'}[tier], d['item'], d['mana'], d['cd'], d['mul'], eff))
        print('-' * 74)
