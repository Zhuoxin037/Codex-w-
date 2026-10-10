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
# 【最大魔力口径 -> 吃「最大魔力值技能倍率」通用加成】两边都以 max_mana_mul 结算,
#   于是自动经 lib/mm_add/hook_calc 吃到(风声 / 忘川彼岸 / 无效), 不必自己调一行。
# 【★ 副手也能放(2026-10-03 修) ★】以前整套横扫写死主手: 把镰刀放副手右键时,
#   300 魔力和冷却已经扣掉, 但等待那里只认 weapon.mainhand, 等 4 tick 之后
#   超时取消 —— 表现就是"扣了魔力、什么也没发生"。
#   现在在 cast 里把"这次用的哪只手"记进施法快照(record.hand = weapon.mainhand
#   / weapon.offhand), 等待、武器判定、挥击帧、还原**全部按它走**。
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
scoreboard players add @s zx.sd_ol 0

# ①.6 ★ 超限快照 ★ 真正的结算在 4 tick 后的挥击帧(见 sweep/start), 那时手里的
#      镰刀已经被通用回手挪走了 —— 所以拍成玩家计分项 zx.sd_ol, 强化段读它。
#      【超限·引梦镰 加在这把上的机制(逐字照抄 oldef."sickle_dreams".lore)】
#        强化那一下从"最大魔力 ×0.2" 提到 "最大魔力 ×0.25";
#        其余(基础 ×0.05 / 附噬心 / 3*5 范围 / 时停 2 秒 / 摘噬心 / 8 秒锁)与基础版一致。
function sweetdream:equipment/sword/sickle_dreams/is_ol
scoreboard players set @s zx.sd_ol 0
execute if score #sd_ol zx.meta matches 1 run scoreboard players set @s zx.sd_ol 1

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
#   【★ 超限版不吃这个 8 秒锁(2026-10-08 修)】
#     基础版 lore 明写"触发强化攻击后则在 8 秒内不可再次触发强化攻击";
#     超限版那整段 lore 里**没有这句话** ⇒ 超限版不该被锁卡住
#     (玩家报: 范围内明明有噬心却死活不强化)。
#     而且超限版的节奏本来就有自限制: 强化会把「噬心」消耗掉, 下一次必须先
#     重新附加才能再强化 —— 不需要额外再上锁。
execute if score @s zx.sd_ol matches 1 as @e[tag=zx.sd_hit] if entity @s[tag=zx.status.shixin] run scoreboard players set #sd_enh zx.meta 1
execute if score @s zx.sd_ol matches 0 unless score @s zx.sd_lock matches 1.. as @e[tag=zx.sd_hit] if entity @s[tag=zx.status.shixin] run scoreboard players set #sd_enh zx.meta 1

# ⑥.5 记下"这一下是从哪只手放的"
#   【为什么必须在这里判】右键使用时, 消耗流程还没收尾 —— 物品仍在手上。
#     过了这一 tick 镰刀就被通用回手挪走了, 再也分不出主手还是副手。
#   【判法】原版规则是"主手物品能用就先用主手", 所以只有"**主手不是镰刀**、
#     副手是"才算副手触发。两只手都拿镰刀时走主手, 和原版行为一致。
#   【为什么用临时标签】只有 sweep/start 消费它, 读完就清, 不会留在身上。
#     (不能读 effect_1 的 zx.ret_off —— 那两个是同一个 consume_item 的两条
#      奖励, 先后顺序不保证, 这里读到的时候它可能还没写。)
tag @s remove zx.sd_off
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] run tag @s add zx.sd_off

# ⑦ 保存本次分支和目标，回手后横扫，在主挥击帧结算。
function sweetdream:equipment/sword/sickle_dreams/sweep/start
