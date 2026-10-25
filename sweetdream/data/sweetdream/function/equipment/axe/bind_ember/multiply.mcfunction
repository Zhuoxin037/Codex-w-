scoreboard players set #be_on zx.meta 0
$execute as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bind_ember"]}] run scoreboard players set #be_on zx.meta 1
$execute as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bind_ember"]}] run scoreboard players set #be_on zx.meta 1
execute unless score #be_on zx.meta matches 1 run return 0
execute store result score #be_d zx.meta run data get storage zx:work a.num 1000
scoreboard players operation #be_half zx.meta = #be_d zx.meta
scoreboard players operation #be_half zx.meta /= #2 zx.meta
scoreboard players operation #be_d zx.meta += #be_half zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #be_d zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
