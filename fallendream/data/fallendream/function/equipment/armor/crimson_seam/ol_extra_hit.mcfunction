$execute unless entity $(vx_uuid) run return 0
scoreboard players set #crx zx.meta 0
execute store result score #crx zx.meta run data get storage zx:combat events[-1].event.actual
execute unless score #crx zx.meta matches 1.. run return 0
data modify storage zx:work a set value {fixed:1b,uncapped:1b,type:"fallendream:true_damage",attack_kind:"extra"}
$data modify storage zx:work a.target set value "$(vx_uuid)"
execute store result storage zx:work a.num double 0.001 run scoreboard players get #crx zx.meta
function fallendream:lib/num/plain
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:internal/damage/with_from with storage zx:work a
