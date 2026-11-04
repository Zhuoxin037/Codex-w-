# -*- coding: utf-8 -*-
import re, os

BASE = 'sweetdream/data/sweetdream/function/equipment/staff'

for eid in ['burst_bank', 'cage_day', 'pour_sack', 'stop_needle']:
    f = os.path.join(BASE, eid, 'give.mcfunction')
    t = open(f, encoding='utf-8').read()
    j = ''.join(re.findall(r'"text":"([^"]*)"', t))
    m = re.search(r'give @s ([a-z_]+)\[', t)
    tg = re.search(r'tags:\[([^\]]*)\]', t)
    nm = re.search(r'item_name=\{text:"([^"]+)"', t)
    print('==== %s | %s | 底物 %s' % (eid, nm.group(1) if nm else '?', m.group(1) if m else '?'))
    print('  tags:', tg.group(1) if tg else '-')
    print('  lore:', j[:420])
    print()

# 主动技能消耗与冷却
print('==== 主动技能消耗/冷却（从 cast 读）====')
for eid in ['burst_bank', 'cage_day', 'pour_sack', 'stop_needle']:
    p = os.path.join(BASE, eid, 'cast.mcfunction')
    if not os.path.exists(p):
        continue
    txt = open(p, encoding='utf-8').read()
    mana = re.findall(r'mana:([\d.]+)', txt)
    cd = re.findall(r'cooldown_seconds:([\d.]+)', txt)
    print('  %-14s mana=%s cd=%s' % (eid, mana[:2], cd[:2]))
