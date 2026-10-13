# -*- coding: utf-8 -*-
"""批量生成「批 I1」4 块超限石的 物品 / 进度 / apply(2026-10-12)

模板照抄 overlimit/item/liuguang + advancement/overlimit/liuguang.json +
overlimit/apply/liuguang —— 那套已经跑通, 手抄 4 遍必然漂移。
(与 _gen_ol_stone_batch7.py 同源, 只换 STONES 表 + 正文改从 _gen_oldef_i1 取,
 保证"石头描述"与"敲上之后的整段描述"永远同出一处。)

【★ 正文同源】`_gen_oldef_i1` 的 ARC/TINDER_*/FISSURE/CHIME_* 就是用户原文;
  石头描述 = "敲入后<名>更名为「超限·<名>」，基础属性变为：" + 同一段原文。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, wrap  # 折行用统一那套(半角宽 37 ≈ 18.5 汉字)
from _gen_oldef_i1 import (ARC, TINDER_BURN, TINDER_HAND,   # noqa: E402
                           FISSURE, CHIME_CAST, CHIME_CRYSTAL)

BASE = "D:/数据包/sweetdream/data/sweetdream"
ITEM = BASE + "/function/overlimit/item"
ADV = BASE + "/advancement/overlimit"
APPLY = BASE + "/function/overlimit/apply"

#  id,        中文全名,      cmd, 适用装备名,  正文(用户原文逐字, 交给 wrap 折行)
STONES = [
    ("arc", "超限·电弧", 53, "电弧",
     "敲入后电弧更名为「超限·电弧」，基础属性变为：" + ARC),
    ("tinder", "超限·火种", 54, "火种",
     "敲入后火种更名为「超限·火种」，基础属性变为：" + TINDER_BURN + TINDER_HAND),
    ("fissure", "超限·崩裂", 55, "崩裂",
     "敲入后崩裂更名为「超限·崩裂」，基础属性变为：" + FISSURE),
    ("chime", "超限·共鸣", 56, "共鸣",
     "敲入后共鸣更名为「超限·共鸣」，基础属性变为：" + CHIME_CAST + CHIME_CRYSTAL),
]


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def lore_json(name, body):
    if isinstance(body, str):
        # 给整段正文, 由 lore_fmt 统一折行(和 overlimit/def 里那份同宽)。
        # ★ 不得在这里动 lore_fmt.PAIRS 之类的全局口径: check.py 的 lore 规则
        #   拿**全局** wrap 的输出比对, 局部打补丁会被判"不是 lore_fmt 的输出"。
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


if __name__ == '__main__':
    for uid, full, cmd, target, body in STONES:
        io.open(os.path.join(ITEM, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(item_txt(uid, full, cmd, target, body))
        io.open(os.path.join(ADV, uid + ".json"), "w",
                encoding="utf-8", newline="\n").write(adv_txt(uid))
        io.open(os.path.join(APPLY, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(apply_txt(uid, target, full))
        print("ok", uid)
