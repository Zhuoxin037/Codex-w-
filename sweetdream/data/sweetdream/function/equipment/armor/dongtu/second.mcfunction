# ============================================================
# sweetdream:equipment/armor/dongtu/second —— 「冻土」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家（lib/second 每秒对 zx.dng_on=1 的玩家调）
# 【顺序】先 -1 秒；到 0 就先 stop（这一秒不再回血），否则回血 + 续抗性。
# 【★ 坑 199】lib/heal 自带重入保护，且这里一秒只调一次 —— 安全。
# ============================================================
scoreboard players remove @s zx.dng_l 1
execute if score @s zx.dng_l matches ..0 run function sweetdream:equipment/armor/dongtu/stop
execute unless score @s zx.dng_on matches 1 run return 0

scoreboard players operation #heal_pt zx.meta = @s zx.dng_hp
execute if score #heal_pt zx.meta matches 1.. run function sweetdream:lib/heal
effect give @s minecraft:resistance 1 0 true

execute at @s run particle minecraft:snowflake ~ ~0.1 ~ 0.45 0.05 0.45 0.01 10 normal
execute at @s run particle minecraft:dust{color:[0.72,0.83,0.9],scale:0.9} ~ ~0.15 ~ 0.5 0.08 0.5 0.008 8 normal
