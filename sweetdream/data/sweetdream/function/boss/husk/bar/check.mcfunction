$bossbar set sweetdream:husk_$(id) players
$execute in minecraft:overworld as @e[tag=sd.hk.body,scores={sdh.id=$(id)},distance=0..,limit=1] at @s run bossbar set sweetdream:husk_$(id) players @a[distance=..40]
$execute in minecraft:the_nether as @e[tag=sd.hk.body,scores={sdh.id=$(id)},distance=0..,limit=1] at @s run bossbar set sweetdream:husk_$(id) players @a[distance=..40]
$execute in minecraft:the_end as @e[tag=sd.hk.body,scores={sdh.id=$(id)},distance=0..,limit=1] at @s run bossbar set sweetdream:husk_$(id) players @a[distance=..40]
