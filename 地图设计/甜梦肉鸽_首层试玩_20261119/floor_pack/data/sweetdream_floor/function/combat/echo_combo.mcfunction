scoreboard players set #echo_combo sd.floor 1
function sweetdream_floor:run/mana {value:28.0}
effect give @s minecraft:instant_health 1 0 true
particle minecraft:sonic_boom ~ ~1 ~ 0 0 0 0 1 force @s
title @s actionbar {"text":"三重回响 · 额外魔力 +28 · 生命恢复","bold":true,"color":"aqua"}
