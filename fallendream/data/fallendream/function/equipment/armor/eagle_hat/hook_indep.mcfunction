# 鹰羽帽：独立放大最大魔力分段，随后由通用公式处理加算和全局独乘。
execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.eh_indep_end > #now manacore.meta run return 0
execute unless items entity @s armor.head *[custom_data~{zx:["eagle_hat"],ol:"eagle_hat"}] run return 0
function fallendream:profession/mage/tally
scoreboard players operation #mp_mul zx.meta = #jorbs zx.meta
scoreboard players set #eh_60 zx.meta 60
scoreboard players operation #mp_mul zx.meta *= #eh_60 zx.meta
scoreboard players add #mp_mul zx.meta 1100
scoreboard players set #mp_src zx.meta 0
execute store result score #mp_src zx.meta run data get storage manacore:out r.seg_m
function fallendream:lib/math/mul_permille
execute store result storage manacore:out r.seg_m int 1 run scoreboard players get #mp_out zx.meta
