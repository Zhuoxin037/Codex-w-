# 旧物品首次拿到手里时自动绑定；流火由客户端 PNG 动画播放，不由函数推进。
# 正在消耗回手时跳过，避免写入尚未返还的物品。
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="flameremnant:sword"] run item modify entity @s weapon.mainhand sweetdream:flame_model
execute as @a[tag=!test_pending_return] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["flame_brokenbody"]}] unless items entity @s weapon.offhand *[minecraft:item_model="flameremnant:sword"] run item modify entity @s weapon.offhand sweetdream:flame_model
