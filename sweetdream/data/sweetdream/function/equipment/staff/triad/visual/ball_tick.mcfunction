# 调用方必须 at @s：原法球的本刻 TP 已执行，使用它的实际新位置。
execute unless data entity @s data.tv_v0 run function sweetdream:equipment/staff/triad/visual/ball_spawn
execute unless data entity @s data.tv_v0 run return 0
scoreboard players add @s zx.tv_age 1
scoreboard players operation #tv_spin zx.meta = @s zx.tv_age
scoreboard players set #tv_cycle zx.meta 12
scoreboard players operation #tv_spin zx.meta %= #tv_cycle zx.meta
execute store result storage zx:triad_visual frame.value float 1 run scoreboard players get #tv_spin zx.meta
function sweetdream:equipment/staff/triad/visual/ball_follow with entity @s data
