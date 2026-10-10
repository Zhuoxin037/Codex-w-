# -*- coding: utf-8 -*-
"""生成「批 G/H · 超限·法杖/盔甲」的 oldef 定义行(2026-10-10)

【只做一件事】往 overlimit/def/load.mcfunction **末尾追加** `oldef."<id>"` 那一行。
【★★ 追加模式但幂等 ★★】已有这个 id 的直接跳过(照 _gen_oldef_f2 的 2026-10-10 版)。
【口径】lore 正文 = 用户原文逐字照抄(只按 lore_fmt 折行 + nfmt 规范 ×/空格)。
【三乘区】四件全是"改写被动/新机制", 不走 dmg/mana/cd 乘区, 全 0.0。
【段结构】与各件基础 give 的排版一致(空行是排版的一部分)。
【★ 颜色 = 该装备本名的颜色 ★】begonia=dark_blue / polarized_light=white /
   dionysus_helmet=gold / furnace_core=red(见各自 give.mcfunction 的 item_name.color)。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, tw, wrap  # noqa: E402

LOAD = "D:/数据包/sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction"

OL_COLOR = {"begonia": "dark_blue", "polarized_light": "white",
            "dionysus_helmet": "gold", "furnace_core": "red"}

TITLE = "✦ 主动技能"
TITLE_P = "✦ 被动技能"

#  条目种类:
#    ("head", 标题) / ("info", 魔力, 冷却) / ("pair", [(text, color), ...])
#    / ("body", 正文) / ("spacer",)
#  正文里以 ● 开头的走 ● 折行(续行缩进 3 空格, 与 lore_fmt.rebuild 同口径)。
DEFS = [
    # ---- 超限·海棠: "基础属性**新加**" => 基础全段原样保留 + 追加新段(照寒鸦范式) ----
    ("begonia", "超限·海棠",
     "漩涡: 范围 4格->6格(scale 8->12); 有生物死在范围内 => 漩涡增强"
     "(增强期间站在 6 格内施最大魔力值技能 +20%, 加算进 mm 通道); "
     "结束时对 6 格内全部 ×0.25 且给中心 2 格附加「渊海」(不再清除); 冷却 -12 秒", [
         ("head", "✦ 普攻"),
         ("pair", [("魔力 ", "gray"), ("30", "aqua"), ("   ·   ", "dark_gray"),
                   ("伤害 ", "gray"), ("自身当前魔力 ×0.02", "yellow")]),
         ("spacer",),
         ("body", "每次普攻命中后都会使其轻微吸引一次其 1 格内的至多 3 个生物。"),
         ("spacer",),
         ("head", TITLE),
         ("pair", [("魔力 ", "gray"), ("450", "aqua"), ("   ·   ", "dark_gray"),
                   ("冷却 ", "gray"), ("120 秒", "yellow")]),
         ("spacer",),
         ("body",
          "使用后召唤一个术阵。之后使自身 16 格内的最多 5 个附有「渊海」的生物"
          "以自身为中心生成一个漩涡。漩涡每秒都会将 4 格内的全部生物拉回中心"
          "一段距离，持续 8 秒。漩涡消失后会对处于中心的生物造成相当于释放者"
          "最大魔力值 ×0.15 的伤害。之后清除「渊海」。"),
         ("spacer",),
         ("body",
          "若有生物在漩涡范围内死亡，则对该漩涡进行增强：在漩涡内使用关于最大"
          "魔力值的技能时造成的伤害提升 20%。将漩涡范围扩大为 6 格，且爆炸后"
          "会对漩涡内全部生物造成相当于自身最大魔力值 ×0.25 的伤害并使处于中心"
          "的生物附加「渊海」，之后该技能冷却时间 -12 秒。"),
     ]),
    # ---- 超限·偏振光: "变为" => 整段换描述(普攻不变 + 主动整段换) ----
    ("polarized_light", "超限·偏振光",
     "一道->三道光线(12 格内最近 3 个); 每秒->每 0.5 秒一次; 缓慢Ⅱ->缓慢Ⅲ;"
     "范围 10 格->12 格; 倍率仍 ×0.05(频率翻倍)", [
         ("head", "✦ 普攻"),
         ("pair", [("魔力 ", "gray"), ("10", "aqua"), ("   ·   ", "dark_gray"),
                   ("伤害 ", "gray"), ("6", "yellow")]),
         ("spacer",),
         ("head", TITLE),
         ("pair", [("魔力 ", "gray"), ("80", "aqua"), ("   ·   ", "dark_gray"),
                   ("冷却 ", "gray"), ("20 秒", "yellow")]),
         ("spacer",),
         ("body",
          "使用后召唤一个术阵。之后自身持续发射三道光线并每 0.5 秒对自身 12 格内"
          "离自己最近的三个生物造成一次相当于自身当前魔力值 ×0.05 的伤害，且被"
          "锁定的生物获得缓慢Ⅲ效果。该效果持续 5 秒。"),
     ]),
    # ---- 超限·狄俄尼索斯之桂冠: "变为" => 被动整段重写 + 「酒浆」单独分段 ----
    ("dionysus_helmet", "超限·狄俄尼索斯之桂冠",
     "魔力上限 200->240; 受伤被动加「酒浆」+1(<=10)且回魔 80->60; "
     "新增攻击触发: 酒浆>=5 消耗 5 层 -> 力量Ⅴ + 技能伤害+30%(3秒) + 酒浆+1 + "
     "回魔 80/秒×3秒 + 每秒瞬间治疗Ⅳ 共 5 秒(期间不可再触发)", [
         ("head", TITLE_P),
         ("body",
          "自身魔力值上限 +240。自身受到伤害后有 20% 的概率会获得反胃Ⅱ和力量Ⅲ"
          "效果，之后获得一层「酒浆」（最多 10 层），并且自身每秒恢复 60 点魔力值，"
          "持续 3 秒。"),
         ("spacer",),
         ("head", "✦ 酒浆"),
         ("body",
          "自身攻击生物时，若自身「酒浆」达到 5 层以上则消耗 5 层「酒浆」，之后"
          "触发该装备的被动效果且强化为获得力量Ⅴ效果，且自身技能伤害提升 30%，"
          "之后获得一层「酒浆」，并且自身每秒恢复 80 点魔力值，之后每秒获得一次"
          "瞬间治疗Ⅳ，持续 5 秒（持续期间不可再次触发）。"),
     ]),
    # ---- 超限·炉心: "变为" => 被动数值改写 + 燃灰新增 12 层冻结 ----
    ("furnace_core", "超限·炉心",
     "基础 100/10/5 -> 150/15/8; 上限 10->12 层; X 最低 3->4 / Y 最低 5->7; "
     "新增: 12 层时 12 秒不减层, 结束后直接降到 8 层", [
         ("head", TITLE_P),
         ("body", "自身魔力值上限 +150，最大生命值 +15，基础攻击力 +8。"),
         ("spacer",),
         ("head", "✦ 燃灰"),
         ("body",
          "自身每攻击一次处于燃烧状态的生物则积攒一层「燃灰」（最大为 12 层）。"
          "每有一层「燃灰」则自身魔力值上限 +30，基础攻击力 +X（X 为自身当前"
          "基础攻击力 ×0.1，最低为 4），最大生命值 +Y（Y 为自身当前最大生命值 "
          "×0.1，最低为 7），且每秒恢复 1 点魔力值。「燃灰」每 3 秒 -1 层。"
          "若「燃灰」达到 12 层则「燃灰」在 12 秒内将不再减少层数。之后自身"
          "「燃灰」层数降至 8 层。"),
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
        elif kind == "info":
            out.append('{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},'
                       '{"text":"%s","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},'
                       '{"text":"冷却 ","color":"gray"},{"text":"%s","color":"yellow"}]}'
                       % (it[1], it[2]))
        elif kind == "pair":
            extra = ",".join('{"text":"%s","color":"%s"}' % (esc(t), c) for (t, c) in it[1])
            out.append('{"text":"","italic":false,"extra":[%s]}' % extra)
        elif kind == "spacer":
            out.append('{"text":" ","italic":false}')
        else:
            text = nfmt(it[1])
            if text.startswith('●'):
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
