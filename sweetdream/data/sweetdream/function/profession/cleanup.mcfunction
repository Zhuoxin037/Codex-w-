function sweetdream:profession/mage/resistance_end
execute if score @s zx.job matches 1 if score @s zx.j_reborn matches 1.. run effect clear @s minecraft:absorption
function sweetdream:profession/cleanup_owned
execute if score @s zx.j_form matches 1 run function sweetdream:profession/twin/return
function sweetdream:profession/twin/clean
function sweetdream:profession/berserker/clear
scoreboard players set @s zx.j_orb 0
scoreboard players set @s zx.j_prop 0
scoreboard players set @s zx.j_cr_t 0
scoreboard players set @s zx.j_cr_n 0
scoreboard players set @s zx.j_im_n 0
scoreboard players set @s zx.j_pick 0
scoreboard players set @s zx.j_pain -1
scoreboard players set @s zx.j_bloom 0
scoreboard players set @s zx.j_sorrow 0
scoreboard players set @s zx.j_book_t -1
scoreboard players set @s zx.j_sor_t -1
scoreboard players set @s zx.j_il_t 0
scoreboard players set @s zx.j_reborn -1
scoreboard players set @s zx.j_form 0
scoreboard players set @s zx.j_empath 0
tag @s remove zx.j_twin_live

function sweetdream:lib/uuid
data modify storage zx:work jchoice.uuid set from storage zx:data self.uuid
function sweetdream:profession/mage/choice_clean with storage zx:work jchoice
attribute @s minecraft:max_absorption modifier remove sweetdream:prophecy_absorption
function sweetdream:profession/twin/unguard

scoreboard players set @s zx.j_host_t -1
scoreboard players set @s zx.j_pick 0

scoreboard players set @s zx.j_pain_n 0
scoreboard players set @s zx.j_sor_t -1

scoreboard players set @s zx.j_hd_book 0
scoreboard players set @s zx.j_hd_sor 0
