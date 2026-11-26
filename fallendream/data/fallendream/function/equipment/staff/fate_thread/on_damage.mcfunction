$scoreboard players set #ft_actual zx.meta $(actual)
execute if score #ft_actual zx.meta matches ..0 run return 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
$execute as @a[tag=zx.ub,tag=zx.ft_link,limit=1] at @s run function fallendream:equipment/staff/fate_thread/damage_owner {source:"$(vx_uuid)",actual:$(actual)}
