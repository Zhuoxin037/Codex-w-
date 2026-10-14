scoreboard players set @s zx.el_clock 0
scoreboard players set @s zx.el_state 0
scoreboard players set @s zx.el_time 0
scoreboard players set @s zx.el_attack -1
scoreboard players set @s zx.el_last -1
scoreboard players set @s zx.el_dim -1
function sweetdream:equipment/tool/everlit/visual/read_mana with entity @s data.zx.el
execute if score @s zx.el_mana matches ..199 run scoreboard players set @s zx.el_state 2
