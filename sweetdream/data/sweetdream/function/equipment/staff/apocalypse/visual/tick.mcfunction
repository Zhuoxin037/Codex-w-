# 只有这一条每刻入口；@a 自带跨维度能力，不重复分维度调用。
execute as @a[tag=zx.apv_active] run function sweetdream:equipment/staff/apocalypse/visual/advance
# 每人只进入 held 一次，双持时仍只推进一次待机时钟。
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["apocalypse"]}] run function sweetdream:equipment/staff/apocalypse/visual/held
execute as @a[tag=!test_pending_return] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["apocalypse"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["apocalypse"]}] run function sweetdream:equipment/staff/apocalypse/visual/held
