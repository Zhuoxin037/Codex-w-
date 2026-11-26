# ============================================================
# fallendream:equipment/armor/lone_walk/off —— 摘下「独行」：撤移速 / 护甲 / 状态
# ============================================================

execute if score @s zx.lw_spd matches 1 run attribute @s minecraft:movement_speed modifier remove fallendream:lw_spd
execute if score @s zx.lw_arm matches 1 run attribute @s minecraft:armor modifier remove fallendream:lw_arm
scoreboard players set @s zx.lw_spd 0
scoreboard players set @s zx.lw_arm 0
scoreboard players set @s zx.lw_on 0
scoreboard players set @s zx.lw_lc 0
