# 仅验证模型链路，不消耗魔力、不触发时停；下一次待机更新恢复。
scoreboard players set #adphase zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand sweetdream:aurora/hold
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand sweetdream:aurora/hold
