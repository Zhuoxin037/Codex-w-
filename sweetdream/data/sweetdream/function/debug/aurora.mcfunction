tellraw @s [{"text":"极光与幻梦 模型状态 / 待机: ","color":"aqua"},{"score":{"name":"@s","objective":"zx.ad_idle"}},{"text":" / 施法: "},{"score":{"name":"@s","objective":"zx.ad_cast"}},{"text":" / 钟声剩余秒: "},{"score":{"name":"@s","objective":"zx.ad_bell"}}]
execute if entity @s[tag=zx.ad_cast] run tellraw @s {"text":"施法模型状态已开启","color":"yellow"}
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run data get entity @s SelectedItem.components."minecraft:custom_model_data"
scoreboard players get #adidle zx.meta
scoreboard players get #adhold zx.meta
