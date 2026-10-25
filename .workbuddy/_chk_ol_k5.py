# -*- coding: utf-8 -*-
"""_chk_ol_k5.py —— 超限机制 批 K5(斧: 剜霜 / 歌谣 / 沉渊)自检

这一批的"不报错、只是不生效"死法:

  ① 分流判据写错 —— 判的不是这一件的 ol 值 / 漏了副手。
  ② 引用了不存在的函数 —— 链条在那一行断掉(前面扣的蓝和冷却照扣)。
  ③ 计分项没在 core/load 声明 —— 分数永不存在, `if score` 恒假。
  ④ 宏函数调用点漏了 `with storage` —— 报"缺少传入参数", 整条调用失败。
  ⑤ 顺序错:
      · 歌谣的"攻击攒层"(ol_tune) 必须排在**清空曲调之后** —— 否则刚攒的那层
        会被本次奏响当场用掉(X 变 X+1);
      · 剜霜的受击钩子必须排在 internal/damage/who **之后**(攻击者靠 zx.d_by 认人);
      · 沉渊的加算 hook 必须排在 lib/dmg_add_apply **之前**(否则 10% 永远不算)。
  ⑥ 每刻/每秒的驱动缺失: 音符(d) 只活 20 刻、披霜(e) 是 12 秒 —— 挂错层级等于没有。
  ⑦ 数值没落地: 300/35/×6/×3/60 刻/20%; 300/20 秒/9-X/×X; 200/8 秒/全选/0.1/80/+10%。

用法: python .workbuddy/_chk_ol_k5.py
"""
import io
import json
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
FN = BASE + "/function"

NEW = [
    "equipment/axe/frost_carve/ol_wing.mcfunction",
    "equipment/axe/frost_carve/ol_wing_tick.mcfunction",
    "equipment/axe/frost_carve/ol_ice.mcfunction",
    "equipment/axe/frost_carve/on_hurt.mcfunction",
    "equipment/axe/ballad/ol_tune.mcfunction",
    "equipment/axe/ballad/ol_spawn.mcfunction",
    "equipment/axe/ballad/ol_pick.mcfunction",
    "equipment/axe/ballad/ol_note_spawn.mcfunction",
    "equipment/axe/ballad/ol_note_tick.mcfunction",
    "equipment/axe/ballad/ol_note_go.mcfunction",
    "equipment/axe/ballad/ol_note_line.mcfunction",
    "equipment/axe/chenyuan/hook_calc.mcfunction",
]

EDIT = [
    "equipment/axe/frost_carve/cast.mcfunction",
    "equipment/axe/frost_carve/apply.mcfunction",
    "equipment/axe/frost_carve/heal_self.mcfunction",
    "equipment/axe/ballad/cast.mcfunction",
    "equipment/axe/ballad/hit.mcfunction",
    "equipment/axe/ballad/kill.mcfunction",
    "equipment/axe/chenyuan/cast.mcfunction",
    "equipment/axe/chenyuan/extra.mcfunction",
    "equipment/axe/chenyuan/dmg_buff.mcfunction",
    "equipment/axe/chenyuan/mana_back.mcfunction",
    "internal/damage/deal.mcfunction",
    "lib/second.mcfunction",
    "lib/rearm.mcfunction",
    "core/tick.mcfunction",
    "core/load.mcfunction",
]

DAMAGE_CALC = "D:/数据包/sweetdream/data/manacore/tags/function/event/damage_calc.json"

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


# ---- ① 三件的分流判据 ----
for rel, oid in [
    ("equipment/axe/frost_carve/cast.mcfunction", "frost_carve"),
    ("equipment/axe/ballad/cast.mcfunction", "ballad"),
    ("equipment/axe/chenyuan/cast.mcfunction", "chenyuan"),
]:
    t = body(texts.get(rel, ""))
    want = 'diamond_axe[minecraft:custom_data~{zx:["%s"],ol:"%s"}]' % (oid, oid)
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
for marker in ["ballad/ol_pick with storage",
               "ballad/ol_note_spawn with storage",
               "ballad/ol_note_go with storage"]:
    hits = sum(body(t).count(marker) for t in texts.values())
    if hits < 1:
        bad.append("宏函数调用点缺失: 没有任何 `%s`(会报缺少传入参数)" % marker)

# ================= 剜霜 frost_carve =================
FC = "equipment/axe/frost_carve/cast.mcfunction"
if "arg.mana set value 300.0" not in body(texts[FC]):
    bad.append("frost_carve/cast: 超限魔力不是 300")
if "arg.cooldown_seconds set value 35.0" not in body(texts[FC]):
    bad.append("frost_carve/cast: 超限冷却不是 35 秒")
if "arg.attack_mul set value 6.0" not in body(texts[FC]):
    bad.append("frost_carve/cast: 重击不是 ×6")
if "arg.attack_mul set value 3.0" not in body(texts[FC]):
    bad.append("frost_carve/cast: 解冻附伤不是 ×3")
if "frc.icz set value 60" not in body(texts[FC]):
    bad.append("frost_carve/cast: 超限冰冻不是 60 刻(3 秒)")
if "frc.pct set value 20" not in body(texts[FC]):
    bad.append("frost_carve/cast: 超限回血不是 20%")
if "frc.ol set value 1" not in body(texts[FC]):
    bad.append("frost_carve/cast: 没写超限标记 frc.ol(「披霜」挂不上)")
if "frost_carve/ol_wing" not in body(texts[FC]):
    bad.append("frost_carve/cast: 没调 ol_wing(披霜不生效)")

AP = body(texts["equipment/axe/frost_carve/apply.mcfunction"])
if "fz.ticks set from storage zx:work frc.icz" not in AP:
    bad.append("frost_carve/apply: 冰冻刻数没从 frc.icz 取(超限还是 1 秒)")
HS = body(texts["equipment/axe/frost_carve/heal_self.mcfunction"])
if "frc.pct" not in HS:
    bad.append("frost_carve/heal_self: 回血百分比没走 frc.pct")
OW = body(texts["equipment/axe/frost_carve/ol_wing.mcfunction"])
if "zx.frc_fr 3" not in OW:
    bad.append("frost_carve/ol_wing: 层数不是 3")
if "zx.frc_ft 12" not in OW:
    bad.append("frost_carve/ol_wing: 时长不是 12 秒")
if "unless data storage zx:work frc{ol:1}" not in OW:
    bad.append("frost_carve/ol_wing: 没有超限门(常态也会挂披霜)")
OH = body(texts["equipment/axe/frost_carve/on_hurt.mcfunction"])
if "remove @s zx.frc_fr 1" not in OH:
    bad.append("frost_carve/on_hurt: 受击没消耗一层")
if "hit_scan_exclude" not in OH:
    bad.append("frost_carve/on_hurt: 没有按先例找最近的非玩家实体(攻击者)")
if "frost_carve/ol_ice" not in OH:
    bad.append("frost_carve/on_hurt: 没有调 ol_ice")
if "advancement revoke @s only sweetdream:equipment/axe/frost_carve_hurt" not in OH:
    bad.append("frost_carve/on_hurt: 首行没 revoke 自己(一次受伤后就永久失效)")
advf = "D:/数据包/sweetdream/data/sweetdream/advancement/equipment/axe/frost_carve_hurt.json"
if not os.path.exists(advf):
    bad.append("缺进度: advancement/equipment/axe/frost_carve_hurt.json(受击触发不了)")
else:
    js = json.load(io.open(advf, encoding="utf-8"))
    if js.get("rewards", {}).get("function") != "sweetdream:equipment/axe/frost_carve/on_hurt":
        bad.append("frost_carve_hurt.json: rewards.function 不是 frost_carve/on_hurt")
    if "entity_hurt_player" not in json.dumps(js):
        bad.append("frost_carve_hurt.json: 触发条件不是 entity_hurt_player")
REARM = body(texts.get("lib/rearm.mcfunction", ""))
if "advancement revoke @a only sweetdream:equipment/axe/frost_carve_hurt" not in REARM:
    bad.append("lib/rearm: 没登记 frost_carve_hurt —— 奖励函数被跳过一次就永久卡死")
OI = body(texts["equipment/axe/frost_carve/ol_ice.mcfunction"])
if "distance=..3" not in OI or "ticks:40" not in OI:
    bad.append("frost_carve/ol_ice: 不是「攻击者 3 格内 / 2 秒(40 刻)」")
if "tag=!zx.frc_self" not in OI:
    bad.append("frost_carve/ol_ice: 没排除受害者自己(近战会把自己冻住)")

DEAL = body(texts["internal/damage/deal.mcfunction"])
if "equipment/axe/frost_carve/on_hurt" in DEAL:
    bad.append("internal/damage/deal: 又挂了剜霜的受击钩子 —— 会和进度重复, 一次受击扣两层")

SEC = body(texts["lib/second.mcfunction"])
if "scores={zx.frc_ft=1..}] run function sweetdream:equipment/axe/frost_carve/ol_wing_tick" not in SEC:
    bad.append("lib/second: 没有「披霜」的每秒推进(12 秒永不到期)")

# ================= 歌谣 ballad =================
BC = "equipment/axe/ballad/cast.mcfunction"
if "arg.mana set value 300.0" not in body(texts[BC]):
    bad.append("ballad/cast: 超限魔力不是 300")
if "arg.cooldown_seconds set value 20.0" not in body(texts[BC]):
    bad.append("ballad/cast: 超限冷却不是 20 秒")
if "bdly.ol set value 1" not in body(texts[BC]):
    bad.append("ballad/cast: 没写超限标记 bdly.ol")

BH = "equipment/axe/ballad/hit.mcfunction"
if "ballad/ol_tune" not in body(texts[BH]):
    bad.append("ballad/hit: 没有调 ol_tune(攻击攒层不生效)")
if "ballad/ol_spawn" not in body(texts[BH]):
    bad.append("ballad/hit: 没有调 ol_spawn(音符不召唤)")
i_clr = where(BH, "scoreboard players set @s zx.bd_tune 0")
i_tune2 = [i for i, l in enumerate(lines(BH), 1) if "ballad/ol_tune" in l]
if i_clr > 0 and i_tune2:
    # 奏响分支里那次 ol_tune 必须排在清层之后
    later = [i for i in i_tune2 if i > i_clr]
    if not later:
        bad.append("ballad/hit: 奏响分支的 ol_tune 排在清层**之前** —— 刚攒的层会被当场用掉")
BK = body(texts["equipment/axe/ballad/kill.mcfunction"])
if "zx.blt_lt = #now manacore.meta run return 0" not in BK:
    bad.append("ballad/kill: 没有同刻去重(一击必杀会加两点曲调)")

BT = body(texts["equipment/axe/ballad/ol_tune.mcfunction"])
if "unless data storage zx:work bdly{ol:1}" not in BT:
    bad.append("ballad/ol_tune: 没有超限门(常态也会攻击攒层)")
if "zx.bd_tune matches 8.." not in BT:
    bad.append("ballad/ol_tune: 没有 8 层上限")

BS = body(texts["equipment/axe/ballad/ol_spawn.mcfunction"])
if "#bdn zx.meta 9" not in BS or "#bdn zx.meta -= #bd_x zx.meta" not in BS:
    bad.append("ballad/ol_spawn: 个数不是 9-X")
if "arg.attack_mul double 1 run scoreboard players get #bd_x" not in BS:
    bad.append("ballad/ol_spawn: 路径伤害不是 基础攻击力 × X")
if "nt.sx set from entity @s Pos[0]" not in BS:
    bad.append("ballad/ol_spawn: 没有记起点坐标(结算时找不到起点)")
BP = body(texts["equipment/axe/ballad/ol_pick.mcfunction"])
if "distance=0.1..$(x)" not in BP or "limit=$(n)" not in BP:
    bad.append("ballad/ol_pick: 范围/个数不是分开传的 $(x) / $(n)")

NS = body(texts["equipment/axe/ballad/ol_note_spawn.mcfunction"])
if 'Tags:["zx.bd_note"' not in NS:
    bad.append("ballad/ol_note_spawn: 音符没有 zx.bd_note 标签(core/tick 推不动)")
if "zx.nt_t 20" not in NS:
    bad.append("ballad/ol_note_spawn: 倒计时不是 20 刻(1 秒)")
NT = body(texts["equipment/axe/ballad/ol_note_tick.mcfunction"])
if "ol_note_go with storage" not in NT:
    bad.append("ballad/ol_note_tick: 到点没有结算")
NG = body(texts["equipment/axe/ballad/ol_note_go.mcfunction"])
if 'type:"sweetdream:true_damage"' not in NG:
    bad.append("ballad/ol_note_go: 路径伤害不是真实伤害")
if "positioned $(sx) $(sy) $(sz) facing entity @s feet" not in NG:
    bad.append("ballad/ol_note_go: 起点->终点不是靠 facing entity @s feet 定的")
if "kill @s" not in NG:
    bad.append("ballad/ol_note_go: 到点没有自毁")
NL = body(texts["equipment/axe/ballad/ol_note_line.mcfunction"])
if "positioned ^ ^ ^1.5 run function sweetdream:equipment/axe/ballad/ol_note_line" not in NL:
    bad.append("ballad/ol_note_line: 自递归那行不对(带 at @s 会卡在原地)")
if "distance=..1.3" not in NL:
    bad.append("ballad/ol_note_line: 采样半径不是 1.3(会把自己算进路径)")
CT = body(texts["core/tick.mcfunction"])
if CT.count("as @e[tag=zx.bd_note,distance=0..] at @s run function sweetdream:equipment/axe/ballad/ol_note_tick") < 3:
    bad.append("core/tick: 音符不是三维度各一遍")

# ================= 沉渊 chenyuan =================
CC = "equipment/axe/chenyuan/cast.mcfunction"
if "arg.mana set value 200.0" not in body(texts[CC]):
    bad.append("chenyuan/cast: 超限魔力不是 200")
if "arg.cooldown_seconds set value 8.0" not in body(texts[CC]):
    bad.append("chenyuan/cast: 超限冷却不是 8 秒")
if "cy.ol set value 1" not in body(texts[CC]):
    bad.append("chenyuan/cast: 没写超限标记 cy.ol")
CE = body(texts["equipment/axe/chenyuan/extra.mcfunction"])
if "if data storage zx:work cy{ol:1} at @s as @e[tag=zx.cy_pool] run tag @s add zx.cy_x" not in CE:
    bad.append("chenyuan/extra: 超限没有改成「6 格内全部」")
if "unless data storage zx:work cy{ol:1} at @s as @e[tag=zx.cy_pool,sort=random,limit=3]" not in CE:
    bad.append("chenyuan/extra: 常态的「额外 3 个」分支不见了")
CD = body(texts["equipment/axe/chenyuan/dmg_buff.mcfunction"])
if "arg.max_mana_mul set value 0.1" not in CD:
    bad.append("chenyuan/dmg_buff: 超限伤害不是最大魔力 ×0.1")
CM = body(texts["equipment/axe/chenyuan/mana_back.mcfunction"])
if "arg.value set value 80.0" not in CM:
    bad.append("chenyuan/mana_back: 超限回魔不是 80")
if "zx.cy_mmn 1" not in CM:
    bad.append("chenyuan/mana_back: 没有挂「下一个最大魔力技能 +10%」")
CH = body(texts["equipment/axe/chenyuan/hook_calc.mcfunction"])
if "# @calc: add" not in texts["equipment/axe/chenyuan/hook_calc.mcfunction"]:
    bad.append("chenyuan/hook_calc: 缺少 `# @calc: add` 声明(排位无法被 check 判)")
if "zx.cy_mmn" not in CH:
    bad.append("chenyuan/hook_calc: 没有判 zx.cy_mmn")
if "max_mana_mul 100" not in CH:
    bad.append("chenyuan/hook_calc: 没有判「本次走没走 mm 通道」")
if "zx.cy_mml" not in CH:
    bad.append("chenyuan/hook_calc: 没有同刻去重(多目标会 +20%)")

if os.path.exists(DAMAGE_CALC):
    vals = json.load(io.open(DAMAGE_CALC, encoding="utf-8")).get("values", [])
    hc = "sweetdream:equipment/axe/chenyuan/hook_calc"
    ap = "sweetdream:lib/dmg_add_apply"
    if hc not in vals:
        bad.append("damage_calc.json: 沉渊的 hook_calc 没登记(写了但永远不生效)")
    elif ap in vals and vals.index(hc) > vals.index(ap):
        bad.append("damage_calc.json: 沉渊的加算 hook 排在 dmg_add_apply 之后 —— 10% 永远不算")
else:
    bad.append("缺 damage_calc.json")

# ---- 报告 ----
print("---- 检查 %d 个文件(新 %d / 改 %d)" % (len(texts), len(NEW), len(EDIT)))
if bad:
    for b in bad:
        print("[错] %s" % b)
print("---- 问题 %d 处" % len(bad))
