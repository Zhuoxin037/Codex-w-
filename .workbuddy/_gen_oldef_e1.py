# -*- coding: utf-8 -*-
"""批量生成「批 E1 · 超限·剑」三条 oldef 定义行(2026-10-08)

【只做一件事】往 overlimit/def/load.mcfunction 末尾追加 `oldef."<id>"` 那一行。
为什么不手抄: lore 要按 lore_fmt 的同一套折行(半角宽 37 ≈ 18.5 汉字), 手抄
必然和磁盘上已有的那条对不齐, 跑 lore_fmt 又会把它改一遍 => 静默漂移。

【口径】lore 正文 = 用户原文逐字照抄(只按 lore_fmt 折行, 不改字、不缩写)。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, wrap  # noqa: E402

LOAD = "D:/数据包/sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction"

# ★ 超限名的颜色 = 该装备**本名**的颜色(2026-10-10 用户要求, 见 overlimit/def/load 头部)。
#   真源是 equipment/**/<id>/give.mcfunction 里的 item_name.color —— 这里只是让重跑
#   生成器时也写对; 改颜色请跑 `python .workbuddy/_fix_oldef_colors.py`, 别手改。
OL_COLOR = {"rogue_star": "white", "shadow_blade": "blue", "deepsea_echo": "blue"}

#  id,             label,      note,                 段列表[(段标题 or None, 魔力, 冷却, 正文)]
#     段标题: "✦ 主动技能" / "✦ 被动技能"; 魔力/冷却 为 None 表示这一段不写消耗行
DEFS = [
    ("rogue_star", "超限·游星", "锁定 3 个->全部, 打 1 次->2 次, 保底 12->16", [
        ("✦ 主动技能", "200", "30 秒",
         "锁定自身 10 格范围内的全部生物，3 秒后对其 2 格内的全部生物造成两次"
         "相当于自身基础攻击力 ×4 的伤害（保底 16 点伤害）。"),
    ]),
    ("shadow_blade", "超限·影刃", "伤害 ×2->×8, 击杀分支: 本武器刷冷却+返100 / 他武器减15秒冷却", [
        ("✦ 主动技能", "120", "40 秒",
         "使用后立即瞬移至自身 10 格内离自身最近的一个生物并对其造成相当于自身"
         "基础伤害 ×8 的伤害。若使用技能后击杀敌人时自身手持该武器则刷新该武器"
         "冷却时间并返还 100 魔力值。若手持的是其他武器则减少手持武器 15 秒主动"
         "技能冷却时间。"),
    ]),
    ("deepsea_echo", "超限·深海的回响", "常驻水下呼吸Ⅰ, 3->4 格, ×0.15->×0.18, 重复耗蓝 110->80, 新增渊海免费再重复", [
        ("✦ 被动技能", None, None,
         "在自身物品栏里时，自身获得常态水下呼吸Ⅰ。"),
        ("✦ 主动技能", "350", "30 秒",
         "使用后标记 12 格内离自身最近的一个生物并使其附加「渊海」。1 秒后对其"
         " 4 格范围内的全部生物造成相当于自身当前魔力值 ×0.18 的伤害，之后标记"
         "受到伤害的生物并重复，但每次重复都会消耗自身 80 魔力值，重复 2 次后"
         "结束。结束后若该技能攻击到了附加了「渊海」的生物则再重复一次，本次"
         "重复不消耗魔力值，之后该生物不再能触发该被动。之后该技能每攻击到附加"
         "了「渊海」的生物都会重复一次。"),
    ]),
]


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def head_json(mana, cd):
    return ('{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},'
            '{"text":"%s","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},'
            '{"text":"冷却 ","color":"gray"},{"text":"%s","color":"yellow"}]}'
            % (mana, cd))


def lore_json(parts):
    out = []
    for (title, mana, cd, body) in parts:
        out.append('{"text":"%s","color":"gold","bold":true,"italic":false}' % esc(title))
        if mana:
            out.append(head_json(mana, cd))
        out.append('{"text":" ","italic":false}')
        for line in wrap(nfmt(body), 37):
            out.append('{"text":"%s","color":"gray","italic":false}' % esc(line))
    return "[" + ",".join(out) + "]"


def line(uid, label, note, parts):
    return ('data modify storage zx:config oldef."%s" set value {label:"%s",'
            'name:{"text":"%s","bold":true,"color":"%s"},note:"%s",'
            'dmg:0.0,mana:0.0,cd:0.0,lore:%s}\n'
            % (uid, esc(label), esc(label), OL_COLOR[uid], esc(note), lore_json(parts)))


if __name__ == '__main__':
    with io.open(LOAD, 'a', encoding='utf-8', newline='\n') as f:
        for (uid, label, note, parts) in DEFS:
            f.write(line(uid, label, note, parts))
            print('ok', uid)
