# ============================================================
# sweetdream:equipment/armor/brain_leech/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(戴着是 -120, 摘下是 +120)   【执行者】玩家
# 【为什么只加差值】面板的 max_mana 只是一个数, 没有"加成层"; 直接 set 会
#   把余烬/桂冠/套装给的加成一并冲掉。
# 【最后读一次再 set 回去】上限变小(戴上本件)时当前魔力可能超过新上限,
#   api/mana/set 会自动夹到 [0,max], 读出来原样 set 一遍就等于夹紧。
# 【账本】zx.bl_mana 记"本件已经从面板里减了多少", 摘下时按这本账加回去。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.bl_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
