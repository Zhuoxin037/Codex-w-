$execute unless entity $(uuid) run return 0
$data modify storage zx:work a set value {target:"$(uuid)",type:"fallendream:true_damage",fixed:1b,uncapped:1b,attack_kind:"extra",chain:0,num:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work a.num double 1 run data get storage zx:ft frames[-1].f.fixed
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:lib/num/plain
function fallendream:internal/damage/with_from with storage zx:work a
$function fallendream:tag/mark {target:"$(uuid)",mark:"shixin"}
