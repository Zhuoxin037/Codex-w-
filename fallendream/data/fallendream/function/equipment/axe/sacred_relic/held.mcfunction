# @s = 玩家; 两手持有判定共用, 结果 #sr_held。不改任何公共 storage。
scoreboard players set #sr_held zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["sacred_relic"]}] run scoreboard players set #sr_held zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["sacred_relic"]}] run scoreboard players set #sr_held zx.meta 1
