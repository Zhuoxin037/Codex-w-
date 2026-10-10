# ============================================================
# sweetdream:equipment/axe/skyvault/hit —— 天穹被动: 每次平A的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/skyvault_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【首行 revoke 自己】见 lib/rearm。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/skyvault_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

scoreboard players set #sv_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["skyvault"]}] run scoreboard players set #sv_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["skyvault"]}] run scoreboard players set #sv_ok zx.meta 1
execute if score #sv_ok zx.meta matches 1 run function sweetdream:equipment/axe/skyvault/hit_go
