execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sip_frost"]}] run scoreboard players reset @s zx.sf_hp
# 按装备/活动灯门控，仅一次玩家 NBT 序列化。
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["huilan"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["retro_shine"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sip_frost"]}] unless score @s zx.wb_on matches 1 run return 0
execute store result score @s zx.hp_snap run data get entity @s Health 1000
scoreboard players operation @s zx.hl_hp = @s zx.hp_snap
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sip_frost"]}] run function sweetdream:equipment/tool/sip_frost/watch
execute if score @s zx.wb_on matches 1 run function sweetdream:equipment/sword/way_back/low
