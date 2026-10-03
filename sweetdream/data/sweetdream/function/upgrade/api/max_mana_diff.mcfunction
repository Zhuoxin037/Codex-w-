# ============================================================
# sweetdream:upgrade/api/max_mana_diff —— 给面板的 max_mana 加/减差值
# ------------------------------------------------------------
# 【入参】#diff(可正可负)   【执行者】玩家(且 zx:data self.uuid 已备好)
# 【为什么最后要再读一次 set 回去】上限变小时当前魔力可能超过新上限(显示 340/220),
#   api/mana/set 内部会夹到 [0,max], 所以读出来原样 set 一遍就等于夹紧。
#   (和静脉泵 apply_mana 完全同一套写法)
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# 记账: 记下"升级系统一共加了多少", 下次才能算差值
scoreboard players operation @s zx.up_mana += #diff zx.meta

# 夹紧当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
