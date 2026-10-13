# 宏击杀者 UUID; marker 的归属准确对应, 不能吃别人的击杀。
# 本入口只调用一次, 故意跨维度查自己的观察记录; 死者 UUID 再决定真正落地维度。
$execute as @e[type=minecraft:marker,tag=zx.sr_w,nbt={data:{owner:[I;$(u0),$(u1),$(u2),$(u3)]}}] run function sweetdream:equipment/axe/sacred_relic/find_dead with entity @s data
