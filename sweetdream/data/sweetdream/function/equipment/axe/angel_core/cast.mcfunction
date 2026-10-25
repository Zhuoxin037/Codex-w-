# ============================================================
# sweetdream:equipment/axe/angel_core/cast —— 天使核心: 圣痕审判
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/angel_core 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 500 魔力 / 冷却 50 秒。
#   ① 对自身 8 格内附加了「圣痕」的生物造成"自身基础攻击力 ×8"的伤害, 重复 2 次。
#   ② 之后对自身 6 格内附加了「圣痕」的生物 2 格内的全部生物造成
#      "自身最大魔力值 ×0.08"的伤害, 重复 2 次。
#   ③ 之后清除触发了第二段效果的「圣痕」(= 6 格内那些做过中心的)。
# 【为什么先确认有目标】8 格内一只带圣痕的都没有就整个不放(不扣蓝、不进冷却)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/angel_core

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:angel_core",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"天使核心冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 500)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 8 格内至少一只带「圣痕」的, 没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8,tag=zx.status.shenghen] run tellraw @s [{"text":"附近没有附带「圣痕」的生物","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8,tag=zx.status.shenghen] run return fail

# ④ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 500)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 50 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:angel_core",cooldown_seconds:50.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 第一段(基础攻击力 ×8)
function sweetdream:equipment/axe/angel_core/dmg1
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.8 0.6 0.8 0.06 24 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.4

# ⑦ 第二段延后 0.5 秒(10 tick)才放 —— 让技能有"一小点间隔", 不是一瞬打完两段。
#   【为什么不用 schedule】同名 schedule 是全局一个槽, 两个人同时放会互相顶掉
#   (deepsea_echo 的老注释讲过)。用"玩家身上的倒计时 + core/tick 推"最稳, 也不会互相顶。
scoreboard players set @s zx.ac_d 10
tag @s add zx.ac_delay
