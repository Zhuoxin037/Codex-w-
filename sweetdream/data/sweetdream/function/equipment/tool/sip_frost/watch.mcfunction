execute unless entity @s[tag=zx.sf_units_v2] run scoreboard players operation @s zx.sf_acc *= #1000 zx.meta
tag @s add zx.sf_units_v2
# 每刻观察真实生命增长，包含自然恢复、再生、药水及 lib/heal；千分单位保留小数。
scoreboard players set #sf_gain zx.meta 0
execute if score @s zx.sf_hp matches 1.. run scoreboard players operation #sf_gain zx.meta = @s zx.hp_snap
execute if score @s zx.sf_hp matches 1.. run scoreboard players operation #sf_gain zx.meta -= @s zx.sf_hp
scoreboard players operation @s zx.sf_hp = @s zx.hp_snap
function sweetdream:equipment/tool/sip_frost/gain
