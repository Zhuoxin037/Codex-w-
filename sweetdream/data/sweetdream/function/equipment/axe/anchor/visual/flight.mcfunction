$execute unless entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run return run kill @s
# 最后2格贴到目标上方，避免越过目标反复穿梭；方向始终指向锁定目标。
$execute if entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=..2,limit=1] at @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] rotated as @s rotated ~ 0 run return run tp @s ~ ~0.9247258234534629 ~ ~ 0
data modify storage zx:anchor aim set value {x:0.0d,y:0.0d,z:0.0d}
$data modify storage zx:anchor aim.x set from entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] Pos[0]
$data modify storage zx:anchor aim.z set from entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] Pos[2]
$execute store result score #av_y zx.meta run data get entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] Pos[1] 1000
scoreboard players add #av_y zx.meta 925
execute store result storage zx:anchor aim.y double 0.001 run scoreboard players get #av_y zx.meta
function sweetdream:equipment/axe/anchor/visual/move with storage zx:anchor aim
particle minecraft:cloud ~ ~ ~ 0.06 0.06 0.06 0.01 1 normal
