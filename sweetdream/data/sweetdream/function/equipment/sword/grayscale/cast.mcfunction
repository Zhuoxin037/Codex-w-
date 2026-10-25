# ============================================================
# sweetdream:equipment/sword/grayscale/cast —— 灰度 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/grayscale(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 30 / 冷却 18 秒。
#   "使用后使自身 2 格内的生物受到一次相当于自身当前魔力值 ×0.08 的伤害，之后使其
#    燃烧 3 秒。若已经处于燃烧状态则改为使其附加「流火」。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 自身 2 格内的全部生物。
#   ③ 次数: 1 次伤害 + 1 次状态(逐只: 燃烧 / 或改「流火」)。
#   ④ 时长: 燃烧 3 秒(Fire=60 tick); 「流火」是标签(自带 TTL)。
# 【伤害口径】当前魔力 ×0.08 -> other_mul 通道(基数默认 = 玩家当前魔力)。
# 【数值改哪】倍率 0.08 = other_mul; 半径 2 = 下面的 distance=..2; 燃烧 3 秒 = apply 的 Fire:60s。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/grayscale

# ⓪.5 【超限分流】(2026-10-23 批 K1) 敲过超限石(ol:"grayscale")的灰度, 右键放的是
#      「超限·灰度」: 120 蓝 / 12 秒 / 5 格 / 最大魔力 ×0.1 / 已燃烧者多吃一发 ×0.08 真伤。
#   ★ 主副手都判, 而且判 ol 的**值**是不是 grayscale(照 liuguang/cast ⓪.5 那一课)。
scoreboard players set #gs_ol zx.meta 0
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["grayscale"],ol:"grayscale"}] run scoreboard players set #gs_ol zx.meta 1
execute if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["grayscale"],ol:"grayscale"}] run scoreboard players set #gs_ol zx.meta 1
execute if score #gs_ol zx.meta matches 1 run function sweetdream:equipment/sword/grayscale/overlimit
execute if score #gs_ol zx.meta matches 1 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 只读检查: 冷却 + 魔力 30
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grayscale",mana:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"灰度冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 30）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ② 自身 2 格内有目标吗? 没有就不放(不扣蓝、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=..2] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=..2] run return fail

# ③ 扣魔力 -30
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记冷却 18 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grayscale",cooldown_seconds:18.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 算伤害: 当前魔力 ×0.08(other 通道; 基数由框架取面板"当前魔力")
data modify storage manacore:in arg set value {uuid:"",other_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ⑥ 圈定"自身 2 格内", 一次性打出去
tag @e[tag=zx.gs_hit,distance=0..] remove zx.gs_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.gs_hit
data modify storage zx:in arg set value {target:"@e[tag=zx.gs_hit]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑦ 逐只: 没在烧 -> 燃烧 3 秒; 已在烧 -> 改附加「流火」
#   ★ 放在伤害**之后**: 被这一下打死的自然不在 zx.gs_hit 里了, 不会给尸体点火。
execute as @e[tag=zx.gs_hit] at @s run function sweetdream:equipment/sword/grayscale/apply
tag @e[tag=zx.gs_hit,distance=0..] remove zx.gs_hit

# ⑧ 表现: 一圈灰雾
execute at @s run particle minecraft:smoke ~ ~1 ~ 1.0 0.6 1.0 0.03 30 normal
execute at @s run particle minecraft:ash ~ ~1 ~ 1.0 0.6 1.0 0.02 20 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.7 0.7
