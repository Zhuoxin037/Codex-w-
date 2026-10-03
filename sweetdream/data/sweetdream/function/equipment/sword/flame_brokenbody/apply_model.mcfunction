# 为手中已有烈火残躯绑定外观；只改 item_model，保留原名称、附魔、技能和其他组件。
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] run item modify entity @s weapon.mainhand sweetdream:flame_model
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] run item modify entity @s weapon.offhand sweetdream:flame_model
