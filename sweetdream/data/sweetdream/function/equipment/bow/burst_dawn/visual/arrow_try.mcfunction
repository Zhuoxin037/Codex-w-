# @s 是新生真实箭；on origin 锁定真实射手，不按距离猜箭归属。
scoreboard players set #bv_match zx.meta 0
execute on origin if entity @s[type=minecraft:player,scores={zx.bv_seek=1..}] run scoreboard players set #bv_match zx.meta 1
execute unless score #bv_match zx.meta matches 1 run return 0
tag @s add zx.bv_arrow
data modify storage zx:work bva set value {a0:0,a1:0,a2:0,a3:0}
execute store result storage zx:work bva.a0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work bva.a1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work bva.a2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work bva.a3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/burst_dawn/visual/arrow_spawn with storage zx:work bva
