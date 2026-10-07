# ============================================================
# sweetdream:equipment/armor/styx_walk/apply_mana —— 给魔力上限补差值
# ------------------------------------------------------------
# 【入参】#diff = 要补的差值(戴上为正 / 摘下为负)
# 【执行者】玩家
# 【为什么用账本】秒级函数每秒都跑 —— 没有账本就会每秒加一次,
#   戴上 10 秒 = +2100。账本 zx.sw_mana 记"已经加了多少", 每次只补差, 幂等。
# 【为什么要读完再 set 回去】上限变小时当前魔力可能超上限, api/mana/set 会夹回去。
#   这一段和炉心 furnace_core/apply_mana 完全同构, 换的只是账本名。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.sw_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
