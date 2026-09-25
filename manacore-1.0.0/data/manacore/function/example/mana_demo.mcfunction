# ============================================================
# example/mana_demo —— 示例: 魔力、恢复修正、禁疗
# ------------------------------------------------------------
# 【怎么用】以玩家身份执行: /function manacore:example/mana_demo
# 【演示内容】
#   ① 读取当前/最大魔力
#   ② 设置最大魔力 200, 直接补满
#   ③ 加一条"装备"恢复修正 +0.5
#   ④ 加一条"临时"恢复修正 +3, 持续 10 秒
#   ⑤ 查看恢复参数(基础/修正合计/倍率)
#   ⑥ 禁疗 5 秒后再解除
# 【观察方法】先 /function manacore:debug/on, HUD 里的魔力会随时间变化
# ============================================================

# 反查自己的 UUID(公开接口, 结果在 manacore:out.uuid)
function manacore:api/player/self_uuid

# ① 读当前魔力
data modify storage manacore:in arg set value {}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/get
tellraw @s [{"text":"魔力: ","color":"gray"},{"nbt":"r.value","storage":"manacore:out"},{"text":" / "},{"nbt":"r.max","storage":"manacore:out"}]

# ② 上限改 200 并补满
data modify storage manacore:in arg set value {value:200.0}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/max/set
data modify storage manacore:in arg set value {value:200.0}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/set

# ③ 装备加成 +0.5/秒
data modify storage manacore:in arg set value {id:"example:ring",type:"equipment",value:0.5}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/regen/modifier/add

# ④ 临时加成 +3/秒, 持续 10 秒
data modify storage manacore:in arg set value {id:"example:potion",type:"temporary",value:3.0,duration_seconds:10}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/regen/modifier/add

# ⑤ 查看恢复参数(实际每秒恢复 = (value + bonus) x multiplier)
data modify storage manacore:in arg set value {}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/regen/get
tellraw @s [{"text":"恢复参数: ","color":"gray"},{"nbt":"r.value","storage":"manacore:out"},{"text":" + "},{"nbt":"r.bonus","storage":"manacore:out"},{"text":" x "},{"nbt":"r.multiplier","storage":"manacore:out"}]

# ⑥ 禁疗 5 秒
data modify storage manacore:in arg set value {seconds:5.0}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/mana/regen/ban
tellraw @s {"text":"接下来 5 秒不会自动恢复魔力","color":"yellow"}
