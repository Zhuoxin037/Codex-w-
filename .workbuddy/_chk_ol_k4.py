# -*- coding: utf-8 -*-
"""_chk_ol_k4.py —— 超限机制 批 K4(斧: 锈犬 / 饮鸩 / 天穹)自检

这一批的"不报错、只是不生效"死法:

  ① 分流判据写错 —— 判的不是这一件的 ol 值 / 只判 .ol 键在不在 / 漏了副手。
  ② 引用了不存在的函数 —— 链条在那一行断掉(前面扣的蓝和冷却照扣)。
  ③ 计分项没在 core/load 声明 —— 分数永不存在, `if score` 恒假。
  ④ 宏函数调用点漏了 `with storage` —— 报"缺少传入参数", 整条调用失败。
  ⑤ 顺序错:
      · 饮鸩第二形态的分支必须在 skill/check **之前**(否则 80 秒冷却永远挡着);
      · 天穹 impact 里 sv_cn 的清零必须在 return 之前、且用快照判;
      · 连锁判定必须在 sv_ol 清零**之后**(否则读到的永远是 0)。
  ⑥ 数值没落地: 200 蓝/30 秒/三只/8 格/×2/×5/5 次/+30%/10 秒;
     360 蓝/12 秒/0.8 倍/60%/0.1/10%/4 次;
     530 蓝/8 格/半径 6/×3/-35 秒/≥10 层/半径 5/当前魔力 ×0.1/1 层升痕/每层 10%。
  ⑦ 进度的兜底: 新 draught_hit 必须进 lib/rearm(否则奖励函数被跳过一次就永久卡死)。

用法: python .workbuddy/_chk_ol_k4.py
"""
import io
import json
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"

NEW = [
    "equipment/axe/xiugou/ol_bite.mcfunction",
    "equipment/axe/xiugou/ol_bite_one.mcfunction",
    "equipment/axe/xiugou/ol_burst.mcfunction",
    "equipment/axe/draught/ol_second.mcfunction",
    "equipment/axe/draught/ol_hit.mcfunction",
    "equipment/axe/draught/ol_strip.mcfunction",
    "equipment/axe/draught/ol_expire.mcfunction",
    "equipment/axe/skyvault/ol_aoe.mcfunction",
    "equipment/axe/skyvault/ol_chain.mcfunction",
    "internal/damage/vuln_summon.mcfunction",
    "internal/damage/stg_per.mcfunction",
]

EDIT = [
    "internal/damage/one.mcfunction",
    "internal/damage/stg_mul.mcfunction",
    "lib/second.mcfunction",
    "lib/rearm.mcfunction",
    "core/load.mcfunction",
    "equipment/axe/xiugou/cast.mcfunction",
    "equipment/axe/xiugou/spawn.mcfunction",
    "equipment/axe/xiugou/dog_tick.mcfunction",
    "equipment/axe/xiugou/bite_one.mcfunction",
    "equipment/axe/draught/cast.mcfunction",
    "equipment/axe/skyvault/cast.mcfunction",
    "equipment/axe/skyvault/rise_step.mcfunction",
    "equipment/axe/skyvault/rise_end.mcfunction",
    "internal/damage/stg_per.mcfunction",
    "equipment/axe/skyvault/impact.mcfunction",
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
    """去掉注释行后的命令正文(注释里写 `ol:"x"` / 数值不算数)。"""
    return "\n".join(l for l in t.split("\n") if not l.strip().startswith("#"))


def lines(rel):
    return body(texts.get(rel, "")).split("\n")


def where(rel, s):
    """s 第一次出现在第几行(1 起) —— 只在正文里找; 没有返回 -1。"""
    for i, l in enumerate(lines(rel), 1):
        if s in l:
            return i
    return -1


def has(rel, s):
    return s in body(texts.get(rel, ""))


# ---- ① 三件的分流判据 ----
for rel, oid, item in [
    ("equipment/axe/xiugou/cast.mcfunction", "xiugou", "iron_axe"),
    ("equipment/axe/draught/cast.mcfunction", "draught", "iron_axe"),
    ("equipment/axe/skyvault/cast.mcfunction", "skyvault", "netherite_axe"),
]:
    t = body(texts.get(rel, ""))
    want = '%s[minecraft:custom_data~{zx:["%s"],ol:"%s"}]' % (item, oid, oid)
    if want not in t:
        bad.append("%s: 没有判 `%s` —— 超限分支永远进不去" % (rel, want))
    if "weapon.mainhand" not in t or "weapon.offhand" not in t:
        bad.append("%s: 分流没同时判主手和副手" % rel)

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
PAT_OBJ = [
    r'^scoreboard players (?:add|remove|set|reset|get|enable|operation) \S+ (zx\.\w+)',
    r'\b(?:if|unless) score \S+ (zx\.\w+)',
    r'\bstore (?:result|success) score \S+ (zx\.\w+)',
]
used = set()
for rel, t in texts.items():
    for s in body(t).split("\n"):
        for pat in PAT_OBJ:
            for m in re.finditer(pat, s.strip()):
                if m.group(1) != "zx.meta":
                    used.add(m.group(1))
for n in sorted(used):
    if n not in declared:
        bad.append("计分项 %s 被用了但没在 core/load 声明 —— if score 会恒假" % n)

# ---- ④ 宏函数的调用点 ----
for marker in ["xiugou/ol_bite_one with storage",
               "xiugou/ol_burst with storage",
               "skyvault/ol_aoe with storage",
               "skyvault/aoe with storage"]:
    hits = sum(body(t).count(marker) for t in texts.values())
    if hits < 1:
        bad.append("宏函数调用点缺失: 没有任何 `%s`(会报缺少传入参数)" % marker)

# ================= 锈犬 xiugou =================
CAST = "equipment/axe/xiugou/cast.mcfunction"
if "arg.mana set value 200.0" not in body(texts[CAST]):
    bad.append("xiugou/cast: 超限魔力不是 200")
if "arg.cooldown_seconds set value 30.0" not in body(texts[CAST]):
    bad.append("xiugou/cast: 超限冷却不是 30 秒")
if "rotated ~ 30 positioned ^ ^ ^2" not in body(texts[CAST]) \
        or "rotated ~ -30 positioned ^ ^ ^2" not in body(texts[CAST]):
    bad.append("xiugou/cast: 没召唤三只(缺少 ±30 度那两条)")
if "#xg_atk zx.meta *= #2 zx.meta" not in body(texts[CAST]):
    bad.append("xiugou/cast: 每口伤害没乘 2(超限系数 ×2)")

SP = body(texts["equipment/axe/xiugou/spawn.mcfunction"])
if '"zx.xg_ol"' not in SP and "add zx.xg_ol" not in SP:
    bad.append("xiugou/spawn: 超限犬没挂 zx.xg_ol 标签 —— dog_tick 分不到 8 格那一路")
DT = body(texts["equipment/axe/xiugou/dog_tick.mcfunction"])
if "tag=zx.xg_ol] if score @s zx.xg_n matches ..9 run function sweetdream:equipment/axe/xiugou/ol_bite" not in DT:
    bad.append("xiugou/dog_tick: 没有按 zx.xg_ol 分流到 ol_bite")
if "unless entity @s[tag=zx.xg_ol] if score @s zx.xg_n matches ..9 run function sweetdream:equipment/axe/xiugou/bite" not in DT:
    bad.append("xiugou/dog_tick: 原版那一路没有 `unless zx.xg_ol`(超限犬会咬两口)")

OB = body(texts["equipment/axe/xiugou/ol_bite.mcfunction"])
if "distance=0.1..8,sort=nearest,limit=1" not in OB:
    bad.append("xiugou/ol_bite: 撕咬范围不是 8 格")
if "zx.xg_hc matches 5.." not in OB:
    bad.append("xiugou/ol_bite: 连击阈值不是 5 次")
if "#xg_bd zx.meta *= #5 zx.meta" not in OB or "#xg_bd zx.meta /= #2 zx.meta" not in OB:
    bad.append("xiugou/ol_bite: ×5 那一下没按 dmg ×5/2 算(犬的每口是基础攻击力×2)")
if "zx.xg_hc 0" not in OB:
    bad.append("xiugou/ol_bite: 换目标时没有把连击清零")
if "scoreboard players add @s zx.xg_hc 0" not in OB:
    bad.append("xiugou/ol_bite: 比较前没有 `add 0`(没分数 ≠ 0, 新犬会判不出变化)")

for rel in ["equipment/axe/xiugou/ol_bite_one.mcfunction",
            "equipment/axe/xiugou/ol_burst.mcfunction"]:
    if "sm:1b" not in body(texts[rel]):
        bad.append("%s: 投递参数没有 sm:1b —— +30% 那段永远不生效" % rel)
if "zx.svul 10" not in body(texts["equipment/axe/xiugou/ol_burst.mcfunction"]):
    bad.append("xiugou/ol_burst: 没有挂 10 秒 zx.svul")
if "sm:1b" not in body(texts["equipment/axe/xiugou/bite_one.mcfunction"]):
    bad.append("xiugou/bite_one: 原版犬的伤害也没打 sm:1b(同一套承伤要走同一判据)")

ONE = body(texts["internal/damage/one.mcfunction"])
if "if data storage zx:work a{sm:1b} if entity @s[scores={zx.svul=1..}] run function sweetdream:internal/damage/vuln_summon" not in ONE:
    bad.append("internal/damage/one: 没有 sm:1b + zx.svul 的钩子(那 30% 无处生效)")
VS = body(texts["internal/damage/vuln_summon.mcfunction"])
if "#vs zx.meta *= #130 zx.meta" not in VS or "#vs zx.meta /= #100 zx.meta" not in VS:
    bad.append("vuln_summon: 乘区不是 ×1.30")
if "#vs_cap zx.meta /= #130 zx.meta" not in VS:
    bad.append("vuln_summon: 没有 int32 上界保护(伤害过 1.6 万会回绕成负数)")

SEC = body(texts["lib/second.mcfunction"])
if SEC.count("scores={zx.svul=1..},distance=0..] run scoreboard players remove @s zx.svul 1") < 3:
    bad.append("lib/second: zx.svul 的每秒 -1 不是三维度各一行")

# ================= 饮鸩 draught =================
DC = "equipment/axe/draught/cast.mcfunction"
i_second = where(DC, "draught/ol_second")
i_check = where(DC, "manacore:api/skill/check")
if i_second < 0:
    bad.append("draught/cast: 没有第二形态分支")
elif i_check < 0:
    bad.append("draught/cast: 找不到 skill/check")
elif i_second > i_check:
    bad.append("draught/cast: 第二形态分支排在 skill/check **之后** —— 80 秒冷却永远挡着")
if "#dg2" not in body(texts[DC]) or "if score #dg2 zx.meta matches 1 run return 0" not in body(texts[DC]):
    bad.append("draught/cast: 第二形态被接管后没有 return(#dg2) —— 失败会掉进第一形态又自伤 80%")
if "arg.mana set value 360.0" not in body(texts[DC]):
    bad.append("draught/cast: 超限魔力不是 360")
if "zx.dg_on 12" not in body(texts[DC]):
    bad.append("draught/cast: 超限加成不是 12 秒")
if "zx.dg_ol2 1" not in body(texts[DC]):
    bad.append("draught/cast: 没有置 zx.dg_ol2 = 1(第二形态永远解锁不了)")
if "#dg_plan" not in body(texts[DC]):
    bad.append("draught/cast: 没有按「本次伤害数值」(#dg_plan)算加成")
if "sweetdream:equipment/axe/draught/ol_strip" not in body(texts[DC]):
    bad.append("draught/cast: 重入时没有撤掉第二形态的旧账(会越叠越高)")

OS = body(texts["equipment/axe/draught/ol_second.mcfunction"])
if "#dg2 zx.meta 1" not in OS.split("\n")[0] and "#dg2 zx.meta 1" not in OS:
    bad.append("draught/ol_second: 第一行没有置 #dg2 = 1(失败时会掉回第一形态)")
if "#60" not in OS:
    bad.append("draught/ol_second: 没有血量 60% 的门槛")
if "cooldown/start" in OS:
    bad.append("draught/ol_second: 第二形态**不该**再起一次冷却(共用第一段的 80 秒)")
if "value:360.0" not in OS:
    bad.append("draught/ol_second: 第二形态没扣 360 蓝")

OH = body(texts["equipment/axe/draught/ol_hit.mcfunction"])
if "zx.dg_mode matches 2" not in OH:
    bad.append("draught/ol_hit: 没有判第二形态(zx.dg_mode = 2)")
if "zx.dg_n matches 4.." not in OH:
    bad.append("draught/ol_hit: 没有 4 次上限")
if 'type:"sweetdream:true_damage"' not in OH:
    bad.append("draught/ol_hit: 自伤不是真实伤害")
if "zx.dg_on2 10" not in OH:
    bad.append("draught/ol_hit: +10% 的持续时间不是 10 秒")
if "#10 zx.meta" not in OH:
    bad.append("draught/ol_hit: 没有按 10% 算加成")
if "zx.dg_buf2" not in OH:
    bad.append("draught/ol_hit: 没有账本 zx.dg_buf2(到期减不回去)")

adv = os.path.join("D:/数据包/sweetdream/data/sweetdream/advancement/equipment/axe/draught_hit.json")
if not os.path.exists(adv):
    bad.append("缺进度: advancement/equipment/axe/draught_hit.json(平A 触发不了)")
else:
    js = json.load(io.open(adv, encoding="utf-8"))
    if js.get("rewards", {}).get("function") != "sweetdream:equipment/axe/draught/ol_hit":
        bad.append("draught_hit.json: rewards.function 不是 draught/ol_hit")
    if "player_hurt_entity" not in json.dumps(js):
        bad.append("draught_hit.json: 触发条件不是 player_hurt_entity")

REARM = body(texts["lib/rearm.mcfunction"])
if "advancement revoke @a only sweetdream:equipment/axe/draught_hit" not in REARM:
    bad.append("lib/rearm: 没登记 draught_hit —— 奖励函数被跳过一次就永久卡死")
if "scores={zx.dg_on2=1..}] run function sweetdream:equipment/axe/draught/ol_expire" not in SEC:
    bad.append("lib/second: 没有第二形态的每秒推进(ol_expire)")

# ================= 天穹 skyvault =================
SC = "equipment/axe/skyvault/cast.mcfunction"
if "arg.mana set value 530.0" not in body(texts[SC]):
    bad.append("skyvault/cast: 超限魔力不是 530")
if "zx.sv_ol = #sv_ol zx.meta" not in body(texts[SC]):
    bad.append("skyvault/cast: 没有把超限快照拍进 zx.sv_ol")
if "zx.sv_cn 0" not in body(texts[SC]):
    bad.append("skyvault/cast: 起手没有清 zx.sv_cn(残留会让下一次跃升变 6 格且自动俯冲)")

RS = body(texts["equipment/axe/skyvault/rise_step.mcfunction"])
if "tp @s ~ ~0.8 ~" not in RS:
    bad.append("skyvault/rise_step: 超限第一段不是 0.8 格/刻(10 刻 = 8 格)")
if RS.count("tp @s ~ ~0.6 ~") < 2:
    bad.append("skyvault/rise_step: 原版与连锁段的 0.6 格/刻 两条不齐")

RE = body(texts["equipment/axe/skyvault/rise_end.mcfunction"])
if "if score @s zx.sv_cn matches 1 run function sweetdream:equipment/axe/skyvault/dive_ready" not in RE:
    bad.append("skyvault/rise_end: 连锁段跃升到顶没有自动俯冲")

IM = body(texts["equipment/axe/skyvault/impact.mcfunction"])
if "distance=..6] add zx.sv_aoe" not in IM:
    bad.append("skyvault/impact: 超限第一段的半径不是 6 格")
if "arg.attack_mul set value 3.0" not in IM:
    bad.append("skyvault/impact: 每层额外伤害不是 基础攻击力 ×3")
if "arg.ticks set value 700" not in IM:
    bad.append("skyvault/impact: 超限减冷却不是 35 秒(700 tick)")
if "matches 10.. run function sweetdream:equipment/axe/skyvault/ol_chain" not in IM:
    bad.append("skyvault/impact: 没有 ≥10 层的连锁触发")
if "#sv_ol zx.meta 0" not in IM or "#sv_ol zx.meta 1" not in IM:
    bad.append("skyvault/impact: 没有把 @s zx.sv_ol 拍成 #sv_ol 快照")
# sv_cn 清零必须在 return 之前, 且 return 用快照判
i_clr = where("equipment/axe/skyvault/impact.mcfunction", "scoreboard players set @s zx.sv_cn 0")
i_ret = where("equipment/axe/skyvault/impact.mcfunction", "#sv_cn zx.meta matches 1 run return 0")
if i_clr < 0 or i_ret < 0:
    bad.append("skyvault/impact: 连锁段的「清零 + return」不齐")
elif i_clr > i_ret:
    bad.append("skyvault/impact: return 排在清零之前 —— 或清零后用 @s 判自己(死分支)")
# 连锁判定必须排在 sv_ol 清零之后
i_olclr = where("equipment/axe/skyvault/impact.mcfunction", "scoreboard players set @s zx.sv_ol 0")
i_chain = where("equipment/axe/skyvault/impact.mcfunction", "ol_chain")
if i_olclr < 0 or i_chain < 0:
    bad.append("skyvault/impact: 找不到 sv_ol 清零或连锁触发")
elif i_chain < i_olclr:
    bad.append("skyvault/impact: 连锁判定排在 sv_ol 清零**之前** —— 快照还没拍好就被判")

if "other_mul:0.1" not in body(texts["equipment/axe/skyvault/ol_aoe.mcfunction"]):
    bad.append("skyvault/ol_aoe: 连锁段不是「当前魔力 ×0.1」(other_mul)")
OC = body(texts["equipment/axe/skyvault/ol_chain.mcfunction"])
if "zx.sv_cn 1" not in OC or "tag @s add zx.sv_rising" not in OC:
    bad.append("skyvault/ol_chain: 没有置 sv_cn / 没有开始第二次跃升")
if "zx.sv_air" in OC and "remove zx.sv_air" not in OC:
    bad.append("skyvault/ol_chain: 连锁段不该给 sv_air(那是等玩家再按的窗口)")

SM = body(texts["internal/damage/stg_mul.mcfunction"])

if '*= #stg_per zx.meta' not in SM:
    bad.append("stg_mul: 乘区还在用写死的 5(/每层 10% 没落地)")
if "run function sweetdream:internal/damage/stg_per" not in SM:
    bad.append("stg_mul: 没有调 stg_per 判「攻击者手里那把」(会让所有天穹都 10%)")
SP2 = body(texts["internal/damage/stg_per.mcfunction"])
if 'zx:["skyvault"],ol:"skyvault"' not in SP2:
    bad.append("stg_per: 没有判 超限·天穹 的主副手")
if "weapon.mainhand" not in SP2 or "weapon.offhand" not in SP2:
    bad.append("stg_per: 主副手没都判")
if "#stg_per zx.meta 10" not in SP2:
    bad.append("stg_per: 超限天穹每层不是 10%")

# ---- 天穹: 三条通道的口径表(连锁段走 other_mul) ----
DEF = io.open(os.path.join(FN, "lib/skill_mul/def.mcfunction"), encoding="utf-8").read()
if "wchan.skyvault set value {mm:1b,atk:1b,oth:1b}" not in DEF:
    bad.append("lib/skill_mul/def: 天穹没标 oth:1b —— 面板会把连锁段那 0.1 漏掉")

# ---- 报告 ----
print("---- 检查 %d 个文件(新 %d / 改 %d)" % (len(texts), len(NEW), len(EDIT)))
if bad:
    for b in bad:
        print("[错] %s" % b)
print("---- 问题 %d 处" % len(bad))
