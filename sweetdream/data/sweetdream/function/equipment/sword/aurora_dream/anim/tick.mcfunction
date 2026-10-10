# 0..31: 1.6秒汇光；32:定格；33:等待原技能计时结束。
execute unless score @s zx.ad_cast matches 0..33 run return run function sweetdream:equipment/sword/aurora_dream/anim/end
scoreboard players operation #adframe zx.meta = @s zx.ad_cast
scoreboard players set #adphase zx.meta 0
execute if score @s zx.ad_cast matches 0..32 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand sweetdream:aurora/frame
execute if score @s zx.ad_cast matches 0..32 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand sweetdream:aurora/frame
execute if score @s zx.ad_cast matches 33 if score @s zx.ad_pulse matches 8 run function sweetdream:equipment/sword/aurora_dream/anim/pulse
execute if score @s zx.ad_cast matches 33 if score @s zx.ad_pulse matches 1 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand sweetdream:aurora/hold
execute if score @s zx.ad_cast matches 33 if score @s zx.ad_pulse matches 1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand sweetdream:aurora/hold
execute if score @s zx.ad_pulse matches 1.. run scoreboard players remove @s zx.ad_pulse 1
execute if score @s zx.ad_cast matches 33 unless score @s zx.ad_bell matches 1.. run function sweetdream:equipment/sword/aurora_dream/anim/end
execute if entity @s[tag=zx.ad_cast] if score @s zx.ad_cast matches 0..32 run scoreboard players add @s zx.ad_cast 1
