# ============================================================
# fallendream:equipment/armor/air_step/land —— 「踏空」落地冲击（进度入口）
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/air_step_land
#   （trigger = minecraft:fall_from_height，distance.y ≥ 2.0 ⇒ 普通跳跃只掉 1.25 格，不触发）
# 【执行者】落地的玩家
# 【文案(lore 逐字 · 基础)】自身魔力值上限 +50。从空中落地时，对 4 格内全部生物造成一次
#   相当于自身基础攻击力的伤害并使其击飞 1 格，之后自身恢复 10 点魔力值。每 10 秒最多一次。
# 【文案(lore 逐字 · 超限)】自身魔力值上限+140。自身从空中落地时生成一个半径 4 格，
#   持续 5 秒的领域。在领域内的生物每秒都会受到一次相当于释放者基础攻击力的伤害并被
#   击飞 1 格并获得 2 秒缓慢Ⅰ。每有一个生物受到影响则自身恢复 10 魔力值。
#   该效果 10 秒最多触发一次。
# 【★ 为什么用进度而不是 OnGround ★】`@a[nbt={OnGround:1b}]` = 每刻给每个玩家做一次
#   完整 NBT 序列化（≈10 ms/次，卡顿坑 1）。fall_from_height 是事件型进度，落地那刻
#   抛一次，零开销。
# 【★ 击飞写法 ★】生物 NBT 可写（玩家不行）⇒ `data modify entity @s Motion`。
#   0.36 的纵向速度 ≈ 1 格高（包内锚·冲击同款）。
# 【★ 超限改成"领域" ★】一次性结算换成一个 5 秒的 marker（`zx.as_field`）：
#   落地当场先结一次算，之后每秒由 lib/second 再结一次，共 5 次；
#   领域里每有一只生物受影响，施放者回 10 魔力（每跳都算）。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/air_step_land

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["air_step"]}] run return 0
execute if score @s zx.as_cd > #now manacore.meta run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 档位快照
scoreboard players set #as_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["air_step"],ol:"air_step"}] run scoreboard players set #as_ol zx.meta 1

# 10 秒冷却（两档同）
scoreboard players operation @s zx.as_cd = #now manacore.meta
scoreboard players add @s zx.as_cd 200

# ---- 超限：生成领域，落地当场先结一跳，之后每秒一跳（lib/second），共 5 跳 ----
execute if score #as_ol zx.meta matches 1 at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.as_field"]}
execute if score #as_ol zx.meta matches 1 run scoreboard players set @e[tag=zx.as_field,distance=..2,limit=1] zx.as_life 5
execute if score #as_ol zx.meta matches 1 run data modify entity @e[tag=zx.as_field,distance=..2,limit=1] data.zx.u set from entity @s UUID
execute if score #as_ol zx.meta matches 1 as @e[tag=zx.as_field,distance=..2,limit=1] at @s run function fallendream:equipment/armor/air_step/field_tick

# ---- 基础：一次性结算（伤害 = 基础攻击力 ×1 + 击飞 + 回 10 魔力）----
execute if score #as_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0}
execute if score #as_ol zx.meta matches 0 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #as_ol zx.meta matches 0 run function manacore:api/damage/calc
execute if score #as_ol zx.meta matches 0 run data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=0.1..4]",damage:0.0}
execute if score #as_ol zx.meta matches 0 run data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute if score #as_ol zx.meta matches 0 run execute at @s run function fallendream:internal/attack/api_extra
execute if score #as_ol zx.meta matches 0 as @e[type=!#fallendream:no_damage,distance=0.1..4] run data modify entity @s Motion set value [0.0d,0.36d,0.0d]
execute if score #as_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",value:10.0}
execute if score #as_ol zx.meta matches 0 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #as_ol zx.meta matches 0 run function manacore:api/mana/add

# 表现（两档都给；超限的领域每跳另有一圈）
particle minecraft:cloud ~ ~0.1 ~ 1.6 0.1 1.6 0.02 20 normal
particle minecraft:explosion_emitter ~ ~0.2 ~ 0 0 0 0 1 normal
playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.5 1.2
