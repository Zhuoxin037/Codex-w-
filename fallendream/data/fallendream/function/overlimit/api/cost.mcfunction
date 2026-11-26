# 只在施放检查、实际扣费、起冷却之前调用；不写 UUID、伤害或任何玩家计分项。
# 宏参数 id 为正在施放的装备；主副手都必须与该装备的超限值精确匹配。
$execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["$(id)"],ol:"$(id)"}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(id)"],ol:"$(id)"}] run return 0
$execute if data storage manacore:in arg.mana if data storage zx:config olcost."$(id)".mana run data modify storage manacore:in arg.mana set from storage zx:config olcost."$(id)".mana
# 兼容既有法杖在检查后使用的扣费缓存；未配置 mana 的百分比技能不被覆盖。
$execute if data storage manacore:in arg.mana if data storage zx:config olcost."$(id)".mana run data modify storage zx:work olv.mana set from storage manacore:in arg.mana
$execute if data storage manacore:in arg.value if data storage zx:config olcost."$(id)".mana run data modify storage manacore:in arg.value set from storage zx:config olcost."$(id)".mana
$execute if data storage manacore:in arg.cooldown_seconds if data storage zx:config olcost."$(id)".cd run data modify storage manacore:in arg.cooldown_seconds set from storage zx:config olcost."$(id)".cd
