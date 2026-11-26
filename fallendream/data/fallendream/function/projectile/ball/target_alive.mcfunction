# This call is synchronous. @e excludes dead entities in native 1.21.5; @s and raw UUID do not.
tag @s add zx.ball_uuid_probe
execute if entity @e[tag=zx.ball_uuid_probe,limit=1] run scoreboard players set #ball_target_live zx.meta 1
tag @s remove zx.ball_uuid_probe
