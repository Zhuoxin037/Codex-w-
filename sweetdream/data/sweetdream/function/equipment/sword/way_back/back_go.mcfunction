$execute unless entity @e[type=marker,tag=zx.wb_lamp_$(uuid)] run return run function sweetdream:equipment/sword/way_back/lost
# ---- 返还量：累计伤害 ×50%，上限 最大生命 ×40% ----
scoreboard players operation #wb_h zx.meta = @s zx.wb_dmg
scoreboard players operation #wb_h zx.meta /= #2 zx.meta

scoreboard players set #wb_mx zx.meta 0
function sweetdream:lib/max_health_score
scoreboard players operation #wb_mx zx.meta = #max_hp zx.meta
scoreboard players operation #wb_cap zx.meta = #wb_mx zx.meta
scoreboard players operation #wb_cap zx.meta *= #4 zx.meta
scoreboard players operation #wb_cap zx.meta /= #10 zx.meta

execute if score #wb_h zx.meta > #wb_cap zx.meta run scoreboard players operation #wb_h zx.meta = #wb_cap zx.meta
scoreboard players operation #wb_h zx.meta /= #1000 zx.meta
execute if score #wb_h zx.meta matches 1.. run scoreboard players operation #heal_pt zx.meta = #wb_h zx.meta
execute if score #wb_h zx.meta matches 1.. run function sweetdream:lib/heal

# ---- 瞬移（marker 就是放灯时站的位置）----
data modify storage zx:work owner_arg set from storage zx:data self
function sweetdream:equipment/sword/way_back/teleport with storage zx:work owner_arg

# ---- 从未低于 50% → 迅捷Ⅱ 3 秒 ----
execute if score @s zx.wb_low matches 0 run effect give @s minecraft:speed 3 1 true

playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.9 1.1
particle minecraft:portal ~ ~1 ~ 0.5 0.8 0.5 0.5 40 normal

function sweetdream:equipment/sword/way_back/end
