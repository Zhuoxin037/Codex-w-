# ============================================================
# sweetdream:equipment/armor/furnace_core/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(穿上为正 / 脱下为负 / 层数变化时的补差)
# 【执行者】玩家
# 【为什么用账本】秒级函数每秒都跑 —— 没有账本就每秒加一次, 穿上 10 秒 = +1000。
#   账本记"已经加了多少", 每次只补差值, 幂等。
# 【为什么最后要读一次再 set 回去】上限变小时(脱装备 / 燃灰掉层)当前魔力可能
#   超过新上限, 会显示成 340/220。api/mana/set 内部会夹到 [0,max]。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.fc_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
