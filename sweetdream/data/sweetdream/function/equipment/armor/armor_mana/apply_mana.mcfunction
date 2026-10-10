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
#   ★ 判据**不能**写 `execute if data storage manacore:out r.value` ★ (2026-10-08 修)
#     那条守卫恒为真: manacore:internal/mana/get 会**无条件**把 out r.value 写成 0.0,
#     而 core/boot 初始化 out r 时本来就带 value:0.0 -> 这个键永远存在。
#     于是"读不到该玩家 current_mana"时会带着 0.0 去 set -> **把魔力清空**
#     (正是这段注释本来想防的事故)。
#     真正的"读到了" = 玩家记录里 stats.current_mana 字段在 -> 用它做判据。
#     (不夹紧最坏只是显示成 340/220, 下一秒回魔/受伤就正常了; 清空是真事故。)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #mhas zx.meta 0
data modify storage zx:work am.uuid set from storage zx:data self.uuid
function sweetdream:equipment/armor/armor_mana/has_mana with storage zx:work am
execute if score #mhas zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:""}
execute if score #mhas zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #mhas zx.meta matches 1 run data modify storage manacore:in arg.value set from storage manacore:out r.value
execute if score #mhas zx.meta matches 1 run function manacore:api/mana/set
