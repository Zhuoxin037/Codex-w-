# ============================================================
# fallendream:equipment/sword/gather_energy/cast —— 聚能(剑/魔导士) 右键主动
# ------------------------------------------------------------
# 【谁调用】进度 fallendream:equipment/sword/gather_energy(consume_item)
# 【执行者】施法玩家
# 【文案逐字(原版)】消耗魔力：50 / 冷却时间：35 秒 / 使用后自身获得一个法球。
#   之后自身每有一个法球则恢复自身 5 %魔力值。
# 【文案逐字(超限)】魔力 160 · 冷却 35 秒 / 使用后自身获得两个不占用普通法球上限的
#   普通法球。若这两个法球超出了当前法球上限则法球在 10 秒后消失。
#   之后自身每有一个法球则恢复自身最大魔力值 5% 的魔力值。
#   若本次恢复至满魔力则也将自身血量恢复满。
# 【分档】#ge_ol = 0 原版 / 1 超限。两档各写一条字面量(魔力 50 / 160)，
#   不把数值塞进变量再传 —— 选择器与倍率不能是变量，这是本包铁律。
# 【回蓝口径】"每有一个法球"= 施放后当前法球总数(zx.j_orb + zx.j_prop + 超额球)，
#   一次性结算, 走 manacore:api/mana/add(不超上限)。
# ============================================================

advancement revoke @s only fallendream:equipment/sword/gather_energy
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["gather_energy"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["gather_energy"]}] run return fail

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 判是不是超限版(就地判物品组件, 与盔甲/法杖同源口径)
scoreboard players set #ge_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["gather_energy"],ol:"gather_energy"}] run scoreboard players set #ge_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["gather_energy"],ol:"gather_energy"}] run scoreboard players set #ge_ol zx.meta 1

# ② 只读检查(魔力 50 / 160)
execute if score #ge_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:gather_energy",mana:50.0}
execute if score #ge_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:gather_energy",mana:160.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力(50 / 160)
execute if score #ge_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",value:50.0}
execute if score #ge_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:160.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 起冷却 35 秒(两档相同)
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:gather_energy",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 给球：原版 1 个带上限；超限 2 个"不占上限"的聚能法球
execute if score #ge_ol zx.meta matches 0 run function fallendream:profession/mage/add_orb
execute if score #ge_ol zx.meta matches 1 run function fallendream:equipment/sword/gather_energy/orb_x

# ⑥ 按施放后当前法球总数 × 5% 最大魔力值回蓝
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ge_mm zx.meta 0
execute store result score #ge_mm zx.meta run data get storage manacore:out r.value 100
function fallendream:profession/mage/tally
scoreboard players set #ge_n zx.meta 0
scoreboard players operation #ge_n zx.meta = #jorbs zx.meta
scoreboard players operation #ge_n zx.meta += @s zx.ge_x
scoreboard players operation #ge_mm zx.meta *= #ge_n zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.0005 run scoreboard players get #ge_mm zx.meta
function manacore:api/mana/add

# ⑦ 超限：本次回到满魔力 ⇒ 血量也回满
execute if score #ge_ol zx.meta matches 0 run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #ge_cur zx.meta 0
execute store result score #ge_cur zx.meta run data get storage manacore:out r.value 100
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ge_cap zx.meta 0
execute store result score #ge_cap zx.meta run data get storage manacore:out r.value 100
execute if score #ge_cur zx.meta >= #ge_cap zx.meta run effect give @s minecraft:instant_health 1 30 true
