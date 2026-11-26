# 验证当前手中真实组件，绝不按秒缓存主手；相同skill自然共用同一冷却。
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{skill:"$(skill)"}] run data modify storage zx:work a.skill set value "$(skill)"
