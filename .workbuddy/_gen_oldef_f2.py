# -*- coding: utf-8 -*-
"""生成「批 F2 · 超限·斧弩」的 oldef 定义行(2026-10-10)

【只做一件事】往 overlimit/def/load.mcfunction **末尾追加** `oldef."<id>"` 那一行。
为什么不手抄: lore 要按 lore_fmt 的同一套折行(半角宽 37 ≈ 18.5 汉字), 手抄必然和
磁盘上已有的那条对不齐, 跑 lore_fmt 又会把它改一遍 => 静默漂移。

【★★ 追加模式: **跑一次就好**, 再跑一遍会重复追加 ★★】
   本批先做寒鸦。蚀骨 / 幽匿残响 / 释梦体 后续把条目补进 DEFS, 再追加。

【口径】lore 正文 = 用户原文逐字照抄(只按 lore_fmt 折行, 不改字、不缩写)。
【三乘区】本批都是"整段换描述 + 私有钩子改机制", 不走 dmg/mana/cd 乘区, 全写 0.0。
【段结构】逐条显式列出(不套模板), 与各件基础 give 的排版一致 ——
   空行(单空格条目)是排版的一部分, lore_fmt.rebuild 会原样保留, 位置必须和基础
   give 一模一样, 否则改完超限描述会"少一个空行"。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, tw, wrap  # noqa: E402

LOAD = "D:/数据包/sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction"

# ★ 超限名的颜色 = 该装备**本名**的颜色(2026-10-10 用户要求, 见 overlimit/def/load 头部)。
#   真源是 equipment/**/<id>/give.mcfunction 里的 item_name.color; 改色跑
#   `python .workbuddy/_fix_oldef_colors.py`, 别手改。
OL_COLOR = {"cold_crow": "aqua", "bone_erode": "gray", "sculk_echo": "dark_aqua",
            "dream_reader": "light_purple"}

TITLE = "✦ 主动技能"
TITLE_P = "✦ 被动技能"

#  id,          label,             note,  条目列表
#  条目: ("head", 标题) / ("manalv", 耗蓝串, 括号说明) / ("info", 魔力, 冷却)
#        / ("body", 正文) / ("spacer",)
DEFS = [
    ("cold_crow", "超限·寒鸦",
     "第4层打完清空后: 若射击后(已扣本发320)魔力>150, 再扣120并把「冰凌」回填至3层"
     " -> 下一发又是第4层, 蓝够就能连续满层", [
         ("head", TITLE),
         ("manalv", "20 / 50 / 120 / 320", "（按「冰凌」层数）"),
         ("spacer",),
         ("body",
          "每次射击都会积攒一点「冰凌」。每次射击都会根据弓目前的「冰凌」而改变"
          "魔力消耗及射击效果。"),
         ("spacer",),
         ("head", "✦ 冰凌"),
         ("body", "● 一层：使被命中的生物冰冻 2 秒。"),
         ("body", "● 二层：使被命中的生物的 2 格内的全部生物冰冻 2 秒。"),
         ("body",
          "● 三层：使被命中的生物的 3 格内的全部生物冰冻 2 秒，并对其造成相当于"
          "自身最大魔力值 ×0.1 的伤害。"),
         ("body",
          "● 四层：使被命中的生物的 4 格内的全部生物冰冻 3 秒，并对其造成相当于"
          "自身最大魔力值 ×0.25 的伤害。之后清空全部「冰凌」。"),
         ("spacer",),
         ("body",
          "「冰凌」到达 4 层并射击后若自身魔力值大于 150，则消耗 120 魔力值并使"
          "「冰凌」恢复至 3 层。"),
     ]),
    # ---- 蚀骨(2026-10-10 补) ----
    #   「✦ 主动技能 / 魔力 20% / 空行 / 正文」—— 与基础 give 的段结构完全一致
    #   (弩没有冷却, 所以用 manaonly 而不是 info)。
    ("bone_erode", "超限·蚀骨",
     "×0.4 -> ×0.5 且改真实伤害; 2 格内带「噬心」的额外吃一次 本次伤害×0.8 的真实伤害"
     "并清「噬心」(噬心判定范围 = 2 格内全部生物)", [
         ("head", TITLE), ("manaonly", "20%"), ("spacer",),
         ("body",
          "每次射击都会对被射击的生物的2格内的全部生物造成相当于本次射击所消耗的"
          "魔力值*0.5的真实伤害。若生物上附有「噬心」则额外受到一次相当于本次伤害"
          "80%的真实伤害，之后清除「噬心」。"),
     ]),
    # ---- 幽匿残响(2026-10-10 补) ----
    #   「✦ 主动技能 / 魔力 100 / 空行 / 正文」—— 与基础 give 的段结构同款
    #   (弩没有冷却, 用 manaonly)。★ 超限原文是**一整段**(没有「✦ 悲鸣」小标题),
    #   "整段换描述"就是照抄这一整段, 不保留基础版的「积攒 10 点 /（上限 50 点）」两行。
    ("sculk_echo", "超限·幽匿残响",
     "积攒 10->20 点、上限 50->100; 命中范围与路径范围 2格->3格; 三倍概率 1%/点 -> 0.5%/点"
     "(满层同样 50%)", [
         ("head", TITLE), ("manaonly", "100"), ("spacer",),
         ("body",
          "每次射击会额外积攒 20 点「悲鸣」（上限 100 点），而每次射击后都会对被"
          "射击的生物的 3 格内额外造成相当于自身基础攻击力 ×「悲鸣」值 ×0.1 的"
          "伤害，同时对发射路径周围 3 格的敌人每刻造成相当于「悲鸣」值 ×0.1 的"
          "伤害。每 1 点「悲鸣」会使该伤害有 0.5% 概率造成三倍伤害，触发后清除"
          "全部「悲鸣」。"),
     ]),
    # ---- 释梦(2026-10-10 补; 用户 2026-10-10 订正: 超限名 = 「超限·释梦」) ----
    #   段结构与基础 give **完全同款**: ✦ 被动技能 / 空行 / ✦ 主动技能 / 魔力·冷却 / 空行 /
    #   召唤句 / 空行 / ✦ 入梦体 / 正文。
    #   ★ 超限原文**没有**基础版那句括号「（不同入梦体不会追踪同一个目标）」—— 整段换描述
    #     就是照抄超限原文, 不保留基础版的括号。
    #   ★ 两处"自身"(18 格 / 12 格)都指**施法者**(用户 2026-10-10 确认)。
    ("dream_reader", "超限·释梦",
     "被动 5×剩余秒数 -> 基础攻击力(最低10)×剩余秒数×0.5; 入梦体: 自毁 10->18 格且改为"
     "「施法者12格内没有未攻击过的目标」(不再打一次就走)、伤害 ×0.1->×0.12、时停 3->2 秒", [
         ("head", TITLE_P),
         ("body",
          "攻击处于时停状态的生物时对其额外造成相当于自身基础攻击力（最低为10） × "
          "剩余时停时间 ×0.5 的真实伤害，之后解除他的时停状态。"),
         ("spacer",),
         ("head", TITLE),
         ("info", "200", "40 秒"),
         ("spacer",),
         ("body", "使用后召唤 3 个“入梦体”。"),
         ("spacer",),
         ("head", "✦ 入梦体"),
         ("body",
          "“入梦体”会在离自身 18 格远或自身 12 格内没有未攻击过的目标后自毁。"
          "“入梦体”会自动追踪离其最近的生物并对其造成相当于释放者当前魔力值 ×0.12 "
          "的伤害，之后使其时停 2 秒并附加「白昼梦」效果。"),
     ]),
]


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def lore_json(items):
    out = []
    for it in items:
        kind = it[0]
        if kind == "head":
            out.append('{"text":"%s","color":"gold","bold":true,"italic":false}' % esc(it[1]))
        elif kind == "manalv":
            # 寒鸦式: 耗蓝按层数分级 -> 两行(第二行是 dark_gray 的括号说明)
            out.append('{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},'
                       '{"text":"%s","color":"aqua"}]}' % esc(it[1]))
            out.append('{"text":"","italic":false,"extra":[{"text":"%s","color":"dark_gray"}]}'
                       % esc(it[2]))
        elif kind == "manaonly":
            # 只有耗蓝、没有冷却(弩类: 射击不是右键技能) —— 与基础 give 的排版一字不差
            out.append('{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},'
                       '{"text":"%s","color":"aqua"}]}' % esc(it[1]))
        elif kind == "info":
            out.append('{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},'
                       '{"text":"%s","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},'
                       '{"text":"冷却 ","color":"gray"},{"text":"%s","color":"yellow"}]}'
                       % (it[1], it[2]))
        elif kind == "spacer":
            out.append('{"text":" ","italic":false}')
        else:
            text = nfmt(it[1])
            if text.startswith('●'):
                # `●` 条目: 去掉项目符号后按 (37 - 符号宽) 折行, **续行缩进 3 空格**
                #   —— 必须与 lore_fmt.rebuild 的 flush() 同口径, 否则 _chk_gen_drift
                #      会报"生成器 ↔ 磁盘"漂移(cold_crow 是本批唯一带 `●` 的件)。
                body = text[len('● '):] if text.startswith('● ') else text
                lines = wrap(body, 37 - tw('● '))
                for k, ln in enumerate(lines):
                    out.append('{"text":"%s","color":"gray","italic":false}'
                               % esc(('● ' + ln) if k == 0 else ('   ' + ln)))
            else:
                for ln in wrap(text, 37):
                    out.append('{"text":"%s","color":"gray","italic":false}' % esc(ln))
    return "[" + ",".join(out) + "]"


def line(uid, label, note, items):
    return ('data modify storage zx:config oldef."%s" set value {label:"%s",'
            'name:{"text":"%s","bold":true,"color":"%s"},note:"%s",'
            'dmg:0.0,mana:0.0,cd:0.0,lore:%s}\n'
            % (uid, esc(label), esc(label), OL_COLOR[uid], esc(note), lore_json(items)))


if __name__ == '__main__':
    # ★ 幂等(2026-10-10 加): 追加模式最怕"跑第二遍重复追加" —— 重复的 oldef 行后写覆盖
    #   前写, 表面看不出问题, 但文件越长越容易撞行数上限, 而且 _chk_lore 会数重复条目。
    #   所以先读一遍磁盘, 已经有这个 id 的直接跳过, 只补缺的。
    disk = io.open(LOAD, encoding='utf-8').read()
    added = 0
    with io.open(LOAD, 'a', encoding='utf-8', newline='\n') as f:
        for (uid, label, note, items) in DEFS:
            if ('oldef."%s"' % uid) in disk:
                print('skip(已存在)', uid)
                continue
            f.write(line(uid, label, note, items))
            added += 1
            print('ok', uid)
    print('新增 %d 条' % added)
