# ============================================================
# sweetdream:equipment/axe/deep_brine/hit —— 重溟被动入口(平A命中生物之后)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/deep_brine_hit(player_hurt_entity, 只算平A)
#   —— 玩家打到任何生物都会触发。**它不告诉我们打的是谁**, 所以下面要自己找。
# 【执行者】动手的玩家
# 【首行 revoke 自己】不撤的话只有第一次平A会触发(这个坑全包都踩过)。
# 【顺序】revoke -> 满蓄力闸 -> 判手里是不是重溟 -> 进 hit_go。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/deep_brine_hit

# ---- 满蓄力闸(全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 手上(主手或副手)是重溟才生效
scoreboard players set #db_ok zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["deep_brine"]}] run scoreboard players set #db_ok zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["deep_brine"]}] run scoreboard players set #db_ok zx.meta 1
execute if score #db_ok zx.meta matches 1 run function sweetdream:equipment/axe/deep_brine/hit_go
