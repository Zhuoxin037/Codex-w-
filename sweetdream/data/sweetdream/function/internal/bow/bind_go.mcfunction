$execute unless data entity @s weapon.components."minecraft:custom_data"{zx:["$(id)"]} run return 0
tag @s add zx.review_bound
# The weapon is a real arrow ItemStack; unlike arbitrary entity NBT this survives reload.
$data modify entity @s weapon.components."minecraft:enchantments"."sweetdream:$(id)" set value 1
data modify entity @s weapon.components."minecraft:custom_data".sd_shot set from storage zx:work shot
