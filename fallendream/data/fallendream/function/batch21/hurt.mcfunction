advancement revoke @s only fallendream:equipment/batch21_hurt
tag @e[tag=zx.s2_source,distance=0..] remove zx.s2_source
tag @s add zx.s2_hurt_player
execute on attacker unless entity @s[tag=zx.s2_hurt_player] run tag @s add zx.s2_source
execute if entity @e[tag=zx.s2_source,distance=0..,limit=1] if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run function fallendream:equipment/armor/empty_cicada/hurt
# 超限·溢流：吸收（临时生命）被这一次攻击打掉 ⇒ 回 1% 上限魔力 + 给攻击者「渊海」
execute if entity @e[tag=zx.s2_source,distance=0..,limit=1] if items entity @s armor.legs *[custom_data~{zx:["overflow"]}] run function fallendream:equipment/armor/overflow/hurt
execute if entity @e[tag=zx.s2_source,distance=0..,limit=1] if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run function fallendream:equipment/armor/still_sky/hurt
tag @e[tag=zx.s2_source,distance=0..] remove zx.s2_source
tag @s remove zx.s2_hurt_player
