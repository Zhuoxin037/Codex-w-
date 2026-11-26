execute unless entity @s[type=minecraft:villager,tag=zx.j_body] run return 0
data merge entity @s {Invulnerable:0b,Silent:1b,DeathLootTable:"minecraft:empty",drop_chances:{offhand:0f}}
attribute @s minecraft:knockback_resistance base set 1
item replace entity @s weapon.offhand with minecraft:paper[minecraft:enchantments={"fallendream:sleep_ward":1},minecraft:enchantment_glint_override=false]
execute if data entity @s active_effects[{id:"minecraft:resistance",amplifier:4b}] run function fallendream:profession/twin/recover_sleep_resistance
tag @s add zx.j_sleep_ward
