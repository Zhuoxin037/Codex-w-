# -*- coding: utf-8 -*-
"""批量生成「神经衰弱」三块升级石的三件套(2026-10-12, 批 9)

产物:
  upgrade/item/neuro_{a,b,o}.mcfunction     (give)
  upgrade/apply/neuro_{a,b,o}.mcfunction    (右键敲入)
  advancement/upgrade/neuro_{a,b,o}.json    (consume_item 进度)

【版式】照抄最新一批(生命提升 / 愿景 / 冷却剂)的写法 —— 适用与前置同在一行、
用 `   ·   ` 隔开, 前置值 aqua 纯名(不是老写法"需要「X」"红字)。所以**不能**复用
_gen_upgrade_items.py 的 lore_lines(那是 1..6 老六块的老版式)。
lore 只给"逻辑内容", 折行/留白仍交给 lore_fmt(它与 check 规则 31 同一套口径)。

用法: python .workbuddy/_gen_stone_batch8.py [--write]
"""
import io
import os
import sys
import importlib.util

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
D = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream')

_spec = importlib.util.spec_from_file_location(
    'lore_fmt', os.path.join(ROOT, '.workbuddy', 'lore_fmt.py'))
LF = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(LF)

CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,has_consume_particles:false,'
              'sound:"block.bamboo_wood_button.click_off"}')

# id, 中文名, 前置id, 前置中文名, 效果
ITEMS = [
    ("neuro_a", "神经衰弱·α", "", "", ["攻击速度 +0.1。"]),
    ("neuro_b", "神经衰弱·β", "neuro_a", "神经衰弱·α", ["攻击速度 +0.2。"]),
    ("neuro_o", "神经衰弱·Ω", "neuro_b", "神经衰弱·β", ["攻击速度 +0.4。"]),
]

# CMD 编号 —— 必须与 _gen_stone_icons.py 的 CMD 表一致(守门 _chk_stone_icons)
CMD = {"neuro_a": 50, "neuro_b": 51, "neuro_o": 52}


def head(text):
    return {'text': text, 'color': 'gold', 'bold': True, 'italic': False}


def info_pair(label1, value1, color1, label2, value2, color2):
    return {'text': '', 'italic': False, 'extra': [
        {'text': label1, 'color': 'gray'}, {'text': value1, 'color': color1},
        {'text': '   ·   ', 'color': 'dark_gray'},
        {'text': label2, 'color': 'gray'}, {'text': value2, 'color': color2}]}


def gray(text):
    return {'text': text, 'color': 'gray', 'italic': False}


def blank():
    return {'text': ' ', 'italic': False}


def lore_of(effect, req_name):
    out = [head('✦ 升级石'),
           info_pair('适用于 ', '剑 / 斧', 'yellow',
                     '前置 ', (req_name or '无'), 'aqua'),
           blank()]
    for l in effect:
        out.append(gray(l))
    return LF.json_to_snbt(LF.rebuild(out))


def give_txt(uid, name, effect, req_name):
    return (
        '# ============================================================\n'
        '# sweetdream:upgrade/item/%s —— 给一块「%s」\n'
        '# ------------------------------------------------------------\n'
        '# 【custom_data】只写一个标记 up_%s :\n'
        '#   进度 advancement/upgrade/%s 靠它认"右键用掉了哪块石头"。\n'
        '# 【为什么不带 itemreplace】那是"通用回手线"的标记(右键用完还手),\n'
        '#   材料是一次性消耗品, 带上它会被还回来 —— 敲失败时才需要还(见 apply/%s)。\n'
        '# 【consumable 不能删】没有它右键不会触发 consume_item 进度。\n'
        '# 【底板】统一 recovery_compass(追溯指针)—— 唯一不会被任何配方当原料吃掉的底座。\n'
        '#   custom_model_data 是它的"图标编号", 资源包靠这个换外观,\n'
        '#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 一一对应, 改一边要改两边。\n'
        '#   ★ 必须写成 floats:[%d.0f]: component 的 floats 是 Float 列表,\n'
        '#     直接给 [%d] 是整型列表, 会被 codec 拒掉。\n'
        '# 【图标】闪电形(神经衰弱 = 神经 / 电流), 编号 %d。\n'
        '#   重跑: python .workbuddy/_gen_stone_icons.py\n'
        '# 【效果已实装】upgrade/def/load 的 updef."%s" + upgrade/held_apply(2026-10-12)。\n'
        '# ============================================================\n\n'
        'give @s recovery_compass[max_stack_size=1,item_name={text:"%s",bold:true,color:light_purple},'
        'custom_model_data={floats:[%d.0f]},lore=%s,custom_data={zx:["up_%s"]},%s]\n'
    ) % (uid, name, uid, uid, uid, CMD[uid], CMD[uid], CMD[uid], uid,
         name, CMD[uid], lore_of(effect, req_name), uid, CONSUMABLE)


def apply_txt(uid, name):
    return (
        '# ============================================================\n'
        '# sweetdream:upgrade/apply/%s —— 右键用掉这块「%s」去敲副手的装备\n'
        '# ------------------------------------------------------------\n'
        '# 【谁调用它】进度 sweetdream:upgrade/%s(consume_item), 以玩家身份\n'
        '# 【流程】①撤销进度(不撤的话这个进度一辈子只触发一次)\n'
        '#         ②把 kind/id/cat~cat4 交给 station/api/apply 统一处理\n'
        '#         ③成功 = 这次消耗成立; 失败 = 把材料还回去 + 说明原因\n'
        '# 【为什么 cat~cat4 要一起来】能不能装要看类别, 而拼物品谓词只能走宏,\n'
        '#   所以在这里从定义表读出来一起传进去(cat3/cat4 缺失时由 apply 补空串)。\n'
        '# ============================================================\n\n'
        'advancement revoke @s only sweetdream:upgrade/%s\n\n'
        'data modify storage zx:work st set value {kind:"upgrade",id:"%s",cat:"",cat2:"",of:""}\n'
        'data modify storage zx:work st.cat set from storage zx:config updef."%s".cat\n'
        'data modify storage zx:work st.cat2 set from storage zx:config updef."%s".cat2\n'
        'data modify storage zx:work st.cat3 set from storage zx:config updef."%s".cat3\n'
        'data modify storage zx:work st.cat4 set from storage zx:config updef."%s".cat4\n'
        'function sweetdream:station/api/apply\n\n'
        'execute if data storage zx:out r{ok:1b} run function sweetdream:upgrade/api/done with storage zx:work st\n'
        'execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/item/%s\n'
        'execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/api/refuse with storage zx:work st\n'
    ) % (uid, name, uid, uid, uid, uid, uid, uid, uid, uid)


def adv_txt(uid):
    return """{
    "criteria": {
        "%s": {
            "trigger": "consume_item",
            "conditions": {
                "item": {
                    "predicates": {
                        "minecraft:custom_data": {
                            "zx": [
                                "up_%s"
                            ]
                        }
                    }
                }
            }
        }
    },
    "rewards": {
        "function": "sweetdream:upgrade/apply/%s"
    }
}
""" % (uid, uid, uid)


def main():
    write = '--write' in sys.argv
    n = 0
    for uid, name, _rid, req_name, effect in ITEMS:
        outs = [
            (os.path.join(D, 'function', 'upgrade', 'item', uid + '.mcfunction'),
             give_txt(uid, name, effect, req_name)),
            (os.path.join(D, 'function', 'upgrade', 'apply', uid + '.mcfunction'),
             apply_txt(uid, name)),
            (os.path.join(D, 'advancement', 'upgrade', uid + '.json'),
             adv_txt(uid)),
        ]
        for p, t in outs:
            old = io.open(p, encoding='utf-8').read() if os.path.exists(p) else None
            flag = 'same' if old == t else ('new' if old is None else 'changed')
            print('[%-7s] %s' % (flag, os.path.relpath(p, ROOT).replace('\\', '/')))
            if write and old != t:
                os.makedirs(os.path.dirname(p), exist_ok=True)
                io.open(p, 'w', encoding='utf-8', newline='\n').write(t)
            n += 1
    print('---- 共 %d 份 (%s)' % (n, '已写回' if write else 'dry-run'))


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    main()
