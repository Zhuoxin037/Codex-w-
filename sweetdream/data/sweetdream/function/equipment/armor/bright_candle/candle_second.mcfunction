scoreboard players add @s zx.bc_next 20
data modify storage zx:work ub set value {}
data modify storage zx:work ub.u0 set from entity @s data.zx.u[0]
data modify storage zx:work ub.u1 set from entity @s data.zx.u[1]
data modify storage zx:work ub.u2 set from entity @s data.zx.u[2]
data modify storage zx:work ub.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,distance=..5,limit=1] run function sweetdream:equipment/armor/bright_candle/regen
