# -*- coding: utf-8 -*-
"""五层连通自检：items -> models -> textures（图标/穿戴层），逐件核对尺寸与引用。"""
import json, os, sys
from PIL import Image

RP = r'D:/数据包/fallendream_rp_完整版/assets/fallendream'
IDS = {'borrow_fire': 'chestplate', 'heart_vein': 'chestplate', 'profile': 'leggings',
       'late_dusk': 'leggings', 'tide_fold': 'helmet', 'glimmer': 'helmet',
       'ebb_tide': 'boots', 'bright_candle': 'helmet'}
SUB = {'helmet': 'humanoid', 'chestplate': 'humanoid', 'leggings': 'humanoid_leggings',
       'boots': 'humanoid'}
bad = 0
for cid, slot in IDS.items():
    paths = {
        'items': os.path.join(RP, 'items', 'armor_%s.json' % cid),
        'model': os.path.join(RP, 'models/item/vanilla', 'armor_%s.json' % cid),
        'equip': os.path.join(RP, 'equipment', 'armor_%s.json' % cid),
        'icon':  os.path.join(RP, 'textures/item/vanilla', 'armor_%s.png' % cid),
        'layer': os.path.join(RP, 'textures/entity/equipment', SUB[slot], 'armor_%s.png' % cid),
    }
    miss = [k for k, p in paths.items() if not os.path.isfile(p)]
    if miss:
        bad += 1
        print('MISS', cid, miss)
        continue
    it = json.load(open(paths['items'], encoding='utf-8'))
    mo = json.load(open(paths['model'], encoding='utf-8'))
    eq = json.load(open(paths['equip'], encoding='utf-8'))
    icon = Image.open(paths['icon'])
    layer = Image.open(paths['layer'])
    ok = (it['model']['model'] == 'fallendream:item/vanilla/armor_%s' % cid
          and mo['textures']['layer0'] == 'fallendream:item/vanilla/armor_%s' % cid
          and eq['layers'][SUB[slot]][0]['texture'] == 'fallendream:armor_%s' % cid
          and icon.size == (16, 16) and layer.size == (64, 32))
    if not ok:
        bad += 1
        print('BAD', cid, it['model']['model'], mo['textures']['layer0'],
              eq['layers'], icon.size, layer.size)
    else:
        print('ok  %-14s %-11s icon16 layer64x32' % (cid, slot))

# 碎骨弩：items -> 6 个 models -> 6 张贴图
cx = 'bone_breaker'
cn = 'crossbow_bone_breaker'
p = os.path.join(RP, 'items', cn + '.json')
if not os.path.isfile(p):
    bad += 1
    print('MISS bone_breaker items')
else:
    tree = json.load(open(p, encoding='utf-8'))['model']
    refs = []

    def walk(n):
        if isinstance(n, dict):
            if n.get('type') == 'minecraft:model':
                refs.append(n['model'])
            for v in n.values():
                walk(v)
        elif isinstance(n, list):
            for v in n:
                walk(v)
    walk(tree)
    print('碎骨弩 模型引用 %d 个: %s' % (len(refs), refs))
    for r in refs:
        mp = os.path.join(RP, 'models', r.split(':')[1] + '.json')
        if not os.path.isfile(mp):
            bad += 1
            print('  MISS model', r)
            continue
        mo = json.load(open(mp, encoding='utf-8'))
        t = mo['textures']['layer0'].split(':')[1]
        tp = os.path.join(RP, 'textures', t + '.png')
        if not os.path.isfile(tp):
            bad += 1
            print('  MISS texture', t)
        else:
            print('  ok', r.split('/')[-1], Image.open(tp).size)
print('---- 问题 %d' % bad)
sys.exit(1 if bad else 0)
