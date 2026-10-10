# -*- coding: utf-8 -*-
"""把 12 块四系新升级石的 lore 正文抽出来（规格来源）。"""
import io, json, os, re

BASE = r'D:\数据包\sweetdream\data\sweetdream\function'
IDS = ['coolant_a', 'coolant_b', 'coolant_o',
       'harden_a', 'harden_b', 'harden_o',
       'mana_surge_a', 'mana_surge_b', 'mana_surge_o',
       'vision_a', 'vision_b', 'vision_o']


def flat(comp):
    out = []
    if isinstance(comp, dict):
        t = comp.get('text')
        if t:
            out.append(t)
        for e in (comp.get('extra') or []):
            out.append(flat(e))
    elif isinstance(comp, list):
        for e in comp:
            out.append(flat(e))
    return ''.join(out)


for i in IDS:
    p = os.path.join(BASE, 'upgrade', 'item', i + '.mcfunction')
    s = io.open(p, encoding='utf-8').read()
    nm = re.search(r'item_name=\{text:"(.*?)",', s)
    m = re.search(r'lore=(\[.*?\]),custom_data=', s, re.S)
    print('=' * 14, i, '=' * 14)
    if nm:
        print('[名]', nm.group(1))
    if not m:
        print('  (没抽到 lore)')
        continue
    lore = json.loads(m.group(1))
    for c in lore:
        line = flat(c)
        if line.strip():
            print('   ', line)
