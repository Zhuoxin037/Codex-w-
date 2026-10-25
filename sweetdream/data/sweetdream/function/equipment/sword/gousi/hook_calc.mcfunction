# ============================================================
# sweetdream:equipment/sword/gousi/hook_calc —— 超限·钩丝: 下三次技能伤害 +10%
# ------------------------------------------------------------
# @calc: indep   ← "独立乘区"型 hook: 必须排在 lib/dmg_add_apply **之后**
# 【谁调用它】#manacore:event/damage_calc(lib/dmg_add_apply 之后)
# 【文案】超限·钩丝: "每拉到一个都会使自身下三次技能伤害 +10%（独立乘区）" /
#   "若中途未能拉到…则使自身下一次技能伤害 +10%"
# 【数据】zx.gs3p = 百分点(0/10/20/30, 封顶 30) / zx.gs3n = 剩余次数(0..3)
#   ★ 三层是**共享**的三次, 不是"每层各三次"(已定口径) —— 见 ol_buff_land。
# 【★ 乘在哪 ★】r.damage 到这里已经过"三通道 + 加算池", 再乘一道 (100+p)/100
#   就是文案说的独立乘区 —— 和愠怒 / 炽天使同一个位置、同一个做法。
# 【★ 次数按"一次技能"消费, 不是"一只目标" ★】damage/calc 每次施法只算一次,
#   结果再分发给每只目标(见 api/damage)。所以这里减 1 = 用掉一次, 与目标数无关。
# 【★ 同刻去重 zx.gs3lt ★】有些技能**一次施法要 calc 好几遍**(剖心 cast 就要
#   d5 / d8 / half 三遍), 不去重的话一次施法就吃掉三次、"下三次"变成"下一次"。
#   反过来: 同刻的多遍 calc 都会吃到这份加成 —— 那正是想要的(同一个技能的各段一起加)。
# 【★ 已知边界: @s 必须是玩家 ★】与 mm_add / 愠怒同一条: 以 marker / 生物为执行者
#   算出来的伤害吃不到这份加成。它们算的是怪物自己的伤害, 本来也不该吃。
# ============================================================

# ⓪ 不是玩家 -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 没有加成 -> 不参与
execute unless score @s zx.gs3p matches 1.. run return 0
execute unless score @s zx.gs3n matches 1.. run return 0

# ② r.damage 换成 ×1000 定点(data get 的第三段是**乘数**, 1000 = 取三位小数)
scoreboard players set #g3d zx.meta 0
execute store result score #g3d zx.meta run data get storage manacore:out r.damage 1000
execute if score #g3d zx.meta matches ..0 run return 0

# ③ × (100 + p) / 100
#   ★ mul_pct 的 obj 参数必须写 zx.meta ★ 本文件的分全在这个 objective,
#     漏了它会去 manacore.math 读输入, 一律读成 0(见 lib/dmg_add_apply 的 A01 那段)。
scoreboard players set #g3k zx.meta 100
scoreboard players operation #g3k zx.meta += @s zx.gs3p
function manacore:internal/damage/mul_pct {src:"#g3d",mul:"#g3k",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta

# ④ 消费: 同一刻只算一次
execute if score @s zx.gs3lt = #now manacore.meta run return 0
scoreboard players operation @s zx.gs3lt = #now manacore.meta
scoreboard players remove @s zx.gs3n 1
execute if score @s zx.gs3n matches ..0 run scoreboard players set @s zx.gs3p 0
