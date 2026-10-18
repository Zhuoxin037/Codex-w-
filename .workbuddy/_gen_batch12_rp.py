# -*- coding: utf-8 -*-
"""_gen_batch12_rp.py —— 批 12 外观：资源包侧 items/*.json + models/item/vanilla/*.json

【只做资源包"接线"，不画图】贴图由 `_gen_batch12_icons.py` 生成；
  这个脚本把「物品定义 → 模型 → 贴图」这三层连起来，缺任何一层客户端都会
  退回原版外观（看不到紫黑，但也没外观），所以三层必须一起补。

【三类形状，各照包内既有先例抄】
  · 剑 / 斧 / 法杖：items 直接 `minecraft:model` → models/item/vanilla/<tex>
    模型 parent = `minecraft:item/handheld`（斜向手持、GUI 里也是一把）
  · 弩：items 必须是一整套 `select(charge_type) → condition(using_item)
    → range_dispatch(crossbow/pull)` 的分支树，6 个态各一个模型；
    这里直接拿 `crossbow_arc.json` 当模板做字符串替换（不手写，免得漏一个分支）
  · 法杖 triad 的模型/贴图统一带 `staff_` 前缀（与包内 8 件法杖一致），
    但 item_model 名是 `sweetdream:triad`（give 里已经这么写了）

【用法】python .workbuddy/_gen_batch12_rp.py
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RP = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream')
ITEMS = os.path.join(RP, 'items')
MODELS = os.path.join(RP, 'models', 'item', 'vanilla')

CROSSBOW_STATES = ('standby', 'pulling_0', 'pulling_1', 'pulling_2', 'arrow', 'firework')

# ---------------------------------------------------------------- 名单（唯一真相来源）
# (items 文件名 / item_model 名, 模型文件名, 贴图文件名, parent)
HANDHELD = [
    ('tidemark',    'tidemark',    'tidemark',    'minecraft:item/handheld'),
    ('grayscale',   'grayscale',   'grayscale',   'minecraft:item/handheld'),
    ('crescent',    'crescent',    'crescent',    'minecraft:item/handheld'),
    ('scorch_bone', 'scorch_bone', 'scorch_bone', 'minecraft:item/handheld'),
]
CROSSBOWS = [
    ('crossbow_dragon_tongue', 'dragon_tongue'),
    ('crossbow_cloudtrail',    'cloudtrail'),
]


def dump(path, obj):
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print('  ->', os.path.relpath(path, ROOT))


def main():
    # ① 单手类：模型 + items
    for item_name, model_name, tex_name, parent in HANDHELD:
        dump(os.path.join(MODELS, model_name + '.json'), {
            'parent': parent,
            'textures': {'layer0': 'sweetdream:item/vanilla/' + tex_name},
        })
        dump(os.path.join(ITEMS, item_name + '.json'), {
            'hand_animation_on_swap': False,
            'model': {'type': 'minecraft:model',
                      'model': 'sweetdream:item/vanilla/' + model_name},
        })

    # ② 弩：6 个态各一个模型；items 拿 crossbow_arc.json 当模板替换
    with open(os.path.join(ITEMS, 'crossbow_arc.json'), encoding='utf-8') as f:
        tpl = f.read()
    for item_name, key in CROSSBOWS:
        for st in CROSSBOW_STATES:
            src = 'crossbow_%s_%s' % (key, st)
            dump(os.path.join(MODELS, src + '.json'), {
                'parent': 'minecraft:item/crossbow',
                'textures': {'layer0': 'sweetdream:item/vanilla/' + src},
            })
        dump(os.path.join(ITEMS, item_name + '.json'),
             json.loads(tpl.replace('crossbow_arc_', 'crossbow_%s_' % key)))


if __name__ == '__main__':
    main()
    print('done')
