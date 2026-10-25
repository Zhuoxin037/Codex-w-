scoreboard players set @s sdh.pending_ref 0
execute store result score @s sdh.hp1000 run data get entity @s Health 1000
scoreboard players operation @s sdh.loss = @s sdh.prev_hp
scoreboard players operation @s sdh.loss -= @s sdh.hp1000
scoreboard players operation @s sdh.prev_hp = @s sdh.hp1000
execute unless score @s sdh.loss matches 1.. run return 0
execute if score #depth sdh.tmp matches 1.. run return 0
execute unless score @s sdh.state matches 21 unless score @s sdh.state matches 31 run return 0
scoreboard players operation @s sdh.prevent = @s sdh.loss
scoreboard players operation @s sdh.prevent *= #13 sdh.tmp
scoreboard players operation @s sdh.prevent /= #7 sdh.tmp
scoreboard players operation @s sdh.energy += @s sdh.prevent
execute if score @s sdh.energy matches 70001.. run scoreboard players set @s sdh.energy 70000
scoreboard players operation @s sdh.pending_ref = @s sdh.prevent
scoreboard players operation @s sdh.pending_ref /= #5 sdh.tmp
execute if score @s sdh.pending_ref matches 3501.. run scoreboard players set @s sdh.pending_ref 3500
execute if score @s sdh.flash matches 0 run scoreboard players set @s sdh.flash 8
