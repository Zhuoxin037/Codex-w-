scoreboard players set @s bs.bar 0
$execute store result bossbar fallendream:b_staff_$(id) value run data get entity @s Health 1
$bossbar set fallendream:b_staff_$(id) players @a[distance=..32]
