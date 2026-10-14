# 只有视觉尾帧；此显示实体从未带 zx.sr_relic，不参与伤害/范围计数。
scoreboard players operation #srm_d_age zx.srm_f = #now manacore.meta
scoreboard players operation #srm_d_age zx.srm_f -= @s zx.srm_d
execute if score #srm_d_age zx.srm_f matches 17.. run return run function sweetdream:equipment/axe/sacred_relic/visual/remnant/cleanup
scoreboard players operation #srm_frame zx.srm_f = #srm_d_age zx.srm_f
scoreboard players add #srm_frame zx.srm_f 300
function sweetdream:equipment/axe/sacred_relic/visual/remnant/apply
