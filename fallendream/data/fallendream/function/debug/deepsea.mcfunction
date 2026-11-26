# 只读观察动画状态；不会开始技能，也不会消耗魔力。
tellraw @s [{"text":"深海的回响 · 动画自检","color":"aqua","bold":true}]
tellraw @s [{"text":"施法帧 ","color":"gray"},{"score":{"name":"@s","objective":"zx.de_cast"}},{"text":" / 0..47；水波相位 ","color":"gray"},{"score":{"name":"@s","objective":"zx.de_wave"}},{"text":" / 0..95","color":"gray"}]
tellraw @s [{"text":"待机阈值 ","color":"gray"},{"score":{"name":"#deidle","objective":"zx.meta"}},{"text":" / 应为 48","color":"gray"}]
execute if entity @s[tag=zx.de_cast] run tellraw @s {"text":"正在播放施法水流。","color":"aqua"}
execute unless entity @s[tag=zx.de_cast] run tellraw @s {"text":"当前为待机；持剑时水波逐刻推进。","color":"gray"}
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run data get entity @s equipment.offhand.components."minecraft:custom_model_data".floats
