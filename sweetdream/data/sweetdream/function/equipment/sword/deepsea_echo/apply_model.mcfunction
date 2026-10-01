# 主手持已有深海的回响时执行一次，仅修改外观。
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"deepseaecho:sword"}}
