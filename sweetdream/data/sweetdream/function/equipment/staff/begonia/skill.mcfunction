# ============================================================
# sweetdream:equipment/staff/begonia/skill —— 海棠: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 主动技能
#   魔力 450   ·   冷却 120 秒
#   使用后召唤一个术阵。之后使自身 16 格内的最多 5 个附有「渊海」的生物以自身
#   为中心生成一个漩涡。漩涡每秒都会将 4 格内的全部生物拉回中心一段距离，持续
#   8 秒。漩涡消失后会对处于中心的生物造成相当于释放者最大魔力值 ×0.15 的伤害。
#   之后清除「渊海」。
# 【四要素(逐个落实)】
#   ① 触发 = 潜行右键;
#   ② 目标范围 = 释放者 16 格内、附有「渊海」的最多 5 个生物(就近取);
#   ③ 次数 = 1 个术阵 + 每只被选中的生物各 1 个漩涡;
#   ④ 时长 = 每个漩涡 8 秒(见 second -> vortex_tick)。
# 【★ 目标没有就不放 ★】16 格内一只「渊海」都没有 -> 整个技能不成立(不扣蓝、不进冷却),
#   和惑梦同一套口径。
# 【“以自身为中心”= 以那只生物自身为中心】每只被选中的生物在原地生成一个漩涡
#   (漩涡 = 位置真相 marker, 见 vortex_make); 之后每秒拉 4 格内的生物回中心。
# 【“清除「渊海」”】在漩涡结束时(见 vortex_end)对中心 2 格内带「渊海」的生物
#   走 lib/mark_consume 摘掉(让余烬/永恒的消耗被动收得到信号)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/begonia

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 先看有没有「渊海」目标(没有就整个不放)
tag @e[tag=zx.bg_src,distance=0..] remove zx.bg_src
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..16,tag=zx.status.yuanhai,sort=nearest,limit=5] add zx.bg_src
execute unless entity @e[tag=zx.bg_src,distance=0..,limit=1] run tellraw @s [{"text":"附近没有附有「渊海」的生物","color":"red"}]
execute unless entity @e[tag=zx.bg_src,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 450
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:begonia",mana:450.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #bg_need zx.meta 0
execute store result score #bg_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"海棠冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#bg_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 450
data modify storage manacore:in arg set value {uuid:"",value:450.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#bg_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 120 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:begonia",cooldown_seconds:120.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑥ 召唤术阵(8 秒, 和漩涡同寿)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:begonia",type:"vortex",duration_seconds:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑦ 记释释放者的 uuid / u0..u3(漩涡结算与归属要用; 每只漩涡各存一份)
data modify storage zx:work bgv set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work bgv.uuid set from storage zx:data self.uuid
data modify storage zx:work bgv.u0 set from entity @s UUID[0]
data modify storage zx:work bgv.u1 set from entity @s UUID[1]
data modify storage zx:work bgv.u2 set from entity @s UUID[2]
data modify storage zx:work bgv.u3 set from entity @s UUID[3]

# ⑧ 每只被选中的「渊海」生物原地生成一个漩涡
execute as @e[tag=zx.bg_src,distance=0..] at @s run function sweetdream:equipment/staff/begonia/vortex_make

# ⑨ 表现 + 清理标记
execute at @s run particle minecraft:nautilus ~ ~1 ~ 2.0 0.6 2.0 0.05 24 normal
execute at @s run playsound minecraft:entity.elder_guardian.ambient_land player @a ~ ~ ~ 0.8 0.9
tag @e[tag=zx.bg_src,distance=0..] remove zx.bg_src
