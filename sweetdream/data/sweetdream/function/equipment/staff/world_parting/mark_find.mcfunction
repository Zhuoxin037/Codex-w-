$execute unless entity @e[tag=zx.wp_mark,distance=0..,nbt={data:{owner:"$(owner)",t0:$(t0),t1:$(t1),t2:$(t2),t3:$(t3)}},limit=1] run summon minecraft:marker ~ ~ ~ {Tags:["zx.wp_mark","zx.wp_new"],data:{}}
execute if entity @e[tag=zx.wp_new,distance=0..,limit=1] run data modify entity @e[tag=zx.wp_new,distance=0..,limit=1] data set from storage zx:work phase4
tag @e[tag=zx.wp_new,distance=0..] remove zx.wp_new
$execute as @e[tag=zx.wp_mark,distance=0..,nbt={data:{owner:"$(owner)",t0:$(t0),t1:$(t1),t2:$(t2),t3:$(t3)}},limit=1] run function sweetdream:equipment/staff/world_parting/mark_add with storage zx:work phase4
