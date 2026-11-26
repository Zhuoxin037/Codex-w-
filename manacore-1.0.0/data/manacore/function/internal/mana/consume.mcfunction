# ------------------------------------------------------------
# internal/mana/consume —— 魔力消耗判定(技能前置检查的核心)
# 【宏参数】manacore:work.a {uuid,value}
# 【出参】out.success = 1b(够, 且已扣除) / 0b(不够, 什么都没扣)
#         out.reason  = "ok" / "mana"
# 【逻辑】#cur >= #need ? consume_ok : consume_fail
# 【关键点】"不够就不扣"——所以只要看到 out.success=0b, 调用方就应该
#         直接中断技能, 不会出现"扣了魔力却没放出技能"的情况。
# 【技能流程里的位置】api/skill/cast 第 2 步。
#
# 【★ 这里曾经有一个非常隐蔽的 bug, 别改回去 ★】
#   原来写成"先判 >= 就扣, 再判 < 就报不够"——本意是模拟 if/else。
#   但 consume_ok 会把 #cur 减去 #need, 也就是**它会改掉第二行判断的输入**!
#   扣完之后 #cur 变小, 第二行的 "#cur < #need" 必然成立, 于是 consume_fail
#   又跑了一遍, 把 success 覆盖成 0b。
#   现象: **魔力明明扣掉了, 却报告"不够"**(而且是扣款成功的那一次报错)。
#   触发条件: 旧魔力 - 消耗 < 消耗, 也就是**魔力不到消耗的两倍**时必现。
#   现在改成"先算出一个开关 #ok, 两个分支都只看 #ok"——判断和动作分离,
#   顺序再也不会影响结果。
# ------------------------------------------------------------
execute store result score #need manacore.math run data get storage manacore:work a.value 1000
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000

# ---- 魔耗减免(2026-11-22, fallendream「超限·共振」用) ----
#   stats.mana_cost_multiplier 是"要扣的量"的倍率(默认 1.0 = 不打折)。
#   只乘 #need —— 判断够不够与真正扣除用的是同一个值, 不会出现"判得多扣得少"。
#   ★ 门控写 matches 1001.. ★ 老玩家记录里没有这个键时 data get 失败、
#     #mcm 保持上一行的 0 ⇒ 不乘 ⇒ 行为与改动前完全一致(不 return, 因为后面
#     的判定还要照常跑)。
#   ★ 中间量按 ×1000 走 ★ value 与 multiplier 都是毫点/千分比例, 乘完再除 1000。
#   ★ R05 上界保护: #need × #mcm 前先夹到 INT32_MAX ÷ #mcm ★ 技能魔耗是千分整数,
#     极端值(几百上千点的耗蓝 × 千分倍率)会越过 2,147,483,647 回绕成负数, 静默。
scoreboard players set #mcm manacore.math 0
$execute store result score #mcm manacore.math run data get storage manacore:players "$(uuid)".stats.mana_cost_multiplier 1000
execute if score #mcm manacore.math matches 1001.. run scoreboard players set #mcm_cap manacore.math 2147483647
execute if score #mcm manacore.math matches 1001.. run scoreboard players operation #mcm_cap manacore.math /= #mcm manacore.math
execute if score #mcm manacore.math matches 1001.. if score #need manacore.math > #mcm_cap manacore.math run scoreboard players operation #need manacore.math = #mcm_cap manacore.math
execute if score #mcm manacore.math matches 1001.. run scoreboard players operation #need manacore.math *= #mcm manacore.math
execute if score #mcm manacore.math matches 1001.. run scoreboard players set #mcm_k manacore.math 1000
execute if score #mcm manacore.math matches 1001.. run scoreboard players operation #need manacore.math /= #mcm_k manacore.math

# 先把"够不够"定下来, 再动手 —— 两个分支只读 #ok, 谁都不会改到判断依据
scoreboard players set #ok manacore.math 0
execute if score #cur manacore.math >= #need manacore.math run scoreboard players set #ok manacore.math 1
execute if score #ok manacore.math matches 1 run function manacore:internal/mana/consume_ok with storage manacore:work a
execute if score #ok manacore.math matches 0 run function manacore:internal/mana/consume_fail
