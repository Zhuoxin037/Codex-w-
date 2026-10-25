$execute store success score @s zx.rt_hit store success score $(ghost_uuid) sdk.hit0 run damage @s 10 sweetdream:knight_blade by $(body_uuid)
$execute if score @s zx.rt_hit matches 1 run function sweetdream:equipment/tool/retro_shine/from_entity {source:"$(body_uuid)"}
$execute unless entity $(ghost_uuid) run scoreboard players reset $(ghost_uuid)
