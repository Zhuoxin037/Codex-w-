# 原0.5格/刻、22刻上限和1.8格停止距离保持；仅将共用目标改为本次目标UUID。
execute if entity @s[nbt={Health:0.0f}] run return run function sweetdream:equipment/axe/anchor/cancel
function sweetdream:equipment/axe/anchor/visual/dimension
$scoreboard players set #av_expected zx.meta $(dim)
execute unless score #av_dim zx.meta = #av_expected zx.meta run return run function sweetdream:equipment/axe/anchor/cancel
$execute unless entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run scoreboard players set @s zx.an_pull 0
$execute if entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=..1.8,limit=1] run scoreboard players set @s zx.an_pull 0
execute if score @s zx.an_pull matches ..0 run function sweetdream:equipment/axe/anchor/pull_end
execute if score @s zx.an_pull matches ..0 run return 0
$execute at @s facing entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] feet positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
particle minecraft:cloud ~ ~0.1 ~ 0.15 0.1 0.15 0.02 3 normal
scoreboard players remove @s zx.an_pull 1
execute if score @s zx.an_pull matches ..0 run function sweetdream:equipment/axe/anchor/pull_end
