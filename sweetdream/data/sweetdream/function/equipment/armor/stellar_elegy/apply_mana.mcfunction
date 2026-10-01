# ============================================================
# sweetdream:equipment/armor/stellar_elegy/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】计分项 #diff = 要加的差值(可正可负)
# 【为什么最后要读一次再 set 回去】摘装备时上限变小, 当前魔力可能超过新上限,
#   会显示成 340/220 —— api/mana/set 内部会夹到 [0,max], 所以读出来原样写回就是"夹紧"。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# 记账: 本来源已经加了多少
scoreboard players operation @s zx.se_mana += #diff zx.meta

# 夹紧当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
