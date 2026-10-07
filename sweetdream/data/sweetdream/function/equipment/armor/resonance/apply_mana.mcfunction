# ============================================================
# sweetdream:equipment/armor/resonance/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(穿上 = +120, 脱下 = -120)   【执行者】玩家
# 【为什么用账本而不是"每次加 120"】秒级函数会每跑一次就加一次 —— 没有账本
#   的话穿上 10 秒就是 +1200。账本记"已经加了多少", 每次只补差值, 幂等。
# 【为什么最后要读一次再 set 回去】上限变小(脱装备)时当前魔力可能超过新上限,
#   会显示成 340/220。api/mana/set 内部会夹到 [0,max], 所以读出来原样 set
#   一遍就等于夹紧。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 记账
scoreboard players operation @s zx.rs_mana += #diff zx.meta

# ③ 夹紧当前魔力(脱装备时上限变小, 当前魔力可能超上限)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
