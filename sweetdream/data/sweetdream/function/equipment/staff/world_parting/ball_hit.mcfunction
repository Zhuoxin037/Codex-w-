execute unless entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] run return 0
data modify storage zx:work phase4 set from entity @s data
data modify storage zx:work phase4.owner set from entity @s data.uuid
data modify storage zx:work phase4.t0 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[0]
data modify storage zx:work phase4.t1 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[1]
data modify storage zx:work phase4.t2 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[2]
data modify storage zx:work phase4.t3 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[3]
function sweetdream:equipment/staff/world_parting/mark_find with storage zx:work phase4
