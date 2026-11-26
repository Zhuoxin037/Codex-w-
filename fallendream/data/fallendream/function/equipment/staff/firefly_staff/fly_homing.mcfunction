# UUID 属于这次施法，其他玩家再施放不会改掉它。
scoreboard players set #ff_target_live zx.meta 0
$execute at $(target) if entity @s[distance=0..] as $(target) if data entity @s Health unless data entity @s {Health:0.0f} run scoreboard players set #ff_target_live zx.meta 1
execute unless score #ff_target_live zx.meta matches 1 run tag @s remove zx.ff_homing
$execute if entity @s[tag=zx.ff_homing] facing entity $(target) eyes positioned ^ ^ ^0.8 run tp @s ~ ~ ~
