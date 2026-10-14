# 帧7 / 0.35秒：普通横斩或强化第一斩穿过正前方。
function sweetdream:equipment/sword/flame_brokenbody/combat/restore
function sweetdream:equipment/sword/flame_brokenbody/dmg
execute if score @s zx.fb_mode matches 0 run function sweetdream:equipment/sword/flame_brokenbody/combat/status
function sweetdream:equipment/sword/flame_brokenbody/combat/burst
tag @e[tag=zx.fb_hit,distance=0..] remove zx.fb_hit
