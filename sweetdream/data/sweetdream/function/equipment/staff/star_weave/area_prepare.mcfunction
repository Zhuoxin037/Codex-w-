execute store result score #weave_ax zx.meta run data get entity @e[tag=zx.weave_a,limit=1,distance=0..] Pos[0] 10
execute store result score #weave_ay zx.meta run data get entity @e[tag=zx.weave_a,limit=1,distance=0..] Pos[1] 10
execute store result score #weave_az zx.meta run data get entity @e[tag=zx.weave_a,limit=1,distance=0..] Pos[2] 10
execute store result score #weave_bx zx.meta run data get entity @e[tag=zx.weave_b,limit=1,distance=0..] Pos[0] 10
execute store result score #weave_by zx.meta run data get entity @e[tag=zx.weave_b,limit=1,distance=0..] Pos[1] 10
execute store result score #weave_bz zx.meta run data get entity @e[tag=zx.weave_b,limit=1,distance=0..] Pos[2] 10
execute store result score #weave_cx zx.meta run data get entity @e[tag=zx.weave_c,limit=1,distance=0..] Pos[0] 10
execute store result score #weave_cy zx.meta run data get entity @e[tag=zx.weave_c,limit=1,distance=0..] Pos[1] 10
execute store result score #weave_cz zx.meta run data get entity @e[tag=zx.weave_c,limit=1,distance=0..] Pos[2] 10
scoreboard players operation #weave_abx zx.meta = #weave_bx zx.meta
scoreboard players operation #weave_abx zx.meta -= #weave_ax zx.meta
scoreboard players operation #weave_abz zx.meta = #weave_bz zx.meta
scoreboard players operation #weave_abz zx.meta -= #weave_az zx.meta
scoreboard players operation #weave_bcx zx.meta = #weave_cx zx.meta
scoreboard players operation #weave_bcx zx.meta -= #weave_bx zx.meta
scoreboard players operation #weave_bcz zx.meta = #weave_cz zx.meta
scoreboard players operation #weave_bcz zx.meta -= #weave_bz zx.meta
scoreboard players operation #weave_cax zx.meta = #weave_ax zx.meta
scoreboard players operation #weave_cax zx.meta -= #weave_cx zx.meta
scoreboard players operation #weave_caz zx.meta = #weave_az zx.meta
scoreboard players operation #weave_caz zx.meta -= #weave_cz zx.meta
scoreboard players operation #weave_orient zx.meta = #weave_abx zx.meta
scoreboard players operation #weave_orient zx.meta *= #weave_bcz zx.meta
scoreboard players operation #weave_tmp zx.meta = #weave_abz zx.meta
scoreboard players operation #weave_tmp zx.meta *= #weave_bcx zx.meta
scoreboard players operation #weave_orient zx.meta -= #weave_tmp zx.meta
execute unless score #weave_orient zx.meta matches 0 as @e[type=!#sweetdream:no_damage,distance=0..] run function sweetdream:equipment/staff/star_weave/area_one
