# ============================================================
# sweetdream:equipment/axe/sunken_weight/cast —— 沉砣（铁斧 · 主动技能）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 180 · 冷却 30 秒
#   "消耗全部「砣」，对前方 4 格内的全部生物造成（10 × 层数）点固定伤害，
#    并使其获得缓慢Ⅱ，持续（层数）秒。"
# 【四要素】
#   ① 触发：右键。
#   ② 范围：前方 4 格 ⇒ 4 个采样点（1~4 格），判定半径 1.5。
#   ③ 次数：立即 1 次。
#   ④ 时长：缓慢Ⅱ 的秒数 = 层数（1~5 秒）。
# 【0 层也能放】设计没禁止。0 层时伤害 0、不给缓慢，等于白花 180 蓝 + 30 秒冷却 ——
#   这是玩家自己的决策（"攒满再放"正是本件的玩法）。
# 【固定伤害】绕开 calc；层数在**施放时**先读进 #sw_n，再清零（顺序反了就是 0）。
# ============================================================
advancement revoke @s only sweetdream:equipment/axe/sunken_weight

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sunken_weight"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sunken_weight"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查：冷却 + 魔力 180
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sunken_weight",mana:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"沉砣冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 180）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 180
data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 180）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sunken_weight",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 读层数（**先读，后清零**）
scoreboard players add @s zx.sw_n 0
scoreboard players set #sw_n zx.meta 0
scoreboard players operation #sw_n zx.meta = @s zx.sw_n
scoreboard players set #sw_dmg zx.meta 0
scoreboard players operation #sw_dmg zx.meta = #sw_n zx.meta
scoreboard players operation #sw_dmg zx.meta *= #10 zx.meta

data modify storage zx:work sw.u0 set from entity @s UUID[0]
data modify storage zx:work sw.u1 set from entity @s UUID[1]
data modify storage zx:work sw.u2 set from entity @s UUID[2]
data modify storage zx:work sw.u3 set from entity @s UUID[3]

# ⑥ 收集前方 4 格内的生物
tag @e[tag=zx.sw_hit] remove zx.sw_hit
execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/axe/sunken_weight/probe
execute rotated ~ 0 positioned ^ ^ ^2.0 run function sweetdream:equipment/axe/sunken_weight/probe
execute rotated ~ 0 positioned ^ ^ ^3.0 run function sweetdream:equipment/axe/sunken_weight/probe
execute rotated ~ 0 positioned ^ ^ ^4.0 run function sweetdream:equipment/axe/sunken_weight/probe

# ⑦ 结算固定伤害
execute if score #sw_dmg zx.meta matches 1.. as @e[tag=zx.sw_hit,distance=..12] at @s run function sweetdream:equipment/axe/sunken_weight/dmg

# ⑧ 缓慢Ⅱ（秒数 = 层数）
execute if score #sw_n zx.meta matches 1 run effect give @e[tag=zx.sw_hit,distance=..12] minecraft:slowness 1 1 true
execute if score #sw_n zx.meta matches 2 run effect give @e[tag=zx.sw_hit,distance=..12] minecraft:slowness 2 1 true
execute if score #sw_n zx.meta matches 3 run effect give @e[tag=zx.sw_hit,distance=..12] minecraft:slowness 3 1 true
execute if score #sw_n zx.meta matches 4 run effect give @e[tag=zx.sw_hit,distance=..12] minecraft:slowness 4 1 true
execute if score #sw_n zx.meta matches 5 run effect give @e[tag=zx.sw_hit,distance=..12] minecraft:slowness 5 1 true

tag @e[tag=zx.sw_hit] remove zx.sw_hit

# ⑨ 清零层数 + 摘掉移速惩罚
scoreboard players reset @s zx.sw_n
function sweetdream:equipment/axe/sunken_weight/speed_sync

execute at @s run playsound minecraft:block.anvil.land player @a ~ ~ ~ 1.0 0.6
execute rotated ~ 0 positioned ^ ^ ^2.0 run particle minecraft:block{block_state:"minecraft:iron_block"} ~ ~0.1 ~ 1.2 0.1 1.2 0.02 24 normal
