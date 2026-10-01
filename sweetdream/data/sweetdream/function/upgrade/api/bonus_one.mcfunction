# 把某一个升级的数值累加进临时计分项 #up_dmg / #up_mana / #up_cd (单位 0.01)
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".dmg 100
scoreboard players operation #up_dmg zx.meta += #up_t zx.meta
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".mana 100
scoreboard players operation #up_mana zx.meta += #up_t zx.meta
$execute store result score #up_t zx.meta run data get storage zx:config updef."$(id)".cd 100
scoreboard players operation #up_cd zx.meta += #up_t zx.meta
