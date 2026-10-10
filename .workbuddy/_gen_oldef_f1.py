# -*- coding: utf-8 -*-
"""批量生成「批 F1 · 超限·斧」三条 oldef 定义行(2026-10-09)

【只做一件事】往 overlimit/def/load.mcfunction 末尾追加 `oldef."<id>"` 那一行。
为什么不手抄: lore 要按 lore_fmt 的同一套折行(半角宽 37 ≈ 18.5 汉字), 手抄
必然和磁盘上已有的那条对不齐, 跑 lore_fmt 又会把它改一遍 => 静默漂移。

【口径】lore 正文 = 用户原文逐字照抄(只按 lore_fmt 折行, 不改字、不缩写)。
【三乘区】这三件都是"整段换描述 + 私有钩子改机制", 不走 dmg/mana/cd 乘区,
   所以全写 0.0(和批 E1/E2 一致)。
【段结构】逐条显式列出(不套模板), 与各件基础 give 的排版一致:
   红莲 / 负离子 = 「✦ 主动技能」+ 数值行 + 空行 + 正文;
   超•负•荷     = 「✦ 被动技能」+ 正文 + 空行 + 「✦ 主动技能」+ 数值行 + 空行 + 正文。
   空行(单空格条目)是排版的一部分, lore_fmt.rebuild 会原样保留 —— 位置必须
   和基础 give 一模一样, 否则改完超限描述会"少一个空行"。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, wrap  # noqa: E402

LOAD = "D:/数据包/sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction"

# ★ 超限名的颜色 = 该装备**本名**的颜色(2026-10-10 用户要求, 见 overlimit/def/load 头部)。
#   真源是 equipment/**/<id>/give.mcfunction 里的 item_name.color; 改色跑
#   `python .workbuddy/_fix_oldef_colors.py`, 别手改。
OL_COLOR = {"red_lotus": "red", "charge": "blue", "anion": "blue"}

TITLE = "✦ 主动技能"
TITLE_P = "✦ 被动技能"

#  id,          label,            note,  条目列表
#  条目: ("head", 标题) / ("info", 魔力, 冷却) / ("body", 正文) / ("spacer",)
DEFS = [
    ("red_lotus", "超限·红莲",
     "流火: 5格×1 -> 6格×1.5+燃烧2秒; 夜火: ×3一次 -> ×4两次+燃烧5秒(均6格); "
     "本次消耗>=6层则自身5格内敌人每秒获「流火」持续5秒", [
         ("head", TITLE), ("info", "80", "30 秒"), ("spacer",),
         ("body",
          "使用后消耗自身 5 格内全部生物的「流火」或「夜火」效果。每消耗一层"
          "「流火」则对自身 6 格内全部生物造成一次相当于自身基础攻击力 ×1.5 的"
          "伤害并使其燃烧 2 秒，每消耗一层「夜火」则对自身 6 格内全部生物造成"
          "两次相当于自身基础攻击力 ×4 的伤害并使其燃烧 5 秒。若本次共消耗了 6 层"
          "及以上「流火」及「夜火」，则使自身 5 格内的敌人每秒都会获得「流火」"
          "效果，持续 5 秒。"),
     ]),
    ("charge", "超限·超•负•荷",
     "常态迅捷II / 技能期间迅捷III; 每秒随机2个; 命中三次闪电+×0.08; 状态15秒; "
     "结束后若冷却完成则自动使用+停止冷却缩减+永久攻击/魔力加成+闪电额外×3+每次攻击自伤5%", [
         ("head", TITLE_P), ("body", "主手持时，自身获得迅捷Ⅱ。"), ("spacer",),
         ("head", TITLE), ("info", "300", "100 秒"), ("spacer",),
         ("body",
          "使用后召唤一个术阵。之后自身获得常态的迅捷 3 效果。每秒都会对自身 8 格"
          "内 2 格外的随机 2 个生物释放闪电，当自身攻击到生物后则立即对其释放三次闪电"
          "并对其 1 格内的全部生物造成相当于自身当前魔力值 ×0.08 的伤害，之后使"
          "该武器技能冷却时间 -4 秒。该状态持续 15 秒。该状态结束后若该技能完成"
          "冷却，则自动使用且该技能停止正常冷却缩减，之后自身攻击力增加相当于"
          "自身当前基础攻击力的数值，最大魔力值增加相当于自身当前最大魔力值"
          " ×0.5 的数值，且自身每次召唤闪电时都会对落点处的生物造成相当于自身"
          "基础攻击力 ×3 的伤害。但每次攻击都会对自身造成相当于自身最大生命值"
          " ×0.05 的伤害。"),
     ]),
    ("anion", "超限·负离子",
     "伤害 ×0.1 -> ×0.12 且范围 3 个 -> 全部; 1 秒后最大魔力 ×0.08; "
     "之后 8 秒内自身召唤闪电额外对落地处造成 当前魔力 ×0.1", [
         ("head", TITLE), ("info", "40", "30 秒"), ("spacer",),
         ("body",
          "使用后对自身 6 格内的全部生物释放闪电并对其造成相当于自身当前魔力值"
          " ×0.12 的伤害，1 秒后再释放闪电并对其相当于自身最大魔力值 ×0.08 的"
          "伤害。之后 8 秒内自身召唤闪电时闪电额外对落地处造成相当于自身当前"
          "魔力值 ×0.1 的伤害"),
     ]),
]


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def lore_json(items):
    out = []
    for it in items:
        if it[0] == "head":
            out.append('{"text":"%s","color":"gold","bold":true,"italic":false}' % esc(it[1]))
        elif it[0] == "info":
            out.append('{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},'
                       '{"text":"%s","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},'
                       '{"text":"冷却 ","color":"gray"},{"text":"%s","color":"yellow"}]}'
                       % (it[1], it[2]))
        elif it[0] == "spacer":
            out.append('{"text":" ","italic":false}')
        else:
            for ln in wrap(nfmt(it[1]), 37):
                out.append('{"text":"%s","color":"gray","italic":false}' % esc(ln))
    return "[" + ",".join(out) + "]"


def line(uid, label, note, items):
    return ('data modify storage zx:config oldef."%s" set value {label:"%s",'
            'name:{"text":"%s","bold":true,"color":"%s"},note:"%s",'
            'dmg:0.0,mana:0.0,cd:0.0,lore:%s}\n'
            % (uid, esc(label), esc(label), OL_COLOR[uid], esc(note), lore_json(items)))


if __name__ == '__main__':
    with io.open(LOAD, 'a', encoding='utf-8', newline='\n') as f:
        for (uid, label, note, items) in DEFS:
            f.write(line(uid, label, note, items))
            print('ok', uid)
