# 手里拿着已有引梦镰时手动执行一次；只更新外观组件。
# 【为什么要两只手都试】2026-10-03 起横扫支持副手, 镰刀可能在副手 ——
#   只认主手的话, 副手那把的外观就永远修不回来(换 item_model 时漏一手,
#   表现是"模型不对但功能正常", 很难查)。
# 【用法】/function sweetdream:equipment/sword/sickle_dreams/apply_model
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sickle"}}
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] run item modify entity @s weapon.offhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sickle"}}
