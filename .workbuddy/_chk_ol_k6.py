# -*- coding: utf-8 -*-
"""_chk_ol_k6.py —— 超限机制 批 K6(斧: 沉锚 / 焦骨 / 重溟 / 陨星)自检

这一批的"不报错、只是不生效"死法:

  ① 分流判据写错 —— 判的不是这一件的 ol 值。
  ② 引用了不存在的函数 —— 链条在那一行断掉(前面扣的蓝和冷却照扣)。
  ③ 计分项没在 core/load 声明 —— 分数永不存在, `if score` 恒假。
  ④ 宏函数调用点漏了 `with storage` —— 报"缺少传入参数", 整条调用失败。
  ⑤ 顺序错:
      · 沉锚的"回到原处"分支必须排在 skill/check **之前**(不查冷却不扣蓝);
        ol_back 第一行就清 anc_back ⇒ 调用方必须先用假玩家拍快照;
      · 焦骨的"附加流火"必须在范围伤害**之后**(否则这一发就被转成夜火);
      · 陨星的大陨石必须排在"清 zx.victim"**之前**;
      · 重溟的领域合并必须**先设半径再 kill 其余**(keep 是随机选的)。
  ⑥ 每刻/每秒的驱动缺失: 沉锚锚点(second) / 领域(second) / 熔星形态(tick)。
  ⑦ 数值没落地: 320/12 格/5 格/×8/击飞 3 格/缓慢Ⅳ/抗性Ⅳ;
                260/25/×8/4 格/0.08/0.12/50%/80%;
                400/0.12/半径 5/6 秒/全部/合并 8·11·14/结束猛拉;
                400/35/12 秒/15%/100%/30%/×8/缓慢Ⅴ。

用法: python .workbuddy/_chk_ol_k6.py
"""
import io
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"

NEW = [
    "equipment/axe/anchor/ol_back.mcfunction",
    "equipment/axe/scorch_bone/ol_refund.mcfunction",
    "equipment/axe/deep_brine/dom_two.mcfunction",
    "equipment/axe/deep_brine/ol_dom_all.mcfunction",
    "equipment/axe/deep_brine/ol_dom_one.mcfunction",
    "equipment/axe/deep_brine/ol_merge.mcfunction",
    "equipment/axe/deep_brine/field_hit.mcfunction",
    "equipment/axe/deep_brine/field_end.mcfunction",
    "equipment/axe/deep_brine/field_end_go.mcfunction",
    "equipment/axe/meteor/ol_big.mcfunction",
    "equipment/axe/meteor/ol_rock.mcfunction",
]

EDIT = [
    "equipment/axe/anchor/cast.mcfunction",
    "equipment/axe/anchor/impact.mcfunction",
    "equipment/axe/anchor/hit.mcfunction",
    "equipment/axe/anchor/ray.mcfunction",
    "equipment/axe/scorch_bone/cast.mcfunction",
    "equipment/axe/scorch_bone/convert.mcfunction",
    "equipment/axe/deep_brine/cast.mcfunction",
    "equipment/axe/deep_brine/field_one.mcfunction",
    "equipment/axe/deep_brine/field_tick.mcfunction",
    "equipment/axe/deep_brine/hit_go.mcfunction",
    "equipment/axe/deep_brine/passive_gate.mcfunction",
    "equipment/axe/meteor/cast.mcfunction",
    "equipment/axe/meteor/tick.mcfunction",
    "equipment/axe/meteor/end.mcfunction",
    "equipment/axe/meteor/hit.mcfunction",
    "equipment/axe/meteor/hit_go.mcfunction",
    "equipment/axe/meteor/fall.mcfunction",
    "lib/second.mcfunction",
    "core/load.mcfunction",
]

bad = []
texts = {}
for rel in NEW + EDIT:
    p = os.path.join(FN, rel.replace("/", os.sep))
    if not os.path.exists(p):
        bad.append("缺文件: %s" % rel)
        continue
    texts[rel] = io.open(p, encoding="utf-8").read()


def body(t):
    return "\n".join(l for l in t.split("\n") if not l.strip().startswith("#"))


def lines(rel):
    return body(texts.get(rel, "")).split("\n")


def where(rel, s):
    for i, l in enumerate(lines(rel), 1):
        if s in l:
            return i
    return -1


def has(rel, s):
    return s in body(texts.get(rel, ""))


# ---- ① 四件的分流判据 ----
for rel, oid in [
    ("equipment/axe/anchor/cast.mcfunction", "anchor"),
    ("equipment/axe/scorch_bone/cast.mcfunction", "scorch_bone"),
    ("equipment/axe/deep_brine/cast.mcfunction", "deep_brine"),
    ("equipment/axe/meteor/cast.mcfunction", "meteor"),
]:
    t = body(texts.get(rel, ""))
    want = 'ol:"%s"' % oid
    if want not in t:
        bad.append("%s: 没有判 `%s` —— 超限分支永远进不去" % (rel, want))
    if "weapon.mainhand" not in t:
        bad.append("%s: 分流没判主手" % rel)
    # ★ 陨星是"必须主手才能放"的持续型主动, 只有触发键判手持 ⇒ 副手不要求
    if "meteor" not in rel and "weapon.offhand" not in t:
        bad.append("%s: 分流没判副手" % rel)

# ---- ② 所有 function 引用必须存在 ----
ref = re.compile(r"function\s+sweetdream:([A-Za-z0-9_/]+)")
missing = set()
for rel in NEW + EDIT:
    for m in ref.finditer(body(texts.get(rel, ""))):
        p = os.path.join(FN, m.group(1).replace("/", os.sep) + ".mcfunction")
        if not os.path.exists(p):
            missing.add("%s -> sweetdream:%s" % (rel, m.group(1)))
for x in sorted(missing):
    bad.append("引用了不存在的函数: " + x)

# ---- ③ 计分项必须在 core/load 声明 ----
LOAD = body(texts.get("core/load.mcfunction", ""))
for obj in ["anc_ol", "anc_back", "anc_bt", "anc_own", "scb_ol", "db_ol", "db_r", "mt_keep"]:
    if "scoreboard objectives add zx.%s " % obj not in LOAD:
        bad.append("core/load: 没有声明 zx.%s —— 分数永不存在, if score 恒假" % obj)

# ============ 沉锚 ============
AC = body(texts["equipment/axe/anchor/cast.mcfunction"])
if "weapon.mainhand" not in AC:
    bad.append("anchor/cast: 没判主手超限")

# "回到原处"分支必须先拍快照再判(ol_back 第一行就清 anc_back)
i_snap = where("equipment/axe/anchor/cast.mcfunction", "#anc_bk zx.meta 1")
i_back = where("equipment/axe/anchor/cast.mcfunction", "equipment/axe/anchor/ol_back")
i_check = where("equipment/axe/anchor/cast.mcfunction", "manacore:api/skill/check")
if i_back < 0:
    bad.append("anchor/cast: 没有「回到原处」的分支")
elif i_snap < 0 or i_snap > i_back:
    bad.append("anchor/cast: 没先拍 #anc_bk 快照 —— ol_back 会清 anc_back, 后面的判断恒假")
if i_check > 0 and i_back > i_check:
    bad.append("anchor/cast: 回程分支排在 skill/check 之后 —— 12 秒冷却会挡住回程")

if "#an_max zx.meta 24" not in AC:
    bad.append("anchor/cast: 超限射程不是 24 步(12 格)")
if "320.0" not in AC:
    bad.append("anchor/cast: 超限没扣 320 蓝")
if "zx.anc_back 4" not in AC:
    bad.append("anchor/cast: 没开 4 秒回程窗口")
if "summon minecraft:marker" not in AC:
    bad.append("anchor/cast: 没钉锚点 marker —— 回程无处可回")

RAY = body(texts["equipment/axe/anchor/ray.mcfunction"])
if "#an_max zx.meta" not in RAY:
    bad.append("anchor/ray: 射程还在用写死的 21 —— 超限 12 格不生效")
if "matches 21.." in RAY:
    bad.append("anchor/ray: 还留着写死的 21 步上限")

OB = body(texts["equipment/axe/anchor/ol_back.mcfunction"])
for s, msg in [
    ("zx.anc_back 0", "回程没关窗口"),
    ("UUID[0]", "回程没按 UUID[0] 认自己的锚点"),
    ("anc_org", "回程没找锚点 marker"),
    ("run tp @s ~ ~ ~", "回程没真的传送"),
]:
    if s not in OB:
        bad.append("anchor/ol_back: " + msg)

IM = body(texts["equipment/axe/anchor/impact.mcfunction"])
for s, msg in [
    ("distance=..2", "普通半径 2 没了"),
    ("distance=..5", "超限半径 5 没落地"),
    ("attack_mul set value 8.0", "超限 ×8 没落地"),
    ("[0.0d,0.55d,0.0d]", "普通击飞 2 格没了"),
    ("[0.0d,0.69d,0.0d]", "超限击飞 3 格没落地"),
    ("minecraft:slowness 5 3", "超限 5 秒缓慢Ⅳ 没落地"),
    ("minecraft:resistance 8 3", "超限 8 秒抗性Ⅳ 没落地"),
    ("scoreboard players add @s zx.anc_ol 0", "没补「没分数≠0」"),
]:
    if s not in IM:
        bad.append("anchor/impact: " + msg)

AH = body(texts["equipment/axe/anchor/hit.mcfunction"])
if "%= #10 zx.meta" not in AH or "#3 zx.meta" not in AH:
    bad.append("anchor/hit: 超限 30% 概率没落地(#rnd %10 对 #3 分界)")
if "^ ^ ^1.5" not in AH:
    bad.append("anchor/hit: 超限「前方 2 格」的范围没扩")

# ============ 焦骨 ============
SC = body(texts["equipment/axe/scorch_bone/cast.mcfunction"])
for s, msg in [
    ("260.0", "超限没扣 260 蓝"),
    ("cooldown_seconds set value 25.0", "超限冷却不是 25 秒"),
    ("attack_mul set value 8.0", "超限主伤不是 ×8"),
    ("distance=..4", "超限溅射半径不是 4"),
    ("#sc_a zx.meta 80", "超限基础溅射不是 ×0.08"),
    ("#sc_a zx.meta 120", "超限夜火档不是 ×0.12"),
]:
    if s not in SC:
        bad.append("scorch_bone/cast: " + msg)

# 顺序: 附加流火必须在范围伤害之后
i_hit = where("equipment/axe/scorch_bone/cast.mcfunction", 'a.target set value "@e[tag=zx.sc_hit')
i_lh = where("equipment/axe/scorch_bone/cast.mcfunction", 'mark:"liuhuo"')
if i_lh < 0:
    bad.append("scorch_bone/cast: 超限没有「附加流火」")
elif i_hit > 0 and i_lh < i_hit:
    bad.append("scorch_bone/cast: 附加流火排在范围伤害之前 —— 这一发当场被转成夜火")

CV = body(texts["equipment/axe/scorch_bone/convert.mcfunction"])
if "#sc_r zx.meta 130" not in CV:
    bad.append("scorch_bone/convert: 超限流火档没返 130(260×50%)")
if "#sc_r zx.meta 40" not in CV:
    bad.append("scorch_bone/convert: 普通档返还 40 被改掉了")

ORF = body(texts["equipment/axe/scorch_bone/ol_refund.mcfunction"])
if "208.0" not in ORF:
    bad.append("scorch_bone/ol_refund: 夜火档没返 208(260×80%)")
if "tag/unmark" in ORF or "tag/mark" in ORF:
    bad.append("scorch_bone/ol_refund: 不该再摘贴标签(夜火档本来就是夜火)")

# ============ 重溟 ============
DC = body(texts["equipment/axe/deep_brine/cast.mcfunction"])
for s, msg in [
    ("400.0", "超限没扣 400 蓝"),
    ("max_mana_mul set value 0.12", "超限立即段不是 ×0.12"),
    ("equipment/axe/deep_brine/ol_dom_all", "超限没走「全部消耗」分支"),
    ("equipment/axe/deep_brine/dom_two", "普通「最多 2 个」分支丢了"),
]:
    if s not in DC:
        bad.append("deep_brine/cast: " + msg)

DOM2 = body(texts["equipment/axe/deep_brine/dom_two.mcfunction"])
if DOM2.count("deep_brine/dom_one") != 2:
    bad.append("deep_brine/dom_two: 不是「就近取 2 个」的两段式")

ODA = body(texts["equipment/axe/deep_brine/ol_dom_all.mcfunction"])
if "ol_dom_one" not in ODA:
    bad.append("deep_brine/ol_dom_all: 没起递归")
ODO = body(texts["equipment/axe/deep_brine/ol_dom_one.mcfunction"])
if "ol_dom_one" not in ODO:
    bad.append("deep_brine/ol_dom_one: 没自递归 —— 只会消耗 1 个")
if "remove zx.db_ysel" not in ODO:
    bad.append("deep_brine/ol_dom_one: 没把已处理的从候选摘掉 —— 会无限递归同一只")

FO = body(texts["equipment/axe/deep_brine/field_one.mcfunction"])
for s, msg in [
    ("zx.db_r 3", "普通领域半径 3 没设"),
    ("zx.db_r 5", "超限领域半径 5 没落地"),
    ("zx.db_ft 6", "超限领域 6 秒没落地"),
    ("zx.db_olm", "超限领域没打 zx.db_olm 标记(结束猛拉/合并都依赖它)"),
    ("deep_brine/ol_merge", "没调领域合并"),
]:
    if s not in FO:
        bad.append("deep_brine/field_one: " + msg)

FT = body(texts["equipment/axe/deep_brine/field_tick.mcfunction"])
if "field_hit with storage zx:work dbr" not in FT:
    bad.append("deep_brine/field_tick: 伤害/拉扯没走宏 —— 半径变了也不生效")
if "distance=..3" in FT:
    bad.append("deep_brine/field_tick: 还留着写死的 distance=..3 半径")
if "field_end" not in FT:
    bad.append("deep_brine/field_tick: 到点没收尾(没有结束猛拉)")

FH = body(texts["equipment/axe/deep_brine/field_hit.mcfunction"])
if "distance=..$(r)" not in FH:
    bad.append("deep_brine/field_hit: 伤害选择器没拼半径")
if "distance=1.01..$(r)" not in FH:
    bad.append("deep_brine/field_hit: 拉扯选择器没拼半径")

FE = body(texts["equipment/axe/deep_brine/field_end.mcfunction"])
if "field_end_go with storage zx:work dbr" not in FE:
    bad.append("deep_brine/field_end: 没走宏(半径拼不进选择器)")
if "kill @s" not in FE:
    bad.append("deep_brine/field_end: 没收掉领域 marker")

FEG = body(texts["equipment/axe/deep_brine/field_end_go.mcfunction"])
if "tag=zx.db_olm" not in FEG:
    bad.append("deep_brine/field_end_go: 没只对超限领域猛拉 —— 普通领域也会多吃一下")
if "^ ^ ^2.5" not in FEG:
    bad.append("deep_brine/field_end_go: 结束猛拉不是 2.5 格")

OM = body(texts["equipment/axe/deep_brine/ol_merge.mcfunction"])
for s, msg in [
    ("sort=nearest,limit=4", "「最多合并 4 个」没落地"),
    ("zx.db_r 8", "合并后半径 8 没落地"),
    ("zx.db_r 11", "合并 3 个半径 11 没落地"),
    ("zx.db_r 14", "合并 4 个半径 14 没落地"),
    ("sort=random,limit=1", "中心不是「随机一个被合并的领域的中心」"),
]:
    if s not in OM:
        bad.append("deep_brine/ol_merge: " + msg)
# 先设后杀: 设半径的行必须排在 kill 之前
i_set = where("equipment/axe/deep_brine/ol_merge.mcfunction", "zx.db_r 8")
i_kill = where("equipment/axe/deep_brine/ol_merge.mcfunction", "run kill @s")
if i_set > 0 and i_kill > 0 and i_set > i_kill:
    bad.append("deep_brine/ol_merge: 先 kill 再设半径 —— keep 可能是被杀的那个, 半径全落空")

PG = body(texts["equipment/axe/deep_brine/passive_gate.mcfunction"])
if "#db_gap zx.meta 60" not in PG:
    bad.append("deep_brine/passive_gate: 超限节流不是 3 秒")
if "#db_gap zx.meta 200" not in PG:
    bad.append("deep_brine/passive_gate: 普通 10 秒节流被改掉了")
HG = body(texts["equipment/axe/deep_brine/hit_go.mcfunction"])
if "#dbp_ol zx.meta 1" not in HG:
    bad.append("deep_brine/hit_go: 没拍超限快照 —— gate 里读不到玩家主手")

# ============ 陨星 ============
MC = body(texts["equipment/axe/meteor/cast.mcfunction"])
for s, msg in [
    ("400.0", "超限没扣 400 蓝"),
    ("cooldown_seconds set value 35.0", "超限冷却不是 35 秒"),
    ("zx.mt_on 12", "超限形态不是 12 秒"),
    ("zx.mt_keep 1", "没拍「换手仍生效」旗标"),
]:
    if s not in MC:
        bad.append("meteor/cast: " + msg)

MT = body(texts["equipment/axe/meteor/tick.mcfunction"])
i_keep = where("equipment/axe/meteor/tick.mcfunction", "zx.mt_keep matches 1 run return 0")
i_end = where("equipment/axe/meteor/tick.mcfunction", "axe/meteor/end")
if i_keep < 0:
    bad.append("meteor/tick: 没跳过「没握就 end」 —— 一换手形态就没了")
elif i_end > 0 and i_keep > i_end:
    bad.append("meteor/tick: 跳过判断排在 end 之后 —— 等于没写")

ME = body(texts["equipment/axe/meteor/end.mcfunction"])
if "zx.mt_keep 0" not in ME:
    bad.append("meteor/end: 没清 mt_keep —— 形态结束后拿任何武器都会掷陨石")

MH = body(texts["equipment/axe/meteor/hit.mcfunction"])
if "zx.mt_keep matches 1 if score @s zx.mt_on matches 1.." not in MH:
    bad.append("meteor/hit: 超限跳门控没同时判 mt_on —— 形态结束后会白嫖")

MHG = body(texts["equipment/axe/meteor/hit_go.mcfunction"])
if "%= #20 zx.meta" not in MHG or "< #3 zx.meta" not in MHG:
    bad.append("meteor/hit_go: 超限平时 15% 没落地(#rnd %20 < 3)")
if "scoreboard players set #mt_p zx.meta 1" not in MHG:
    bad.append("meteor/hit_go: 超限熔星 100% 没落地")
if "meteor/ol_big" not in MHG:
    bad.append("meteor/hit_go: 没有大陨石那一路")
# 大陨石必须排在清 victim 之前
i_big = where("equipment/axe/meteor/hit_go.mcfunction", "axe/meteor/ol_big")
i_clr = where("equipment/axe/meteor/hit_go.mcfunction", "remove zx.victim")
if i_big > 0 and i_clr > 0 and i_big > i_clr:
    bad.append("meteor/hit_go: 大陨石排在清 zx.victim 之后 —— 打不到「自身攻击的那只」")

MF = body(texts["equipment/axe/meteor/fall.mcfunction"])
for s, msg in [
    ("distance=0.1..4,sort=random,limit=3", "超限「4 格内随机 3 只」没落地"),
    ("distance=0.1..2,sort=random,limit=1", "普通「2 格内随机 1 只」被改掉了"),
    ("attack_mul set value 5.0", "超限 ×5 没落地"),
    ("minecraft:slowness 3 1", "超限 3 秒缓慢Ⅱ 没落地"),
]:
    if s not in MF:
        bad.append("meteor/fall: " + msg)

OB2 = body(texts["equipment/axe/meteor/ol_big.mcfunction"])
for s, msg in [
    ("%= #10 zx.meta", "30% 概率没落地"),
    ("distance=0.1..4,sort=random,limit=1", "「4 格内随机 1 只」没落地"),
    ('attack_mul:8.0', "大陨石 ×8 没落地"),
    ("minecraft:slowness 3 4", "3 秒缓慢Ⅴ(amplifier 4)没落地"),
]:
    if s not in OB2:
        bad.append("meteor/ol_big: " + msg)

ORK = body(texts["equipment/axe/meteor/ol_rock.mcfunction"])
if "scale:[2.8f,2.8f,2.8f]" not in ORK:
    bad.append("meteor/ol_rock: 大陨石没放大")
if "~ ~7 ~" not in ORK or "zx.mt_rk 4" not in ORK:
    bad.append("meteor/ol_rock: 高度/倒计时必须和 rock 一致(7 格 / 4 刻), 否则落石停在半空")

# ============ 每秒 / 每刻驱动 ============
SEC = body(texts["lib/second.mcfunction"])
for s in [
    "zx.anc_back=1..",
    "tag=zx.anc_org",
    "tag=zx.db_field",
]:
    if s not in SEC:
        bad.append("lib/second: 缺驱动 `%s`" % s)

if not bad:
    print("OK  %d 个文件全部通过" % (len(NEW) + len(EDIT)))
else:
    print("问题 %d 处:" % len(bad))
    for b in bad:
        print("  - " + b)
