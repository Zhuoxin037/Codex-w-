execute if score @s sdh.age matches ..8 run function fallendream:boss/husk/face
execute if score @s sdh.age matches 12.. unless score @s sdh.hit0 matches 1 run function fallendream:boss/husk/hit/slam
execute if score @s sdh.age matches 29.. run scoreboard players set @s sdh.rest 29
execute if score @s sdh.age matches 29.. run scoreboard players set @s sdh.pending_cd 1
execute if score @s sdh.age matches 29.. run function fallendream:boss/husk/finish
