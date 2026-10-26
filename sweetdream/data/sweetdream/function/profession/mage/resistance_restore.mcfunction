$execute unless data storage zx:jobs p."$(uuid)".resistance run return 0
$data modify storage zx:work jr_old set from storage zx:jobs p."$(uuid)".resistance
scoreboard players set #jr_old_duration zx.meta 0
execute store result score #jr_old_duration zx.meta run data get storage zx:work jr_old.duration
scoreboard players operation #jr_elapsed zx.meta = #now manacore.meta
scoreboard players operation #jr_elapsed zx.meta -= @s zx.j_res_start
execute unless score #jr_old_duration zx.meta matches -1 run scoreboard players operation #jr_old_duration zx.meta -= #jr_elapsed zx.meta
execute if score #jr_old_duration zx.meta matches 0..0 run return 0
execute if score #jr_old_duration zx.meta matches ..-2 run return 0
data modify storage zx:work jr_apply set value {seconds:"infinite",amp:0,hide:"true"}
execute store result storage zx:work jr_apply.amp int 1 run data get storage zx:work jr_old.amplifier
execute unless score #jr_old_duration zx.meta matches -1 run scoreboard players add #jr_old_duration zx.meta 19
execute unless score #jr_old_duration zx.meta matches -1 run scoreboard players operation #jr_old_duration zx.meta /= #j20 zx.meta
execute unless score #jr_old_duration zx.meta matches -1 store result storage zx:work jr_apply.seconds int 1 run scoreboard players get #jr_old_duration zx.meta
execute if data storage zx:work jr_old{show_particles:1b} run data modify storage zx:work jr_apply.hide set value "false"
function sweetdream:profession/mage/resistance_apply with storage zx:work jr_apply
$data remove storage zx:jobs p."$(uuid)".resistance
