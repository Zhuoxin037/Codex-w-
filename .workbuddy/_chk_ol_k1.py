# -*- coding: utf-8 -*-
"""_chk_ol_k1.py —— 超限机制 批 K1(剑: 曳步 / 潮痕 / 灰度)自检

这四条都是**静默死**, 不报错、日志里也看不出来, 只能静态抓:

  ① 分流判据写错 id —— cast/hit 里判 `ol:"xx"` 判的不是这一件, 敲了超限也走原版。
     (真实事故: 只判 `.ol` 键在不在 => 副手拿着**别的**超限武器时误走超限分支。)
  ② 引用了不存在的函数 —— 整条链在这里断, 前面扣的蓝和冷却照扣。
  ③ 用了没在 core/load 声明的计分项 —— 分数永远不存在, `if score` 恒假(不报错)。
  ④ 查询半径和打标记半径不一致 —— "命中后清不掉"那类事故的根。

用法: python .workbuddy/_chk_ol_k1.py
"""
import io
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"

# 本批新增/改动涉及的文件(相对 function/ 的路径)
FILES = [
    "equipment/sword/yebu/hit.mcfunction",
    "equipment/sword/yebu/slow.mcfunction",
    "equipment/sword/yebu/ol_slow.mcfunction",
    "equipment/sword/yebu/ol_stack.mcfunction",
    "equipment/sword/yebu/ol_bind.mcfunction",
    "equipment/sword/yebu/ol_bind_end.mcfunction",
    "equipment/sword/yebu/ol_bind_dim.mcfunction",
    "equipment/sword/yebu/ol_bind_sweep.mcfunction",
    "equipment/sword/tidemark/cast.mcfunction",
    "equipment/sword/tidemark/overlimit.mcfunction",
    "equipment/sword/tidemark/ol_strike.mcfunction",
    "equipment/sword/tidemark/ol_area.mcfunction",
    "equipment/sword/tidemark/ol_apply.mcfunction",
    "equipment/sword/grayscale/cast.mcfunction",
    "equipment/sword/grayscale/overlimit.mcfunction",
    "equipment/sword/grayscale/ol_mark_burn.mcfunction",
    "station/api/apply_go.mcfunction",
    "lib/second.mcfunction",
]

bad = []
texts = {}
for rel in FILES:
    p = os.path.join(FN, rel.replace("/", os.sep))
    if not os.path.exists(p):
        bad.append("缺文件: %s" % rel)
        continue
    texts[rel] = io.open(p, encoding="utf-8").read()

# ---- ③ 计分项声明 ----
load = io.open(os.path.join(FN, "core", "load.mcfunction"), encoding="utf-8").read()
declared = set(re.findall(r'scoreboard objectives add (zx\.[A-Za-z0-9_.]+)', load))
used = set()
for rel, t in texts.items():
    for ln in t.split("\n"):
        s = ln.strip()
        if s.startswith("#"):
            continue
        # ★ 计分项名允许带点(zx.tt.yuanhai) —— 用 \w+ 会在第一个点处截断,
        #   于是"把 zx.tt.yuanha 拼错"这种错两边都被截成 zx.tt, 检查变成空转。
        for m in re.finditer(r'\bzx\.([A-Za-z0-9_.]+)', s):
            name = "zx." + m.group(1).rstrip(".")
            # 只看计分项上下文, 别把 zx.meta / 存储键当计分项
            if name == "zx.meta":
                continue
            if re.search(r'(scoreboard players|if score|unless score|store result score|store success score)[^#]*'
                         + re.escape(name), s):
                used.add(name)
for name in sorted(used - declared):
    bad.append("计分项 %s 被用到但 core/load 没有声明(分数永不存, if score 恒假)" % name)

# ---- ② 函数引用 ----
for rel, t in texts.items():
    for ln in t.split("\n"):
        s = ln.strip()
        if s.startswith("#"):
            continue
        for m in re.finditer(r'function (sweetdream:[A-Za-z0-9_/]+)', s):
            path = m.group(1).split(":", 1)[1]
            if not os.path.exists(os.path.join(FN, path.replace("/", os.sep) + ".mcfunction")):
                bad.append("%s: 引用了不存在的函数 sweetdream:%s" % (rel, path))

# ---- ① 分流判据 ----
for wid in ("yebu", "tidemark", "grayscale"):
    for rel in ("equipment/sword/%s/hit.mcfunction" % wid,
                "equipment/sword/%s/cast.mcfunction" % wid):
        t = texts.get(rel)
        if t is None:
            continue
        tag = 'ol:"%s"' % wid
        if tag not in t:
            bad.append("%s: 没有判 `%s` 的超限分流(敲了石头也走原版)" % (rel, tag))
        for hand in ("weapon.mainhand", "weapon.offhand"):
            if hand not in t:
                bad.append("%s: 分流没判 %s(副手拿超限武器时会被当成原版)" % (rel, hand))

# 曳步: 分流必须排在 slow 的 ① 之前, 否则永远走不到
sy = texts.get("equipment/sword/yebu/slow.mcfunction", "")
i_branch = sy.find("ol_slow")
i_first = sy.find("# ① 升级")
if i_branch < 0 or i_first < 0 or i_branch > i_first:
    bad.append("yebu/slow: 超限分流没有排在 ① 之前(会被原版分支吞掉)")

# ---- ④ 潮痕: 采样点数量 / 半径一致 ----
st = texts.get("equipment/sword/tidemark/ol_strike.mcfunction", "")
n_area = st.count("tidemark/ol_area with storage zx:work tm")
if n_area != 9:
    bad.append("tidemark/ol_strike: 采样球 %d 个, 应该是 9 个(3 纵 × 3 横)" % n_area)
ar = texts.get("equipment/sword/tidemark/ol_area.mcfunction", "")
rad = set(re.findall(r'distance=\.\.([0-9.]+)', ar))
if rad != {"1.05"}:
    bad.append("tidemark/ol_area: 打人半径/打标记半径不是同一个 1.05(实际 %s)" % sorted(rad))

# ---- 灰度: "已在烧"必须在主伤之前判 ----
go = texts.get("equipment/sword/grayscale/overlimit.mcfunction", "")
i_mark = go.find("ol_mark_burn")
i_dmg = go.find('target:"@e[tag=zx.gs_hit,distance=0..]"')
if i_mark < 0 or i_dmg < 0 or i_mark > i_dmg:
    bad.append("grayscale/overlimit: ol_mark_burn 没有排在主伤之前(主伤后再判 => 所有人都算'已在烧')")
if "max_mana_mul:0.1" not in go or "max_mana_mul:0.08" not in go:
    bad.append("grayscale/overlimit: 主伤 0.1 / 真伤 0.08 两条 max_mana_mul 不全")
if go.count("function manacore:api/damage/calc") != 2:
    bad.append("grayscale/overlimit: 必须两次 calc(主伤 + 真伤各一次), 实际 %d 次"
               % go.count("function manacore:api/damage/calc"))

# ---- 灰度 tags: cur_mana -> max_mana 必须在 append overlimit 之前 ----
ag = texts.get("station/api/apply_go.mcfunction", "")
i_tg = ag.find('of:"grayscale"')
i_ap = ag.find('append value "overlimit"')
if i_tg < 0:
    bad.append("apply_go: 没有灰度超限的 tags 换基数那一行(cur_mana 不会变 max_mana)")
elif "max_mana" not in ag[i_tg:i_tg + 400]:
    bad.append("apply_go: 灰度那一行里没有 max_mana")
elif i_ap > 0 and i_tg > i_ap:
    bad.append("apply_go: 灰度换 tags 排在 append overlimit 之后(会把 overlimit 冲掉)")

print("\n".join(bad) if bad else "OK")
print("bad = %d" % len(bad))
