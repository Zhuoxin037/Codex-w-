scoreboard players operation #cr_restore zx.meta = @s zx.cr_layers
$scoreboard players set #cr_cap zx.meta $(cap)
$execute as @e[type=!#sweetdream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run function sweetdream:equipment/sword/contract_rift/restore_target
kill @s
