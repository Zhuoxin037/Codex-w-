execute unless entity @s[tag=sd.hk.body] run return 0
function sweetdream:boss/husk/hurt/read
execute unless score @s sdh.pending_ref matches 1.. run return 0
execute store result storage sweetdream:husk reflect_args.id int 1 run scoreboard players get @s sdh.id
execute store result storage sweetdream:husk reflect_args.amount int 1 run scoreboard players get @s sdh.pending_ref
execute on attacker run function sweetdream:boss/husk/reflection/capture
