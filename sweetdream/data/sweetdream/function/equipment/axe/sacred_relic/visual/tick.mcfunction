# @a 每刻仅一遍，跨维度；双持只推进一个玩家时钟。
execute as @a[tag=zx.srv_cast] run function sweetdream:equipment/axe/sacred_relic/visual/advance
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["sacred_relic"]}] run function sweetdream:equipment/axe/sacred_relic/visual/held
execute as @a[tag=!test_pending_return] unless items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["sacred_relic"]}] if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["sacred_relic"]}] run function sweetdream:equipment/axe/sacred_relic/visual/held
