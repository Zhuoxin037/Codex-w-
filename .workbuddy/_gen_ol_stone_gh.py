# -*- coding: utf-8 -*-
"""批量生成「批 G/H · 超限·法杖/盔甲」的超限石 物品 / 进度 / apply(2026-10-10)

模板照抄 _gen_ol_stone_f2.py(那套已跑通 6 件)。【覆盖模式】可直接重跑。
编号: 46 起(前一批到 45 为止, 见 _gen_stone_icons.py 的 CMD)。
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

#  id,             中文全名,              cmd, 适用装备名,          lore 正文
STONES = [
    ("begonia", "超限·海棠", 46, "海棠",
     "敲入后海棠更名为「超限·海棠」，基础属性新加：若有生物在漩涡范围内死亡，"
     "则对该漩涡进行增强：在漩涡内使用关于最大魔力值的技能时造成的伤害提升"
     "20%。将漩涡范围扩大为6格，且爆炸后会对漩涡内全部生物造成相当于自身最大"
     "魔力值*0.25的伤害并使处于中心的生物附加「渊海」，之后该技能冷却时间-12秒。"),
    ("polarized_light", "超限·偏振光", 47, "偏振光",
     "敲入后偏振光更名为「超限·偏振光」，基础属性变为：使用后召唤一个术阵。"
     "之后自身持续发射三道光线并每0.5秒对自身12格内离自己最近的三个生物造成"
     "一次相当于自身当前魔力值*0.05的伤害，且被锁定的生物获得缓慢三效果。"
     "该效果持续5秒。"),
    ("dionysus_helmet", "超限·狄俄尼索斯之桂冠", 48, "狄俄尼索斯之桂冠",
     "敲入后狄俄尼索斯之桂冠更名为「超限·狄俄尼索斯之桂冠」，基础属性变为："
     "自身魔力上限+240。自身受到伤害后有20%的概率会获得反胃2和力量3效果，"
     "之后获得一层「酒浆」（最多10层），并且自身每秒恢复60点魔力值，持续3秒。"
     "自身攻击生物时，若自身「酒浆」达到5层以上则消耗5层「酒浆」，之后触发该"
     "装备的被动效果且强化为获得力量5效果，且自身技能伤害提升30%，之后获得"
     "一层「酒浆」，并且自身每秒恢复80点魔力值，之后每秒获得一次瞬间治疗4，"
     "持续5秒（持续期间不可再次触发）。"),
    ("furnace_core", "超限·炉心", 49, "炉心",
     "敲入后炉心更名为「超限·炉心」，基础属性变为：自身魔力值上限+150，最大"
     "生命值+15，基础攻击力+8。自身每攻击一次处于燃烧状态的生物则积攒一层"
     "「燃灰」（最大为12层）。每有一层「燃灰」则自身魔力值上限+30，基础攻击力"
     "+X（X为自身当前基础攻击力*0.1，最低为4），最大生命值+Y（Y为自身当前最大"
     "生命值*0.1，最低为7），且每秒恢复1点魔力值。「燃灰」每3秒-1层。若「燃灰」"
     "达到12层则「燃灰」在12秒内将不再减少层数。之后自身「燃灰」层数降至8层。"),
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
    ) % (uid, target, uid, uid, uid, uid, uid, full, uid)


if __name__ == '__main__':
    for uid, full, cmd, target, body in STONES:
        io.open(os.path.join(ITEM, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(item_txt(uid, full, cmd, target, body))
        io.open(os.path.join(ADV, uid + ".json"), "w",
                encoding="utf-8", newline="\n").write(adv_txt(uid))
        io.open(os.path.join(APPLY, uid + ".mcfunction"), "w",
                encoding="utf-8", newline="\n").write(apply_txt(uid, target, full))
        print("ok", uid)
