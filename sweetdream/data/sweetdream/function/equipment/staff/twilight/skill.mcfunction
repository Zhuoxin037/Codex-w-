# ============================================================
# sweetdream:equipment/staff/twilight/skill —— 暮光: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 主动技能
#   魔力 350   ·   冷却 100 秒
#   使用后召唤一个术阵。之后使自身 12 格内最多 3 个带有「噬心」效果的生物的护甲值
#   及护甲韧性减半，且其抗性提升效果失效。持续 8 秒。
# 【四要素(逐个落实)】
#   ① 触发 = 潜行右键;
#   ② 目标范围 = 释放者 12 格内、带「噬心」的最多 3 个生物(就近取);
#   ③ 次数 = 1 个术阵 + 每个目标一套减益;
#   ④ 时长 = 8 秒(每秒由 second -> tw_tick 维持; 到点 tw_end 摘掉修饰符)。
# 【★ 目标没有就不放 ★】12 格内一只带「噬心」的都没有 -> 不成立。
# 【护甲/韧性减半怎么实现】attribute modifier(add_multiplied_base -0.5 = 基础值 ×0.5),
#   同 id 重复 add 会静默失败(值不变), 所以重贴不用先 remove; 8 秒后 tw_end 统一 remove。
# 【抗性提升失效】每秒清一次目标身上的抗性提升(effect clear) —— 期间新获得的也清掉。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/twilight

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 先看有没有「噬心」目标(没有就整个不放)
tag @e[tag=zx.tw_tgt,distance=0..] remove zx.tw_tgt
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..12,tag=zx.status.shixin,sort=nearest,limit=3] add zx.tw_tgt
execute unless entity @e[tag=zx.tw_tgt,distance=0..,limit=1] run tellraw @s [{"text":"附近没有带有「噬心」的生物","color":"red"}]
execute unless entity @e[tag=zx.tw_tgt,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 350
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:twilight",mana:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #tw_need zx.meta 0
execute store result score #tw_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"暮光冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tw_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 350
data modify storage manacore:in arg set value {uuid:"",value:350.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tw_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 100 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:twilight",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑥ 召唤术阵(8 秒, 和效果同寿)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:twilight",type:"dusk",duration_seconds:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑦ 给每个目标上减益 + 起 8 秒倒计时
execute as @e[tag=zx.tw_tgt,distance=0..] run function sweetdream:equipment/staff/twilight/tw_lock

# ⑧ 表现
execute at @s run particle minecraft:witch ~ ~1 ~ 2.0 0.6 2.0 0.1 30 normal
execute at @s run playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 0.7 1.3
