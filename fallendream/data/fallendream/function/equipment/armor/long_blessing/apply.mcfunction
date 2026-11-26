# @s = 被选中的玩家。"同一玩家同时只接受一份同名长祝" = 覆盖式刷新(直接 set, 不叠加)。
# 12 秒 = 240 刻; 首次治疗在 40 刻(2 秒)后。
scoreboard players operation @s zx.lb_end = #now manacore.meta
scoreboard players add @s zx.lb_end 240
scoreboard players operation @s zx.lb_next = #now manacore.meta
scoreboard players add @s zx.lb_next 40
scoreboard players set @s zx.lb_ext 0
scoreboard players set @s zx.lb_hacc 0
particle minecraft:heart ~ ~1 ~ 0.3 0.3 0.3 0.02 6 normal
