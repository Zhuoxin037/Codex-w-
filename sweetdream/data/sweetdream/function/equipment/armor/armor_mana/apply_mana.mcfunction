# ============================================================
# sweetdream:equipment/armor/armor_mana/apply_mana —— 给魔力上限加差值(账本 zx.am_mana)
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   【执行者】玩家
# 【为什么用账本】秒级函数每跑一次就加一次 -> 没账本的话穿上 10 秒就是 +10N。
#   账本记"已经加了多少", 每次只补差值, 幂等。
# 【为什么末尾要读一次再 set 回去】上限变小(脱装备)时当前魔力可能超上限,
#   会显示成 340/220。api/mana/set 内部会夹到 [0,max], 读出来原样 set 一遍就等于夹紧。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 记账
scoreboard players operation @s zx.am_mana += #diff zx.meta

# ③ 夹紧当前魔力
#   ★ 读不到就跳过 —— arg.value 的初值是 0.0, 要是拿它去 set 就等于**把魔力清空**。
#     (不夹紧最坏只是显示成 340/220, 下一秒回魔/受伤就正常了; 清空是真事故。)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r.value run data modify storage manacore:in arg.value set from storage manacore:out r.value
execute if data storage manacore:out r.value run function manacore:api/mana/set
