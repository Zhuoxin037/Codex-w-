execute store result score #fixed_base zx.meta run data get storage zx:work a.num 1000
execute store result score #fixed_part zx.meta run data get storage zx:work a.fixed_add 1000
scoreboard players operation #fixed_base zx.meta += #fixed_part zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #fixed_base zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
