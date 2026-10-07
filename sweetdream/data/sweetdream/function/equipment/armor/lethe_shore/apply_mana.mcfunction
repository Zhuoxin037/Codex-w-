# ============================================================
# sweetdream:equipment/armor/lethe_shore/apply_mana —— 给魔力上限补差值
# ------------------------------------------------------------
# 【入参】#diff = 要补的差值(戴上为正 / 摘下为负)   【执行者】玩家
# 【和漫步冥河 apply_mana 完全同构】只有账本名(zx.lt_mana)不同。
#   差值账本的理由: 秒级函数每秒都跑, 没有账本就会每秒加一次 +180。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.lt_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
