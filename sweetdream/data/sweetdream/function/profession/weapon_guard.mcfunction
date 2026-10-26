scoreboard players set #jweapon_block zx.meta 0
execute unless score @s zx.job matches 1 if items entity @s weapon.mainhand *[custom_data~{profession:1}] run scoreboard players set #jweapon_block zx.meta 1
execute unless score @s zx.job matches 4 if items entity @s weapon.mainhand *[custom_data~{profession:4}] run scoreboard players set #jweapon_block zx.meta 1
execute if score #jweapon_block zx.meta matches 1 unless entity @s[tag=zx.j_weapon_locked] run attribute @s minecraft:attack_damage modifier add sweetdream:profession_weapon_lock -1 add_multiplied_total
execute if score #jweapon_block zx.meta matches 1 run tag @s add zx.j_weapon_locked
execute if score #jweapon_block zx.meta matches 0 if entity @s[tag=zx.j_weapon_locked] run attribute @s minecraft:attack_damage modifier remove sweetdream:profession_weapon_lock
execute if score #jweapon_block zx.meta matches 0 run tag @s remove zx.j_weapon_locked
