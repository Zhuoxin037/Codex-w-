# ============================================================
# sweetdream:equipment/armor/dongtu/start —— 进入「冻土」
# ------------------------------------------------------------
# 【执行者】玩家
# 【算出每秒回多少】最大生命（attribute minecraft:max_health get，含修饰符）× 3 ÷ 100，
#   向下取整，至少 1 点。存进 zx.dng_hp，之后每秒直接用这个数（不再重复读属性）。
# 【为什么读属性而不是面板缓存】坑 199 的同类教训：任何"临时压低上限"的机制
#   都会让缓存变成假值。这里只在进入的那一瞬读一次，且此时没有临时补丁在场。
# ============================================================
scoreboard players set @s zx.dng_on 1
scoreboard players set @s zx.dng_l 6

execute store result score #dng_mh zx.meta run attribute @s minecraft:max_health get
scoreboard players set #dng_k zx.meta 3
scoreboard players operation #dng_h zx.meta = #dng_mh zx.meta
scoreboard players operation #dng_h zx.meta *= #dng_k zx.meta
scoreboard players operation #dng_h zx.meta /= #100 zx.meta
execute if score #dng_h zx.meta matches ..0 run scoreboard players set #dng_h zx.meta 1
scoreboard players operation @s zx.dng_hp = #dng_h zx.meta

effect give @s minecraft:resistance 1 0 true
execute at @s run particle minecraft:snowflake ~ ~0.1 ~ 0.6 0.1 0.6 0.02 24 normal
execute at @s run particle minecraft:dust{color:[0.72,0.83,0.9],scale:1.2} ~ ~0.2 ~ 0.7 0.1 0.7 0.01 16 normal
execute at @s run playsound minecraft:block.powder_snow.place player @a ~ ~ ~ 0.7 0.9
