# 保留待机相位；换入另一把同名武器时，同步时停阶段。
execute if entity @s[tag=zx.ad_cast] unless score @s zx.ad_cast matches 0..33 run function fallendream:equipment/sword/aurora_dream/anim/end
execute if entity @s[tag=zx.ad_cast] if score @s zx.ad_cast matches 33 run scoreboard players set #adphase zx.meta 0
execute if entity @s[tag=zx.ad_cast] if score @s zx.ad_cast matches 33 if score @s zx.ad_pulse matches 1.. if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand fallendream:aurora/pulse
execute if entity @s[tag=zx.ad_cast] if score @s zx.ad_cast matches 33 if score @s zx.ad_pulse matches 1.. if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand fallendream:aurora/pulse
execute if entity @s[tag=zx.ad_cast] if score @s zx.ad_cast matches 33 unless score @s zx.ad_pulse matches 1.. if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand fallendream:aurora/hold
execute if entity @s[tag=zx.ad_cast] if score @s zx.ad_cast matches 33 unless score @s zx.ad_pulse matches 1.. if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand fallendream:aurora/hold
execute if entity @s[tag=zx.ad_cast] run return 0
execute unless score @s zx.ad_idle matches 0..23 run scoreboard players set @s zx.ad_idle 0
scoreboard players operation #adphase zx.meta = @s zx.ad_idle
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand fallendream:aurora/idle
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand fallendream:aurora/idle
