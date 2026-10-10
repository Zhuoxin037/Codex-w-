# -*- coding: utf-8 -*-
"""批量生成「批 E1 · 超限·剑」3 块超限石的 物品 / 进度 / apply(2026-10-08)

模板照抄 overlimit/item/liuguang + advancement/overlimit/liuguang.json +
overlimit/apply/liuguang —— 那套已经跑通, 手抄 3 遍必然漂移。
编号: 32 / 33 / 34(前一批到 31 为止, 见 _gen_stone_icons.py 的 CMD)。
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
STONES = [
    ("rogue_star", "超限·游星", 32, "游星",
     "敲入后游星更名为「超限·游星」，主动技能变为：锁定自身 10 格范围内的全部生物，"
     "3 秒后对其 2 格内的全部生物造成两次相当于自身基础攻击力 ×4 的伤害"
     "（保底 16 点伤害）。"),
    ("shadow_blade", "超限·影刃", 33, "影刃",
     "敲入后影刃更名为「超限·影刃」，主动技能变为：使用后立即瞬移至自身 10 格内离"
     "自身最近的一个生物并对其造成相当于自身基础伤害 ×8 的伤害。若使用技能后击杀"
     "敌人时自身手持该武器则刷新该武器冷却时间并返还 100 魔力值。若手持的是其他"
     "武器则减少手持武器 15 秒主动技能冷却时间。"),
    ("deepsea_echo", "超限·深海的回响", 34, "深海的回响",
     "敲入后深海的回响更名为「超限·深海的回响」，被动变为：在自身物品栏里时，自身"
     "获得常态水下呼吸 1。主动技能变为：使用后标记 12 格内离自身最近的一个生物并"
     "使其附加「渊海」。1 秒后对其 4 格范围内的全部生物造成相当于自身当前魔力值"
     " ×0.18 的伤害，之后标记受到伤害的生物并重复，但每次重复都会消耗自身 80 魔力"
     "值，重复 2 次后结束。结束后若该技能攻击到了附加了「渊海」的生物则再重复一次"
     "，本次重复不消耗魔力值，之后该生物不再能触发该被动。之后该技能每攻击到附加"
     "了「渊海」的生物都会重复一次。"),
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
