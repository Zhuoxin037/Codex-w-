function fallendream:profession/berserker/expire
scoreboard players add @s zx.j_b_sum 0
scoreboard players operation #jbdiff zx.meta = #jbsum zx.meta
scoreboard players operation #jbdiff zx.meta -= @s zx.j_b_sum
execute if score #jbsum zx.meta matches 0 if score @s zx.s2_natural matches 1 run function fallendream:equipment/armor/cease_war/start
scoreboard players set @s zx.s2_natural 0
# 重新获得职业攻击增益时的余勇处理:
#   基础版 = 余勇提前结束; 超限·止战 = "改为"转化态(扣目标护甲/韧性 + 自身加攻), 不结束。
execute if score #jbsum zx.meta matches 1.. if entity @s[tag=zx.s2_cw] if items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"],ol:"cease_war"}] run function fallendream:equipment/armor/cease_war/ol_swap
execute if score #jbsum zx.meta matches 1.. if entity @s[tag=zx.s2_cw] unless items entity @s armor.chest *[minecraft:custom_data~{zx:["cease_war"],ol:"cease_war"}] run function fallendream:equipment/armor/cease_war/end
execute if score #jbdiff zx.meta matches 0 run return 0
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #jbdiff zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.j_b_sum = #jbsum zx.meta
attribute @s minecraft:attack_damage modifier remove fallendream:profession_berserker
execute store result storage zx:work jbattr.value double 0.001 run scoreboard players get #jbsum zx.meta
execute if score #jbsum zx.meta matches 1.. run function fallendream:profession/berserker/native with storage zx:work jbattr
