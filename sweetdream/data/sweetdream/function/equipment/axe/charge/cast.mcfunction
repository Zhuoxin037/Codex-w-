# ============================================================
# sweetdream:equipment/axe/charge/cast —— 主动技能(右键)
# ------------------------------------------------------------
# 【文案】消耗 300 魔力 / 冷却 100 秒。使用后召唤一个术阵; 之后自身获得迅捷 II;
#   每秒对自身 8 格内随机 1 个生物释放闪电; 当自身攻击到生物后立即对其实放一次
#   闪电, 并对其 1 格内的全部生物造成"自身当前魔力值 ×0.05"的伤害,
#   之后使该武器技能冷却时间 -3 秒。该状态持续 10 秒。
#
# 【状态怎么记】zx.chg_on = 还剩几秒(每秒由 second 扣)。
#   它同时就是"技能在不在生效期"的开关 —— 命中触发那个函数第一件事就看它。
# 【术阵】用框架的接口建一个, id 固定 sweetdream:charge(再放会刷新, 不会越堆越多)。
#   术阵数量满了会建失败 —— 那不影响技能本身, 所以这里不看返回值。
# ============================================================

# ⓪ 撤销自己的进度(不撤销的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/axe/charge

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 300
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",mana:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"超•负•荷 冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 300)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 300
data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 300)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 100 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 召唤一个术阵(满上限会失败, 不影响技能)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:charge",type:"charge",duration_seconds:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 进入超载状态 10 秒
scoreboard players set @s zx.chg_on 10

# ⑦ 立刻给迅捷 II(之后每秒由 tick 续上; II 级 = amplifier 1)
effect give @s minecraft:speed 3 1 true

# ⑧ 表现
#   【只给音效和粒子, 不播报聊天文字】原来这里有一句技能介绍 tellraw,
#   已经按你的要求删掉了(和风行回响那次一样: 开技能时少一行字, 画面更干净)。
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.8 0.8 0.8 0.05 30 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.9 1.1
