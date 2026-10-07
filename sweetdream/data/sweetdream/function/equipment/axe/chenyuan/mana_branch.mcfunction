# ============================================================
# sweetdream:equipment/axe/chenyuan/mana_branch —— 魔力>300 的额外分支
# ------------------------------------------------------------
# 【执行者】动手的玩家   【目标】zx.victim(刚打中的那只)
# 【文案】若自身魔力值高于 300 则额外消耗 50 魔力值并使其附加「渊海」效果,
#   若其已附加则改为为自身恢复 70 魔力值。
# ============================================================

# 额外消耗 50 魔力(不够就什么都不做)
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return 0

# 目标已附带「渊海」? (选择器不能写两个 tag=, 所以先翻成一个标记)
scoreboard players set #cy_yh zx.meta 0
execute as @e[tag=zx.victim,limit=1] if entity @s[tag=zx.status.yuanhai] run scoreboard players set #cy_yh zx.meta 1
execute if score #cy_yh zx.meta matches 1 run function sweetdream:equipment/axe/chenyuan/mana_back
execute if score #cy_yh zx.meta matches 0 run function sweetdream:equipment/axe/chenyuan/mark_yuanhai
