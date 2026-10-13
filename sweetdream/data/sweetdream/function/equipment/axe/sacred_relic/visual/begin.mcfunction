# 仅在圣骸技能扣费、冷却及状态设置成功之后调用。
scoreboard players operation @s zx.srv_start = #now manacore.meta
scoreboard players set @s zx.srv_pulse -1
tag @s add zx.srv_cast
