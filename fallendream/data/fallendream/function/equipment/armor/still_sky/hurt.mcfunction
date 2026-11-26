# ============================================================
# fallendream:equipment/armor/still_sky/hurt —— 「星帷」受击消耗(分流)
# ------------------------------------------------------------
# 【执行者】玩家(batch21/hurt, 已判 job 1 + 戴着静穹 + 伤害来源在场)
# 【基础】消耗 1 法球 + 这一层 → 4 秒 5 点临时生命, 来源 2 秒缓慢Ⅲ
# 【超限】消耗 1 法球 + 其中一层 → 8 秒 最大生命 ×0.1(保底 8 点)临时生命,
#   来源 2 秒缓慢Ⅲ 并附加「白昼梦」; 8 秒内消耗满三层 → 4 秒抗性Ⅴ + 移速 +40%
# ============================================================
scoreboard players set #s2_sky_ol zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["still_sky"],ol:"still_sky"}] run scoreboard players set #s2_sky_ol zx.meta 1
execute if score #s2_sky_ol zx.meta matches 1 run return run function fallendream:equipment/armor/still_sky/hurt_ol

execute unless score @s zx.s2_sky_end > #now manacore.meta run return 0
execute unless score @s zx.j_orb matches 1.. run return 0
function fallendream:equipment/armor/eagle_hat/orb_before
scoreboard players remove @s zx.j_orb 1
function fallendream:equipment/armor/eagle_hat/orb_after
scoreboard players set @s zx.s2_sky_end 0
scoreboard players set @s zx.s2_sky_full 0
scoreboard players set #s2_g_v zx.meta 5000
scoreboard players set #s2_g_t zx.meta 80
function fallendream:batch21/shield/grant
effect give @e[tag=zx.s2_source,distance=0..,limit=1] minecraft:slowness 2 2 true
