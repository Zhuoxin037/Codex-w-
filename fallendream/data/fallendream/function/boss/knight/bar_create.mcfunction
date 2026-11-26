$bossbar add fallendream:knight_$(id) {"text":"\"骑士\""}
$bossbar set fallendream:knight_$(id) max 800
$bossbar set fallendream:knight_$(id) color purple
$data modify storage fallendream:knight bars append value {id:$(id)}
