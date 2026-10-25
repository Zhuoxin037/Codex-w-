# -*- coding: utf-8 -*-
"""_chk_ol_k2.py —— 超限机制 批 K2(剑: 回锋 / 退汐 / 剖心)自检

这批几乎全是**静默死**: 不报错、日志干净、只有玩起来"没变化"。静态能抓的有:

  ① 分流判据写错 —— 判 `ol:"xx"` 判的不是这一件 / 只判 .ol 键在不在。
  ② 引用了不存在的函数 —— 链条在那一行断掉(前面扣的蓝和冷却照扣)。
  ③ 用了没在 core/load 声明的计分项 —— 分数永不存在, `if score` 恒假。
  ④ 顺序错: 回锋的倍率必须在「断刃」清零**之前**算(清零在 cast ⑧);
     剖心的"相等伤害"必须在 half 档**之后**覆盖(否则被默认值冲掉)。
  ⑤ 数值没落地: 80/50/4、0.12、6 格、3 格、2×8、1.5、-3 秒、-10 秒。

用法: python .workbuddy/_chk_ol_k2.py
"""
import io
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"

FILES = [
    "equipment/sword/rebound/hit.mcfunction",
    "equipment/sword/rebound/cast.mcfunction",
    "equipment/sword/rebound/recalc.mcfunction",
    "equipment/sword/backflow_tide/cast.mcfunction",
    "equipment/sword/backflow_tide/area.mcfunction",
    "equipment/sword/backflow_tide/dom_one.mcfunction",
    "equipment/sword/backflow_tide/push_one.mcfunction",
    "equipment/sword/profane/hit.mcfunction",
    "equipment/sword/profane/cast.mcfunction",
    "equipment/sword/profane/cd.mcfunction",
    "equipment/sword/profane/one_shixin.mcfunction",
    "equipment/sword/profane/ol_prev_cd.mcfunction",
]

bad = []
texts = {}
for rel in FILES:
    p = os.path.join(FN, rel.replace("/", os.sep))
    if not os.path.exists(p):
        bad.append("缺文件: %s" % rel)
        continue
    texts[rel] = io.open(p, encoding="utf-8").read()


def body(t):
    """去掉注释行后的命令正文(注释里写 `ol:"x"` 不算数)。"""
    return "\n".join(l for l in t.split("\n") if not l.strip().startswith("#"))


# ---- ③ 计分项声明 ----
load = io.open(os.path.join(FN, "core", "load.mcfunction"), encoding="utf-8").read()
declared = set(re.findall(r'scoreboard objectives add (zx\.[A-Za-z0-9_.]+)', load))
used = set()
for rel, t in texts.items():
    for s in body(t).split("\n"):
        s = s.strip()
        for m in re.finditer(r'\bzx\.([A-Za-z0-9_.]+)', s):
            name = "zx." + m.group(1).rstrip(".")
            if name == "zx.meta":
                continue
            if re.search(r'(scoreboard players|if score|unless score|store result score|store success score)[^#]*'
                         + re.escape(name), s):
                used.add(name)
for name in sorted(used - declared):
    bad.append("计分项 %s 被用到但 core/load 没声明(分数永不存, if score 恒假)" % name)

# ---- ② 函数引用 ----
for rel, t in texts.items():
    for s in body(t).split("\n"):
        for m in re.finditer(r'function (sweetdream:[A-Za-z0-9_/]+)', s):
            path = m.group(1).split(":", 1)[1]
            if not os.path.exists(os.path.join(FN, path.replace("/", os.sep) + ".mcfunction")):
                bad.append("%s: 引用了不存在的函数 sweetdream:%s" % (rel, path))

# ---- ① 分流判据 ----
for wid, rels in (
    ("rebound", ["equipment/sword/rebound/hit.mcfunction",
                 "equipment/sword/rebound/cast.mcfunction"]),
    ("backflow_tide", ["equipment/sword/backflow_tide/cast.mcfunction"]),
    ("profane", ["equipment/sword/profane/hit.mcfunction",
                 "equipment/sword/profane/cast.mcfunction"]),
):
    tag = 'ol:"%s"' % wid
    for rel in rels:
        t = texts.get(rel)
        if t is None:
            continue
        b = body(t)
        if tag not in b:
            bad.append("%s: 没有判 `%s` 的超限分流(敲了石头也走原版)" % (rel, tag))
        for hand in ("weapon.mainhand", "weapon.offhand"):
            if hand not in b:
                bad.append("%s: 分流没判 %s(副手拿超限武器时会被当成原版)" % (rel, hand))

# ---- ⑤ 回锋: 80 / 50 / 4 + 倍率表 ----
rh = body(texts.get("equipment/sword/rebound/hit.mcfunction", ""))
for want, why in (("#rb_need zx.meta 80", "门槛 80"), ("#rb_cost zx.meta 50", "消耗 50"),
                  ("#rb_cap zx.meta 4", "上限 4")):
    if want not in rh:
        bad.append("rebound/hit: 缺超限档 %s" % why)
if "< #rb_need" not in rh:
    bad.append("rebound/hit: 门槛比较没改成计分项(还是写死的 ..49)")
if ">= #rb_cap" not in rh:
    bad.append("rebound/hit: 上限比较没改成计分项(还是写死的 matches 3..)")

rc = body(texts.get("equipment/sword/rebound/cast.mcfunction", ""))
if "zx.rb_omul 32000" not in rc:
    bad.append("rebound/cast: 4 层对应的 ×32(32000 千分比)没落地")
i_mul = rc.find("zx.rb_omul")
i_clr = rc.find("scoreboard players set @s zx.rb_blade 0")
i_dmg = rc.find("rebound/recalc")
if i_mul < 0:
    bad.append("rebound/cast: 没有任何倍率计算")
elif i_clr > 0 and i_mul > i_clr:
    bad.append("rebound/cast: 倍率算在「断刃」清零之后(层数已变 0, 永远是 ×2)")
elif i_dmg > 0 and i_mul > i_dmg:
    bad.append("rebound/cast: 倍率算在 recalc 之后(这一发用的还是旧值)")

rr = body(texts.get("equipment/sword/rebound/recalc.mcfunction", ""))
if "double 0.001" not in rr or "zx.rb_omul" not in rr:
    bad.append("rebound/recalc: 没把千分比换算成 attack_mul(double 0.001)")

# ---- ⑤ 退汐: 6 格 / ×0.12 / 3 格击退 ----
bc = body(texts.get("equipment/sword/backflow_tide/cast.mcfunction", ""))
if "max_mana_mul set value 0.12" not in bc:
    bad.append("backflow_tide/cast: 超限额外段 ×0.12 没落地")
if "dx=6.0,dy=2.6,dz=6.0" not in bc:
    bad.append("backflow_tide/cast: 门槛没盖住 6×6(会漏判站在走廊边上的目标)")
ba = body(texts.get("equipment/sword/backflow_tide/area.mcfunction", ""))
if "dx=6.0,dy=2.6,dz=6.0" not in ba:
    bad.append("backflow_tide/area: 超限覆盖不是 6×6")
if "dx=4.0,dy=2.6,dz=4.0" not in ba:
    bad.append("backflow_tide/area: 非超限的 4×4 分支被弄丢了")
bp = body(texts.get("equipment/sword/backflow_tide/push_one.mcfunction", ""))
if r"^ ^ ^-3" not in bp:
    bad.append("backflow_tide/push_one: 没有推到第 3 格的命令")

# ---- ⑤ 剖心: 2×8 / 1.5 / 相等伤害 / -3 秒 / -10 秒 ----
pc = body(texts.get("equipment/sword/profane/cast.mcfunction", ""))
if r"^ ^ ^8.0" not in pc:
    bad.append("profane/cast: 剖线没补到 8 格")
if "independent_multiplier set value 1.5" not in pc:
    bad.append("profane/cast: 超限独立乘区不是 1.5(+50%)")
if "pf.ol set value 1b" not in pc:
    bad.append("profane/cast: 没往 zx:work pf 里写 ol 标记(one_shixin 判不了超限)")
if "profane/ol_prev_cd" not in pc:
    bad.append("profane/cast: 没调用 ol_prev_cd(>5 个噬心不减前面武器冷却)")
if "#pf_clear zx.meta matches 6.." not in pc:
    bad.append("profane/cast: 触发条件不是 6..(原文是「大于 5 个」)")

os_ = body(texts.get("equipment/sword/profane/one_shixin.mcfunction", ""))
i_half = os_.find("pf.half")
i_ol = os_.find("pf{ol:1b}")
if i_half < 0:
    bad.append("profane/one_shixin: 没先取 half 档")
elif i_ol < 0:
    bad.append("profane/one_shixin: 超限没改成'相等的伤害'")
elif i_ol < i_half:
    bad.append("profane/one_shixin: ol 覆盖排在 half 之前(会被 half 冲回去)")

pcd = body(texts.get("equipment/sword/profane/cd.mcfunction", ""))
if "#pf_per zx.meta 3" not in pcd:
    bad.append("profane/cd: 超限每清一个不是 -3 秒")

pv = body(texts.get("equipment/sword/profane/ol_prev_cd.mcfunction", ""))
n_slot = len(re.findall(r'Inventory\[\{Slot:[0-7]b\}\]', pv))
if n_slot < 8:
    bad.append("profane/ol_prev_cd: 只看了 %d 个前驱槽(剖心最多在第 8 格, 要 0..7)" % n_slot)
if "seconds:10.0" not in pv:
    bad.append("profane/ol_prev_cd: 减的不是 10 秒")
if "SelectedItemSlot" not in pv:
    bad.append("profane/ol_prev_cd: 没读快捷栏选中槽(不知道剖心在第几格)")
if pv.count("data remove storage zx:work pfo.skill") < 8:
    bad.append("profane/ol_prev_cd: 槽位之间没有清 pfo.skill(空槽会顶着上一格的 skill 再减一次)")
if "return" in pv:
    bad.append("profane/ol_prev_cd: 用了 return —— 会整段退出, 后面 7 个槽全不看")

ph = body(texts.get("equipment/sword/profane/hit.mcfunction", ""))
for want in ("#pf_add zx.meta 3", "#pf_cap zx.meta 24"):
    if want not in ph:
        bad.append("profane/hit: 缺超限档 `%s`" % want)

print("\n".join(bad) if bad else "OK")
print("bad = %d" % len(bad))
