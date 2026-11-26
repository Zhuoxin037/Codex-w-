# -*- coding: utf-8 -*-
"""
_sync_armor_rp.py —— 把「原版风 · 盔甲」生成物**打包进完整版资源包**（幂等）。

做四件事（一件盔甲五份文件，缺一即紫黑块 / 不生效）：
  ① textures/item/vanilla/armor_<id>.png                     背包图标 16×16
  ② textures/entity/equipment/humanoid[_leggings]/armor_<id>.png  穿戴层 64×32
  ③ items/armor_<id>.json                                     item_model 入口
  ④ models/item/vanilla/armor_<id>.json                       layer0 指向 ①
  ⑤ equipment/armor_<id>.json                                 asset_id 指向 ②

★ 为什么必须有这个脚本：五份文件里只有 ① ② 是画出来的，③④⑤ 是纯模板；
  上次明烛是手写的，很容易漏一份 ⇒ 游戏里就是紫黑块且**一条日志都没有**（坑195）。
★ 目录口径：真源只有 `fallendream_rp_完整版/`（另两个 rp 目录已删，别再往那儿写）。
"""
import io
import json
import os
import shutil
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_armor import P, ICON_DIR, LAYER_DIR                  # noqa: E402

RP = r'D:\数据包\fallendream_rp_完整版\assets\fallendream'
TEX_ITEM = os.path.join(RP, 'textures', 'item', 'vanilla')
TEX_LAYER = os.path.join(RP, 'textures', 'entity', 'equipment')
ITEMS = os.path.join(RP, 'items')
MODELS = os.path.join(RP, 'models', 'item', 'vanilla')
EQUIP = os.path.join(RP, 'equipment')

LAYER_SUB = {'helmet': 'humanoid', 'chestplate': 'humanoid',
             'leggings': 'humanoid_leggings', 'boots': 'humanoid'}


def write_json(path, obj):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, 'w', encoding='utf-8', newline='\n').write(
        json.dumps(obj, ensure_ascii=False, indent=2) + '\n')


def main(only=None):
    n = dict(tex=0, layer=0, items=0, model=0, equip=0)
    for p in P:
        cid, slot = p['id'], p['slot']
        if only and cid not in only:
            continue
        icon = os.path.join(ICON_DIR, cid + '.png')
        layer = os.path.join(LAYER_DIR, cid + '.png')
        if not (os.path.isfile(icon) and os.path.isfile(layer)):
            raise SystemExit('✗ 缺生成物，先跑 build_vanilla_armor.py: ' + cid)

        dst_icon = os.path.join(TEX_ITEM, 'armor_%s.png' % cid)
        shutil.copyfile(icon, dst_icon)
        n['tex'] += 1

        sub = LAYER_SUB[slot]
        dst_layer = os.path.join(TEX_LAYER, sub, 'armor_%s.png' % cid)
        os.makedirs(os.path.dirname(dst_layer), exist_ok=True)
        shutil.copyfile(layer, dst_layer)
        n['layer'] += 1

        write_json(os.path.join(ITEMS, 'armor_%s.json' % cid), {
            'hand_animation_on_swap': False,
            'model': {'type': 'minecraft:model',
                      'model': 'fallendream:item/vanilla/armor_%s' % cid},
        })
        n['items'] += 1

        write_json(os.path.join(MODELS, 'armor_%s.json' % cid), {
            'parent': 'minecraft:item/generated',
            'textures': {'layer0': 'fallendream:item/vanilla/armor_%s' % cid},
        })
        n['model'] += 1

        write_json(os.path.join(EQUIP, 'armor_%s.json' % cid), {
            'layers': {sub: [{'texture': 'fallendream:armor_%s' % cid}]},
        })
        n['equip'] += 1

    print('打包完成: 图标 %d / 穿戴层 %d / items %d / models %d / equipment %d'
          % (n['tex'], n['layer'], n['items'], n['model'], n['equip']))


if __name__ == '__main__':
    main(sys.argv[1:] or None)
