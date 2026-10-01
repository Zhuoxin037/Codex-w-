# ============================================================
# sweetdream:equipment/sword/sickle_dreams/cast —— 主动技能(右键)
# ------------------------------------------------------------
# 【文案】消耗 300 魔力 / 冷却 5 秒。
#   横扫命中时对自身前方 2*3 范围内的生物造成"自身最大魔力值 ×0.05"的伤害并附加「噬心」。
#   ✦ 强化: 若对有「噬心」的生物造成伤害, 则本次伤害强化为对前方 3*5 范围内的生物
#     造成"最大魔力值 ×0.2"的伤害并时停 2 秒, 之后移除「噬心」。
#     触发强化攻击后 8 秒内不可再次触发强化攻击。
#
# 【流程】先按**基础范围**圈一次怪 -> 看圈里有没有带「噬心」的(而且没在 8 秒锁里)
#   -> 有就走强化(换成大范围、大伤害、时停、摘噬心), 没有就走基础(伤害 + 附噬心)。
#   注意: 不是"先打一下再强化", 文案的"本次伤害强化为"是**替换**, 所以只打一次。
# 【最大魔力口径 -> 吃「下一次技能加成」】两边都调 lib/max_mana_bonus。
# ============================================================

# ⓪ 撤销自己的进度(不撤销就只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/sword/sickle_dreams
execute if entity @s[tag=zx.sd_sweep] run return 0

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 把"强化锁"的计分项先建出来
#   ★ 没分数的目标在 `if score ... matches` 里判不出来 —— 不建这一下,
#     强化判定会永远失败(这次就是这么栽的)。
scoreboard players add @s zx.sd_lock 0

# ② 只读检查: 冷却 + 魔力 300
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sickle_dreams",mana:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"引梦镰 冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 300)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 300
data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 300)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 5 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sickle_dreams",cooldown_seconds:5.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 先按基础范围(前方 2*3)圈一次怪
tag @e[tag=zx.sd_hit] remove zx.sd_hit
function sweetdream:equipment/sword/sickle_dreams/area_base

# ⑥ 判定强化: 圈里要有一只带「噬心」的, 而且自己不在 8 秒锁里
# 【★ 另一个坑 ★】别用选择器里的 nbt= 谓词(@e[nbt={data:{...}}])去挑"带噬心的怪" ——
#   实测不稳。换成"逐个问"的写法: as @e[...] if entity @s[tag=zx.status.shixin]
#   (观测镜的判定就是这么写的, 那个是验证过的)
scoreboard players set #sd_enh zx.meta 0
execute unless score @s zx.sd_lock matches 1.. as @e[tag=zx.sd_hit] if entity @s[tag=zx.status.shixin] run scoreboard players set #sd_enh zx.meta 1

# ⑦ 保存本次分支和目标，回手后横扫，在主挥击帧结算。
function sweetdream:equipment/sword/sickle_dreams/sweep/start
