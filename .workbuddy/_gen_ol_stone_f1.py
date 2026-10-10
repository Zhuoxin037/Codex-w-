# -*- coding: utf-8 -*-
"""批量生成「批 F1 · 超限·斧」3 块超限石的 物品 / 进度 / apply(2026-10-09)

模板照抄 overlimit/item/hengdao + advancement/overlimit/hengdao.json +
overlimit/apply/hengdao —— 那套已经跑通, 手抄 3 遍必然漂移。
编号: 39 / 40 / 41(前一批到 38 为止, 见 _gen_stone_icons.py 的 CMD)。
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

#  id,        中文全名,               cmd, 适用装备名,    lore 正文(整段, 由 lore_fmt 折行)
#  正文 = 用户原文逐字照抄(与 oldef."<id>".lore 同源), 只按 lore_fmt 折行。
STONES = [
    ("red_lotus", "超限·红莲", 39, "红莲",
     "敲入后红莲更名为「超限·红莲」，主动技能变为：使用后消耗自身 5 格内全部生物的"
     "「流火」或「夜火」效果。每消耗一层「流火」则对自身 6 格内全部生物造成一次"
     "相当于自身基础攻击力 ×1.5 的伤害并使其燃烧 2 秒，每消耗一层「夜火」则对自身"
     " 6 格内全部生物造成两次相当于自身基础攻击力 ×4 的伤害并使其燃烧 5 秒。若本次"
     "共消耗了 6 层及以上「流火」及「夜火」，则使自身 5 格内的敌人每秒都会获得"
     "「流火」效果，持续 5 秒。"),
    ("charge", "超限·超•负•荷", 40, "超•负•荷",
     "敲入后超•负•荷更名为「超限·超•负•荷」，被动技能变为：主手持时，自身获得"
     "迅捷Ⅱ。主动技能变为：使用后召唤一个术阵。之后自身获得常态的迅捷 3 效果。"
     "每秒都会对自身 8 格内 2 格外的随机 2 个生物释放闪电，当自身攻击到生物后则立即对其"
     "释放三次闪电并对其 1 格内的全部生物造成相当于自身当前魔力值 ×0.08 的伤害，"
     "之后使该武器技能冷却时间 -4 秒。该状态持续 15 秒。该状态结束后若该技能完成"
     "冷却，则自动使用且该技能停止正常冷却缩减，之后自身攻击力增加相当于自身当前"
     "基础攻击力的数值，最大魔力值增加相当于自身当前最大魔力值 ×0.5 的数值，且"
     "自身每次召唤闪电时都会对落点处的生物造成相当于自身基础攻击力 ×3 的伤害。"
     "但每次攻击都会对自身造成相当于自身最大生命值 ×0.05 的伤害。"),
    ("anion", "超限·负离子", 41, "负离子",
     "敲入后负离子更名为「超限·负离子」，主动技能变为：使用后对自身 6 格内的全部"
     "生物释放闪电并对其造成相当于自身当前魔力值 ×0.12 的伤害，1 秒后再释放闪电"
     "并对其相当于自身最大魔力值 ×0.08 的伤害。之后 8 秒内自身召唤闪电时闪电额外"
     "对落地处造成相当于自身当前魔力值 ×0.1 的伤害"),
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


for uid, full, cmd, target, body in STONES:
    io.open(os.path.join(ITEM, uid + ".mcfunction"), "w",
            encoding="utf-8", newline="\n").write(item_txt(uid, full, cmd, target, body))
    io.open(os.path.join(ADV, uid + ".json"), "w",
            encoding="utf-8", newline="\n").write(adv_txt(uid))
    io.open(os.path.join(APPLY, uid + ".mcfunction"), "w",
            encoding="utf-8", newline="\n").write(apply_txt(uid, target, full))
    print("ok", uid)
