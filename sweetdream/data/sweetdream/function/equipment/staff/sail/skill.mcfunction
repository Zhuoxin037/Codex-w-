# ============================================================
# sweetdream:equipment/staff/sail/skill —— 风帆: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 主动技能
#   魔力 500   ·   冷却 100 秒
#   使用后在被自身记录的生物处生成一个旋风。旋风每 3 秒都会吸引一次其 5 格内
#   的生物并使其附加被自身记录的生物的随机一种属性。期间自身可以再次使用技能
#   来将该生物召唤至自身处，持续 15 秒。若自身召唤了该生物则技能缩短 3 秒。
# 【四要素(逐个落实)】
#   ① 触发 = 潜行右键;
#   ② 目标范围 = "被记录的生物"处生成旋风; 旋风影响它 5 格内的生物;
#   ③ 次数 = 1 个旋风(每 3 秒脉冲一次);
#   ④ 时长 = 15 秒(每秒由 second -> whirl_tick 推)。
# 【"再次使用技能"】旋风进行中(zx.sl_vt >= 1)再按技能 -> 走 recall 分支
#   (把**旋风**召唤到身边 —— 不是把被记录的生物拽过来, 见 recall / find_whirl)。
# 【★ 被记录的生物不在了就不放 ★】既省钱也避免生成空旋风。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/sail

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 有记录吗
execute unless score @s zx.sl_ok matches 1 run tellraw @s [{"text":"还没有记录到生物（先用普攻记录一次）","color":"red"}]
execute unless score @s zx.sl_ok matches 1 run return fail

# ③ 旋风进行中 -> 召回分支(不再花蓝、不再起冷却)
execute if score @s zx.sl_vt matches 1.. run function sweetdream:equipment/staff/sail/recall
execute if score @s zx.sl_vt matches 1.. run return 0

# ④ 被记录的生物还在吗(按 uuid 反查)
data modify storage zx:work slu set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work slu.u0 int 1 run scoreboard players get @s zx.sl_u0
execute store result storage zx:work slu.u1 int 1 run scoreboard players get @s zx.sl_u1
execute store result storage zx:work slu.u2 int 1 run scoreboard players get @s zx.sl_u2
execute store result storage zx:work slu.u3 int 1 run scoreboard players get @s zx.sl_u3
function sweetdream:equipment/staff/sail/find_rec with storage zx:work slu
execute unless entity @e[tag=zx.sl_found,distance=0..,limit=1] run tellraw @s [{"text":"被记录的生物已经不在了","color":"red"}]
execute unless entity @e[tag=zx.sl_found,distance=0..,limit=1] run return fail

# ⑤ 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sail",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #sl_need zx.meta 0
execute store result score #sl_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"风帆冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#sl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ⑥ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#sl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑦ 起冷却 100 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sail",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑧ 召唤术阵(15 秒, 和旋风同寿)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:sail",type:"wind",duration_seconds:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑨ 组装旋风 marker 的参数(释放者 uuid / u0..u3 / 属性码列表)
data modify storage zx:work sl set value {uuid:"",u0:0,u1:0,u2:0,u3:0,n:0,m:[]}
data modify storage zx:work sl.uuid set from storage zx:data self.uuid
data modify storage zx:work sl.u0 set from storage zx:work slu.u0
data modify storage zx:work sl.u1 set from storage zx:work slu.u1
data modify storage zx:work sl.u2 set from storage zx:work slu.u2
data modify storage zx:work sl.u3 set from storage zx:work slu.u3
function sweetdream:equipment/staff/sail/mask_build
execute store result storage zx:work sl.n int 1 run scoreboard players get #sl_n zx.meta

# ⑩ 在被记录的生物处生成旋风
execute at @e[tag=zx.sl_found,distance=0..,limit=1] run function sweetdream:equipment/staff/sail/whirl_spawn

# ⑪ 标记"旋风进行中"(供"再次使用技能"识别)
scoreboard players set @s zx.sl_vt 15
function sweetdream:equipment/staff/sail/visual/begin

# ⑫ 表现 + 清理临时标记
execute at @e[tag=zx.sl_found,distance=0..,limit=1] run particle minecraft:small_gust ~ ~1 ~ 0.6 0.6 0.6 0.1 20 normal
execute at @s run playsound minecraft:item.elytra.flying player @a ~ ~ ~ 0.8 1.2
tag @e[tag=zx.sl_found,distance=0..] remove zx.sl_found
