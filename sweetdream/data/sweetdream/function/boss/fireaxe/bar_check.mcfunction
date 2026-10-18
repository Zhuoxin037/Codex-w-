$bossbar set sweetdream:fireaxe_$(id) name {"text":"NauseAxe"}
$bossbar set sweetdream:fireaxe_$(id) players
$execute as @e[tag=sd.fb.rig,scores={aj.id=$(id)},limit=1] at @s run bossbar set sweetdream:fireaxe_$(id) players @a[distance=..32]
