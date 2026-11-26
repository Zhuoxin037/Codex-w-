$execute unless entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run return run function fallendream:profession/delayed/finish
execute unless entity @s run return 0
data modify storage zx:work a set from entity @s data
$data modify storage zx:work a.target set value "@e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1]"
# 注魔超限（用户原文）："之后对其 2 格内的其他生物造成相当于自身对其造成的伤害的 80%"
#   ★ 必须在主伤害之前：主目标被打死后 at @e[...] 选不到实体，溅射会整段消失。
#   ★ aoe 结尾会把 zx:work a 还原成本函数第 3 行那份快照（aoe_one 逐只重建过它），
#     所以下面两行读到的仍是主伤害的原始入参。
function fallendream:lib/num/plain
function fallendream:internal/damage/with_from with storage zx:work a
