tellraw @s {"text":"装备抽取 · 选 1 个标签","color":"aqua"}
execute if data storage sweetdream_floor:run offers[0] run function sweetdream_floor:reward/button {index:0,code:30}
execute if data storage sweetdream_floor:run offers[1] run function sweetdream_floor:reward/button {index:1,code:31}
execute if data storage sweetdream_floor:run offers[2] run function sweetdream_floor:reward/button {index:2,code:32}
