# -*- coding: utf-8 -*-
"""_chk_ol_k3.py —— 超限机制 批 K3(剑: 归途 / 钩丝 / 雷楔)自检

这三件都有一批"不报错、只是不生效"的死法, 静态能抓的:

  ① 分流判据写错 —— 判 `ol:"xx"` 的不是这一件 / 只判 .ol 键在不在。
  ② 引用了不存在的函数 —— 链条在那一行断掉(前面扣的蓝和冷却照扣)。
  ③ 用了没在 core/load 声明的计分项 —— 分数永不存在, `if score` 恒假。
  ④ 宏函数的调用点漏了 `with storage` —— 报"缺少传入参数", 整条调用失败。
  ⑤ 顺序错: 归途的连线真伤必须在**瞬移之前**(瞬移后两点重合, 一个人也打不到);
     雷楔的 DoT 结算必须在倒计时**之前**; 落雷的 DoT 挂载必须在主伤**之后**。
  ⑥ 数值没落地: 100%/10 秒/5 秒/三目标/0.8 格/12 格/10 秒/0.07/0.08/3 秒/5 秒。

用法: python .workbuddy/_chk_ol_k3.py
"""
import io
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"
JSON = "D:/数据包/sweetdream/data/manacore/tags/function/event/damage_calc.json"

NEW = [
    "equipment/sword/way_back/ol_back.mcfunction",
    "equipment/sword/way_back/ol_back_go.mcfunction",
    "equipment/sword/way_back/ol_line.mcfunction",
    "equipment/sword/gousi/ol_cast.mcfunction",
    "equipment/sword/gousi/ol_lock.mcfunction",
    "equipment/sword/gousi/ol_pull_go.mcfunction",
    "equipment/sword/gousi/ol_pull.mcfunction",
    "equipment/sword/gousi/ol_step.mcfunction",
    "equipment/sword/gousi/ol_land.mcfunction",
    "equipment/sword/gousi/ol_miss.mcfunction",
    "equipment/sword/gousi/ol_hit.mcfunction",
    "equipment/sword/gousi/ol_timeout.mcfunction",
    "equipment/sword/gousi/ol_done.mcfunction",
    "equipment/sword/gousi/ol_buff_land.mcfunction",
    "equipment/sword/gousi/ol_buff_miss.mcfunction",
    "equipment/sword/gousi/hook_calc.mcfunction",
    "equipment/sword/thunder_wedge/ol_tick.mcfunction",
    "equipment/sword/thunder_wedge/ol_dot_one.mcfunction",
    "equipment/sword/thunder_wedge/ol_dot_apply.mcfunction",
    "equipment/sword/thunder_wedge/ol_dot_down.mcfunction",
    "equipment/sword/thunder_wedge/ol_end.mcfunction",
    "equipment/sword/thunder_wedge/ol_end_one.mcfunction",
]

EDIT = [
    "lib/heal.mcfunction",
    "lib/second.mcfunction",
    "core/load.mcfunction",
    "equipment/sword/way_back/back.mcfunction",
    "equipment/sword/gousi/cast.mcfunction",
    "equipment/sword/gousi/pull_go.mcfunction",
    "equipment/sword/thunder_wedge/cast.mcfunction",
    "equipment/sword/thunder_wedge/hit.mcfunction",
    "equipment/sword/thunder_wedge/strike.mcfunction",
    "equipment/sword/thunder_wedge/wedge_tick.mcfunction",
    "equipment/sword/thunder_wedge/wedge_end.mcfunction",
    "equipment/sword/thunder_wedge/wedge_one.mcfunction",
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
    """去掉注释行后的命令正文(注释里写 `ol:"x"` 不算数)。"""
    return "\n".join(l for l in t.split("\n") if not l.strip().startswith("#"))


def has(rel, s):
    return s in body(texts.get(rel, ""))


def where(rel, s):
    """返回 s 第一次出现所在的行号(1 起); 没有则 -1。"""
    for i, l in enumerate(texts.get(rel, "").split("\n"), 1):
        if s in l and not l.strip().startswith("#"):
            return i
    return -1


# ---- ① 分流判据: 三件都要有"主手 + 副手"两行, 且判的是 ol 的值 ----
for rel, oid in [
    ("equipment/sword/way_back/back.mcfunction", "way_back"),
    ("equipment/sword/gousi/cast.mcfunction", "gousi"),
    ("equipment/sword/thunder_wedge/cast.mcfunction", "thunder_wedge"),
]:
    t = body(texts.get(rel, ""))
    want = 'ol:"%s"' % oid
    if want not in t:
        bad.append("%s: 没有判 %s —— 超限分支永远进不去" % (rel, want))
    if "weapon.mainhand" not in t:
        bad.append("%s: 分流没判主手" % rel)
    if "weapon.offhand" not in t:
        bad.append("%s: 分流没判副手" % rel)

# ---- ② 所有 function 引用都存在 ----
referenced = set()
for rel, t in texts.items():
    for m in re.finditer(r'function (sweetdream:[a-z0-9_/]+)', body(t)):
        referenced.add(m.group(1))
for fq in sorted(referenced):
    p = os.path.join(FN, fq.split(":", 1)[1].replace("/", os.sep) + ".mcfunction")
    if not os.path.exists(p):
        bad.append("引用了不存在的函数: %s" % fq)

# ---- ③ 计分项声明 ----
load = io.open(os.path.join(FN, "core", "load.mcfunction"), encoding="utf-8").read()
declared = set(re.findall(r'scoreboard objectives add (zx\.[A-Za-z0-9_.]+)', load))
used = set()
PAT_OBJ = [
    r'^scoreboard players (?:add|remove|set|reset|get|enable|operation) \S+ (zx\.\w+)',
    r'\b(?:if|unless) score \S+ (zx\.\w+)',
    r'\bstore (?:result|success) score \S+ (zx\.\w+)',
]
for rel, t in texts.items():
    for s in body(t).split("\n"):
        for pat in PAT_OBJ:
            for m in re.finditer(pat, s.strip()):
                if m.group(1) != "zx.meta":
                    used.add(m.group(1))
for n in sorted(used):
    if n not in declared:
        bad.append("计分项 %s 被用了但没在 core/load 声明 —— %s" % (n, n))

# ---- ④ 宏函数必须有 with storage 调用点 ----
for macro_file, marker in [
    ("equipment/sword/way_back/ol_back_go.mcfunction", "way_back/ol_back_go with storage"),
    ("equipment/sword/gousi/ol_lock.mcfunction", "gousi/ol_lock with storage"),
    ("equipment/sword/gousi/ol_pull.mcfunction", "gousi/ol_pull with storage"),
    ("equipment/sword/gousi/ol_step.mcfunction", "gousi/ol_step with storage"),
    ("equipment/sword/gousi/ol_land.mcfunction", "gousi/ol_land with storage"),
    ("equipment/sword/gousi/ol_miss.mcfunction", "gousi/ol_miss with storage"),
    ("equipment/sword/gousi/ol_timeout.mcfunction", "gousi/ol_timeout with storage"),
]:
    hits = sum(body(t).count(marker) for t in texts.values())
    if hits < 1:
        bad.append("%s 是宏函数(有 $(own)/$(uuid)), 但没有任何 `with storage` 调用点" % macro_file)

# ================= 归途 way_back =================
WB = "equipment/sword/way_back/ol_back_go.mcfunction"
# ⑤ heal 必须排在 teleport 之前
i_heal = where(WB, "sweetdream:lib/heal")
i_tp = where(WB, "way_back/teleport with storage")
if i_heal < 0:
    bad.append("ol_back_go: 没有调 lib/heal —— 返还整段没实现")
elif i_tp < 0:
    bad.append("ol_back_go: 没有调 teleport —— 不会瞬移回去")
elif i_heal > i_tp:
    bad.append("ol_back_go: lib/heal 排在瞬移**之后** —— 连线真伤会算成 0 长")
# 100%: 不能再出现 /2
if "/= #2 zx.meta" in body(texts.get(WB, "")):
    bad.append("ol_back_go: 还在 /2(那是原版的 50%) —— 超限应是 100%")
# 40% 上限不能留
if "#wb_cap" in body(texts.get(WB, "")):
    bad.append("ol_back_go: 还留着 40% 上限(#wb_cap) —— 超限文案没有上限")
# 真伤
if 'type:"sweetdream:true_damage"' not in body(texts.get(WB, "")):
    bad.append("ol_back_go: 连线伤害不是真伤")
if "#heal_got" not in body(texts.get(WB, "")):
    bad.append("ol_back_go: 没有用 #heal_got(实际回复量)当真伤基数")
# 增益
if "minecraft:speed 10 1 true" not in body(texts.get(WB, "")):
    bad.append("ol_back_go: 迅捷Ⅱ 不是 10 秒(应为 speed 10 1)")
if "minecraft:resistance 5 2 true" not in body(texts.get(WB, "")):
    bad.append("ol_back_go: 抗性提升Ⅲ 不是 5 秒(应为 resistance 5 2)")

# lib/heal 出参
heal = body(texts.get("lib/heal.mcfunction", ""))
if "#heal_got zx.meta = #heal_new zx.meta" not in heal:
    bad.append("lib/heal: 没写 #heal_got 出参")
if "#heal_got zx.meta -= #heal_base zx.meta" not in heal:
    bad.append("lib/heal: #heal_got 没减基点(应 = 目标生命 − 基点)")

# 连线递归: 有步数上限 + 递归行不含 at @s
LINE = body(texts.get("equipment/sword/way_back/ol_line.mcfunction", ""))
if "#wb_step zx.meta matches 28.." not in LINE:
    bad.append("ol_line: 没有 28 步上限 —— 朝向退化时会无限递归")
for l in LINE.split("\n"):
    if "run function sweetdream:equipment/sword/way_back/ol_line" in l:
        if "at @s" in l:
            bad.append("ol_line: 递归行带了 `at @s` —— 采样点会永远停在玩家脚下")
        if "positioned ^ ^ ^2.5" not in l:
            bad.append("ol_line: 递归行没有前进 2.5 格")

# ================= 钩丝 gousi =================
GC = body(texts.get("equipment/sword/gousi/ol_cast.mcfunction", ""))
if "mana:180.0" not in GC:
    bad.append("ol_cast: 魔力不是 180")
if "cooldown_seconds:28.0" not in GC:
    bad.append("ol_cast: 冷却不是 28 秒")
if "zx.gs_st 12" not in GC:
    bad.append("ol_cast: 步数不是 12")
if "zx.gs3 1" not in GC:
    bad.append("ol_cast: 没有打 zx.gs3=1 的分流标记")
if 'zx:work gs3 set value {own:0,uu:"",u0:0,u1:0,u2:0,u3:0}' not in GC:
    bad.append("ol_cast: zx:work gs3 少了 uu/u0..u3 —— 拉到位那一发会失去魔力基数与归属")

LOCK = body(texts.get("equipment/sword/gousi/ol_lock.mcfunction", ""))
if "sort=nearest,limit=3" not in LOCK:
    bad.append("ol_lock: 不是「最近的三个」(缺 sort=nearest,limit=3)")

STEP = body(texts.get("equipment/sword/gousi/ol_step.mcfunction", ""))
if "positioned ^ ^ ^0.8" not in STEP:
    bad.append("ol_step: 每步不是 0.8 格")
if "minecraft:slowness 1 0 true" not in STEP:
    bad.append("ol_step: 拉动期间没有常态缓慢Ⅰ")
if "facing entity @e[tag=zx.gs3_src,limit=1] feet" not in STEP:
    bad.append("ol_step: tp 之前没面向施法者 —— 那是推不是拉")

LAND = body(texts.get("equipment/sword/gousi/ol_land.mcfunction", ""))
if "minecraft:slowness 5 1 true" not in LAND:
    bad.append("ol_land: 到位缓慢Ⅱ 不是 5 秒")
if "#gs_k zx.meta 12" not in LAND:
    bad.append("ol_land: 到位伤害系数不是 12(×0.12)")
MISS = body(texts.get("equipment/sword/gousi/ol_miss.mcfunction", ""))
if "#gs_k zx.meta 8" not in MISS:
    bad.append("ol_miss: 没拉到伤害系数不是 8(×0.08)")

HIT = body(texts.get("equipment/sword/gousi/ol_hit.mcfunction", ""))
if "zx:work gs3.uu" not in HIT:
    bad.append("ol_hit: 没用施法者的 uu 去读最大魔力 —— 会读成怪物自己的")
if "zx:work gs3.u0" not in HIT:
    bad.append("ol_hit: 伤害归属没有带施法者 UUID")

BL = body(texts.get("equipment/sword/gousi/ol_buff_land.mcfunction", ""))
if "zx.gs3n 3" not in BL:
    bad.append("ol_buff_land: 次数没刷成 3")
if "zx.gs3p 30" not in BL:
    bad.append("ol_buff_land: 百分点没有 30 封顶")
BM = body(texts.get("equipment/sword/gousi/ol_buff_miss.mcfunction", ""))
if "zx.gs3n matches ..0" not in BM:
    bad.append("ol_buff_miss: 会把已挂的三次降级成一次(应只补 ..0)")

# hook_calc: 声明 indep + 登记在 dmg_add_apply 之后
HK = texts.get("equipment/sword/gousi/hook_calc.mcfunction", "")
if "# @calc: indep" not in HK:
    bad.append("gousi/hook_calc: 头部缺 `# @calc: indep`")
if "obj:\"zx.meta\"" not in HK:
    bad.append("gousi/hook_calc: mul_pct 没写 obj —— 会去 manacore.math 读输入, 结果恒 0")
if "zx.gs3lt" not in HK:
    bad.append("gousi/hook_calc: 没有同刻去重(一次施法会吃掉三次)")
try:
    vals = io.open(JSON, encoding="utf-8").read()
    i_apply = vals.find("lib/dmg_add_apply")
    i_hook = vals.find("equipment/sword/gousi/hook_calc")
    if i_hook < 0:
        bad.append("damage_calc.json: gousi/hook_calc 没登记 —— 永不生效")
    elif i_apply < 0 or i_hook < i_apply:
        bad.append("damage_calc.json: gousi/hook_calc 排在 lib/dmg_add_apply 之前(独立乘区必须之后)")
except Exception as e:
    bad.append("读 damage_calc.json 失败: %s" % e)

# pull_go 分流 + cast 清标记
if "zx.gs3 matches 1 run return run function sweetdream:equipment/sword/gousi/ol_pull_go" \
        not in body(texts.get("equipment/sword/gousi/pull_go.mcfunction", "")):
    bad.append("gousi/pull_go: 没有按 zx.gs3 分流到 ol_pull_go")
if "execute if score #gs3_ol zx.meta matches 0 run scoreboard players set @s zx.gs3 0" \
        not in body(texts.get("equipment/sword/gousi/cast.mcfunction", "")):
    bad.append("gousi/cast: 非超限路径没把 zx.gs3 清 0 —— 上一轮残留会让这一轮误走三目标")

# ================= 雷楔 thunder_wedge =================
TC = body(texts.get("equipment/sword/thunder_wedge/cast.mcfunction", ""))
if "duration_seconds set value 10.0" not in TC:
    bad.append("twg/cast: 超限术阵不是 10 秒")
if "arg.data.radius set value 12.0" not in TC:
    bad.append("twg/cast: 超限术阵半径不是 12")
if "twg.ft set value 10" not in TC:
    bad.append("twg/cast: 超限雷楔寿命不是 10 秒")

W1 = body(texts.get("equipment/sword/thunder_wedge/wedge_one.mcfunction", ""))
if '"zx.twg_ol"' not in W1:
    bad.append("wedge_one: marker 没挂 zx.twg_ol 标签")
if "$(ft)" not in W1:
    bad.append("wedge_one: 寿命还是写死的 8(应为宏 $(ft))")

TH = body(texts.get("equipment/sword/thunder_wedge/hit.mcfunction", ""))
if "distance=..8] if score @s zx.twg_own = #twg_me zx.meta unless entity @s[tag=zx.twg_ol]" not in TH:
    bad.append("twg/hit: 原版 8 格那一路没有 unless zx.twg_ol(会与超限那路重复落雷)")
if "distance=..12] if score @s zx.twg_own = #twg_me zx.meta if entity @s[tag=zx.twg_ol]" not in TH:
    bad.append("twg/hit: 超限 12 格那一路没写(或没判 zx.twg_ol)")

ST = body(texts.get("equipment/sword/thunder_wedge/strike.mcfunction", ""))
if "ol_dot_apply" not in ST:
    bad.append("twg/strike: 落雷后没挂 DoT")
if "if entity @s[tag=zx.twg_ol]" not in ST:
    bad.append("twg/strike: DoT 没有只对超限生效")

TK = body(texts.get("equipment/sword/thunder_wedge/wedge_tick.mcfunction", ""))
i_dot = where("equipment/sword/thunder_wedge/wedge_tick.mcfunction", "thunder_wedge/ol_tick")
i_ft = where("equipment/sword/thunder_wedge/wedge_tick.mcfunction", "zx.twg_ft 1")
if i_dot < 0:
    bad.append("wedge_tick: 没有每秒调 ol_tick —— DoT 永远不结算")
elif i_ft > 0 and i_dot > i_ft:
    bad.append("wedge_tick: ol_tick 排在倒计时**之后** —— 寿命归零那一秒会先 kill 掉自己")
if "zx.twg_end" not in TK:
    bad.append("wedge_tick: 到点没打 zx.twg_end 标记")

WE = body(texts.get("equipment/sword/thunder_wedge/wedge_end.mcfunction", ""))
if "if entity @s[tag=zx.twg_ol] if entity @s[tag=zx.twg_end]" not in WE:
    bad.append("wedge_end: 收尾落雷的两个门(超限 + 自然到期)没写全")
i_end = where("equipment/sword/thunder_wedge/wedge_end.mcfunction", "thunder_wedge/ol_end")
i_kill = where("equipment/sword/thunder_wedge/wedge_end.mcfunction", "kill @s")
if i_end < 0:
    bad.append("wedge_end: 没有调 ol_end")
elif i_kill > 0 and i_end > i_kill:
    bad.append("wedge_end: ol_end 排在自己 kill **之后** —— marker 已经没了, 读不到 NBT")

OT = body(texts.get("equipment/sword/thunder_wedge/ol_tick.mcfunction", ""))
for s in ["r.value 10", "#twg_k zx.meta 7", "r.max 10", "#twg_k zx.meta 8"]:
    if s not in OT:
        bad.append("ol_tick: 少了 %s(0.07 / 0.08 定点)" % s)
if "distance=..12" not in OT:
    bad.append("ol_tick: 结算半径不是 12")

DA = body(texts.get("equipment/sword/thunder_wedge/ol_dot_apply.mcfunction", ""))
if "scoreboard players add @s zx.twg_dot 0" not in DA:
    bad.append("ol_dot_apply: 没先补 0 —— 第一次命中两档都不进(没分数 != 0)")
if "zx.twg_dotk 2" not in DA or "zx.twg_dot 5" not in DA:
    bad.append("ol_dot_apply: 强化档不是 5 秒 / 2 档")
if "zx.twg_dot 3" not in DA:
    bad.append("ol_dot_apply: 普通档不是 3 秒")

DD = body(texts.get("equipment/sword/thunder_wedge/ol_dot_down.mcfunction", ""))
if "remove @s zx.twg_dot 1" not in DD:
    bad.append("ol_dot_down: 没有每秒 -1")
if "zx.twg_dotk 0" not in DD:
    bad.append("ol_dot_down: 到点没清档位")

SEC = body(texts.get("lib/second.mcfunction", ""))
for dim in ["minecraft:overworld", "minecraft:the_nether", "minecraft:the_end"]:
    if "execute in %s as @e[scores={zx.twg_dot=1..},distance=0..] run function " \
            "sweetdream:equipment/sword/thunder_wedge/ol_dot_down" % dim not in SEC:
        bad.append("lib/second: %s 维度没有 DoT 倒计时 —— DoT 会永久残留" % dim)

OE = body(texts.get("equipment/sword/thunder_wedge/ol_end.mcfunction", ""))
if "distance=..12" not in OE:
    bad.append("ol_end: 收尾落雷范围不是 12 格")
if "data.zx.dmg" not in OE:
    bad.append("ol_end: 没把 marker 的 dmg 摊进 twgdot")

# ---- 汇总 ----
print("扫描 %d 个文件" % len(texts))
if bad:
    print("---- 问题 %d 处 ----" % len(bad))
    for b in bad:
        print(" [错]", b)
else:
    print("---- 问题 0 处 ----")
