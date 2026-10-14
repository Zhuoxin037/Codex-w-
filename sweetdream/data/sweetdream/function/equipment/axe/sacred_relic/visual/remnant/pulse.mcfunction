# 仅在原 strike 确实锁定目标并结算后记录共鸣；不改变目标和伤害。
execute on vehicle if entity @s[type=minecraft:item_display,tag=zx.sr_model] run scoreboard players operation @s zx.srm_p = #now manacore.meta
