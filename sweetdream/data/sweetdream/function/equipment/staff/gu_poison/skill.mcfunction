# ============================================================
# sweetdream:equipment/staff/gu_poison/skill —— 蛊毒: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 主动技能
#   魔力 500   ·   冷却 120 秒
#   使用后召唤一个术阵。之后使自身 8 格内的最多 2 个带有「噬心」效果的生物每秒
#   受到相当于自身最大生命值 ×0.1 的伤害，之后移除「噬心」。持续 6 秒。（若
#   「噬心」效果提前结束则技能效果也提前失效）
# 【四要素(逐个落实)】
#   ① 触发 = 潜行右键;
#   ② 目标范围 = 释放者 8 格内、带「噬心」的最多 2 个生物(就近取);
#   ③ 次数 = 1 个术阵 + 每个目标每秒 1 发(共 6 发);
#   ④ 时长 = 6 秒(每秒由 second 驱动 gp_tick)。
# 【★ 目标没有就不放 ★】8 格内一只带「噬心」的都没有 -> 不成立(不扣蓝、不进冷却)。
# 【伤害口径】"自身最大生命值 ×0.1" -> health_ratio 通道(基数 = 面板最大生命)。
#   "自身" = 释放者(和普攻的"自身当前魔力"同一约定)。
# 【"之后移除「噬心」"】放在 6 秒走完时(见 gp_end), 走统一入口 mark_consume。
# 【"提前结束则提前失效"】gp_tick 每拍先查目标身上还有没有「噬心」。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/gu_poison

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 先看有没有「噬心」目标(没有就整个不放)
tag @e[tag=zx.gp_tgt,distance=0..] remove zx.gp_tgt
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,tag=zx.status.shixin,sort=nearest,limit=2] add zx.gp_tgt
execute unless entity @e[tag=zx.gp_tgt,distance=0..,limit=1] run tellraw @s [{"text":"附近没有带有「噬心」的生物","color":"red"}]
execute unless entity @e[tag=zx.gp_tgt,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gu_poison",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #gp_need zx.meta 0
execute store result score #gp_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"蛊毒冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#gp_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#gp_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 120 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gu_poison",cooldown_seconds:120.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑥ 召唤术阵(6 秒, 和效果同寿)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:gu_poison",type:"poison",duration_seconds:6.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑦ 记释放者 uuid / u0..u3(每秒结算与归属要用)
data modify storage zx:work gp set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work gp.uuid set from storage zx:data self.uuid
data modify storage zx:work gp.u0 set from entity @s UUID[0]
data modify storage zx:work gp.u1 set from entity @s UUID[1]
data modify storage zx:work gp.u2 set from entity @s UUID[2]
data modify storage zx:work gp.u3 set from entity @s UUID[3]

# ⑧ 把参数写到每个目标身上 + 起 6 秒倒计时
execute as @e[tag=zx.gp_tgt,distance=0..] run function sweetdream:equipment/staff/gu_poison/gp_lock

# ⑨ 表现
execute at @s run particle minecraft:witch ~ ~1 ~ 2.0 0.6 2.0 0.1 30 normal
execute at @s run playsound minecraft:entity.spider.ambient player @a ~ ~ ~ 0.8 0.7
