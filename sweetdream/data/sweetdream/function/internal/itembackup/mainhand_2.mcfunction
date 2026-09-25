#盔甲架复制有itemreplace的物品（实测有效
# execute in overworld: 架子住在主世界, 但执行者是玩家(可能在别的维度),
# 所以要把"搜索实体"的维度切过去, 同时 @s 仍然指向玩家本人。
$execute in minecraft:overworld run item replace entity @e[tag=test_stand_$(uuid),limit=1] weapon.mainhand from entity @s[nbt={SelectedItem:{components:{"minecraft:custom_data":{zx:["itemreplace"]}}}}] weapon.mainhand
