# core/tick 仅对未施法的持剑者调用，同一玩家两手持剑也只推进一次。
# 96 帧、每刻一帧 = 4.8 秒循环；每人独立相位，多人不会互相覆写。
scoreboard players add @s zx.de_wave 0
scoreboard players operation #dewave zx.meta = @s zx.de_wave
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/idle_frame
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/idle_frame
scoreboard players add @s zx.de_wave 1
execute if score @s zx.de_wave matches 96.. run scoreboard players set @s zx.de_wave 0
