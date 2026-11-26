# 独立的外观时钟，只改变物品模型，不参与伤害、圣痕、魔力或技能冷却。
execute unless data storage zx:config obj_acvf run scoreboard objectives add zx.acvf dummy
data modify storage zx:config obj_acvf set value 1b
scoreboard players set #tick zx.acvf 0
scoreboard players set #frame zx.acvf 0
# 光柱自己的 40 刻表现寿命，与玩家技能两段伤害的 zx.ac_d 完全分开。
execute unless data storage zx:config obj_ab_age run scoreboard objectives add zx.ab_age dummy
data modify storage zx:config obj_ab_age set value 1b
