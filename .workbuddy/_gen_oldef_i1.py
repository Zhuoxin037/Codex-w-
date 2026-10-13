# -*- coding: utf-8 -*-
"""生成「批 I1 · 超限·电弧 / 火种 / 崩裂 / 共鸣」的 oldef 定义行(2026-10-12)

【只做一件事】往 overlimit/def/load.mcfunction **末尾追加** `oldef."<id>"` 那一行。
【★★ 追加模式但幂等 ★★】已有这个 id 的直接跳过(照 _gen_oldef_gh 的写法)。
【口径】lore 正文 = 用户原文逐字照抄(只按 lore_fmt 折行 + nfmt 规范 ×/空格)。
【三乘区】四件全是"机制型"超限 —— 数值写死在武器自己的钩子里, dmg/mana/cd 全 0.0。
【段结构】与各件基础 give 的排版一致(空行是排版的一部分):
  arc     = ✦ 主动技能(魔力 30) + 正文
  tinder  = ✦ 火种 + 正文(燃烧/熄灭) + 正文(手持充能)
  fissure = ✦ 主动技能(魔力 150 · 冷却 40 秒) + 正文
  chime   = ✦ 普攻(12/7) + ✦ 主动技能(140/40 秒) + 正文 + ✦ 共鸣水晶 + 正文
【★ 颜色 = 该装备本名的颜色 ★】arc=aqua / tinder=red / fissure=gray / chime=aqua
  (见各自 give.mcfunction 的 item_name.color; _fix_oldef_colors.py 会反查)
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lore_fmt import nfmt, tw, wrap  # noqa: E402

LOAD = "D:/数据包/sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction"

OL_COLOR = {"arc": "aqua", "tinder": "red", "fissure": "gray", "chime": "aqua"}

TITLE = "✦ 主动技能"
TITLE_P = "✦ 被动技能"

# 用户原文(超限后的"基础属性"，逐字；* 与半角数字交给 nfmt 规范)
ARC = ("每次射击都会对被攻击的生物附加「电刺」效果。若附有「电刺」的生物 8 格内有"
       "另一个附有「电刺」的生物，则每秒都会在他们之间产生一道 3 格宽的电线并对"
       "沿途的生物及他们自身 1 格内的全部生物造成一次相当于自身基础攻击力 *2+ "
       "当前魔力值 *0.03 的伤害并召唤闪电，持续 3 秒。之后移除「电刺」。")

# ★ "并熄灭该武器" —— 设计文档初稿漏写, 2026-10-12 用户确认补回
#   (原稿只写到"…燃烧 5 秒，且使附有「夜火」的生物额外受到一次伤害。" ⇒ 会被读成
#    "点燃后永久燃烧"; 补回后超限版与基础版一样: 打一发就熄。详见 burn ③)
TINDER_BURN = ("「火种」为燃烧状态时，攻击生物时将会对其 3 格内的全部生物造成相当于"
               "自身最大魔力值 *0.1 的伤害，之后使未处于燃烧状态的生物燃烧 5 秒并"
               "熄灭该武器，且使附有「夜火」的生物额外受到一次伤害。为熄灭状态时，"
               "攻击生物后会对自身造成相当于自身最大生命值 *0.3 的伤害并使「火种」"
               "变为燃烧状态。")
TINDER_HAND = ("手持时，若自身魔力值大于 400 且「火种」为熄灭状态则消耗 350 点魔力"
               "值并使「火种」变为燃烧状态。")

FISSURE = ("立即对自身前方 8 格的生物造成一次相当于自身基础攻击力 *6 的伤害并形成一个"
           "持续 8 秒的裂缝。之后在裂缝处的生物将每秒受到一次相当于释放者基础攻击力"
           "的伤害。在裂缝上的生物将无法离开裂缝。")

CHIME_CAST = "使用后召唤一个术阵。之后在原地生成一个“共鸣水晶”。"
CHIME_CRYSTAL = ("其每 2 秒都会对其 6 格内的一个生物造成一次相当于自身最大魔力值 "
                 "*0.05 的伤害。自身释放的法术穿过“共鸣水晶”时会立即对其 5 格内的"
                 "全部生物及释放者 3 格内的全部生物造成一次相当于自身最大魔力值 "
                 "*0.1 的伤害。“共鸣水晶”在另一个“共鸣水晶”被召唤出来后或 18 秒后"
                 "自毁。自毁时会吸引一次其 5 格内的全部生物并造成相当于自身当前魔力"
                 "值 *0.2 的伤害。")

#  条目种类:
#    ("head", 标题) / ("pair", [(text, color), ...]) / ("body", 正文) / ("spacer",)
DEFS = [
    # ---- 超限·电弧: 弩无右键 -> 只有一条"主动技能"段(魔力 30 是每发扣的) ----
    ("arc", "超限·电弧",
     "8 格内配对(原 6); 电线 1->3 格宽; 沿途 + 双方 1 格内全部生物; "
     "每秒一次持续 3 秒 + 召唤闪电(原: 命中即刻一次); 之后移除「电刺」", [
         ("head", TITLE),
         ("pair", [("魔力 ", "gray"), ("30", "aqua")]),
         ("spacer",),
         ("body", ARC),
     ]),
    # ---- 超限·火种: 整段换「火种」(没有右键) ----
    ("tinder", "超限·火种",
     "燃烧态: 2->3 格, 当前魔力 -> 最大魔力 ×0.1, 附「夜火」者额外一次伤害; "
     "熄灭态: 自伤最大生命 ×0.3 并转燃烧; 手持魔力>400 且熄灭 -> 耗 350 转燃烧", [
         ("head", "✦ 火种"),
         ("body", TINDER_BURN),
         ("spacer",),
         ("body", TINDER_HAND),
     ]),
    # ---- 超限·崩裂: 主动技能整段换(魔力/冷却照旧) ----
    ("fissure", "超限·崩裂",
     "前方 5->8 格; ×5->×6; 裂缝 5->8 秒; 裂缝内每秒 1 倍不变; "
     "新增「在裂缝上的生物无法离开裂缝」", [
         ("head", TITLE),
         ("pair", [("魔力 ", "gray"), ("150", "aqua"), ("   ·   ", "dark_gray"),
                   ("冷却 ", "gray"), ("40 秒", "yellow")]),
         ("spacer",),
         ("body", FISSURE),
     ]),
    # ---- 超限·共鸣: 普攻不变 -> 主动整段换 + 「共鸣水晶」单独分段 ----
    ("chime", "超限·共鸣",
     "水晶 ×0.03->×0.05; 穿过 3->5 格 ×0.05->×0.1 且加释放者 3 格内; "
     "8->18 秒自毁; 新增「另一个水晶被召唤即自毁」; 自毁吸引 5 格内 + 当前魔力 ×0.2", [
         ("head", "✦ 普攻"),
         ("pair", [("魔力 ", "gray"), ("12", "aqua"), ("   ·   ", "dark_gray"),
                   ("伤害 ", "gray"), ("7", "yellow")]),
         ("spacer",),
         ("head", TITLE),
         ("pair", [("魔力 ", "gray"), ("140", "aqua"), ("   ·   ", "dark_gray"),
                   ("冷却 ", "gray"), ("40 秒", "yellow")]),
         ("spacer",),
         ("body", CHIME_CAST),
         ("spacer",),
         ("head", "✦ 共鸣水晶"),
         ("body", CHIME_CRYSTAL),
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
                # ★ 折行走 lore_fmt 的**全局**口径(中文引号 “ ” 不在 PAIRS 里,
                #   所以 “共鸣水晶” 可能与收尾引号分居两行 —— 这是全包既有现象,
                #   check.py 的 lore 规则就是拿这套口径比对的, 别在这里单独打补丁)。
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
