# ============================================================
# sweetdream:equipment/sword/yebu/upgrade —— 把目标从缓慢Ⅰ 升到 缓慢Ⅱ
# ------------------------------------------------------------
# 【执行者】被命中的生物
# 【只在 slow.mcfunction 的 ① 分支里调用】—— 那里已经保证"它此刻确实在缓慢中，
#   且这次升级不在 4 秒冷却内"，所以这里不再重复判断。
# ============================================================
effect give @s minecraft:slowness 3 1 true
scoreboard players operation @s zx.yb = #yb_now zx.meta
scoreboard players add @s zx.yb 60
scoreboard players operation @s zx.ybu = #yb_now zx.meta
scoreboard players add @s zx.ybu 80
execute at @s run particle minecraft:dust{color:[0.42,0.5,0.62],scale:1.1} ~ ~0.45 ~ 0.45 0.5 0.45 0.005 12 normal
execute at @s run particle minecraft:snowflake ~ ~0.5 ~ 0.3 0.4 0.3 0.01 6 normal
execute at @s run playsound minecraft:block.powder_snow.step player @a ~ ~ ~ 0.5 1.4
