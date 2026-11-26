# ============================================================
# fallendream:equipment/armor/breathing_soil/hurt_heal —— 领域内"每次受伤回 1 点"
# ------------------------------------------------------------
# 【谁调用它】breathing_soil/on_hurt（确认自己正站在自己的领域里）
# 【执行者】玩家
# 【文案】
#   基础: "每次受到伤害时恢复 1 点生命值，该效果 2 秒内最多触发一次。"
#   超限: "每次受到伤害时恢复 1 点生命值，之后使该装备的冷却时间 -1 秒，
#          该效果 0.5 秒内最多触发一次。"
# 【★ 节流刻数 ★】基础 40 刻（2 秒）/ 超限 10 刻（0.5 秒）。
# 【★ 冷却 -1 秒 ★】只减"这件装备自己的被动冷却" zx.so_cd（40 秒那一档）；
#   减到早于现在就夹到"现在"，免得账本变成很久以前、下一次触发后被误判成"已经转好"。
# ============================================================

scoreboard players set #so_gap zx.meta 40
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"],ol:"breathing_soil"}] run scoreboard players set #so_gap zx.meta 10
execute if score @s zx.so_hc > #now manacore.meta run return 0

scoreboard players set #heal_pt zx.meta 1
function fallendream:lib/heal

# 超限: 该装备冷却 -1 秒（20 刻），不早于现在
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"],ol:"breathing_soil"}] run scoreboard players remove @s zx.so_cd 20
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["breathing_soil"],ol:"breathing_soil"}] if score @s zx.so_cd < #now manacore.meta run scoreboard players operation @s zx.so_cd = #now manacore.meta

scoreboard players operation @s zx.so_hc = #now manacore.meta
scoreboard players operation @s zx.so_hc += #so_gap zx.meta

execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.3 0.3 0.3 0.02 3 normal
