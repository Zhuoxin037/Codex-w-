# ============================================================
# example/formation_demo —— 示例: 术阵的创建 / 查询 / 删除
# ------------------------------------------------------------
# 【怎么用】以玩家身份执行: /function manacore:example/formation_demo
# 【演示内容】
#   ① 查询当前术阵数量与上限
#   ② 创建一个持续 15 秒的术阵(带自定义载荷 data)
#   ③ 查询它的详情
#   ④ 刷新持续时间
#   ⑤ 删除它
# 【注意】创建/删除都会触发 formation 事件; 因为前置包不做表现,
#   所以这里看不到任何特效 —— 表现请写在你自己的事件函数里。
# ============================================================

# 反查自己的 UUID(公开接口, 结果在 manacore:out.uuid)
function manacore:api/player/self_uuid

# ① 当前数量 / 上限
data modify storage manacore:in arg set value {}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/formation/count
tellraw @s [{"text":"当前术阵: ","color":"gray"},{"nbt":"r.count","storage":"manacore:out"},{"text":" / "},{"nbt":"r.limit","storage":"manacore:out"}]

# ② 创建一个
data modify storage manacore:in arg set value {id:"example:fire_array",type:"fire",duration_seconds:15,data:{radius:4.0,damage:5.0}}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/formation/create
execute if data storage manacore:out r{success:1b} run tellraw @s {"text":"术阵创建成功","color":"green"}
execute if data storage manacore:out r{success:0b} run tellraw @s {"text":"术阵数量已达上限","color":"red"}

# ③ 查询详情
data modify storage manacore:in arg set value {id:"example:fire_array"}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/formation/get
tellraw @s [{"text":"术阵数据: ","color":"gray"},{"nbt":"r.formation","storage":"manacore:out"}]

# ④ 刷新到 30 秒
data modify storage manacore:in arg set value {id:"example:fire_array",duration_seconds:30}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/formation/refresh

# ⑤ 删除
data modify storage manacore:in arg set value {id:"example:fire_array"}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/formation/remove
