# ============================================================
# sweetdream:equipment/axe/skyvault/hit —— 天穹被动: 每次平A的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/skyvault_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【首行 revoke 自己】见 lib/rearm。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/skyvault_hit

scoreboard players set #sv_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["skyvault"]}] run scoreboard players set #sv_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["skyvault"]}] run scoreboard players set #sv_ok zx.meta 1
execute if score #sv_ok zx.meta matches 1 run function sweetdream:equipment/axe/skyvault/hit_go
