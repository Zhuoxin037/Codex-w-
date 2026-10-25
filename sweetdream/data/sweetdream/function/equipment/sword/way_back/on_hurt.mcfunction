# 灯亮期间仍计账，收起武器不停止。每次事件只加一次。
execute unless score @s zx.wb_on matches 1 run return 0
scoreboard players operation @s zx.wb_dmg += @s zx.hurt_evt
function sweetdream:equipment/sword/way_back/low
