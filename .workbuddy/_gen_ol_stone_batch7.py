# -*- coding: utf-8 -*-
"""批量生成最后一批 3 块超限石的 物品 / 进度 / apply(2026-10-08)

模板照抄 overlimit/item/liuguang + advancement/overlimit/liuguang.json +
overlimit/apply/liuguang —— 那套已经跑通, 手抄 3 遍必然漂移。
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

#  id,              中文全名,                cmd, 适用装备名,    lore 正文(每串一行, 已按 ~18 汉字宽硬切)
STONES = [
    ("stellar_elegy", "超限·群星坠落之挽歌", 30, "群星坠落之挽歌", [
        "敲入后群星坠落之挽歌更名为「超限·群星",
        "坠落之挽歌」，被动变为：自身魔力值上",
        "限 +350，每次受到攻击后获得抗性提升",
        "Ⅲ且每秒恢复 2% 魔力值，持续 5 秒，之",
        "后使自身 6 格内全部带有任意一个通用效",
        "果的生物受到一次相当于自身当前魔力值",
        "×0.03 的伤害并使其随机附加一个效果。",
    ]),
    ("dusk_dawn", "超限·黄昏黎明之交界", 31, "黄昏黎明之交界", [
        "敲入后黄昏黎明之交界更名为「超限·黄昏",
        "黎明之交界」，被动变为：自身魔力值上",
        "限 +250，魔力值低于上限 80% 时每秒获",
        "得 3% 魔力值，击杀生物后临时获得 200",
        "魔力值上限持续 12 秒，若其带有通用效",
        "果则额外获得 100×X 魔力值上限（X 为该",
        "生物所有的效果数量）。",
    ]),
    # ★ 万念这段**不许缩写**: 以前用的是"命中 -> 领域 -> 5 次 -> 2 秒窗口"的
    #   缩略版, 把"特殊技能到底打出什么效果"整段省掉了 —— 玩家拿着石头根本
    #   看不懂自己买了什么(2026-10-08 用户反馈)。正文直接和
    #   overlimit/def/load 里 oldef."myriad".lore 逐字对齐(那是实装的口径)。
    # ★ 只写万念那一半: 千散侧的描述跟着换手后的物品走(超限·千散), 石头上省略。
    ("myriad", "超限·万念", 29, "万念",
     "敲入后万念更名为「超限·万念」，主动技能变为：使用后切换为【千散】并对自身 "
     "3 格内的全部生物造成一次相当于自身当前魔力值 ×0.1 的伤害。若攻击到生物则"
     "召唤一个半径为 5 格持续 6 秒的领域。之后若自身处于领域中且攻击生物 5 次后"
     "则有 2 秒时间可以释放一次特殊技能。本次技能的效果为将【千散】切换回【万念"
     "】并对领域内的生物使用一次【千散】的主动技能效果。若原本就为【万念】则改"
     "为使用一次【万念】的主动技能且本次伤害提高为相当于自身最大魔力值 ×0.12。"
     "若自身没有选择释放此次特殊技能则召唤一个相等的领域，之后召唤一个“剑魂”。"),
]


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def lore_json(name, body):
    if isinstance(body, str):
        # 给整段正文, 由 lore_fmt 统一折行(和 overlimit/def 里那份同宽)
        body = wrap(nfmt(body), 37)
    parts = [
        '{"text":"✦ 超限石","color":"gold","bold":true,"italic":false}',
        '{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},'
        '{"text":"%s","color":"blue"},{"text":"   ·   ","color":"dark_gray"},'
        '{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]}' % name,
        '{"text":" ","italic":false}',
    ]
    for line in body:
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
