# 心脉受害者附魔回调：核对胸甲后放行伤害来源；文案未设置冷却，不额外限制触发。
data remove storage zx:work hv
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["heart_vein"]}] run return 0
data modify storage zx:work hv set value {ok:1b}
