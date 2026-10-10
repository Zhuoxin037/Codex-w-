# 恢复待机通道；换栏/丢弃时仍完成玩家状态收尾，重新持剑后 idle_tick 自动修复。
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_idle
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_idle
scoreboard players set @s zx.de_wave 0
scoreboard players reset @s zx.de_cast
tag @s remove zx.de_cast
