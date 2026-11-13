# ============================================================
# sweetdream:equipment/sword/wound_stack/cast —— 积伤（剑·狂徒2）主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/wound_stack（右键 consume_item）
# 【文案（用户定稿，逐字）】
#   魔力 100   ·   冷却 20 秒
#   对前方 2 x 4 格内的全部生物造成一次相当于自身已损失生命值 ×2.5 的伤害。
# 【读法】"已损失生命值" = 真实最大生命值 − 当前生命值；
#   "前方 2 x 4 格" = 水平宽 2 格、沿视线深 4 格的矩形（竖直按包惯例覆盖整个人高）。
#   用世界轴方盒近似（同 backflow_tide/area），转身放时方盒不跟随朝向，属包内既有口径。
# 【链】revoke → 职业门控(狂徒2) → lib/uuid → skill/check → lib/mana/pay
#       → cooldown/start → 算伤害 → 框范围 → fire 一次投递给全部目标
# 【单位】1 点血 = 1000；#max_hp / Health×1000 / zx:work wsk.dmg 都按此换算
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/wound_stack

execute unless score @s zx.job matches 2 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 2 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 只读检查：冷却 + 魔力 100
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wound_stack",mana:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"积伤冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 100）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

# 扣魔力 100
data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# 起冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wound_stack",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 已损失生命值 = 真实最大生命值 − 当前生命值（×1000 单位）
function sweetdream:lib/max_health_score
execute store result score #wsk_now zx.meta run data get entity @s Health 1000
scoreboard players operation #wsk_lost zx.meta = #max_hp zx.meta
scoreboard players operation #wsk_lost zx.meta -= #wsk_now zx.meta

# ×2.5：mul_permille(#mp_src × #mp_mul / 1000)，#mp_mul = 2500
scoreboard players operation #mp_src zx.meta = #wsk_lost zx.meta
scoreboard players set #mp_mul zx.meta 2500
function sweetdream:lib/math/mul_permille

# 把算好的整点伤害冻结进专用节点（范围伤害入参不边遍历边算）
execute store result storage zx:work wsk.dmg double 0.001 run scoreboard players get #mp_out zx.meta

# 框"前方 2 x 4 格"：宽 2 / 深 4 / 高 2.6 的世界轴方盒，钉成 zx.wsk_t
tag @e[tag=zx.wsk_t,distance=0..] remove zx.wsk_t
execute at @s anchored eyes rotated ~ 0 positioned ^ ^ ^2.0 positioned ~-1.0 ~-1.3 ~-2.0 run tag @e[type=!#sweetdream:no_damage,dx=2.0,dy=2.6,dz=4.0] add zx.wsk_t

# 伤害 > 0 时一次投给范围内全部生物
execute if score #mp_out zx.meta matches 1.. run function sweetdream:equipment/sword/wound_stack/fire

# 清本轮标记
tag @e[tag=zx.wsk_t,distance=0..] remove zx.wsk_t
