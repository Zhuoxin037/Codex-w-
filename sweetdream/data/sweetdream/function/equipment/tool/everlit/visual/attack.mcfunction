# 原 strike 真正选中目标后才触发动画。复燃期间暂存这次动作。
scoreboard players operation @s zx.el_mana = #el_m zx.meta
execute if score @s zx.el_state matches 2 run function sweetdream:equipment/tool/everlit/visual/start_light
execute unless score @s zx.el_state matches 0 run scoreboard players set @s zx.el_attack -2
execute if score @s zx.el_state matches 0 run scoreboard players set @s zx.el_attack 0
