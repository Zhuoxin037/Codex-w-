# ============================================================
# sweetdream:lib/mana_floor_apply —— 把"托底补正"落进面板
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值   【执行者】玩家
# 【最后读一次再 set 回去】补正把上限变小时当前魔力可能超过新上限,
#   api/mana/set 会夹到 [0,max], 读出来原样 set 一遍就等于夹紧。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.floor_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
