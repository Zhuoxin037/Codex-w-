# ============================================================
# sweetdream:equipment/axe/chenyuan/cast —— 沉渊: 深渊一击
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/chenyuan 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 100 魔力 / 冷却 10 秒。
#   使用后使自身 6 格内随机一个生物及另一附加了「渊海」效果的生物获得 3 秒缓慢Ⅳ,
#   之后对其造成"自身当前魔力值 ×0.08"的伤害。
#   若自身有"给自身最大魔力值相关技能的增益"(= 风声 / 忘川彼岸 / 无效 给的
#   zx.mm_add), 则额外锁定 3 个生物并释放该技能效果, 且本次伤害改为"最大魔力值 ×0.08"。
# 【★ 2026-10-07 起这份好处改在普通函数里判 ★】原来 wg_bonus 是按 uuid 存的键,
#   只能拼进 storage 路径 -> cast_go 必须写成宏; 现在加成是玩家身上的计分项
#   zx.mm_add, 判 @s 即可, cast_go 已经不是宏函数了, 这里也不再传 uuid。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/chenyuan

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 100
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:chenyuan",mana:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"沉渊冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 100)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放(不扣蓝、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run return fail

# ④ 扣魔力 100
data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 100)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 10 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:chenyuan",cooldown_seconds:10.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 圈目标
#   A = 6 格内随机一只  (sort=random 每次求值都会重挑, 所以先冻结成标签)
#   B = 6 格内另一只带「渊海」的(排除 A)
tag @e[tag=zx.cy_a] remove zx.cy_a
tag @e[tag=zx.cy_b] remove zx.cy_b
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6,sort=random,limit=1] add zx.cy_a
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6] add zx.cy_in6
execute as @e[tag=zx.cy_in6] if entity @s[tag=zx.status.yuanhai] unless entity @s[tag=zx.cy_a] run tag @s add zx.cy_pool
execute at @s as @e[tag=zx.cy_pool,sort=nearest,limit=1] run tag @s add zx.cy_b
tag @e[tag=zx.cy_in6] remove zx.cy_in6
tag @e[tag=zx.cy_pool] remove zx.cy_pool

# ⑦ 施加效果 + 伤害(交给落点函数, 里面判 zx.mm_add)
function sweetdream:equipment/axe/chenyuan/cast_go
