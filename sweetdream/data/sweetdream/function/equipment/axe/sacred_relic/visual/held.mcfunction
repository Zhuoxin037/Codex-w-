# 待机32帧、每帧4刻；只推进自身时钟，不重复分维度或分手调用。
scoreboard players add @s zx.srv_i 1
execute if score @s zx.srv_i matches 128.. run scoreboard players set @s zx.srv_i 0
scoreboard players operation #sr_frame zx.srv_frame = @s zx.srv_i
scoreboard players set #sr_four zx.srv_frame 4
scoreboard players operation #sr_frame zx.srv_frame /= #sr_four zx.srv_frame
# 原技能每秒结算刚发生后播放20帧共鸣。缺少脉冲章时保持待机。
scoreboard players set #sr_age zx.srv_frame 999
execute if score @s zx.srv_pulse matches 0.. run scoreboard players operation #sr_age zx.srv_frame = #now manacore.meta
execute if score @s zx.srv_pulse matches 0.. run scoreboard players operation #sr_age zx.srv_frame -= @s zx.srv_pulse
execute if score #sr_age zx.srv_frame matches 0..19 run scoreboard players operation #sr_frame zx.srv_frame = #sr_age zx.srv_frame
execute if score #sr_age zx.srv_frame matches 0..19 run scoreboard players add #sr_frame zx.srv_frame 200
# 施法优先级最高；第48帧与归位不同刻，完整保留收尾。
execute if entity @s[tag=zx.srv_cast] run scoreboard players operation #sr_frame zx.srv_frame = #now manacore.meta
execute if entity @s[tag=zx.srv_cast] run scoreboard players operation #sr_frame zx.srv_frame -= @s zx.srv_start
execute if entity @s[tag=zx.srv_cast] run scoreboard players add #sr_frame zx.srv_frame 100
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["sacred_relic"]}] run function sweetdream:equipment/axe/sacred_relic/visual/mainhand
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["sacred_relic"]}] run function sweetdream:equipment/axe/sacred_relic/visual/offhand
