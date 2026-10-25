$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,tag=zx.av_cast,distance=0..,limit=1] run return run kill @s
# ② 施法者死了 -> 收掉(★ 用原版 health 计分项 zx.hp_c, 不读玩家 NBT:
#    `nbt={Health:0.0f}` 每刻一次 ≈10 ms, 见 lib/u_by 头注释)
execute if entity @a[tag=zx.ub,distance=0..,limit=1,scores={zx.hp_c=..0}] run return run kill @s
execute if score @s zx.av_phase matches 0 run function sweetdream:equipment/axe/anchor/visual/flight with entity @s item.components."minecraft:custom_data".zx_an
execute if score @s zx.av_phase matches 1 run function sweetdream:equipment/axe/anchor/visual/world_impact with entity @s item.components."minecraft:custom_data".zx_an
