# ============================================================
# fallendream:equipment/armor/breathing_soil/field_tick —— 息土领域每秒结算
# ------------------------------------------------------------
# 【谁调它】lib/second 对 `@a[scores={zx.so_ft=1..}]` 每人跑一次
# 【每秒】恢复 3 点生命值（走 lib/heal：坑 199 的上限重入问题由它内部处理）
# 【12 秒】zx.so_ft 从 12 减到 0，到 0 收场
# ============================================================
scoreboard players remove @s zx.so_ft 1

# 每秒回血: 基础 3 点 / 超限 4 点
scoreboard players set #heal_pt zx.meta 3
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"],ol:"breathing_soil"}] run scoreboard players set #heal_pt zx.meta 4
function fallendream:lib/heal

execute at @s run particle minecraft:dust{color:[0.4,0.62,0.32],scale:1.2} ~ ~0.15 ~ 3.2 0.1 3.2 0.01 18 normal
execute at @s run particle minecraft:heart ~ ~1.1 ~ 0.5 0.4 0.5 0.01 3 normal
execute at @s run particle minecraft:composter ~ ~0.2 ~ 2.4 0.1 2.4 0.02 8 normal

execute if score @s zx.so_ft matches ..0 run function fallendream:equipment/armor/breathing_soil/field_end
