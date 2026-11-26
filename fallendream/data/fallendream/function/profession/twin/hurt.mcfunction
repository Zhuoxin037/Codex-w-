advancement revoke @s only fallendream:profession/hurt
execute unless score @s zx.job matches 4 run return 0
function fallendream:equipment/sword/contract_rift/player_track
scoreboard players add @s zx.j_dmg 0
scoreboard players add @s zx.j_dlast 0
scoreboard players operation #jem_got zx.meta = @s zx.j_dmg
scoreboard players operation #jem_got zx.meta -= @s zx.j_dlast
scoreboard players operation @s zx.j_dlast = @s zx.j_dmg
execute unless items entity @s weapon.mainhand *[custom_data~{zx:["empathy"]}] run return 0
execute if score #jem_got zx.meta matches ..0 run return 0
scoreboard players operation #jem_got zx.meta *= #j100 zx.meta
execute if score @s zx.j_form matches 0 run function fallendream:profession/twin/reflect
execute if score @s zx.j_form matches 1 run function fallendream:profession/twin/transmit
