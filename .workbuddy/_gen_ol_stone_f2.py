# -*- coding: utf-8 -*-
"""批量生成「批 F2 · 超限·斧弩」的超限石 物品 / 进度 / apply(2026-10-10)

模板照抄 overlimit/item/anion + advancement/overlimit/anion.json +
overlimit/apply/anion —— 那套已经跑通, 手抄多遍必然漂移。
【覆盖模式】可以直接重跑(和 _gen_oldef_f2.py 那种追加的不一样)。
编号: 42 起(前一批到 41 为止, 见 _gen_stone_icons.py 的 CMD)。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, wrap  # 折行用统一那套(半角宽 37 ≈ 18.5 汉字)

BASE = "D:/数据包/sweetdream/data/sweetdream"
ITEM = BASE + "/function/overlimit/item"
ADV = BASE + "/advancement/overlimit"
APPLY = BASE + "/function/overlimit/apply"

#  id,        中文全名,         cmd, 适用装备名,  lore 正文(整段, 由 lore_fmt 折行)
STONES = [
    ("cold_crow", "超限·寒鸦", 42, "寒鸦",
     "敲入后寒鸦更名为「超限·寒鸦」，主动技能新加：「冰凌」到达 4 层并射击后若自身"
     "魔力值大于 150，则消耗 120 魔力值并使「冰凌」恢复至 3 层。"),
    # ---- 蚀骨(2026-10-10 补) ----
    ("bone_erode", "超限·蚀骨", 43, "蚀骨",
     "敲入后蚀骨更名为「超限·蚀骨」，主动技能变为：每次射击都会对被射击的生物的2格内的"
     "全部生物造成相当于本次射击所消耗的魔力值*0.5的真实伤害。若生物上附有「噬心」则"
     "额外受到一次相当于本次伤害80%的真实伤害，之后清除「噬心」。"),
]


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def lore_json(name, body):
    parts = [
        '{"text":"✦ 超限石","color":"gold","bold":true,"italic":false}',
        '{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},'
        '{"text":"%s","color":"blue"},{"text":"   ·   ","color":"dark_gray"},'
        '{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]}' % name,
        '{"text":" ","italic":false}',
    ]
    for line in wrap(nfmt(body), 37):
        parts.append('{"text":"%s","color":"gray","italic":false}' % esc(line))
    return "[" + ",".join(parts) + "]"


def item_txt(uid, full, cmd, target, body):
    return (
        "# ============================================================\n"
        "# sweetdream:overlimit/item/%s —— 给一块「%s」\n"
        "# ------------------------------------------------------------\n"
        "# 【custom_data】只写一个标记 ol_%s :\n"
        "#   进度 advancement/overlimit/%s 靠它认\"右键用掉了哪块超限石\"。\n"
        "# 【底座】recovery_compass + custom_model_data={floats:[%d.0f]}(八芒星, 编号 %d)。\n"
        "#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。\n"
        "# 【适用】只有「%s」能敲(见 overlimit/api/fit: 副手 zx 必须含 %s 且还没敲过 ol)。\n"
        "# ============================================================\n"
        "\n"
        "give @s recovery_compass[max_stack_size=1,item_name={text:\"%s\",bold:true,color:light_purple},"
        "custom_model_data={floats:[%d.0f]},lore=%s,"
        "custom_data={zx:[\"ol_%s\"]},"
        "consumable={animation:\"none\",consume_seconds:0,has_consume_particles:false,"
        "sound:\"block.bamboo_wood_button.click_off\"}]\n"
    ) % (uid, full, uid, uid, cmd, cmd, target, target, full, cmd, lore_json(target, body), uid)


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
                                "ol_%s"
                            ]
                        }
                    }
                }
            }
        }
    },
    "rewards": {
        "function": "sweetdream:overlimit/apply/%s"
    }
}
""" % (uid, uid, uid)


def apply_txt(uid, target, full):
    return (
        "# ============================================================\n"
        "# sweetdream:overlimit/apply/%s —— 右键用掉超限石去敲副手那件「%s」\n"
        "# ------------------------------------------------------------\n"
        "# 【谁调用它】进度 sweetdream:overlimit/%s(consume_item), 以玩家身份\n"
        "# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of=%s)\n"
        "#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因\n"
        "# 【of 是什么】这块石头\"属于哪件装备\" —— overlimit/api/fit 会拿它去比对\n"
        "#   副手的 zx(必须含 %s), 并且确认这件还没敲过 ol。\n"
        "# ============================================================\n"
        "\n"
        "advancement revoke @s only sweetdream:overlimit/%s\n"
        "\n"
        "data modify storage zx:work st set value {kind:\"overlimit\",id:\"\",cat:\"\",cat2:\"\",of:\"%s\"}\n"
        "function sweetdream:station/api/apply\n"
        "\n"
        "execute if data storage zx:out r{ok:1b} run tellraw @s [{\"text\":\"✔ %s已超限\",\"color\":\"green\"}]\n"
        "execute if data storage zx:out r{ok:1b} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2\n"
        "execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/item/%s\n"
        "execute if data storage zx:out r{ok:0b} run function sweetdream:overlimit/api/refuse\n"
    ) % (uid, target, uid, uid, uid, uid, uid, target, uid)


if __name__ == '__main__':
    for uid, full, cmd, target, body in STONES:
        io.open(os.path.join(ITEM, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(item_txt(uid, full, cmd, target, body))
        io.open(os.path.join(ADV, uid + ".json"), "w",
                encoding="utf-8", newline="\n").write(adv_txt(uid))
        io.open(os.path.join(APPLY, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(apply_txt(uid, target, full))
        print("ok", uid)
