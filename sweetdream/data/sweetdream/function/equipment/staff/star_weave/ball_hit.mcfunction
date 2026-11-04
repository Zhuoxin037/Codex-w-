execute unless entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] run return 0
data modify storage zx:work weave set from entity @s data
data modify storage zx:work weave.owner set from entity @s data.uuid
data modify storage zx:work weave.t0 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[0]
data modify storage zx:work weave.t1 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[1]
data modify storage zx:work weave.t2 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[2]
data modify storage zx:work weave.t3 set from entity @e[tag=zx.ball_hit,distance=..4,sort=nearest,limit=1] UUID[3]
function sweetdream:equipment/staff/star_weave/mark_find with storage zx:work weave
