# ============================================================
# sweetdream:equipment/armor/lone_walk/set_lc —— 套装「临敌」的触发（每秒）
# ------------------------------------------------------------
# 【执行者】玩家（已确认穿着「独行」）
# 【★ 套装还要求胸甲是「空营」★】没穿就只更新基线，不触发。
# 【★ 数量变化 = zx.lw_last ≠ #lw_n ★】lw_last 没分数（第一次跑）时只记基线。
# ============================================================

# 没穿空营 ⇒ 只同步基线
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run scoreboard players operation @s zx.lw_last = #lw_n zx.meta
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run return 0

# 首次跑：只记基线
execute unless score @s zx.lw_last matches 0.. run scoreboard players operation @s zx.lw_last = #lw_n zx.meta
execute unless score @s zx.lw_last matches 0.. run return 0

# 数量没变 ⇒ 收工
execute if score @s zx.lw_last = #lw_n zx.meta run return 0
scoreboard players operation @s zx.lw_last = #lw_n zx.meta

# 16 秒冷却
execute if score @s zx.lw_cd > #now manacore.meta run return 0

# 触发 4 秒「临敌」
scoreboard players operation @s zx.lw_lc = #now manacore.meta
scoreboard players add @s zx.lw_lc 80
scoreboard players operation @s zx.lw_cd = #now manacore.meta
scoreboard players add @s zx.lw_cd 320

tellraw @s [{"text":"「临敌」","color":"gold"},{"text":"  护甲值 +4、技能伤害 +10%","color":"gray"}]
particle minecraft:crit ~ ~1 ~ 0.6 0.4 0.6 0.05 12 normal
