attribute @s minecraft:armor modifier remove fallendream:fh_a_dn
tag @s remove zx.fh_strip
execute if entity @s[tag=zx.status.liuhuo] run attribute @s minecraft:armor modifier remove fallendream:tag_liuhuo
execute if entity @s[tag=zx.status.liuhuo] run attribute @s minecraft:armor modifier add fallendream:tag_liuhuo -0.2 add_multiplied_base
