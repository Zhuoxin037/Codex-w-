data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,tag=!zx.j_anchor,tag=!zx.j_shadow,distance=..5,sort=nearest,limit=5]",type:"sweetdream:skill",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
