# -*- coding: utf-8 -*-
"""_gen_late_rp.py —— 46 件补外观的**资源包接线**（items / models / equipment）。

【只接线，不画图】贴图由 `_gen_late_icons.py` 生成。三层必须一起补，
  缺任一层客户端就退回原版外观（不报错、也没紫黑，最难发现）：
    items/<名>.json  ->  models/item/vanilla/<key>.json  ->  textures/item/vanilla/<key>.png

【四类形状，各抄包内既有先例】
  · 剑/斧：items 直接 `minecraft:model` -> parent `minecraft:item/handheld`
  · 弩：items 是一整套 `select(charge_type) -> condition(using_item)
    -> range_dispatch(crossbow/pull)` 的分支树，6 个态各一个模型
    —— 直接拿 `crossbow_arc.json` 做字符串替换，不手写（免得漏分支）
  · 法杖：与剑同构，只是模型/贴图 key 带 `staff_` 前缀（包内 8 件法杖同规矩）
  · 副手：parent `minecraft:item/generated`（不是 handheld），key 带 `tool_` 前缀
  · 盔甲：**两份** —— items/<armor_<id>> 管图标；equipment/<armor_<id>> 管穿在身上，
    后者 `layers.humanoid[_leggings]` 只写本槽位需要的那一个键
    （头/胸/靴 = humanoid，护腿 = humanoid_leggings）

【用法】python .workbuddy/_gen_late_rp.py
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _gen_late_icons import AXES, CROSSBOWS, STAFFS, SWORDS, TOOLS, ARMOR  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RP = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream')
ITEMS = os.path.join(RP, 'items')
MODELS = os.path.join(RP, 'models', 'item', 'vanilla')
EQUIP = os.path.join(RP, 'equipment')
CB_STATES = ('standby', 'pulling_0', 'pulling_1', 'pulling_2', 'arrow', 'firework')


def dump(path, obj):
    d = os.path.dirname(path)
    if not os.path.isdir(d):
        os.makedirs(d)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print('  ->', os.path.relpath(path, ROOT))


def handheld(items_name, model_key, parent='minecraft:item/handheld'):
    dump(os.path.join(MODELS, model_key + '.json'), {
        'parent': parent,
        'textures': {'layer0': 'sweetdream:item/vanilla/' + model_key},
    })
    dump(os.path.join(ITEMS, items_name + '.json'), {
        'hand_animation_on_swap': False,
        'model': {'type': 'minecraft:model',
                  'model': 'sweetdream:item/vanilla/' + model_key},
    })


def main():
    print('== 剑 / 斧')
    for s in SWORDS + AXES:
        # ★ 沉锚（anchor）**跳过**：资源包里 `items/anchor.json` 已经被那份
        #   "四向静态审阅模型；尚未部署"的 3D 手持候选占着（57 KB，带手部姿态分支）。
        #   拿平面图标盖上去 = 直接抹掉那份工程，且覆盖后零提示。
        #   平面图标已画好（textures/item/vanilla/anchor.png + models/item/vanilla/anchor.json），
        #   等用户对 3D 候选的握姿给结论后再决定挂哪一份。
        if s['id'] == 'anchor':
            print('  跳过 anchor（3D 候选占位，等验收）')
            continue
        handheld(s['id'], s['id'])
    print('== 法杖（model key 带 staff_）')
    for s in STAFFS:
        handheld(s['id'], 'staff_' + s['id'])
    print('== 副手（parent generated，key 带 tool_）')
    for s in TOOLS:
        handheld('tool_' + s['id'], 'tool_' + s['id'], parent='minecraft:item/generated')
    print('== 弩（6 态 + 分支树）')
    with open(os.path.join(ITEMS, 'crossbow_arc.json'), encoding='utf-8') as f:
        tpl = f.read()
    for s in CROSSBOWS:
        key = 'crossbow_' + s['id']
        for st in CB_STATES:
            dump(os.path.join(MODELS, '%s_%s.json' % (key, st)), {
                'parent': 'minecraft:item/crossbow',
                'textures': {'layer0': 'sweetdream:item/vanilla/%s_%s' % (key, st)},
            })
        dump(os.path.join(ITEMS, key + '.json'),
             json.loads(tpl.replace('crossbow_arc_', key + '_')))
    print('== 盔甲（图标 + 穿戴层）')
    for s in ARMOR:
        key = 'armor_' + s['id']
        dump(os.path.join(MODELS, key + '.json'), {
            'parent': 'minecraft:item/generated',
            'textures': {'layer0': 'sweetdream:item/vanilla/' + key},
        })
        dump(os.path.join(ITEMS, key + '.json'), {
            'hand_animation_on_swap': False,
            'model': {'type': 'minecraft:model', 'model': 'sweetdream:item/vanilla/' + key},
        })
        layer = 'humanoid_leggings' if s['slot'] == 'leggings' else 'humanoid'
        dump(os.path.join(EQUIP, key + '.json'), {
            'layers': {layer: [{'texture': 'sweetdream:' + key}]},
        })


if __name__ == '__main__':
    main()
    print('done')
