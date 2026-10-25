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
# 【★ 超限·超•负•荷 的差别(逐字照抄 oldef."charge".lore)★】
#   "使用后召唤一个术阵。之后自身获得常态的迅捷 3 效果。每秒都会对自身 8 格内的
#    随机 **2** 个生物释放闪电，当自身攻击到生物后则立即对其释放**三次**闪电并对其
#    1 格内的全部生物造成相当于自身当前魔力值 ×**0.08** 的伤害，之后使该武器技能
#    冷却时间 -3 秒。该状态持续 **15** 秒。该状态结束后若该技能完成冷却，则自动使用
#    且该技能停止正常冷却缩减，之后自身攻击力增加相当于自身当前基础攻击力的数值，
#    最大魔力值增加相当于自身当前最大魔力值 ×0.5 的数值，且自身每次召唤闪电时都会
#    对落点处的生物造成相当于自身基础攻击力 ×3 的伤害。但每次攻击都会对自身造成
#    相当于自身最大生命值 ×0.05 的伤害。"
#   落实: ①常态迅捷Ⅱ(passive); ②每秒随机 1 -> 2(tick); ③命中一次雷 -> 三次(tick/hit);
#         ④×0.05 -> ×0.08(hit_area); ⑤10 秒 -> 15 秒(本文件 ⑤⑥);
#         ⑥"第二形态"(end_ol / mode_on / ol_bolt_bonus; mode_tick 已于 2026-10-10 删除);
#           ★ 冻结(原文"该技能停止正常冷却缩减")**只在进入第二形态之后**跑 ——
#             第一阶段(第一形态, chg_mode=0)的状态冷却照常自然 -1/秒。见 tick ③ / freeze_cd。
#         ⑦技能期间迅捷 II -> III(本文件 ⑦ / tick ① / autocast)。
#   ★ ⑦ 的写法注意: cast ⑦ 与 tick ① 的 effect give 是**基础版共用**的, 所以
#     不能直接改数字, 要"先给 II 再按超限补一行 III"(原版只认更强的那一个)。
#   ★ 超限**不改变**消耗(仍是 300 魔力 / 100 秒冷却)。
# 【术阵】用框架的接口建一个, id 固定 sweetdream:charge(再放会刷新, 不会越堆越多)。
#   术阵数量满了会建失败 —— 那不影响技能本身, 所以这里不看返回值。
# ============================================================

# ⓪ 撤销自己的进度(不撤销的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/axe/charge

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①' 超限快照: 手里这把是不是超限版(判一次存到玩家身上)
#   ★ 为什么要拍快照: 状态要活 15 秒, 期间玩家完全可能换武器;
#     后面 tick(随机 2 个) / hit(三次雷 + ×0.08) / end(第二形态) 都读它。
function sweetdream:equipment/axe/charge/is_ol
scoreboard players operation @s zx.chg_ol = #chg_ol zx.meta

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
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 300)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 100 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 召唤一个术阵(满上限会失败, 不影响技能)
#   超限: 状态 10 秒 -> 15 秒, 术阵时长跟着一起变成 15。
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:charge",type:"charge",duration_seconds:10.0}
execute if score @s zx.chg_ol matches 1 run data modify storage manacore:in arg.duration_seconds set value 15.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 进入超载状态(基础 10 秒 / 超限 15 秒)
scoreboard players set @s zx.chg_on 10
execute if score @s zx.chg_ol matches 1 run scoreboard players set @s zx.chg_on 15

# ⑦ 立刻给迅捷(之后每秒由 tick 续上)
#   基础 II(amplifier 1) / 超限 III(amplifier 2) —— 两级一起给不打架:
#   原版只认"更强 or 更久"的那个, III 永远盖住 II。
effect give @s minecraft:speed 3 1 true
execute if score @s zx.chg_ol matches 1 run effect give @s minecraft:speed 3 2 true

# ⑧ 表现
#   【只给音效和粒子, 不播报聊天文字】原来这里有一句技能介绍 tellraw,
#   已经按你的要求删掉了(和风行回响那次一样: 开技能时少一行字, 画面更干净)。
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.8 0.8 0.8 0.05 30 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.9 1.1
