# ============================================================
# sweetdream:equipment/armor/intravenous_pump/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参(都在计分项上)】#diff = 要加的差值(可正可负)   #src = 哪个来源要的
#   1 = 静脉泵本身   2 = 套装(在 external_power 那边调用)
# 【为什么放两个来源的账本】每个来源单独记账, 各自穿上加、脱下减, 互不干涉。
# 【为什么最后要读一次再 set 回去】上限变小(摘装备)时当前魔力可能超过新上限,
#   会显示成 340/220。api/mana/set 内部会夹到 [0,max], 所以读出来原样 set
#   一遍就等于夹紧。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# 记账
execute if score #src zx.meta matches 1 run scoreboard players operation @s zx.pump_mana += #diff zx.meta
execute if score #src zx.meta matches 2 run scoreboard players operation @s zx.set_mana += #diff zx.meta

# 夹紧当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
