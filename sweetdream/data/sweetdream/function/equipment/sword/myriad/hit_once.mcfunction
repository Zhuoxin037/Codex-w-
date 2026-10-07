# ------------------------------------------------------------
# 打一次(并给循环计数 -1)。目标 = zx.mq_dmg, 数值 = manacore:out r.damage
# ------------------------------------------------------------
scoreboard players remove #mq_rep zx.meta 1
data modify storage zx:in arg set value {target:"@e[tag=zx.mq_dmg]",read:"manacore"}
function sweetdream:api/damage
