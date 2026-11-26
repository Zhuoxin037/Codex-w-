$bossbar set fallendream:fireaxe_$(id) name {"text":"NauseAxe"}
$bossbar set fallendream:fireaxe_$(id) players
$execute as @e[tag=sd.fb.rig,scores={aj.id=$(id)},limit=1] at @s run bossbar set fallendream:fireaxe_$(id) players @a[distance=..32]
