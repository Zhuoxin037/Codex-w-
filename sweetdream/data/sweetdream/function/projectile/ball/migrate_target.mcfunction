data modify storage zx:work ball.target_uuid set value "00000000-0000-0000-0000-000000000000"
$execute as @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run function sweetdream:projectile/ball/cache_target_uuid
data modify entity @s data.target_uuid set from storage zx:work ball.target_uuid
