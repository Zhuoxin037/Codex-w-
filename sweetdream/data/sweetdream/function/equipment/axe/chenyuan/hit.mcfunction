# ============================================================
# sweetdream:equipment/axe/chenyuan/hit —— 沉渊被动: 攻击带缓慢的生物的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/chenyuan_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【首行 revoke 自己】不撤的话只有第一次平A会触发(这个坑全包都踩过)。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/chenyuan_hit

# 手上(主手或副手)是沉渊才生效
scoreboard players set #cy_ok zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["chenyuan"]}] run scoreboard players set #cy_ok zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["chenyuan"]}] run scoreboard players set #cy_ok zx.meta 1
execute if score #cy_ok zx.meta matches 1 run function sweetdream:equipment/axe/chenyuan/hit_go
