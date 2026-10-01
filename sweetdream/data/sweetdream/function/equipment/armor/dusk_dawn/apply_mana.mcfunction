# ============================================================
# sweetdream:equipment/armor/dusk_dawn/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   #src = 哪个来源要的
#   1 = 靴子本身(+180)   2 = 套装(+200)   3 = 击杀后的临时上限
# 【为什么要分三个账本】每个来源自己记"已经加了多少", 换装/到点时才知道该减多少,
#   互相不冲掉。(静脉泵/体外那套也是这个思路)
# 【最后为什么读一次再 set 回去】上限变小时当前魔力可能超上限, 写回一次就等于夹紧。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

execute if score #src zx.meta matches 1 run scoreboard players operation @s zx.dd_mana += #diff zx.meta
execute if score #src zx.meta matches 2 run scoreboard players operation @s zx.dd_set += #diff zx.meta
execute if score #src zx.meta matches 3 run scoreboard players operation @s zx.dd_app += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
