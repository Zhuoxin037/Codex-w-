$bossbar add fallendream:fireaxe_$(id) {"text":"NauseAxe"}
$bossbar set fallendream:fireaxe_$(id) max 1000
$bossbar set fallendream:fireaxe_$(id) color red
$bossbar set fallendream:fireaxe_$(id) style notched_10
$data modify storage fallendream:fireaxe bars append value {id:$(id)}
