advancement revoke @s only sweetdream:equipment/axe/no_return_hit
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless score @s zx.job matches 2 run return 0
execute unless entity @s[tag=zx.nr_active] run return 0
execute if score @s zx.nr_reject = #now manacore.meta run return 0
function sweetdream:lib/uuid
execute anchored eyes positioned ^ ^ ^0 run summon minecraft:marker ~ ~ ~ {Tags:["zx.nr_blade","zx.nr_new"],data:{owner:"",u0:0,u1:0,u2:0,u3:0}}
execute anchored eyes positioned ^ ^ ^0 run tp @e[tag=zx.nr_new,distance=0..,limit=1] ~ ~ ~ ~ ~
data modify entity @e[tag=zx.nr_new,distance=0..,limit=1] data.owner set from storage zx:data self.uuid
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u0 int 1 run scoreboard players get @s manacore.u0
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u1 int 1 run scoreboard players get @s manacore.u1
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u2 int 1 run scoreboard players get @s manacore.u2
execute store result entity @e[tag=zx.nr_new,distance=0..,limit=1] data.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players operation @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_tick = #now manacore.meta
scoreboard players operation @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_due = #now manacore.meta
scoreboard players add @e[tag=zx.nr_new,distance=0..,limit=1] zx.nr_due 10
tag @e[tag=zx.nr_new,distance=0..] remove zx.nr_new
