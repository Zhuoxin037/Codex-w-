# ============================================================
# sweetdream:equipment/axe/xiugou/cast —— 锈犬（铁斧 · 主动）主手右键
# ------------------------------------------------------------
# 【施放】主手/副手右键（consumable + consume_item 进度）
# 【魔力 90 / 冷却 32 秒】落过渡档预算内，是铁档唯一的召唤件
# 【机制】身前 2 格召唤「锈犬」：10 秒内每秒咬 3 格内最近的敌人，
#         每次伤害 = 自身基础攻击力，最多咬 10 次。同一使用者同时只能有一只。
# 【★ 基础攻击力口径（2026-10-21 改）】manacore 面板 stats.base_attack
#   —— **不含手持武器**。原来读 `attribute attack_damage get`，会把铁斧的 7 点算进去：
#   咬一口 10 点 ≈ 让犬替玩家打一次平A，不是文案写的"自身基础攻击力"。
#   面板 base_attack 才是 skill/calc 里 attack_mul 的同一个基数。铁蒺藜同步改。
# 【★ 一次性把伤害算好存进 marker】犬是独立实体，不能每咬一口再回头读玩家属性
#   （玩家可能死了/退出/换武器）。施放瞬间定值 = 这一发召唤的强度，
#   和雷楔把 dmg 存进 marker 是同一套做法。
# ============================================================
advancement revoke @s only sweetdream:equipment/axe/xiugou

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["xiugou"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["xiugou"]}] run return 0

# ⓪.5 【超限分流】敲过超限石(ol:"xiugou")的锈犬: 200 蓝 / 30 秒 / 三只犬 / 8 格 / ×2
#   判据判 ol 的**值**, 主副手都要判(与 liuguang 同一套标准写法)。
scoreboard players set #xg_ol zx.meta 0
execute if items entity @s weapon.mainhand iron_axe[minecraft:custom_data~{zx:["xiugou"],ol:"xiugou"}] run scoreboard players set #xg_ol zx.meta 1
execute if items entity @s weapon.offhand iron_axe[minecraft:custom_data~{zx:["xiugou"],ol:"xiugou"}] run scoreboard players set #xg_ol zx.meta 1

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:xiugou",mana:90.0}
execute if score #xg_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 200.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"锈犬冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #xg_ol zx.meta matches 0 run tellraw @s [{"text":"魔力不足（需要 90）","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #xg_ol zx.meta matches 1 run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:90.0}
execute if score #xg_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 200.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} if score #xg_ol zx.meta matches 0 run tellraw @s [{"text":"魔力不足（需要 90）","color":"red"}]
execute if data storage manacore:out r{success:0b} if score #xg_ol zx.meta matches 1 run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:xiugou",cooldown_seconds:32.0,reduce:1b}
execute if score #xg_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 30.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ---- 这一发的基础攻击力（不含手持武器）----
# 【口径】读 manacore 面板 stats.base_attack，与 api/damage/calc 的 attack_mul 基数同源。
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #xg_atk zx.meta run data get storage manacore:out r.value
execute if score #xg_atk zx.meta matches ..0 run scoreboard players set #xg_atk zx.meta 1
# 超限: 每口 = 基础攻击力 ×2(文案"系数 ×1 -> ×2")
execute if score #xg_ol zx.meta matches 1 run scoreboard players operation #xg_atk zx.meta *= #2 zx.meta

# ---- 同一使用者只能有一只：先收旧的 ----
scoreboard players set #xg_me zx.meta 0
execute store result score #xg_me zx.meta run data get entity @s UUID[0]
execute in minecraft:overworld as @e[type=marker,tag=zx.xg_dog,distance=0..] if score @s zx.xg_own = #xg_me zx.meta run kill @s
execute in minecraft:the_nether as @e[type=marker,tag=zx.xg_dog,distance=0..] if score @s zx.xg_own = #xg_me zx.meta run kill @s
execute in minecraft:the_end as @e[type=marker,tag=zx.xg_dog,distance=0..] if score @s zx.xg_own = #xg_me zx.meta run kill @s

# ---- 召唤 ----
data modify storage zx:work xg set value {dmg:0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work xg.dmg int 1 run scoreboard players get #xg_atk zx.meta
data modify storage zx:work xg.u0 set from entity @s UUID[0]
data modify storage zx:work xg.u1 set from entity @s UUID[1]
data modify storage zx:work xg.u2 set from entity @s UUID[2]
data modify storage zx:work xg.u3 set from entity @s UUID[3]
execute at @s rotated ~ 0 positioned ^ ^ ^2 run function sweetdream:equipment/axe/xiugou/spawn with storage zx:work xg
# 超限: 身前 2 格**三只**(左右各偏 30 度, 仍是身前 2 格 = 半径 2 的弧)
execute if score #xg_ol zx.meta matches 1 run execute at @s rotated ~ 30 positioned ^ ^ ^2 run function sweetdream:equipment/axe/xiugou/spawn with storage zx:work xg
execute if score #xg_ol zx.meta matches 1 run execute at @s rotated ~ -30 positioned ^ ^ ^2 run function sweetdream:equipment/axe/xiugou/spawn with storage zx:work xg

playsound minecraft:entity.wolf.ambient player @a ~ ~ ~ 0.9 0.8
playsound minecraft:entity.wolf.growl player @a ~ ~ ~ 0.6 1.2
