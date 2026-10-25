# 迟暮秒级维护；回光最多3层，重复获得刷新8秒，到期检查另在每刻及消耗入口执行。抗性提升仍为15秒。
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run return 0
execute if score @s zx.ld_t matches 1.. if score @s zx.ld_t <= #now manacore.meta run scoreboard players set @s zx.ld_s 0
execute if score @s zx.ld_r5 matches 1.. if score @s zx.ld_r5 <= #now manacore.meta run scoreboard players set @s zx.ld_r5 0
