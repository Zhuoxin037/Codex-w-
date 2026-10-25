$bossbar add sweetdream:knight_$(id) {"text":"\"骑士\""}
$bossbar set sweetdream:knight_$(id) max 800
$bossbar set sweetdream:knight_$(id) color purple
$data modify storage sweetdream:knight bars append value {id:$(id)}
