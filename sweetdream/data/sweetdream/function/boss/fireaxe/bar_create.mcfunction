$bossbar add sweetdream:fireaxe_$(id) {"text":"NauseAxe"}
$bossbar set sweetdream:fireaxe_$(id) max 1000
$bossbar set sweetdream:fireaxe_$(id) color red
$bossbar set sweetdream:fireaxe_$(id) style notched_10
$data modify storage sweetdream:fireaxe bars append value {id:$(id)}
