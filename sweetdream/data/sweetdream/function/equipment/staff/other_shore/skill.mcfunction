# ============================================================
# sweetdream:equipment/staff/other_shore/skill —— 彼岸 · 主动技能(潜行右键)
# ------------------------------------------------------------
# 【谁调用它】cast ①(潜行)   【执行者】施法者
# 【技能原文】
#   ✦ 主动技能   魔力 450 · 冷却 55 秒
#   "使用后选择自身 8 格内最多 3 个附有「渊海」或「噬心」的生物。若其只附有
#    「渊海」，则将其转化为「噬心」，并造成一次相当于自身最大魔力值 ×0.1 的伤害。
#    若其只附有「噬心」，则将其转化为「渊海」，并造成一次相当于自身最大魔力值
#    ×0.08 的真实伤害。若其同时附有两种效果，则消耗「渊海」和「噬心」，对其造成
#    一次相当于自身最大魔力值 ×0.2 的真实伤害，并对其 3 格内的其他生物造成一次
#    相当于自身最大魔力值 ×0.12 的伤害。每消耗一组「渊海」和「噬心」，则为自身
#    恢复最大生命值 5% 的生命。"
# 【★ 四要素 ★】
#   ① 触发: 潜行右键。
#   ② 范围: 自身 8 格内、**附有「渊海」或「噬心」**的生物, 按距离取最近 3 个。
#   ③ 次数: 一段(每个目标只吃一次)。
#   ④ 时长: 无(全链同一 tick 跑完)。
# 【★ 三种分支怎么分工 ★】classify 先给每只打快照标签, 然后
#     both_go        -> 双状态: 消耗两者 + ×0.2 真伤 + 3 格内其他 ×0.12
#     to_shixin_go   -> 只有渊海: 转成噬心 + ×0.1 伤害
#     to_yuanhai_go  -> 只有噬心: 转成渊海 + ×0.08 真实伤害
#   转化**不走** lib/mark_consume(转化是"换成另一种", 不是"消耗") ——
#   否则穿「永恒」会把旧状态补回来, 变成双状态(同热熔/余烬的老坑, 见 mark_consume 头)。
# 【★ 顺序: 先查目标再扣费 ★】一只可选的都没有 = 技能没放出去, 不扣魔力、不进冷却。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 450
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:other_shore",mana:450.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"彼岸冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 450）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 圈出"8 格内带「渊海」或「噬心」"的(两个选择器各打一次, 并集)
tag @e[tag=zx.os_any,distance=0..] remove zx.os_any
execute as @e[type=!#sweetdream:no_damage,distance=0.1..8] if entity @s[tag=zx.status.yuanhai] run tag @s add zx.os_any
execute as @e[type=!#sweetdream:no_damage,distance=0.1..8] if entity @s[tag=zx.status.shixin] run tag @s add zx.os_any

# ④ 按距离取最近 3 个
tag @e[tag=zx.os_sel,distance=0..] remove zx.os_sel
execute as @e[tag=zx.os_any,distance=0..,sort=nearest,limit=3] run tag @s add zx.os_sel

# ⑤ 一个都没有 -> 提示并收工(不扣魔力/不进冷却)
execute unless entity @e[tag=zx.os_sel,distance=0..] run tellraw @s [{"text":"8 格内没有附有「渊海」或「噬心」的生物","color":"red"}]
execute unless entity @e[tag=zx.os_sel,distance=0..] run return fail

# ⑥ 扣魔力 -450
data modify storage manacore:in arg set value {uuid:"",value:450.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑦ 记冷却 55 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:other_shore",cooldown_seconds:55.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑧ 拍快照(在改任何状态之前)
execute as @e[tag=zx.os_sel,distance=0..] run function sweetdream:equipment/staff/other_shore/classify

# ⑨ 先数"消耗了几组" —— ★ 必须排在三段结算**之前** ★
#   双状态者会在 both_go 里吃一发 ×0.2 真伤, 有可能当场被打死; 死了标签就没了,
#   等结算完再数会**少算回血**。所以先把组数拍下来。
scoreboard players set #os_pairs zx.meta 0
execute as @e[tag=zx.os_sel,tag=zx.os_both,distance=0..] run scoreboard players add #os_pairs zx.meta 1

# ⑩ 三种分支各走一遍
execute if entity @e[tag=zx.os_sel,tag=zx.os_both,distance=0..] run function sweetdream:equipment/staff/other_shore/both_go
execute if entity @e[tag=zx.os_sel,tag=zx.os_y,distance=0..] run function sweetdream:equipment/staff/other_shore/to_shixin_go
execute if entity @e[tag=zx.os_sel,tag=zx.os_s,distance=0..] run function sweetdream:equipment/staff/other_shore/to_yuanhai_go

# ⑪ 每消耗一组「渊海」+「噬心」回 5% 最大生命
execute if score #os_pairs zx.meta matches 1.. run function sweetdream:equipment/staff/other_shore/heal

# ⑫ 收尾: 清本轮临时标签
tag @e[tag=zx.os_any,distance=0..] remove zx.os_any
tag @e[tag=zx.os_sel,distance=0..] remove zx.os_sel
tag @e[tag=zx.os_both,distance=0..] remove zx.os_both
tag @e[tag=zx.os_y,distance=0..] remove zx.os_y
tag @e[tag=zx.os_s,distance=0..] remove zx.os_s
tag @e[tag=zx.os_none,distance=0..] remove zx.os_none
tag @e[tag=zx.os_splash,distance=0..] remove zx.os_splash

# ⑬ 表现: 彼岸的门开了一下
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:portal ~ ~1 ~ 1.6 0.9 1.6 0.15 30 normal
execute at @s run playsound minecraft:block.portal.trigger player @a ~ ~ ~ 0.7 1.3
execute at @s run playsound minecraft:entity.enderman.portal player @a ~ ~ ~ 0.6 0.9
