# 主手拿着已有引梦镰时手动执行一次；只更新外观组件。
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sickle"}}
