# 消费成功后记录；同类第二次只叠层，奖励统一在批次结算时发放。
scoreboard players add @s zx.mv_end 0
execute unless score @s zx.mv_end > #now manacore.meta run function fallendream:equipment/armor/mottle_vein/open
$execute if entity @s[tag=zx.mv.$(mark)] run return run function fallendream:equipment/armor/mottle_vein/record_second {mark:"$(mark)"}
scoreboard players add @s zx.mv_n 1
$tag @s add zx.mv.$(mark)
execute if score @s zx.mv_n matches 3.. run scoreboard players set @s zx.mv_pend 1
