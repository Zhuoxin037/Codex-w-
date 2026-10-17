# 遗骸显示专用；重载保留正在进行的动画、原始 marker 和全部标签快照。
execute unless data storage zx:config obj_srm_b run scoreboard objectives add zx.srm_b dummy
data modify storage zx:config obj_srm_b set value 1b
execute unless data storage zx:config obj_srm_end run scoreboard objectives add zx.srm_end dummy
data modify storage zx:config obj_srm_end set value 1b
execute unless data storage zx:config obj_srm_p run scoreboard objectives add zx.srm_p dummy
data modify storage zx:config obj_srm_p set value 1b
execute unless data storage zx:config obj_srm_d run scoreboard objectives add zx.srm_d dummy
data modify storage zx:config obj_srm_d set value 1b
execute unless data storage zx:config obj_srm_f run scoreboard objectives add zx.srm_f dummy
data modify storage zx:config obj_srm_f set value 1b
execute unless data storage zx:config obj_srm_last run scoreboard objectives add zx.srm_last dummy
data modify storage zx:config obj_srm_last set value 1b
scoreboard players set #srm_4 zx.srm_f 4
scoreboard players set #srm_80 zx.srm_f 80
execute as @e[type=minecraft:marker,tag=zx.sr_relic] at @s run function sweetdream:equipment/axe/sacred_relic/visual/remnant/ensure

# 兼容已在场上的遗骸，重载不重置其寿命或动画相位。
execute as @e[type=minecraft:item_display,tag=zx.sr_model] run function sweetdream:equipment/axe/sacred_relic/visual/remnant/size
