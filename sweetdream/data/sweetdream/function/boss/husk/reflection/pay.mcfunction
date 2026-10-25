scoreboard players set #last sdh.tmp -1000
scoreboard players set #used sdh.tmp 0
$execute store result score #last sdh.tmp run data get storage sweetdream:husk reflects."$(id)"."$(uuid)".last
$execute store result score #used sdh.tmp run data get storage sweetdream:husk reflects."$(id)"."$(uuid)".used
scoreboard players operation #gap sdh.tmp = #now manacore.meta
scoreboard players operation #gap sdh.tmp -= #last sdh.tmp
execute if score #gap sdh.tmp matches ..9 run return 0
scoreboard players set #available sdh.tmp 10000
scoreboard players operation #available sdh.tmp -= #used sdh.tmp
execute if score #available sdh.tmp matches ..0 run return 0
$scoreboard players set #pay sdh.tmp $(amount)
execute if score #pay sdh.tmp > #available sdh.tmp run scoreboard players operation #pay sdh.tmp = #available sdh.tmp
scoreboard players operation #used sdh.tmp += #pay sdh.tmp
$execute store result storage sweetdream:husk reflects."$(id)"."$(uuid)".used int 1 run scoreboard players get #used sdh.tmp
$execute store result storage sweetdream:husk reflects."$(id)"."$(uuid)".last int 1 run scoreboard players get #now manacore.meta
execute store result storage sweetdream:husk ref_damage.amount double 0.001 run scoreboard players get #pay sdh.tmp
scoreboard players set #depth sdh.tmp 1
function sweetdream:boss/husk/reflection/damage with storage sweetdream:husk ref_damage
scoreboard players set #depth sdh.tmp 0
