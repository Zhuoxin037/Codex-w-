# 浮光每刻：8秒未受伤随机发色；白光绝对期限由maintain管理。生命整点变化由此兜底，小数原版受伤由internal/hurt/event处理。
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] run return 0
execute if score @s zx.gl_lh matches 0 run scoreboard players operation @s zx.gl_lh = #now manacore.meta
execute if score @s zx.hp_c < @s zx.gl_hp run function sweetdream:equipment/armor/glimmer/clear
scoreboard players operation @s zx.gl_hp = @s zx.hp_c
scoreboard players operation #gl_gap zx.meta = #now manacore.meta
scoreboard players operation #gl_gap zx.meta -= @s zx.gl_lh
execute if score #gl_gap zx.meta matches 160.. run function sweetdream:equipment/armor/glimmer/give_color

execute if score @s zx.gl_wt > #now manacore.meta run function sweetdream:equipment/armor/glimmer/white_pulse
