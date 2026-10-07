# ============================================================
# sweetdream:equipment/axe/chenyuan/mana_back —— 已附带渊海 -> 自身恢复 70 魔力
# ------------------------------------------------------------
# 【执行者】玩家
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:70.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
# 【2026-10-04 删掉文字提示】原来这里有一行 tellraw("渊海共鸣: 恢复 70 魔力")。
#   玩家反馈连打时会刷屏 -> 去掉; 只留一个音效当反馈。
execute at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.6 1.5
