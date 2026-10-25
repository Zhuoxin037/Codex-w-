$bossbar add sweetdream:husk_$(id) {text:"空壳",color:"dark_red"}
$bossbar set sweetdream:husk_$(id) max 1000
$bossbar set sweetdream:husk_$(id) color red
$data modify storage sweetdream:husk bars append value {id:$(id)}
