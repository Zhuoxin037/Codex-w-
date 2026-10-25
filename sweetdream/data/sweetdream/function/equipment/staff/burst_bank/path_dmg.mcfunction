# 宏快照在进入时冻结；先记本人路径再打伤害，防结算重入。
$tag @s add zx.bb_path_$(uuid)
data modify storage zx:work a set value {channel_atk:0.0,target:"@s",type:"sweetdream:skill"}
$data modify storage zx:work a.num set value $(pd)
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
$data modify storage zx:work a.u0 set value $(u0)
$data modify storage zx:work a.u1 set value $(u1)
$data modify storage zx:work a.u2 set value $(u2)
$data modify storage zx:work a.u3 set value $(u3)
function sweetdream:internal/damage/with_from with storage zx:work a
execute at @s run particle minecraft:dust{color:[0.2,0.6,0.85],scale:1.1} ~ ~1 ~ 0.3 0.4 0.3 0.02 10 normal
