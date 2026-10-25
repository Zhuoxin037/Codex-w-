# ============================================================
# sweetdream:equipment/bow/sculk_echo/shot —— 每次射击(幽匿残响)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/sculk_echo(触发器 shot_crossbow)。
# 【文案(基础版)】每次射击额外积攒 10 点「悲鸣」(上限 50); 射击后对被射击生物 **2 格**内
#   额外造成 基础攻击力 ×「悲鸣」×0.1 的伤害; 同时对发射路径周围 **2 格**的敌人
#   每刻造成 「悲鸣」×0.1 的伤害; 每 1 点「悲鸣」使该伤害有 **1%** 概率三倍, 触发后清空。
# 【文案(超限·幽匿残响, 2026-10-10 实装)】积攒 **20** 点(上限 **100**); 两个范围
#   **2 格 -> 3 格**; 三倍概率 **1%/点 -> 0.5%/点**(满层同样是 50%)。
#   ★ 三条都随"这一发是不是超限版"走, 判定在离弦这一刻拍下来随快照带到命中点
#     (`zx:work se.ol`), 与「蚀骨」同一套(命中时手里未必还是这把弩)。
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
scoreboard players set #se_n zx.meta 0
scoreboard players operation #se_n zx.meta = @s zx.se_cry

# ①' 这一发是不是**超限版**(幽匿残响敲过超限石 -> custom_data 里 `ol:"sculk_echo"`)
#   ★ 玩家物品 NBT 只能读不能写, 这里只"读"。
#   ★ 为什么必须在**离弦这一刻**拍下来: 命中结算要等"箭落地那一刻"才跑, 路径每刻伤
#     更是整段飞行期都在算, 那时手里拿的未必还是这把弩 ⇒ 判定得随快照一路带过去
#     (与「蚀骨」同款: 见 bone_erode/shot ①')。
#   ★ 只判 mainhand: 弩是武器, `shot_crossbow` 本来就是"手持那把"触发。
scoreboard players set #se_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["sculk_echo"],ol:"sculk_echo"}] run scoreboard players set #se_ol zx.meta 1

# ② 扣魔力(固定 100)
data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

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
#    hit_dmg = 上一步算出的伤害; path_dmg = 悲鸣 ×0.1(固定); ol = 这一发走不走超限数值
data modify storage zx:work se set value {uuid:"",hit_dmg:0.0,path_dmg:0.0,cry:0,ol:0b,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work se.uuid set from storage zx:data self.uuid
data modify storage zx:work se.hit_dmg set from storage manacore:out r.damage
execute store result score #se_path zx.meta run scoreboard players get #se_n zx.meta
execute store result storage zx:work se.path_dmg double 0.1 run scoreboard players get #se_path zx.meta
execute store result storage zx:work se.cry int 1 run scoreboard players get #se_n zx.meta
execute store result storage zx:work se.ol byte 1 run scoreboard players get #se_ol zx.meta
execute store result storage zx:work se.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work se.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work se.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work se.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/sculk_echo/store with storage zx:work se
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/sculk_echo/snapshot with storage zx:work se

# ⑥ 悲鸣 +10(上限 50) —— 放在算完之后, 这一发用的是旧值
#    ★ 超限版: +20(上限 100)(见头注)。上限用 #se_max 变量, 别写死两处。
scoreboard players set #se_max zx.meta 50
execute if score #se_ol zx.meta matches 1 run scoreboard players set #se_max zx.meta 100
scoreboard players add @s zx.se_cry 10
execute if score #se_ol zx.meta matches 1 run scoreboard players add @s zx.se_cry 10
execute if score @s zx.se_cry > #se_max zx.meta run scoreboard players operation @s zx.se_cry = #se_max zx.meta

# ⑦ 表现
execute at @s run particle minecraft:sculk_soul ~ ~1.3 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:block.sculk_sensor.clicking player @a ~ ~ ~ 0.7 1.0

# ⑧ 「启示录」记页: 幽匿残响固定扣 100, 同上。
function sweetdream:equipment/staff/apocalypse/spend
