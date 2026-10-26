execute unless score @s zx.j_draws matches 1.. run return 0
scoreboard players set @s zx.j_pick 1
scoreboard players set @s zx.j_pick_t 120
function sweetdream:profession/mage/resistance_begin
effect give @s minecraft:resistance 1 1 true
function sweetdream:lib/rnd
scoreboard players operation @s zx.j_draw1 = #rnd zx.meta
scoreboard players operation @s zx.j_draw1 %= #j5 zx.meta
scoreboard players add @s zx.j_draw1 1
function sweetdream:lib/rnd
scoreboard players operation @s zx.j_draw2 = #rnd zx.meta
scoreboard players operation @s zx.j_draw2 %= #j5 zx.meta
scoreboard players add @s zx.j_draw2 1
function sweetdream:lib/rnd
scoreboard players operation @s zx.j_draw3 = #rnd zx.meta
scoreboard players operation @s zx.j_draw3 %= #j5 zx.meta
scoreboard players add @s zx.j_draw3 1

function sweetdream:lib/uuid
data modify storage zx:work jchoice set value {uuid:""}
data modify storage zx:work jchoice.uuid set from storage zx:data self.uuid
function sweetdream:profession/mage/choice_clean with storage zx:work jchoice
execute anchored eyes positioned ^-1 ^ ^2 run function sweetdream:profession/mage/choice_new
execute anchored eyes positioned ^0 ^ ^2 run function sweetdream:profession/mage/choice_new
execute anchored eyes positioned ^1 ^ ^2 run function sweetdream:profession/mage/choice_new
tellraw @s [{"text":"选择一个未知「预言」（6 秒）： ","color":"light_purple"},{"text":"[Ⅰ]  ","color":"aqua","click_event":{"action":"run_command","command":"/trigger zx.prophecy_tg set 1"}},{"text":"[Ⅱ]  ","color":"aqua","click_event":{"action":"run_command","command":"/trigger zx.prophecy_tg set 2"}},{"text":"[Ⅲ]","color":"aqua","click_event":{"action":"run_command","command":"/trigger zx.prophecy_tg set 3"}}]
scoreboard players enable @s zx.prophecy_tg

scoreboard players operation @s zx.j_pick_end = #now manacore.meta
scoreboard players add @s zx.j_pick_end 120
