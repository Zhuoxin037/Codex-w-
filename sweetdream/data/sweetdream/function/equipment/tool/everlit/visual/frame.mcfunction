# 待机10FPS，攻击/熄灭/复燃20FPS。只改一只显示实体的帧号。
scoreboard players operation #el_frame zx.meta = @s zx.el_clock
scoreboard players operation #el_frame zx.meta %= #el_80 zx.meta
scoreboard players operation #el_frame zx.meta /= #el_2 zx.meta
scoreboard players set #el_dim zx.meta 0
execute if score @s zx.el_state matches 2 run scoreboard players add #el_frame zx.meta 400
execute if score @s zx.el_state matches 2 run scoreboard players set #el_dim zx.meta 8
execute if score @s zx.el_state matches 1..1 run function sweetdream:equipment/tool/everlit/visual/frame_dark
execute if score @s zx.el_state matches 3..3 run function sweetdream:equipment/tool/everlit/visual/frame_light
execute if score @s zx.el_state matches 0 if score @s zx.el_attack matches 0..22 run scoreboard players operation #el_frame zx.meta = @s zx.el_attack
execute if score @s zx.el_state matches 0 if score @s zx.el_attack matches 0..22 run scoreboard players add #el_frame zx.meta 100
execute unless score @s zx.el_last = #el_frame zx.meta run function sweetdream:equipment/tool/everlit/visual/apply
execute unless score @s zx.el_dim = #el_dim zx.meta run function sweetdream:equipment/tool/everlit/visual/brightness
