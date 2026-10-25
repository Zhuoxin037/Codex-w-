# -*- coding: utf-8 -*-
"""_chk_ol_k7.py —— 超限机制 批 K7(弩: 退弦 / 逆弦 / 黯日 / 龙舌)自检

这一批的"不报错、只是不生效"死法:

  ① 弩没有右键、没有 consumable, 全部结算都在附魔回调里 —— 那时手里拿的未必
     还是这把弩, 所以"超限"必须在 shot 那一刻写进**射手身上**。漏写 ⇒ 超限分支
     永远进不去, 表现是"扣了 60/280/420/100 蓝, 但效果和普通版一模一样"。
  ② 通道口径混用: 逆弦的"强化档"局部假名(#rs_ol)与玩家身上的 zx.rs_ov 同名不同物,
     写成同一个 ⇒ 门槛判据失效。
  ③ 两档判据**没有互斥**: 逆弦先 ×4 再 ×10 = 当前 ≤ 7.5%(门槛反而更严);
     龙舌先 %400 再 %800 = 落点仍只有 2 格(取模不会变大)。
  ④ 计分项没在 core/load 声明 —— 分数永不存在, `if score` 恒假。
  ⑤ 顺序错:
      · 退弦 ol_bite 必须在清 zx.bs_ready **之前**(弦满额外翻倍要用它);
      · ol_bite 里"弦满额外翻倍"必须排在"普通翻倍"**之前**(否则第 3 层那发白拿一层);
      · 龙舌 ol_burst 必须排在清 zx.dt_v **之前**(它拿受害者当圆心)。
  ⑥ 每刻驱动缺失: 退弦的翻倍层计时(ol_tick)没挂进 core/tick ⇒ 层数永不掉。
  ⑦ 数值没落地: 60/5 秒/8 点/120/240/30; 280/30%/3.0/140; 420/0.168/最大魔力/去节流/全体;
                100/8 格/4 格/>20/附流火。

用法: python .workbuddy/_chk_ol_k7.py
"""
import io
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"

NEW = [
    "equipment/bow/backstring/ol_bite.mcfunction",
    "equipment/bow/backstring/ol_tick.mcfunction",
    "equipment/bow/dragon_tongue/ol_burst.mcfunction",
]

EDIT = [
    "equipment/bow/backstring/shot.mcfunction",
    "equipment/bow/backstring/fire.mcfunction",
    "equipment/bow/reverse_string/shot.mcfunction",
    "equipment/bow/reverse_string/fire.mcfunction",
    "equipment/bow/dark_sun/shot.mcfunction",
    "equipment/bow/dark_sun/fire.mcfunction",
    "equipment/bow/dark_sun/volley.mcfunction",
    "equipment/bow/dragon_tongue/shot.mcfunction",
    "equipment/bow/dragon_tongue/fire.mcfunction",
    "equipment/bow/dragon_tongue/rain_deal.mcfunction",
    "core/tick.mcfunction",
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


# ---- ① 四件都在 shot 里判「这一发是超限弩」 ----
for rel, obj, oid in [
    ("equipment/bow/backstring/shot.mcfunction", "zx.bs_ol", "backstring"),
    ("equipment/bow/reverse_string/shot.mcfunction", "zx.rs_ov", "reverse_string"),
    ("equipment/bow/dark_sun/shot.mcfunction", "zx.ds_ol", "dark_sun"),
    ("equipment/bow/dragon_tongue/shot.mcfunction", "zx.dt_ol", "dragon_tongue"),
]:
    t = body(texts.get(rel, ""))
    want = 'ol:"%s"' % oid
    if want not in t:
        bad.append("%s: 没有判 `%s` —— 超限分支永远进不去" % (rel, want))
    if "weapon.mainhand" not in t:
        bad.append("%s: 分流没判主手" % rel)
    if ("scoreboard players set @s %s 0" % obj) not in t:
        bad.append("%s: 没先 %s 归零 —— 上一发的超限状态会漏到这一发" % (rel, obj))
    if ("scoreboard players set @s %s 1" % obj) not in t:
        bad.append("%s: 没写 %s = 1" % (rel, obj))

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

# ---- ③ 计分项 / 常量必须在 core/load 声明 ----
LOAD = body(texts.get("core/load.mcfunction", ""))
for obj in ["bs_ol", "bsb_n", "bsb_t", "bsb_x", "bsb_xt", "rs_ov", "ds_ol", "dt_ol"]:
    if "scoreboard objectives add zx.%s " % obj not in LOAD:
        bad.append("core/load: 没有声明 zx.%s —— 分数永不存在, if score 恒假" % obj)
if "scoreboard players set #800 zx.meta 800" not in LOAD:
    bad.append("core/load: 没设 #800 —— rain_deal 的 `%= 0` 会让整条 operation 失败")
# ★ 2026-10-25 落点 +2 格: 超限档跨度 8 -> 12 格, 平移量 600 必须也 set 过
if "scoreboard players set #1200 zx.meta 1200" not in LOAD:
    bad.append("core/load: 没设 #1200 —— 超限落点 ±6 格那两条会 %= 0 整条失败")
if "scoreboard players set #600 zx.meta 600" not in LOAD:
    bad.append("core/load: 没设 #600 —— 超限落点的平移量缺了, 落点会整体偏向一侧")

# ============ 退弦 ============
BS_SHOT = body(texts["equipment/bow/backstring/shot.mcfunction"])
if "value 60.0" not in BS_SHOT:
    bad.append("backstring/shot: 超限每发不是 60 蓝")

BS_FIRE = texts["equipment/bow/backstring/fire.mcfunction"]
BF = body(BS_FIRE)
for s, msg in [
    ("minecraft:speed 5 1", "超限迅捷Ⅱ 不是 5 秒"),
    ("damage set value 30.0", "超限弦满不是 30 点"),
    ("backstring/ol_bite", "没接上超限被动"),
]:
    if s not in BF:
        bad.append("backstring/fire: " + msg)
i_bite = where("equipment/bow/backstring/fire.mcfunction", "backstring/ol_bite")
i_clr = where("equipment/bow/backstring/fire.mcfunction", "scoreboard players set @s zx.bs_ready 0")
if i_bite < 0 or i_clr < 0 or i_bite > i_clr:
    bad.append("backstring/fire: ol_bite 必须排在清 zx.bs_ready 之前(弦满额外翻倍要用它)")

OB = body(texts["equipment/bow/backstring/ol_bite.mcfunction"])
for s, msg in [
    ("sweetdream:true_damage", "8 点不是真实伤害(true_damage)"),
    ("zx.bsb_n 0", "没给目标补「没分数≠0」"),
    ("scoreboard players set #bsb_d zx.meta 8", "基础 8 点没落地"),
    ("scoreboard players set #bsb_d zx.meta 16", "第 1 次翻倍(16)没落地"),
    ("scoreboard players set #bsb_d zx.meta 32", "第 2 次翻倍(32)没落地"),
    ("scoreboard players set #bsb_d zx.meta 64", "第 3 次翻倍(64)没落地"),
    ("scoreboard players set #bsb_d zx.meta 128", "弦满突破上限(128)没落地"),
    ("zx.bsb_t 120", "6 秒(120 刻)没落地"),
    ("zx.bsb_xt 240", "12 秒(240 刻)没落地"),
    ("zx.bsb_x 1", "弦满额外那一层没落地"),
    ("tag @e[tag=zx.bs_v,distance=0..,limit=1] add zx.bsb", "没挂 zx.bsb —— ol_tick 扫不到它"),
]:
    if s not in OB:
        bad.append("backstring/ol_bite: " + msg)
# 顺序: 弦满额外翻倍(判 zx.bs_ready + bsb_n 3..)必须在普通翻倍之前
i_extra = where("equipment/bow/backstring/ol_bite.mcfunction", "zx.bsb_xt 240")
i_up = where("equipment/bow/backstring/ol_bite.mcfunction", "scoreboard players set #bsb_up")
if i_extra < 0 or i_up < 0 or i_extra > i_up:
    bad.append("backstring/ol_bite: 弦满额外翻倍必须排在普通翻倍之前(否则第 3 层那发白拿一层)")
# 满 3 层不再涨: 判据必须是 ..2
if "zx.bsb_n matches ..2 run scoreboard players set #bsb_up zx.meta 1" not in OB:
    bad.append("backstring/ol_bite: 主层上限判据不是 ..2 —— 「最多翻倍 3 次」会变成 4 次")

OT = body(texts["equipment/bow/backstring/ol_tick.mcfunction"])
for s, msg in [
    ("zx.bsb_t matches 1..", "主层计时没递减"),
    ("zx.bsb_xt matches 1..", "额外层计时没递减"),
    ("zx.bsb_n 0", "到点没清主层"),
    ("zx.bsb_x 0", "到点没清额外层"),
    ("remove zx.bsb", "两层都空了还没摘牌 —— 每刻会一直扫"),
]:
    if s not in OT:
        bad.append("backstring/ol_tick: " + msg)

TICK = body(texts["core/tick.mcfunction"])
for dim in ["overworld", "the_nether", "the_end"]:
    if "execute in minecraft:%s as @e[distance=0..,tag=zx.bsb] at @s run function sweetdream:equipment/bow/backstring/ol_tick" % dim not in TICK:
        bad.append("core/tick: %s 维度没有退弦层计时驱动" % dim)

# ============ 逆弦 ============
RS_SHOT = body(texts["equipment/bow/reverse_string/shot.mcfunction"])
if "value 280.0" not in RS_SHOT:
    bad.append("reverse_string/shot: 超限每发不是 280 蓝")
if "zx.rs_ov" not in RS_SHOT:
    bad.append("reverse_string/shot: 没写 zx.rs_ov")

RF = body(texts["equipment/bow/reverse_string/fire.mcfunction"])
for s, msg in [
    ("matches 0 run scoreboard players operation #rs_cm zx.meta *= #4", "普通 25% 判据没了"),
    ("matches 1 run scoreboard players operation #rs_cm zx.meta *= #10", "超限 30% 判据没落地"),
    ("matches 1 run scoreboard players operation #rs_mm zx.meta *= #3", "超限门槛分母没 ×3"),
    ("independent_multiplier set value 3.0", "超限 +200%(独立乘区 3.0)没落地"),
    ("arg.value set value 140.0", "超限返还不是 140"),
]:
    if s not in RF:
        bad.append("reverse_string/fire: " + msg)
# 两套门槛必须互斥(同一条判据不能既走 ×4 又走 ×10)
for ln in lines("equipment/bow/reverse_string/fire.mcfunction"):
    if "*= #4" in ln and "rs_ov" not in ln:
        bad.append("reverse_string/fire: `*= #4` 没有 ds_ov 互斥条件 —— 会与 ×10 叠加成 7.5%")
        break
for ln in lines("equipment/bow/reverse_string/fire.mcfunction"):
    if "*= #10" in ln and "matches 1" not in ln:
        bad.append("reverse_string/fire: `*= #10` 没有 matches 1 互斥条件")
        break

# ============ 黯日 ============
DS_SHOT = body(texts["equipment/bow/dark_sun/shot.mcfunction"])
if "value 420.0" not in DS_SHOT:
    bad.append("dark_sun/shot: 超限每发不是 420 蓝")

DF = body(texts["equipment/bow/dark_sun/fire.mcfunction"])
for s, msg in [
    ("zx.ds_ol matches 0 if score @s zx.ds_gate > #now", "超限没跳过节流(cd 还在)"),
    ("zx.ds_ol matches 0 run scoreboard players operation @s zx.ds_gate = #now", "超限还在续 20 秒闸"),
    ("key:\"max_mana\"", "没去读最大魔力值"),
    ("arg.other_base set from storage zx:work ds.mm", "超限没把基数换成最大魔力"),
    ("arg.other_mul set value 0.168", "超限流火加成 40%(0.168)没落地"),
]:
    if s not in DF:
        bad.append("dark_sun/fire: " + msg)
if "arg.other_mul set value 0.156" not in DF:
    bad.append("dark_sun/fire: 普通的 30%(0.156)被删了")

DV = body(texts["equipment/bow/dark_sun/volley.mcfunction"])
if "matches 0 at @e[tag=zx.ds_pos,limit=1]" not in DV or "sort=nearest,limit=4" not in DV:
    bad.append("dark_sun/volley: 普通的「最近 4 个」没了")
if "matches 1 at @e[tag=zx.ds_pos,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..6,tag=!zx.ds_v] add zx.ds_t" not in DV:
    bad.append("dark_sun/volley: 超限的「范围内全部」没落地(还带 limit 就是没改)")
if "arg.other_base set from storage zx:work ds.mm" not in DV:
    bad.append("dark_sun/volley: 影矢伤害没跟着换成最大魔力")

# ============ 龙舌 ============
DT_SHOT = body(texts["equipment/bow/dragon_tongue/shot.mcfunction"])
if "value 100.0" not in DT_SHOT:
    bad.append("dragon_tongue/shot: 超限每发不是 100 蓝")

DTF = texts["equipment/bow/dragon_tongue/fire.mcfunction"]
DFT = body(DTF)
for s, msg in [
    ("tag=zx.status.liuhuo,distance=..8", "超限 X 计数半径 8 格没落地"),
    ("tag=zx.status.yehuo,distance=..8", "超限夜火计数半径 8 格没落地"),
    ("dragon_tongue/ol_burst", "没接上「箭数 > 20」的收尾一段"),
    ("matches 21..", "额外一段的判据不是 > 20 根箭"),
]:
    if s not in DFT:
        bad.append("dragon_tongue/fire: " + msg)
# ★ 2026-10-25 用户拍板: X 的计数半径 +2 格 ⇒ 普通 6 -> 8 格
if "tag=zx.status.liuhuo,distance=..8" not in DFT:
    bad.append("dragon_tongue/fire: 普通的 8 格计数被删了")
i_burst = where("equipment/bow/dragon_tongue/fire.mcfunction", "dragon_tongue/ol_burst")
# 收尾那句在文件里出现两次(① 开头清一次 + ⑦ 收尾清一次) ⇒ 取**最后一个**
i_end = -1
for i, l in enumerate(lines("equipment/bow/dragon_tongue/fire.mcfunction"), 1):
    if "remove zx.dt_x" in l:
        i_end = i
if i_burst < 0 or i_end < 0 or i_burst > i_end:
    bad.append("dragon_tongue/fire: ol_burst 必须排在 ⑦ 收尾(清 zx.dt_x)之前(它拿受害者当圆心)")
# 计数半径两档必须互斥(★ 2026-10-25 整体 +2 格: 普通 6->8, 超限 8->10)
#   ..8 那三条要 matches 0, ..10 那三条要 matches 1
for ln in lines("equipment/bow/dragon_tongue/fire.mcfunction"):
    if "distance=..8" in ln and "dt_ol matches 0" not in ln:
        bad.append("dragon_tongue/fire: 8 格那条没有 dt_ol matches 0 互斥 —— 两档会叠加")
        break
for ln in lines("equipment/bow/dragon_tongue/fire.mcfunction"):
    if "distance=..10" in ln and "dt_ol matches 1" not in ln:
        bad.append("dragon_tongue/fire: 10 格那条没有 dt_ol matches 1 互斥")
        break

RD = body(texts["equipment/bow/dragon_tongue/rain_deal.mcfunction"])
# ★ 2026-10-25 用户拍板: 落点整体 +2 格 ⇒ 普通 ±4 格(#800/#400)、超限 ±6 格(#1200/#600)。
if "%= #1200 zx.meta" not in RD or "-= #600 zx.meta" not in RD:
    bad.append("dragon_tongue/rain_deal: 超限落点 ±6 格没落地")
if "%= #800 zx.meta" not in RD or "-= #400 zx.meta" not in RD:
    bad.append("dragon_tongue/rain_deal: 普通落点 ±4 格被删了")
for ln in lines("equipment/bow/dragon_tongue/rain_deal.mcfunction"):
    if "%= #800" in ln and "dt_ol matches 0" not in ln:
        bad.append("dragon_tongue/rain_deal: %800 那条没有 matches 0 互斥 —— 两档会叠加")
        break
    if "%= #1200" in ln and "dt_ol matches 1" not in ln:
        bad.append("dragon_tongue/rain_deal: %1200 那条没有 matches 1 互斥 —— 两档会叠加")
        break

OBU = body(texts["equipment/bow/dragon_tongue/ol_burst.mcfunction"])
for s, msg in [
    ("distance=..4", "额外一段的范围不是 4 格"),
    ("dt.dmg", "额外一段没复用「当前魔力 × X × 0.01」"),
    ("mark:\"liuhuo\"", "额外一段没附「流火」"),
    ("@e[tag=zx.dt_bt]", "额外一段没一次选中范围内全部"),
]:
    if s not in OBU:
        bad.append("dragon_tongue/ol_burst: " + msg)

if not bad:
    print("OK  %d 个文件全部通过" % (len(NEW) + len(EDIT)))
else:
    print("问题 %d 处:" % len(bad))
    for b in bad:
        print("  - " + b)
