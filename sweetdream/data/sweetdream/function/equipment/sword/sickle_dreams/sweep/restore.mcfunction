# 只恢复原槽位中带有本次编号的镰刀，不能覆盖后来换进去的物品。
$execute if items entity @s hotbar.$(slot) *[minecraft:custom_data~{zx:["sickle_dreams"],sd_sweep:$(id)}] run item modify entity @s hotbar.$(slot) sweetdream:sickle_sweep_reset
