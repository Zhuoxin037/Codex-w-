# -*- coding: utf-8 -*-
"""批量生成「批 E2 · 超限·剑」4 块超限石的 物品 / 进度 / apply(2026-10-08)

模板照抄 overlimit/item/liuguang + advancement/overlimit/liuguang.json +
overlimit/apply/liuguang —— 那套已经跑通, 手抄 4 遍必然漂移。
编号: 35 / 36 / 37 / 38(前一批到 34 为止, 见 _gen_stone_icons.py 的 CMD)。
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

#  id,              中文全名,             cmd, 适用装备名,    lore 正文(整段, 由 lore_fmt 折行)
#  正文 = 用户原文逐字照抄(与 oldef."<id>".lore 同源), 只按 lore_fmt 折行。
STONES = [
    ("everfrost", "超限·永霜", 35, "永霜",
     "敲入后永霜更名为「超限·永霜」，主动技能变为：冰冻自身 5 格范围内的全部生物 3 秒，"
     "之后每秒对被冰冻的生物造成一次相当于其最大生命值 ×0.03 的真实伤害（最多 10 秒），"
     "并在结束后对被冰冻的生物造成相当于自身当前魔力值 ×0.15 的伤害。"),
    ("flame_brokenbody", "超限·“烈火，残躯”", 36, "“烈火，残躯”",
     "敲入后“烈火，残躯”更名为「超限·“烈火，残躯”」，主动技能变为：对前方 5*3 范围内"
     "的生物造成一次相当于自身最大魔力值 ×0.1 的伤害，若攻击到的生物附有「流火」或"
     "「夜火」则该技能冷却时间立即结束，且若有「流火」则转化为「夜火」，每有一个"
     "「夜火」则吸收并为自身积攒一点「熔浆」。若释放技能时「熔浆」大于或等于 4 层则"
     "本次技能强化为对前方 5*3 范围内的生物造成两次相当于自身最大魔力值 ×0.1 的伤害，"
     "之后再对自身 6 格内的生物造成相当于自身最大魔力值 ×0.2 的伤害，之后清除「熔浆」。"),
    ("sickle_dreams", "超限·引梦镰", 37, "引梦镰",
     "敲入后引梦镰更名为「超限·引梦镰」，主动技能变为：使用后立即对自身前方 2*3 范围内"
     "的生物造成一次相当于自身最大魔力值 ×0.05 的伤害并附加「噬心」。若对有「噬心」的"
     "生物造成伤害则本次伤害强化为对自身前方 3*5 范围内的生物造成相当于自身最大魔力值"
     " ×0.25 的伤害并时停 2 秒，之后移除「噬心」。"),
    ("hengdao", "超限·横刀", 38, "横刀",
     "敲入后横刀更名为「超限·横刀」，主动技能变为：使用后向前突击最多 3 格，若碰到生物"
     "或障碍物则立即停下并对附近 5 格内的全部生物造成两次相当于自身最大魔力值 ×0.1 的"
     "伤害。若击杀生物则重置冷却时间。"),
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
    ) % (uid, full, uid, uid, cmd, cmd, target, uid, full, cmd, lore_json(target, body), uid)


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


for uid, full, cmd, target, body in STONES:
    io.open(os.path.join(ITEM, uid + ".mcfunction"), "w",
            encoding="utf-8", newline="\n").write(item_txt(uid, full, cmd, target, body))
    io.open(os.path.join(ADV, uid + ".json"), "w",
            encoding="utf-8", newline="\n").write(adv_txt(uid))
    io.open(os.path.join(APPLY, uid + ".mcfunction"), "w",
            encoding="utf-8", newline="\n").write(apply_txt(uid, target, full))
    print("ok", uid)
