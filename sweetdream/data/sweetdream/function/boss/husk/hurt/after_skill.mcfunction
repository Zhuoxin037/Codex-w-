# Every successfully received skill, including this pack's true_damage, may charge the window.
function sweetdream:boss/husk/hurt/read
execute unless score @s sdh.pending_ref matches 1.. run return 0
execute if data storage sweetdream:husk skill_kind{dot:1b} run return 0
execute store result storage sweetdream:husk reflect_args.id int 1 run scoreboard players get @s sdh.id
execute store result storage sweetdream:husk reflect_args.amount int 1 run scoreboard players get @s sdh.pending_ref
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,distance=0..,limit=1] run function sweetdream:boss/husk/reflection/capture
