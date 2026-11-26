scoreboard players operation #av_pose zx.meta = @s zx.av_t
scoreboard players add #av_pose zx.meta 200
function fallendream:equipment/axe/anchor/visual/set_hand
scoreboard players add @s zx.av_t 1
execute if score @s zx.av_t matches 17.. run function fallendream:equipment/axe/anchor/visual/end
