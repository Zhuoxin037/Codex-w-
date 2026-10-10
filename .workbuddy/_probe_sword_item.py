# -*- coding: utf-8 -*-
"""_probe_sword_item.py —— 广谱普查: 哪些行在"造出"这 12 件剑的物品串

判据放宽到任何形态（不只看 give / item replace @s）:
  · give / item replace ... with <item>[...custom_data={zx:["<id>"]...}]
  · data modify ... set value {id:"minecraft:iron_sword",components:{...custom_data:{zx:["<id>"]}}}
  · 任何行里同时出现 `zx:["<id>"]` 与 `item_model` 所在的那串组件
用来确认 _chk_sword_icon.py 的扫描范围没有漏（漏了 = 某条路径产出的剑没有图标）。
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCAN = os.path.join(ROOT, 'sweetdream', 'data')
IDS = ['everfrost', 'hengdao', 'hush', 'liaoyuan', 'liuguang', 'myriad',
       'qiansan', 'rebound', 'remelt', 'rogue_star', 'shadow_blade', 'verdict']

# zx[0] 是我们的 id，且这一行看起来在**给出/替换**物品
p_zx = re.compile(r'custom_data\s*[:=]\s*\{?\s*zx\s*:\s*\[\s*"(\w+)"')
p_give = re.compile(r'\bgive\b.*@\w+')
p_repl = re.compile(r'\bitem\s+replace\b')
p_nbt = re.compile(r'\bid\s*:\s*"minecraft:\w+"')

found = {}
for r, _, fns in os.walk(SCAN):
    for fn in sorted(fns):
        if not fn.endswith(('.mcfunction', '.json')):
            continue
        p = os.path.join(r, fn)
        for ln, s in enumerate(io.open(p, encoding='utf-8'), 1):
            m = p_zx.search(s)
            if not m or m.group(1) not in IDS:
                continue
            kind = None
            if p_give.search(s):
                kind = 'give'
            elif p_repl.search(s):
                kind = 'item replace'
            elif p_nbt.search(s) and 'item_model' in s:
                kind = 'nbt(带item_model)'
            elif p_nbt.search(s):
                kind = 'nbt(裸)'
            elif 'no-equip-check-ok' in s or s.lstrip().startswith('#'):
                kind = '注释/引用'
            else:
                kind = '判据/其它'
            found.setdefault(m.group(1), []).append(
                (kind, os.path.relpath(p, SCAN).replace('\\', '/'), ln,
                 'item_model="sweetdream:%s"' % m.group(1) in s))

for i in IDS:
    rows = found.get(i, [])
    prod = [x for x in rows if x[0] in ('give', 'item replace', 'nbt(带item_model)', 'nbt(裸)')]
    bad = [x for x in prod if not x[3]]
    print('%-13s 共 %2d 行 / 产出型 %2d 行 / 缺 item_model %d %s'
          % (i, len(rows), len(prod), len(bad), '✓' if not bad else '✗'))
    for x in prod:
        print('      %-16s %-56s L%-4d %s' % (x[0], x[1], x[2], '✓' if x[3] else '✗ 缺'))
