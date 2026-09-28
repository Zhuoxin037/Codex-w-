# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(可正可负)   【执行者】玩家
# 【为什么是"加差值"而不是"设成某个数"】面板里每一项只是一个数, 没有加成层。
#   直接 set 会把别的来源的加成一并冲掉, 所以只加差额。
# 【为什么最后要读一次再 set 回去】上限变小(摘头盔)时, 当前魔力可能超过新上限,
#   会显示成 540/340 这种。api/mana/set 内部会自动夹到 [0,max], 读出来原样
#   set 一遍就等于夹紧。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# 记账
scoreboard players operation @s zx.dio_mana += #diff zx.meta

# 夹紧当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
