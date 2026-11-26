# 把某个武器的超限数值搬进出参(宏 {of}), 单位 0.01 -> 0.01 还原成小数
$execute store result score #ol_x zx.meta run data get storage zx:config oldef."$(of)".dmg 100
$execute store result score #ol_m zx.meta run data get storage zx:config oldef."$(of)".mana 100
$execute store result score #ol_c zx.meta run data get storage zx:config oldef."$(of)".cd 100
execute store result storage zx:out r.dmg double 0.01 run scoreboard players get #ol_x zx.meta
execute store result storage zx:out r.mana double 0.01 run scoreboard players get #ol_m zx.meta
execute store result storage zx:out r.cd double 0.01 run scoreboard players get #ol_c zx.meta
