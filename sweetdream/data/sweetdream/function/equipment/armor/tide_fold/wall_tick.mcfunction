# Wall lifetime remains ten seconds. Legacy uninitialized walls are discarded.
execute unless score @s zx.tf_end matches 1.. run return run function sweetdream:equipment/armor/tide_fold/wall_end
scoreboard players operation @s zx.tf_life = @s zx.tf_end
scoreboard players operation @s zx.tf_life -= #now manacore.meta
execute if score @s zx.tf_life matches ..0 run return run function sweetdream:equipment/armor/tide_fold/wall_end
scoreboard players remove @s zx.tf_fx 1
execute if score @s zx.tf_fx matches ..0 run function sweetdream:equipment/armor/tide_fold/fx_wall
execute if score @s zx.tf_fx matches ..0 run scoreboard players set @s zx.tf_fx 5
execute store result storage zx:work tf.u0 int 1 run scoreboard players get @s zx.tf_u0
execute store result storage zx:work tf.u1 int 1 run scoreboard players get @s zx.tf_u1
execute store result storage zx:work tf.u2 int 1 run scoreboard players get @s zx.tf_u2
execute store result storage zx:work tf.u3 int 1 run scoreboard players get @s zx.tf_u3
execute store result storage zx:work tf.id int 1 run scoreboard players get @s zx.tf_id
execute store result storage zx:work tf.nx int 1 run scoreboard players get @s zx.tf_nx
execute store result storage zx:work tf.nz int 1 run scoreboard players get @s zx.tf_nz
execute store result storage zx:work tf.cx int 1 run scoreboard players get @s zx.tf_cx
execute store result storage zx:work tf.cy int 1 run scoreboard players get @s zx.tf_cy
execute store result storage zx:work tf.cz int 1 run scoreboard players get @s zx.tf_cz
function sweetdream:equipment/armor/tide_fold/probe
execute unless score @s zx.tf_exp matches 1 if score @s zx.tf_fx matches 5 run function sweetdream:equipment/armor/tide_fold/expand_check
