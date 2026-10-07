# ============================================================
# sweetdream:equipment/armor/withered_garden/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(穿上为正 / 脱下为负)   【执行者】玩家
# 【账本】zx.gd_mana 记"已经加了多少", 每次只补差值, 幂等。
# 【为什么最后要读一次再 set 回去】上限变小时当前魔力可能超过新上限,
#   api/mana/set 内部会夹到 [0,max]。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.gd_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
