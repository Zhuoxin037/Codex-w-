$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},tag=zx.av_cast,distance=0..,limit=1] run return run kill @s
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1,nbt={Health:0.0f}] run return run kill @s
execute if score @s zx.av_phase matches 0 run function sweetdream:equipment/axe/anchor/visual/flight with entity @s item.components."minecraft:custom_data".zx_an
execute if score @s zx.av_phase matches 1 run function sweetdream:equipment/axe/anchor/visual/world_impact with entity @s item.components."minecraft:custom_data".zx_an
