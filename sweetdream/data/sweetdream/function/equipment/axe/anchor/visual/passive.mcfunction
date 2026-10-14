execute if entity @s[tag=zx.av_cast] run return 0
function sweetdream:equipment/axe/anchor/visual/remember_hand
scoreboard players set @s zx.av_phase 2
# 原伤害已经同刻命中；从短击命中姿态开始播放收势，不推迟伤害。
scoreboard players set @s zx.av_t 6
function sweetdream:equipment/axe/anchor/visual/passive_tick
