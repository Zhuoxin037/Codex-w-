# ============================================================
# fallendream:equipment/armor/resonance/passive —— 共振的被动(魔力上限那一条)
# ------------------------------------------------------------
# 【文案】自身魔力值上限 +120。自身当前每有一个术阵则自身释放技能的伤害 +10%。
#
# 【★ 两件事必须分开做, 原因不同 ★】
#   ① 魔力上限 +120 —— "穿上加、脱下减"的差值账本(zx.rs_mana), 秒级跑就够。
#   ② 技能伤害 +10%/术阵 —— 不能在这里做。它读的是"施法那一刻的术阵数量",
#      每秒快照会在术阵刚生成 / 刚过期的那一秒算错。那一条挂在
#      #manacore:event/damage_calc 上, 见 resonance/hook_calc。
#
# 【为什么对全部玩家跑(不筛穿着的人)】账本是差值的: 只筛穿胸甲的人的话,
#   脱下那一秒没人执行, 那 +120 就永远加不回来(变成"穿过一次就永久 +120")。
# 【自己判穿着】本函数被 event/second 以 @a 广播调用, 所以第一件事就是
#   看自己到底穿没穿 —— 不判的话没穿的人也会吃到加成(静默 bug)。
# 【认装备用 ~ 部分匹配 + 独有标记】custom_data~{zx:["resonance"]}
#   用 = 精确匹配会"多一段少一段就整个对不上"且不报错(踩过两次)。
# ============================================================

# ① 拿 UUID
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗(共振是铁胸甲, 槽位 armor.chest)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"]}] run scoreboard players set #on zx.meta 1

# ③ 差值 = 想要的 - 账本上已经加过的; 差值为 0 就什么都不用做
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players set #want zx.meta 120
# 超限·共振 +180
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"],ol:"resonance"}] run scoreboard players set #want zx.meta 180
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.rs_mana
execute unless score #diff zx.meta matches 0 run function fallendream:equipment/armor/resonance/apply_mana

# ④ 超限(2026-11-22): 术阵位全满 → 每秒 8 魔力 + 魔耗/冷却 -15%
#   ★ 不穿超限共振的人必须走 full_off ★ 否则换上普通共振之后那两个开关
#     永远退不掉(账本还记着 150 / 850)。
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"],ol:"resonance"}] run function fallendream:equipment/armor/resonance/full
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"],ol:"resonance"}] run function fallendream:equipment/armor/resonance/full_off
