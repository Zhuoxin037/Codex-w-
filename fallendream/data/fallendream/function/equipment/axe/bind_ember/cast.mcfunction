# ============================================================
# fallendream:equipment/axe/bind_ember/cast —— 缚烬（铁斧 · 主动技能）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 260 · 冷却 50 秒
#   "向前方劈出一道 4 格长、120 度的扇形斧痕，对范围内全部生物造成相当于自身基础攻击力
#    ×6 的伤害，并使其附加「流火」、获得缓慢Ⅱ，持续 3 秒。每当有生物新获得「流火」时，
#    自身所有技能的冷却时间减少 1 秒。"
# 【四要素】
#   ① 触发：右键。
#   ② 范围：120° 扇形 = 朝向两侧各 -60°..+60°，每 30° 一条射线共 5 条；
#      每条取 1.5 / 3.0 / 4.5 三个采样点，判定半径 1.2（覆盖"4 格长"）。
#   ③ 次数：立即 1 次。
#   ④ 时长：流火走 tag/mark（15 秒满值）；缓慢Ⅱ 3 秒。
# 【"新获得流火"怎么判】施加前先看它**原本有没有** zx.status.liuhuo ——
#   有就不算"新获得"，也就没有减冷却。判据在施加之前，而不是之后（否则人人都是新获得）。
# 【减冷却口径】只减本武器技能（fallendream:bind_ember 的 50 秒）—— 包内没有可遍历的
#   全局冷却表（见 upgrade/api/cd_tick 头注释）。5 个目标 = -5 秒。
# ============================================================
advancement revoke @s only fallendream:equipment/axe/bind_ember

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bind_ember"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bind_ember"]}] run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 超限判定（主手 / 副手）
scoreboard players set #be_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bind_ember"],ol:"bind_ember"}] run scoreboard players set #be_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bind_ember"],ol:"bind_ember"}] run scoreboard players set #be_ol zx.meta 1

# ② 只读检查：冷却 + 魔力 260
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:bind_ember",mana:260.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"缚烬冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 260）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 260
data modify storage manacore:in arg set value {uuid:"",value:260.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 260）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 50 秒（超限 45 秒）
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:bind_ember",cooldown_seconds:50.0,reduce:1b}
execute if score #be_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 45.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 预结算 ×6 伤害 + 拍施法者 UUID（超限 ×8）
data modify storage manacore:in arg set value {uuid:"",attack_mul:6.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if score #be_ol zx.meta matches 1 run data modify storage manacore:in arg.attack_mul set value 8.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:work be set value {dmg:0.0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work be.dmg set from storage manacore:out r.damage
data modify storage zx:work be.s2_b_dmg set value {n:0,d:1}
data modify storage zx:work be.s2_b_dmg set from storage manacore:out r.s2_b_damage
data modify storage zx:work be.u0 set from entity @s UUID[0]
data modify storage zx:work be.u1 set from entity @s UUID[1]
data modify storage zx:work be.u2 set from entity @s UUID[2]
data modify storage zx:work be.u3 set from entity @s UUID[3]

# ⑥ 收集 120° / 4 格扇形内的生物
tag @e[tag=zx.be_hit] remove zx.be_hit
execute rotated ~-60 0 positioned ^ ^ ^1.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~-60 0 positioned ^ ^ ^3.0 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~-60 0 positioned ^ ^ ^4.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~-30 0 positioned ^ ^ ^1.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~-30 0 positioned ^ ^ ^3.0 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~-30 0 positioned ^ ^ ^4.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~ 0 positioned ^ ^ ^1.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~ 0 positioned ^ ^ ^3.0 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~ 0 positioned ^ ^ ^4.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~30 0 positioned ^ ^ ^1.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~30 0 positioned ^ ^ ^3.0 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~30 0 positioned ^ ^ ^4.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~60 0 positioned ^ ^ ^1.5 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~60 0 positioned ^ ^ ^3.0 run function fallendream:equipment/axe/bind_ember/probe
execute rotated ~60 0 positioned ^ ^ ^4.5 run function fallendream:equipment/axe/bind_ember/probe

# 超限：扇形从 4 格延到 6 格 —— 只补最外那一圈采样点，原版 15 行一个字不动
execute if score #be_ol zx.meta matches 1 rotated ~-60 0 positioned ^ ^ ^6.0 run function fallendream:equipment/axe/bind_ember/probe
execute if score #be_ol zx.meta matches 1 rotated ~-30 0 positioned ^ ^ ^6.0 run function fallendream:equipment/axe/bind_ember/probe
execute if score #be_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^6.0 run function fallendream:equipment/axe/bind_ember/probe
execute if score #be_ol zx.meta matches 1 rotated ~30 0 positioned ^ ^ ^6.0 run function fallendream:equipment/axe/bind_ember/probe
execute if score #be_ol zx.meta matches 1 rotated ~60 0 positioned ^ ^ ^6.0 run function fallendream:equipment/axe/bind_ember/probe

# ⑦ 逐个结算（先判"原本有没有流火"，再施加）
scoreboard players set #be_new zx.meta 0
scoreboard players set #be_newye zx.meta 0
execute as @e[tag=zx.be_hit,distance=..16] at @s run function fallendream:equipment/axe/bind_ember/one
tag @e[tag=zx.be_hit] remove zx.be_hit

# ⑧ 每有一个新获得流火的目标，缚烬冷却 -1 秒
execute if score #be_new zx.meta matches 1.. run function fallendream:equipment/axe/bind_ember/cd

# ⑨ 表现
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 1.0 0.8
execute at @s run playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.7 1.1
execute rotated ~-60 0 positioned ^ ^ ^2.5 run particle minecraft:flame ~ ~0.4 ~ 0.6 0.3 0.6 0.02 8 normal
execute rotated ~ 0 positioned ^ ^ ^2.5 run particle minecraft:flame ~ ~0.4 ~ 0.6 0.3 0.6 0.02 8 normal
execute rotated ~60 0 positioned ^ ^ ^2.5 run particle minecraft:flame ~ ~0.4 ~ 0.6 0.3 0.6 0.02 8 normal
