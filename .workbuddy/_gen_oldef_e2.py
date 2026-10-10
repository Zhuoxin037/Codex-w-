# -*- coding: utf-8 -*-
"""批量生成「批 E2 · 超限·剑」四条 oldef 定义行(2026-10-08)

【只做一件事】往 overlimit/def/load.mcfunction 末尾追加 `oldef."<id>"` 那一行。
为什么不手抄: lore 要按 lore_fmt 的同一套折行(半角宽 37 ≈ 18.5 汉字), 手抄
必然和磁盘上已有的那条对不齐, 跑 lore_fmt 又会把它改一遍 => 静默漂移。

【口径】lore 正文 = 用户原文逐字照抄(只按 lore_fmt 折行, 不改字、不缩写)。
【三乘区】这四件都是"整段换描述 + 私有钩子改机制", 不走 dmg/mana/cd 乘区,
   所以全写 0.0(和批 E1 的三条一致)。
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
OL_COLOR = {"everfrost": "aqua", "flame_brokenbody": "red",
            "sickle_dreams": "dark_purple", "hengdao": "blue"}

#  id,             label,      note,                 段列表[(段标题 or None, 魔力, 冷却, 正文)]
DEFS = [
    ("everfrost", "超限·永霜", "8 个->全部; 新增每秒目标最大生命 ×0.03 真实伤害(最多10秒); 收尾 ×0.1->×0.15", [
        ("✦ 主动技能", "200", "30 秒",
         "冰冻自身 5 格范围内的全部生物 3 秒，之后每秒对被冰冻的生物造成一次"
         "相当于其最大生命值 ×0.03 的真实伤害（最多 10 秒），并在结束后对被冰冻"
         "的生物造成相当于自身当前魔力值 ×0.15 的伤害。"),
    ]),
    ("flame_brokenbody", "超限·“烈火，残躯”", "触发条件放宽到「流火」或「夜火」; 若有「流火」则转化为「夜火」", [
        ("✦ 主动技能", "350", "12 秒",
         "使用后对前方 5*3 范围内的生物造成一次相当于自身最大魔力值 ×0.1 的伤害，"
         "若攻击到的生物附有「流火」或「夜火」则该技能冷却时间立即结束，且若有"
         "「流火」则转化为「夜火」，每有一个「夜火」则吸收并为自身积攒一点"
         "「熔浆」。若自身释放技能时「熔浆」大于或等于 4 层则本次技能强化为对"
         "前方 5*3 范围内的生物造成两次相当于自身最大魔力值 ×0.1 的伤害，之后再"
         "对自身 6 格内的生物造成相当于自身最大魔力值 ×0.2 的伤害，之后清除"
         "「熔浆」。"),
    ]),
    ("sickle_dreams", "超限·引梦镰", "强化那一下 ×0.2 -> ×0.25(其余同基础版)", [
        ("✦ 主动技能", "300", "5 秒",
         "使用后立即对自身前方 2*3 范围内的生物造成一次相当于自身最大魔力值"
         " ×0.05 的伤害并附加「噬心」。若对有「噬心」的生物造成伤害则本次伤害"
         "强化为对自身前方 3*5 范围内的生物造成相当于自身最大魔力值 ×0.25 的"
         "伤害并时停 2 秒，之后移除「噬心」。"),
    ]),
    ("hengdao", "超限·横刀", "×0.08 打 2 格一次 -> ×0.1 打 5 格两次; 新增击杀重置冷却", [
        ("✦ 主动技能", "15", "20 秒",
         "使用后向前突击最多 3 格，若碰到生物或障碍物则立即停下并对附近 5 格内的"
         "全部生物造成两次相当于自身最大魔力值 ×0.1 的伤害。若击杀生物则重置"
         "冷却时间。"),
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
