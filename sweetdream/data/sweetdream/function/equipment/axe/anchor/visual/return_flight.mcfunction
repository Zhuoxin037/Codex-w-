$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] run return run kill @s
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..0.8,limit=1] at @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] rotated ~ 0 positioned ^0.35 ^0.35 ^0.55 run return run tp @s ~ ~ ~ ~ 0
data modify storage zx:anchor aim set value {x:0.0d,y:0.0d,z:0.0d}
$data modify storage zx:anchor aim.x set from entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] Pos[0]
$data modify storage zx:anchor aim.z set from entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] Pos[2]
$execute store result score #av_y zx.meta run data get entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] Pos[1] 1000
scoreboard players add #av_y zx.meta 350
execute store result storage zx:anchor aim.y double 0.001 run scoreboard players get #av_y zx.meta
function sweetdream:equipment/axe/anchor/visual/move_return with storage zx:anchor aim
