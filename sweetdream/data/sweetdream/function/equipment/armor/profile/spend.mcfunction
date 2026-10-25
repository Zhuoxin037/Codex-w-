# 累计每消耗100魔力触发高血目标噬心及下一次其他技能+20%加算；待发增益持续到使用。
scoreboard players remove @s zx.pm_sum 100000
execute at @s as @e[type=#sweetdream:living,type=!minecraft:player,distance=..5] run function sweetdream:equipment/armor/profile/mark_hi
scoreboard players set @s zx.pf_mul 20
scoreboard players set @s zx.pf_mn 1
scoreboard players set @s zx.pf_mt 0
execute at @s run particle minecraft:dust{color:[0.30,0.75,0.72],scale:1.1} ~ ~1 ~ 0.5 0.6 0.5 0.02 16 normal
execute at @s run playsound minecraft:block.amethyst_block.step player @a ~ ~ ~ 0.6 1.3
