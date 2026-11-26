# ============================================================
# fallendream:equipment/staff/firefly_staff/skill —— 主动技能「萤火齐射」
# ------------------------------------------------------------
# 【文案·原版】魔力 100 · 冷却 35 秒: 使自身周围的萤火立即向自身前方射出。
# 【文案·超限】魔力 200 · 冷却 30 秒; 并且准星方向 12 格内有生物时, 其中至多 5 个
#   萤火改为**追踪**那只生物(追踪的萤火伤害 = 当前魔力 ×0.05); 射出后飞 16 格
#   没命中的萤火转而回到身边环绕 8 秒(碰触生物 → ×0.04 + 流火)。
# 【★ 档位在按下技能的这一刻拍一次 ★】之后玩家可能在萤火飞行的 1 秒内换手,
#   而"要不要追踪 / 魔力多少 / 冷却多久"都该按**释放时**的装备算。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

scoreboard players set #ff_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["firefly_staff"],ol:"firefly_staff"}] run scoreboard players set #ff_ol zx.meta 1

# ① 魔力: 原版 100 / 超限 200
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:firefly_staff",mana:100.0}
execute if score #ff_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 200.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:100.0}
execute if score #ff_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 200.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

# ② 冷却: 原版 35 秒 / 超限 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:firefly_staff",cooldown_seconds:35.0,reduce:1b}
execute if score #ff_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 30.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ③ 超限: 先准星索敌, 至多 5 个萤火改成追踪
#    ★ 必须在 fire_all **之前**: fire_one 是"离弦那一刻"决定走直线还是追人的。
data modify storage zx:work firefly set value {uuid:"",ol:0}
data modify storage zx:work firefly.uuid set from storage zx:data self.uuid
execute store result storage zx:work firefly.ol int 1 run scoreboard players get #ff_ol zx.meta
execute if score #ff_ol zx.meta matches 1 run function fallendream:equipment/staff/firefly_staff/mark_homing with storage zx:work firefly

# ④ 全部萤火朝前方射出
function fallendream:equipment/staff/firefly_staff/fire_all with storage zx:work firefly
