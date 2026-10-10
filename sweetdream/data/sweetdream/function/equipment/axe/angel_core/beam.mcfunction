# 天使核心：在每个圣痕引爆目标处升起金白光柱，仍只生成一个表现实体。
# 模型 16 像素高，最终纵向缩放 6；实体抬高 3 格，柱底恰好贴地。
# 初始缩放 0.8、Y 平移 -2.6，同样贴地；四刻升起、最后八刻收束。
# zx.ab_age 负责精确的 40 刻表现寿命；旧柱子的 zx.ab_t 秒计时仅作兼容。
# 目标、圣痕清除和技能伤害均由 dmg2 处理，本函数只有模型、粒子和音效。

execute at @s run summon minecraft:item_display ~ ~3 ~ {Tags:["zx.ac_beam","zx.ac_beam_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:angel_beam"}},brightness:{sky:15,block:15},interpolation_duration:4,transformation:{translation:[0.0f,-2.6f,0.0f],scale:[0.72f,0.8f,0.72f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
execute at @s run particle minecraft:end_rod ~ ~0.15 ~ 1.5 0.05 1.5 0.02 24 normal
execute at @s run particle minecraft:dust{color:[1.0,0.97,0.86],scale:2.2} ~ ~0.25 ~ 1.2 0.05 1.2 0.0 8 normal
execute at @s run particle minecraft:end_rod ~ ~2.5 ~ 0.3 2.2 0.3 0.02 12 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.70 1.05
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.70 1.00
execute at @s run playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.30 1.60
scoreboard players set @n[limit=1,tag=zx.ac_beam_new] zx.ab_t 2
scoreboard players set @n[limit=1,tag=zx.ac_beam_new] zx.ab_age 0
tag @n[limit=1,tag=zx.ac_beam_new] remove zx.ac_beam_new
