# -*- coding: utf-8 -*-
"""批量生成最后一批 6 块升级石的 apply + 进度(2026-10-08)

模板照抄 upgrade/apply/vision_a 与 advancement/upgrade/vision_a.json ——
那两套已经跑通, 手抄 6 遍必然漂移。
"""
import io
import os

BASE = "D:/数据包/sweetdream/data/sweetdream"
APPLY = BASE + "/function/upgrade/apply"
ADV = BASE + "/advancement/upgrade"

# id, 中文名
ITEMS = [
    ("torch", "火炬"),
    ("boil", "沸腾"),
    ("night_vision", "夜视仪"),
    ("life_up_a", "生命提升·α"),
    ("life_up_b", "生命提升·β"),
    ("life_up_o", "生命提升·Ω"),
]


def apply_txt(uid, name):
    return f"""# ============================================================
# sweetdream:upgrade/apply/{uid} —— 右键用掉这块「{name}」去敲副手的装备
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:upgrade/{uid}(consume_item), 以玩家身份
# 【流程】①撤销进度(不撤的话这个进度一辈子只触发一次)
#         ②把 kind/id/cat~cat4 交给 station/api/apply 统一处理
#         ③成功 = 这次消耗成立; 失败 = 把材料还回去 + 说明原因
# 【为什么 cat~cat4 要一起来】能不能装要看类别, 而拼物品谓词只能走宏,
#   所以在这里从定义表读出来一起传进去(cat3/cat4 缺失时由 apply 补空串)。
# ============================================================

advancement revoke @s only sweetdream:upgrade/{uid}

data modify storage zx:work st set value {{kind:"upgrade",id:"{uid}",cat:"",cat2:"",of:""}}
data modify storage zx:work st.cat set from storage zx:config updef."{uid}".cat
data modify storage zx:work st.cat2 set from storage zx:config updef."{uid}".cat2
data modify storage zx:work st.cat3 set from storage zx:config updef."{uid}".cat3
data modify storage zx:work st.cat4 set from storage zx:config updef."{uid}".cat4
function sweetdream:station/api/apply

execute if data storage zx:out r{{ok:1b}} run function sweetdream:upgrade/api/done with storage zx:work st
execute if data storage zx:out r{{ok:0b}} run function sweetdream:upgrade/item/{uid}
execute if data storage zx:out r{{ok:0b}} run function sweetdream:upgrade/api/refuse with storage zx:work st
"""


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


for uid, name in ITEMS:
    io.open(os.path.join(APPLY, uid + ".mcfunction"), "w",
            encoding="utf-8", newline="\n").write(apply_txt(uid, name))
    io.open(os.path.join(ADV, uid + ".json"), "w",
            encoding="utf-8", newline="\n").write(adv_txt(uid))
    print("ok", uid)
