$tag @s add zx.wb_owner_$(uuid)
$kill @e[type=marker,tag=zx.wb_lamp_$(uuid)]
$summon marker ~ ~ ~ {Tags:["zx.wb_lamp","zx.wb_lamp_$(uuid)"],data:{wb:{uuid:"$(uuid)"}}}
