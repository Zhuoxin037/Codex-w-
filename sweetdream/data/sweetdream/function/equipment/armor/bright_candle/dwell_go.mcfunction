$execute unless entity @e[tag=zx.bc_contact,distance=..0.1,scores={zx.bc_parent=$(cid),zx.bc_target=$(tid)},limit=1] run function sweetdream:equipment/armor/bright_candle/contact_new {cid:$(cid),tid:$(tid),end:$(end)}
scoreboard players set #bc_convert zx.meta 0
$execute as @e[tag=zx.bc_contact,distance=..0.1,scores={zx.bc_parent=$(cid),zx.bc_target=$(tid)},limit=1] run function sweetdream:equipment/armor/bright_candle/contact_step
execute unless score #bc_convert zx.meta matches 1 run return 0
tag @s add zx.bc_cvt
function sweetdream:equipment/armor/bright_candle/convert
tag @s remove zx.bc_cvt
