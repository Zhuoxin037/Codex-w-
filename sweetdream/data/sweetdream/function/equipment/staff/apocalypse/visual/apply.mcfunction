# 宏仅用整数帧号。组件一致时不再写物品，静置期间不会每刻重复发同步包。
# 两只手逐槽检查身份；只改模型组件及其首个浮点帧号，不覆盖名称、强化或其他装备。
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["apocalypse"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:apocalypse",minecraft:custom_model_data={floats:[$(frame).0f]}] run item modify entity @s weapon.mainhand sweetdream:apocalypse_visual
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["apocalypse"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:apocalypse",minecraft:custom_model_data={floats:[$(frame).0f]}] run item modify entity @s weapon.offhand sweetdream:apocalypse_visual
