# ============================================================
# sweetdream:equipment/bow/rainbow/shot —— 每次射击(虹彩)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/rainbow(触发器 shot_crossbow)。
# 【文案】每次射击若射到生物, 则使其附着 10 秒「漫彩」; 期间若其有 流火/夜火/渊海/
#   白昼梦/噬心 中任意一个效果, 则消耗该效果并使其受到 自身最大生命值 ×0.1 的伤害,
#   之后「漫彩」-1 秒; 若「漫彩」在 5 秒内结束, 则对其 2 格内生物造成
#   自身最大生命值 ×0.2 的伤害。
# 【★ 命中判定交给附魔回调 ★】射击本身只负责扣魔力 + 记"这一发有效",
#   真正"射到了谁"由附魔 hook_victim 判定(和寒鸦同一套)。
# 【★ 魔力是射出去之后才扣的 ★】没蓝就不生效(提示一句)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/rainbow
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 扣魔力(固定 580)
data modify storage manacore:in arg set value {uuid:"",value:580.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

# ② 魔力不足 -> 这一发不生效
execute if data storage manacore:out r{success:0b} run data modify storage zx:work rb.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/rainbow/clear with storage zx:work rb
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有漫彩效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 把这一发的归属写进射手名下 + 逐箭快照(命中时用来算伤害归属)
data modify storage zx:work rb set value {uuid:"",ok:1b,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work rb.uuid set from storage zx:data self.uuid
execute store result storage zx:work rb.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work rb.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work rb.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work rb.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/rainbow/store with storage zx:work rb
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/rainbow/snapshot with storage zx:work rb

# ④ 表现
execute at @s run particle minecraft:end_rod ~ ~1.3 ~ 0.3 0.3 0.3 0.05 12 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.0

# ⑤ 「启示录」记页: 漫彩固定扣 580, 同上。
function sweetdream:equipment/staff/apocalypse/spend
