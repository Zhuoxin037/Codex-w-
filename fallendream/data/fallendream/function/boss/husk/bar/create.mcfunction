$bossbar add fallendream:husk_$(id) {text:"空壳",color:"dark_red"}
$bossbar set fallendream:husk_$(id) max 1000
$bossbar set fallendream:husk_$(id) color red
$data modify storage fallendream:husk bars append value {id:$(id)}
