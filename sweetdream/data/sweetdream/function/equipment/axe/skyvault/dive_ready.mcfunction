# ============================================================
# sweetdream:equipment/axe/skyvault/dive_ready —— 天穹第二段: 进入俯冲
# ------------------------------------------------------------
# 【执行者】施法者(已跃升、等俯冲)
# 【进入条件】zx.sv_air 在, 且 zx.sv_launch 已经走到 0。
#   （2026-10-04 起 sv_launch 直接设 0 = 跃升到顶即可俯冲; 若以后再加间隔,
#     这里会提示"还在跃升, 稍候再按一次。"并原样保留 zx.sv_air ——
#     上层 cast 靠它判断"该收工"。）
# 【进入俯冲后】摘 zx.sv_air, 挂 zx.sv_dive, 之后的推进交给 core/tick -> dive_tick。
# ============================================================

execute if score @s zx.sv_launch matches 1.. run tellraw @s [{"text":"还在跃升, 稍候再按一次。","color":"gray","italic":true}]
execute if score @s zx.sv_launch matches 1.. run return 0

tag @s remove zx.sv_air
tag @s add zx.sv_dive
scoreboard players set @s zx.sv_step 60
execute at @s run tp @s ^ ^ ^1.5
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.6 0.3 0.6 0.02 20 normal
execute at @s run playsound minecraft:entity.ender_dragon.flap player @a ~ ~ ~ 0.8 1.2
execute at @s run playsound minecraft:item.trident.riptide_2 player @a ~ ~ ~ 0.9 1.0
