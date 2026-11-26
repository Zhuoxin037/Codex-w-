# Wrapper also migrates projectiles spawned before this reload, before macro expansion.
execute unless data entity @s data.target_uuid run function fallendream:projectile/ball/migrate_target with entity @s data
function fallendream:projectile/ball/tick_target with entity @s data
