# @s = 到期的火球 marker, 位置 = 落点。反查射手后由其归属结算伤害。
data modify storage zx:work sfm set from entity @s data.zx
function fallendream:lib/find_by with storage zx:work sfm
execute as @a[tag=zx.mc_by,limit=1] run function fallendream:equipment/staff/skyfire/meteor_go
tag @a remove zx.mc_by
kill @s
