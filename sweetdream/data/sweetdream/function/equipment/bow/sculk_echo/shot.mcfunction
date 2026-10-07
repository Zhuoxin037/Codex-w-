# ============================================================
# sweetdream:equipment/bow/sculk_echo/shot —— 每次射击(幽匿残响)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/sculk_echo(触发器 shot_crossbow)。
# 【文案】每次射击额外积攒 10 点「悲鸣」(上限 50); 射击后对被射击生物 2 格内
#   额外造成 基础攻击力 ×「悲鸣」×0.1 的伤害; 同时对发射路径周围 2 格的敌人
#   每刻造成 「悲鸣」×0.1 的伤害; 每 1 点「悲鸣」使该伤害有 1% 概率三倍, 触发后清空。
# 【层数怎么存】计分项 zx.se_cry —— 每人一份, 跨射击累积, 上限 50。
#   本发用的层数 = **射击前**的层数(积分在算完伤害之后再加, 见 ⑤)。
# 【★ 两处伤害都基于"本发层数" ★】
#   命中范围伤 hit_dmg  走 manacore 的 attack_mul 通道基数=基础攻击力, 倍率=悲鸣×0.1
#   路径每刻伤 path_dmg = 悲鸣 ×0.1(固定)
#   两者在射击时算好, 存进快照; 命中范围伤由附魔回调结算, 路径伤由 core/tick 逐刻推。
# 【★ 魔力是射出去之后才扣的 ★】没蓝就不生效(提示一句)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/sculk_echo
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.se_cry 0

# ① 本发层数 = 射击前的悲鸣(点)
scoreboard players operation #se_n zx.meta = @s zx.se_cry

# ② 扣魔力(固定 100)
data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume

# ③ 魔力不足 -> 这一发不生效(清旧数据, 提示)
execute if data storage manacore:out r{success:0b} run data modify storage zx:work se.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/sculk_echo/clear with storage zx:work se
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有悲鸣效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算命中范围伤: 走 attack_mul 通道, 倍率 = 悲鸣 ×0.1
data modify storage manacore:in arg set value {uuid:"",attack_mul:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
scoreboard players set #se_mul zx.meta 0
scoreboard players operation #se_mul zx.meta = #se_n zx.meta
execute store result storage manacore:in arg.attack_mul double 0.1 run scoreboard players get #se_mul zx.meta
function manacore:api/damage/calc

# ⑤ 写这一发的数据(射手名下 + 逐箭快照)
#    hit_dmg = 上一步算出的伤害; path_dmg = 悲鸣 ×0.1(固定)
data modify storage zx:work se set value {uuid:"",hit_dmg:0.0,path_dmg:0.0,cry:0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work se.uuid set from storage zx:data self.uuid
data modify storage zx:work se.hit_dmg set from storage manacore:out r.damage
execute store result score #se_path zx.meta run scoreboard players get #se_n zx.meta
execute store result storage zx:work se.path_dmg double 0.1 run scoreboard players get #se_path zx.meta
execute store result storage zx:work se.cry int 1 run scoreboard players get #se_n zx.meta
execute store result storage zx:work se.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work se.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work se.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work se.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/sculk_echo/store with storage zx:work se
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/sculk_echo/snapshot with storage zx:work se

# ⑥ 悲鸣 +10(上限 50) —— 放在算完之后, 这一发用的是旧值
scoreboard players add @s zx.se_cry 10
execute if score @s zx.se_cry matches 51.. run scoreboard players set @s zx.se_cry 50

# ⑦ 表现
execute at @s run particle minecraft:sculk_soul ~ ~1.3 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:block.sculk_sensor.clicking player @a ~ ~ ~ 0.7 1.0

# ⑧ 「启示录」记页: 幽匿残响固定扣 100, 同上。
function sweetdream:equipment/staff/apocalypse/spend
