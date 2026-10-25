# 浮光绿/白每秒回魔0.5%/0.8%、回血1%/3%；生命与魔力均按千分单位累积，回血不足1点保留余数。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #gl_m zx.meta 0
execute if data storage manacore:out r.value store result score #gl_m zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #gl_m zx.meta /= #200 zx.meta
scoreboard players set #gl_cap zx.meta 2147483647
scoreboard players operation #gl_cap zx.meta /= #8 zx.meta
execute if score #gl_regen zx.meta matches 2 if score #gl_m zx.meta > #gl_cap zx.meta run scoreboard players operation #gl_m zx.meta = #gl_cap zx.meta
execute if score #gl_regen zx.meta matches 2 run scoreboard players operation #gl_m zx.meta *= #8 zx.meta
execute if score #gl_regen zx.meta matches 2 run scoreboard players operation #gl_m zx.meta /= #5 zx.meta
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #gl_m zx.meta
function manacore:api/mana/add
scoreboard players operation @s zx.regen_milli += #gl_m zx.meta
function sweetdream:lib/max_health_score
scoreboard players operation #gl_h zx.meta = #max_hp zx.meta
scoreboard players operation #gl_h zx.meta /= #100 zx.meta
execute if score #gl_regen zx.meta matches 2 run scoreboard players operation #gl_h zx.meta *= #3 zx.meta
scoreboard players operation @s zx.gl_hacc += #gl_h zx.meta
execute if score @s zx.gl_hacc matches 1000.. run function sweetdream:equipment/armor/glimmer/heal_out
