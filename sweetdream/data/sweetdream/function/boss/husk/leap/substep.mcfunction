scoreboard players set @s sdh.moved 0
$execute at @s positioned ~$(x) ~$(y) ~$(z) run function sweetdream:boss/husk/move_check
scoreboard players remove @s sdh.jumpsteps 1
execute if score @s sdh.jumpsteps matches 1.. if score @s sdh.moved matches 1 run function sweetdream:boss/husk/leap/substep with storage sweetdream:husk jump
