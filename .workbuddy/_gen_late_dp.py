# -*- coding: utf-8 -*-
"""_gen_late_dp.py —— 46 件补外观的**数据包侧补充接线**（弩 / 法杖两类图标驱动）。

【为什么单独一份】剑 / 斧 / 副手 / 盔甲四类各有生成器在管
  （`_gen_sword_icons.py` / `_gen_axe_icons.py` / `_gen_offhand_visual.py` /
   `_gen_armor_visual.py`），把那四份名单补上新件即可。
  **弩和法杖没有生成器** —— 现有 7 根弩 + 9 根法杖的 modifier 与 held 行是当年手写的，
  照抄一遍容易漏（尤其 held 是"主手 + 副手"两行，漏一行就是只有一只手能修好）。
  所以这里补一份，只负责这两类：

    ① item_modifier/crossbow_icons/<id>.json    item_model = sweetdream:crossbow_<id>
    ② item_modifier/staff_icons/<id>.json       item_model = sweetdream:<id>（法杖不带前缀）
    ③ visual/crossbow_icon_held.mcfunction      追加 2 行/件
    ④ visual/staff_icon_held.mcfunction         追加 2 行/件

【★ 幂等】已经存在的 id 直接跳过（按 `zx:["<id>"]` 在文件里查一遍），
  所以可以反复跑；新加件只补它自己那几行，不动别人的。

【★ 为什么 held 要先 `unless items … item_model="…"`】
  `item modify` 一执行就重写组件，哪怕值没变；客户端把"组件变了"当"换了一件物品"
  ⇒ 每刻播一次举手动画 ⇒ 在手上一直抽搐（与 sword/axe 那两份同一个理由）。

【用法】python .workbuddy/_gen_late_dp.py
"""
import io
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _gen_late_icons import CROSSBOWS, STAFFS  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream')
MOD = os.path.join(DATA, 'item_modifier')
FUNC = os.path.join(DATA, 'function', 'visual')

# 弩：items 名 / item_model 名都带 crossbow_ 前缀；法杖只有模型/贴图带前缀，
# item_model 与 items 文件名就是裸 id（先例：staff/begonia -> sweetdream:begonia）
CB_KEY = lambda cid: 'crossbow_' + cid      # noqa: E731
SF_KEY = lambda cid: cid                    # noqa: E731


def write(path, text):
    with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def modifier(kind, fname, model):
    data = {
        'function': 'minecraft:set_components',
        'components': {'minecraft:item_model': 'sweetdream:' + model},
    }
    p = os.path.join(MOD, kind, fname + '.json')
    if os.path.exists(p):
        old = io.open(p, encoding='utf-8').read()
        new = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
        if old == new:
            print('  = modifier 已是最新', kind + '/' + fname)
            return
    write(p, json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('  + modifier', kind + '/' + fname)


def append_held(path, kind, cid, model):
    """在 held 文件末尾追加"主手 + 副手"两行（已存在则跳过）。"""
    src = io.open(path, encoding='utf-8').read()
    if 'zx:["%s"]' % cid in src:
        print('  = held 已有', cid)
        return
    if not src.endswith('\n'):
        src += '\n'
    add = []
    for slot in ('mainhand', 'offhand'):
        add.append(
            'execute if items entity @s weapon.%s *[minecraft:custom_data~{zx:["%s"]}]'
            ' unless items entity @s weapon.%s *[minecraft:item_model="sweetdream:%s"]'
            ' run item modify entity @s weapon.%s sweetdream:%s/%s'
            % (slot, cid, slot, model, slot, kind, cid))
    write(path, src + '\n'.join(add) + '\n')
    print('  + held %-18s %s' % (cid, kind))


def main():
    cb_held = os.path.join(FUNC, 'crossbow_icon_held.mcfunction')
    sf_held = os.path.join(FUNC, 'staff_icon_held.mcfunction')
    print('== 弩')
    for s in CROSSBOWS:
        cid = s['id']
        modifier('crossbow_icons', cid, CB_KEY(cid))
        append_held(cb_held, 'crossbow_icons', cid, CB_KEY(cid))
    print('== 法杖')
    for s in STAFFS:
        cid = s['id']
        modifier('staff_icons', cid, SF_KEY(cid))
        append_held(sf_held, 'staff_icons', cid, SF_KEY(cid))


if __name__ == '__main__':
    main()
    print('done')
