# ============================================================
# sweetdream:equipment/sword/remelt/hit —— 热熔: 每次平A的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/remelt_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【这一下做两件事, 但**两件事的计数口径不一样** —— 顺序不能随便调 ★】
#   ② 20% 把"刚打中的那只"的「流火」转成「夜火」(convert)
#      文案是"每次攻击附加了流火的**生物**" = 按**命中数**算 -> 打 3 只就掷 3 次骰子。
#   ① 「熔解」状态开着 -> 对自身 8 格内带「夜火」的生物打一次 + 融甲(strike)
#      文案是"每**攻击一次**" = 一次平A只算一次(玩家 2026-10-07 口径) -> 要按刻去重。
# 【★ 为什么①排在最后, 且它的 return 安全】①的去重靠 `run return 0` 提前退出, 而 return
#   中断的是**整个函数** —— 所以"按命中数"的②必须排在①**之前**。
#   ★ 以后往本函数加新东西, 一律加在①之前(排在①后面 = 会被同刻第二次调用的 return 吞掉)。
# 【为什么①不看主手】状态是施法给的, 文案没说换手会失效; 只要求"攻击"这个动作。
# 【武器判定放在②】被动"每次攻击附加流火效果的生物"是这把武器的被动, 所以要判穿着。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/remelt_hit

# ② 被动(按命中数, 不去重): 手上(主手或副手)是热熔才继续
scoreboard players set #rm_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_sword[custom_data~{zx:["remelt"]}] run scoreboard players set #rm_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_sword[custom_data~{zx:["remelt"]}] run scoreboard players set #rm_ok zx.meta 1
execute if score #rm_ok zx.meta matches 1 run function sweetdream:equipment/sword/remelt/convert

# ① 熔解状态(按刻去重): 同一次平A只结算一次 —— 横扫打 3 只不再打 3 轮
#   ⚠️ 这行 return 之后本函数就结束了, 新内容一律加在上面 ★
execute if score @s zx.rm_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.rm_lt = #now manacore.meta
execute if score @s zx.rm_on matches 1.. run function sweetdream:equipment/sword/remelt/strike
