# @s=控制marker；主人离线、死亡、重置或离开维度后清理自己的路径。
$execute if entity @a[scores={zx.bb_on=1,zx.hp_c=1..,manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},distance=..64] run return 0
$tag @e[tag=zx.bb_path_$(uuid)] remove zx.bb_path_$(uuid)
kill @s
