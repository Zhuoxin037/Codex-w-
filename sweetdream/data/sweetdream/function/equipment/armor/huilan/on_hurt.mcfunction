# 共享受伤事件消费者：只记录最后一次伤害。
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["huilan"]}] run return 0
execute unless score @s zx.hurt_evt matches 1.. run return 0
scoreboard players operation @s zx.hl_dmg = @s zx.hurt_evt
scoreboard players set @s zx.hl_t 60
scoreboard players set @s zx.hl_on 1
