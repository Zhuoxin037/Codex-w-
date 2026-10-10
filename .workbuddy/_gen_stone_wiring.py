# -*- coding: utf-8 -*-
"""
_gen_stone_wiring.py —— 生成 12 块新升级石的「敲入函数 + 进度」与
                        2 颗超限石(脑髓蛭/脊骨共生)的同套件。
--------------------------------------------------------------------------
【为什么用生成器】这 14 份是纯样板(只差 id / 中文名 / 类别词), 手抄 14 遍
  必然有抄错的一行 —— 而这一行错了就是"这颗石头永远敲不上"或"敲上了不生效",
  且不报错。生成器 + 可重跑, 和 _gen_batch5.py 一个路子。
【产物】
  upgrade/apply/<id>.mcfunction      × 12
  advancement/upgrade/<id>.json      × 12
  overlimit/apply/<id>.mcfunction    × 2
  advancement/overlimit/<id>.json    × 2
【不产】upgrade/item/*.mcfunction 与 overlimit/item/*.mcfunction(那些是物品, 早就有了)。
用法: python .workbuddy/_gen_stone_wiring.py [--write]
"""
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
D = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream')

# (id, 中文名)
UPGRADE = [
    ('coolant_a', '冷却剂·α'), ('coolant_b', '冷却剂·β'), ('coolant_o', '冷却剂·Ω'),
    ('harden_a', '硬化·α'), ('harden_b', '硬化·β'), ('harden_o', '硬化·Ω'),
    ('mana_surge_a', '魔力沸涌·α'), ('mana_surge_b', '魔力沸涌·β'), ('mana_surge_o', '魔力沸涌·Ω'),
    ('vision_a', '愿景·α'), ('vision_b', '愿景·β'), ('vision_o', '愿景·Ω'),
]

OVERLIMIT = [
    ('brain_leech', '脑髓蛭'),
    ('spine_symbiote', '脊骨共生'),
]

APPLY_TPL = u"""# ============================================================
# sweetdream:upgrade/apply/%(id)s —— 右键用掉这块「%(label)s」去敲副手的装备
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:upgrade/%(id)s(consume_item), 以玩家身份
# 【流程】①撤销进度(不撤的话这个进度一辈子只触发一次)
#         ②把 kind/id/cat~cat4 交给 station/api/apply 统一处理
#         ③成功 = 这次消耗成立; 失败 = 把材料还回去 + 说明原因
# 【为什么 cat~cat4 要一起来】能不能装要看类别, 而拼物品谓词只能走宏,
#   所以在这里从定义表读出来一起传进去(cat3/cat4 缺失时由 apply 补空串)。
# ============================================================

advancement revoke @s only sweetdream:upgrade/%(id)s

data modify storage zx:work st set value {kind:"upgrade",id:"%(id)s",cat:"",cat2:"",of:""}
data modify storage zx:work st.cat set from storage zx:config updef."%(id)s".cat
data modify storage zx:work st.cat2 set from storage zx:config updef."%(id)s".cat2
data modify storage zx:work st.cat3 set from storage zx:config updef."%(id)s".cat3
data modify storage zx:work st.cat4 set from storage zx:config updef."%(id)s".cat4
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run function sweetdream:upgrade/api/done with storage zx:work st
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/item/%(id)s
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/api/refuse with storage zx:work st
"""

ADV_TPL = u"""{
    "criteria": {
        "%(id)s": {
            "trigger": "consume_item",
            "conditions": {
                "item": {
                    "predicates": {
                        "minecraft:custom_data": {
                            "zx": [
                                "up_%(id)s"
                            ]
                        }
                    }
                }
            }
        }
    },
    "rewards": {
        "function": "sweetdream:upgrade/apply/%(id)s"
    }
}
"""

OL_APPLY_TPL = u"""# ============================================================
# sweetdream:overlimit/apply/%(id)s —— 右键用掉超限石去敲副手的「%(label)s」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/%(id)s(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=%(id)s)
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手那件的 zx(必须含 %(id)s), 并且确认它还没敲过 ol。
# 【与武器的差别】脑髓蛭/脊骨共生是**盔甲**, 超限乘区(dmg/mana/cd)全 0 ——
#   换名字 + 整段换描述 + 效果由装备自己的 second/kill/attack 读 ol 分流。
# ============================================================

advancement revoke @s only sweetdream:overlimit/%(id)s

data modify storage zx:work st set value {kind:"overlimit",id:"",cat:"",cat2:"",of:"%(id)s"}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run tellraw @s [{"text":"✔ %(label)s已超限","color":"green"}]
execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/%(id)s
execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse
"""

OL_ADV_TPL = u"""{
    "criteria": {
        "%(id)s": {
            "trigger": "consume_item",
            "conditions": {
                "item": {
                    "predicates": {
                        "minecraft:custom_data": {
                            "zx": [
                                "ol_%(id)s"
                            ]
                        }
                    }
                }
            }
        }
    },
    "rewards": {
        "function": "sweetdream:overlimit/apply/%(id)s"
    }
}
"""


def wr(path, text):
    io.open(path, 'w', encoding='utf-8', newline='\n').write(text)
    return os.path.relpath(path, ROOT).replace('\\', '/')


def main():
    write = '--write' in sys.argv
    outs = []
    for i, lab in UPGRADE:
        outs.append((os.path.join(D, 'function', 'upgrade', 'apply', i + '.mcfunction'),
                     APPLY_TPL % {'id': i, 'label': lab}))
        outs.append((os.path.join(D, 'advancement', 'upgrade', i + '.json'),
                     ADV_TPL % {'id': i}))
    for i, lab in OVERLIMIT:
        outs.append((os.path.join(D, 'function', 'overlimit', 'apply', i + '.mcfunction'),
                     OL_APPLY_TPL % {'id': i, 'label': lab}))
        outs.append((os.path.join(D, 'advancement', 'overlimit', i + '.json'),
                     OL_ADV_TPL % {'id': i}))

    for p, t in outs:
        old = None
        if os.path.exists(p):
            old = io.open(p, encoding='utf-8').read()
        flag = 'same' if old == t else ('new' if old is None else 'changed')
        rel = os.path.relpath(p, ROOT).replace('\\', '/')
        print('[%-7s] %s' % (flag, rel))
        if write and old != t:
            wr(p, t)
    print('---- 共 %d 份 (%s)' % (len(outs), '已写回' if write else 'dry-run'))


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    main()
