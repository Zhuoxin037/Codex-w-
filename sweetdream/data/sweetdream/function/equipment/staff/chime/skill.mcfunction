# ============================================================
# sweetdream:equipment/staff/chime/skill —— 共鸣: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 主动技能
#   魔力 140   ·   冷却 40 秒
#   使用后召唤一个术阵。之后在原地生成一个“共鸣水晶”。
#   ✦ 共鸣水晶
#   每 2 秒都会对其 6 格内的一个生物造成一次相当于自身最大魔力值 ×0.03 的伤害。
#   自身释放的法术穿过“共鸣水晶”时会立即对其 3 格内的全部生物造成一次相当于
#   自身最大魔力值 ×0.05 的伤害。“共鸣水晶”8 秒后自毁。
# 【四要素(逐个落实)】
#   ① 触发 = 潜行右键;
#   ② 目标范围 = 原地(术阵 + 水晶)—— 不对生物直接造成伤害;
#   ③ 次数 = 1 个术阵 + 1 颗水晶;
#   ④ 时长 = 水晶 8 秒(到期自毁, 见 second -> crystal_end)。
#   · 水晶"每 2 秒"那一段 目标范围 = 水晶 **6 格内的一个**生物 → crystal_tick
#   · "法术穿过"那一段 目标范围 = 水晶 **3 格内的全部**生物 → pass_check/pass_go
# 【"自身"= 释放者】两句伤害的基数都是**释放者的最大魔力值** -> mm 通道。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 140
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:chime",mana:140.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"共鸣冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 140）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 140
data modify storage manacore:in arg set value {uuid:"",value:140.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 140）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:chime",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 召唤术阵(8 秒, 和水晶同寿)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:chime",type:"chime",duration_seconds:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 原地生成"共鸣水晶" —— 一个 marker
#   【位置真相 = marker】框架术阵只存数据、不存位置; "6 格内 / 3 格内"要有圆心。
#   【归属】data.zx.ch 存释放者 uuid(字符串) + u0..u3(四个 int, 宏反查用, 见 crystal_set)。
summon minecraft:marker ~ ~ ~ {Tags:["zx.ch_cry","zx.ch_new"]}
data modify entity @n[limit=1,tag=zx.ch_new] data.zx.ch set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify entity @n[limit=1,tag=zx.ch_new] data.zx.ch.uuid set from storage zx:data self.uuid
data modify entity @n[limit=1,tag=zx.ch_new] data.zx.ch.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.ch_new] data.zx.ch.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.ch_new] data.zx.ch.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.ch_new] data.zx.ch.u3 set from entity @s UUID[3]
#   寿命: 8 秒 = #now + 160
scoreboard players operation @n[limit=1,tag=zx.ch_new] zx.ch_end = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.ch_new] zx.ch_end 160
tag @n[limit=1,tag=zx.ch_new] remove zx.ch_new

# ⑦ 表现(水晶成型)
particle minecraft:end_rod ~ ~1 ~ 0.4 0.6 0.4 0.05 24 normal
particle minecraft:enchant ~ ~1 ~ 0.5 0.5 0.5 0.3 20 normal
playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.9 1.2
