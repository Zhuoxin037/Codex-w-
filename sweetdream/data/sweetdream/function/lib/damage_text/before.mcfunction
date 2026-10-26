execute unless data storage zx:config damage_text{enabled:1b} run return 0
execute if entity @s[type=minecraft:player] run return 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0
function sweetdream:lib/entity_id
function sweetdream:lib/damage_text/sample
data modify storage zx:work hit_success_stack[-1].float set value {open:1b,hp:0,ab:0,sid:0,children:0}
execute store result storage zx:work hit_success_stack[-1].float.hp int 1 run scoreboard players get @s zx.dt_hp
execute store result storage zx:work hit_success_stack[-1].float.ab int 1 run scoreboard players get @s zx.dt_ab
execute store result storage zx:work hit_success_stack[-1].float.sid int 1 run scoreboard players get @s zx.sid
