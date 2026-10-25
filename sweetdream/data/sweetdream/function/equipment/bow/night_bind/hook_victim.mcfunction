execute unless entity @s[tag=zx.status.yehuo] run data remove storage zx:work shot_hit
execute unless data storage zx:work shot_hit{id:"night_bind",paid:1b} run return 0
tag @e[type=#sweetdream:cc_arrow,tag=zx.nb_arrow,distance=0..,limit=1] add zx.review_proc
data modify storage zx:work shot_stack append from storage zx:work shot_hit
data remove storage zx:work shot_hit
function sweetdream:equipment/bow/night_bind/hit
data remove storage zx:work shot_stack[-1]
tag @e[tag=zx.nb_arrow,distance=0..] remove zx.nb_arrow
