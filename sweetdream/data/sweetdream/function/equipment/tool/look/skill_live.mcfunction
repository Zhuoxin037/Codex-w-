# @s=面板玩家；uuid来自本次render，缓存严格按玩家隔离。
data remove storage zx:work skill_probe
$data modify storage zx:work skill_probe set from storage zx:look skill_cache."$(uuid)"
execute if data storage zx:work skill_probe.skill run function sweetdream:equipment/tool/look/skill_cached with storage zx:work skill_probe
execute if data storage zx:work a.skill run return 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data] run return 0
data modify storage zx:work a.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill
$execute if data storage zx:work a.skill run data modify storage zx:look skill_cache."$(uuid)".skill set from storage zx:work a.skill
