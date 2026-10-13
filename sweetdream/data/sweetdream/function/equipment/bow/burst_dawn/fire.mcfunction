# ============================================================
# sweetdream:equipment/bow/burst_dawn/fire —— 「爆裂黎明」命中结算(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bd {target, shooter, uuid, mode}
#   mode: 1 = 主力 / 2 = 续轰(由 hook_victim 按箭上的标签认出来)
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(apply 用 as/at 送进来)
# 【技能原文(lore 逐字)】
#   「自身对射中的生物及其 3 格内的全部生物造成一次相当于自身基础攻击力 ×8
#     + 自身最大魔力值 ×0.15 的伤害并使生物获得 2 秒缓慢Ⅴ，之后再造成一次
#    相当于上次总伤害 50% 的伤害。」
#   「…之后自身可以使用自身召唤的「魂灵之影」当作弹药继续进行轰击，但是伤害
#    变为自身基础攻击力 ×4 + 自身最大魔力值 ×0.08。」
# 【★ 第二段的 50% 基数怎么定的(2026-10-12 用户拍板)★】
#   第一段对每只都打 D = 基础攻击力 ×8 + 最大魔力 ×0.15; 场上圈到 N 只
#   => 第一段"总伤害" T = N × D; **第二段每只都吃 T × 50%**(不是"各自 50%")。
#   实现上不自己乘: calc 的 independent_multiplier 是一个整体乘区, 把它设成
#   N × 0.5 就正好等于 (基础攻击力 ×8 + 最大魔力 ×0.15) × N × 0.5 = D × N × 0.5。
#   ★ 为什么不用"先算 D 再乘": 存储里的两个数没法直接相乘(只能整数缩放),
#     而 calc 的公式对两条通道是线性的, 走乘区既精确又不用自制定点乘法
#     (定点乘法会撞 int32 上界, 见坑 112)。
# 【★ 续轰也照给 2 秒缓慢Ⅴ ★】文案只说"伤害变为 …", 也就是**同一个轰击**换了
#   数值 —— 其余(范围 / 缓慢 / 第二段)一概不变。
# 【范围怎么圈】以被打中的那只为中心开一个"判定箱相交"的盒子(边长 = 2×3 = 6),
#   和其余弩同款 —— 不用 distance(高个子会因为"脚太远"被漏掉)。
# 【★ 必须排除 zx.bd_shade ★】魂灵之影是**自己的弹药**, 站在自己脚边,
#   不排除就会被自己这一炮轰掉(表现为"续轰打不出来")。
# ============================================================

# ① 圈出「射中那只 + 其 3 格内」的全部生物(排除玩家 / 非生物 / 自己的影)
tag @e[tag=zx.bd_aoe,distance=0..] remove zx.bd_aoe
$execute at $(target) positioned ~-3.0 ~-3.0 ~-3.0 run tag @e[type=!#sweetdream:no_damage,tag=!zx.bd_shade,dx=6.0,dy=6.0,dz=6.0] add zx.bd_aoe
execute unless entity @e[tag=zx.bd_aoe,distance=0..,limit=1] run return 0

# ② 数一数一共有几只 —— 第二段要用"第一段的**总**伤害"(= D × N)
scoreboard players set #bd_n2 zx.meta 0
execute as @e[tag=zx.bd_aoe,distance=0..] run scoreboard players add #bd_n2 zx.meta 1

# ③ 2 秒缓慢Ⅴ(先给, 免得被第一段打死的没吃到)
execute as @e[tag=zx.bd_aoe,distance=0..] run effect give @s minecraft:slowness 2 4 true

# ④ 第一段: 每只吃 D(主力 攻击力 ×8 + 最大魔力 ×0.15 / 续轰 ×4 + ×0.08)
data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0,max_mana_mul:0.15,independent_multiplier:1.0}
execute if data storage zx:work bd{mode:2} run data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0,max_mana_mul:0.08,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:work bd.uuid
function manacore:api/damage/calc
data modify storage zx:work bd.dmg set value 0.0
data modify storage zx:work bd.dmg set from storage manacore:out r.damage
function sweetdream:equipment/bow/burst_dawn/fire_hit

# ⑤ 第二段: 每只再吃 (第一段总伤害) × 50%
execute store result storage zx:work bd.im double 0.5 run scoreboard players get #bd_n2 zx.meta
data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0,max_mana_mul:0.15,independent_multiplier:1.0}
execute if data storage zx:work bd{mode:2} run data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0,max_mana_mul:0.08,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:work bd.uuid
data modify storage manacore:in arg.independent_multiplier set from storage zx:work bd.im
function manacore:api/damage/calc
data modify storage zx:work bd.dmg set value 0.0
data modify storage zx:work bd.dmg set from storage manacore:out r.damage
function sweetdream:equipment/bow/burst_dawn/fire_hit

# ⑥ 表现 + 收尾(工作标签一定要清, 否则会污染下一箭)
$execute at $(target) run particle minecraft:flash ~ ~1 ~ 0 0 0 0 1 normal
$execute at $(target) run particle minecraft:soul ~ ~1 ~ 1.5 1.0 1.5 0.06 60 normal
$execute at $(target) run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.5 1.2
tag @e[tag=zx.bd_aoe,distance=0..] remove zx.bd_aoe
