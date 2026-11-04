# ============================================================
# sweetdream:equipment/armor/air_step/land —— 「踏空」落地冲击（进度入口）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/air_step_land
#   （trigger = minecraft:fall_from_height，distance.y ≥ 2.0 ⇒ 普通跳跃只掉 1.25 格，不触发）
# 【执行者】落地的玩家
# 【文案】魔力 +50（armor_mana 登记）。从空中落地时，对 4 格内全部生物造成一次相当于
#   自身基础攻击力的伤害并使其击飞 1 格，之后自身恢复 10 点魔力值。每 10 秒最多一次。
# 【★ 为什么用进度而不是 OnGround ★】`@a[nbt={OnGround:1b}]` = 每刻给每个玩家做一次
#   完整 NBT 序列化（≈10 ms/次，卡顿坑 1）。fall_from_height 是事件型进度，落地那刻
#   抛一次，零开销。
# 【★ 击飞写法 ★】生物 NBT 可写（玩家不行）⇒ `data modify entity @s Motion`。
#   0.36 的纵向速度 ≈ 1 格高（包内锚·冲击同款）。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/air_step_land

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["air_step"]}] run return 0
execute if score @s zx.as_cd > #now manacore.meta run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 10 秒冷却
scoreboard players operation @s zx.as_cd = #now manacore.meta
scoreboard players add @s zx.as_cd 200

# 伤害：基础攻击力 ×1
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=0.1..4]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# 击飞 1 格
execute as @e[type=!#sweetdream:no_damage,distance=0.1..4] run data modify entity @s Motion set value [0.0d,0.36d,0.0d]

# 回 10 魔力
data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 表现
particle minecraft:cloud ~ ~0.1 ~ 1.6 0.1 1.6 0.02 20 normal
particle minecraft:explosion_emitter ~ ~0.2 ~ 0 0 0 0 1 normal
playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.5 1.2
