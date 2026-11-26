# Visual objectives: separate from gameplay lifetime and mana.
execute unless data storage zx:config obj_slvi run scoreboard objectives add zx.slvi dummy
data modify storage zx:config obj_slvi set value 1b
execute unless data storage zx:config obj_slva run scoreboard objectives add zx.slva dummy
data modify storage zx:config obj_slva set value 1b
execute unless data storage zx:config obj_slvf run scoreboard objectives add zx.slvf dummy
data modify storage zx:config obj_slvf set value 1b
execute unless data storage zx:config obj_slvm run scoreboard objectives add zx.slvm dummy
data modify storage zx:config obj_slvm set value 1b
execute unless data storage zx:config obj_slve run scoreboard objectives add zx.slve dummy
data modify storage zx:config obj_slve set value 1b
scoreboard players set #2 zx.slvf 2
scoreboard players set #4 zx.slvf 4
