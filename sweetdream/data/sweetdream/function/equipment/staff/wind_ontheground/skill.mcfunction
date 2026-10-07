# ============================================================
# sweetdream:equipment/staff/wind_ontheground/skill —— 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 550 魔力 / 冷却 120 秒。召唤 X 个术阵(X = 当前剩余可召唤数);
#   每召唤一个就对"自身 12 格内随机一个生物"周围 5 格的全部生物造成 3 次
#   最大魔力 ×0.07 的伤害, 每命中一个生物积攒 1 点「风声」;
#   随后若「风声」超过 60, 每超出 1 点让"下一次以最大魔力结算的技能"伤害 +1%;
#   之后每 1 点「风声」使最大魔力 +10, 并对自身 5 格内生物造成 5 次
#   最大魔力 ×0.04 的伤害, 持续 20 秒; 结束后清空「风声」。
#
# 【"3 次"怎么拆: 每秒一轮, 共 3 轮 —— 千万不要合并】
#   这三下是"每个术阵各 3 次", 拆成 3 轮、每秒一轮(由 second 驱动,
#   计分项 zx.wg_burst 记还剩几轮), 每一轮对"所有术阵中心"各打一圈。
#   ⚠️ 绝不能合并成一击 —— 「风声」是按"命中几个生物"一点一点叠的,
#      合并之后层数只剩三分之一, 直接算错。
#   1 秒的间隔 > 生物的受伤无敌帧(0.5 秒), 三下都能落地。
#   (aura 的"5 次"仍是每 4 秒一次, 间隔更宽, 那个不用动。)
#
# 【谁先谁后】先打完 3 轮, 才结算 bonus(风声奖励) 和 aura(20 秒回响)。
#   因为风声是"边打边叠"的, 施法那一瞬间它还是 0 —— 提前算永远够不到 60。
#
# 【加成是普通乘区】风声奖励乘进**最大魔力值技能倍率**(max_mana_mul), 不是独立乘区。
#   2026-10-07 起它直接折进这条通道的**通用加成**(lib/mm_add/hook_calc, 20 秒),
#   所有"以最大魔力结算"的技能在生效期内都自动吃得到, 不再需要各自调一行。
#
# 【「风声」是这个武器专属的】不放进"渊海/流火/夜火/白昼梦/噬心"那五个通用标签里,
#   就记在玩家自己的计分项 zx.wg_sound 上, 别的武器不会碰它。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 ★ 拍下超限乘区 ★ 技能后半段(3 轮爆发 + 20 秒回响)全是延迟结算的,
#      到那时玩家多半已经换手 —— 所以乘区必须在**施法这一刻**定下来。
function sweetdream:overlimit/api/snap

# ② 只读检查: 冷却 + 魔力 550
#    ★ 先过超限: 敲过超限的技能要 660 蓝、冷却 144 秒(见 overlimit/api/mod)
#    ★ 顺序不能反 ★ "填基准值 -> 抄进 olv.mana -> 再让 mod 覆盖":
#      没敲超限时 mod 会在开头就 return, 那一步根本不会写 olv.mana ——
#      这里必须先把基准值抄好, 否则 check 失败时提示会读成 0(或上一轮的陈旧值)。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wind_ontheground",mana:550.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #wg_need zx.meta 0
execute store result score #wg_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"风行于大地之上 冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#wg_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 550(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:550.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#wg_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记冷却 120 秒(超限后 144 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wind_ontheground",cooldown_seconds:120.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ④.5 播放释放动画(风行枝冠炸开, 26 tick = 1.3 秒)
#   为什么卡在这里而不是函数末尾: 到这一步魔力已扣、冷却已记, "这一次施法成立"
#   就已经确定了。而下面第 ⑤ 段里有一处 `run return 0`(术阵已满的分支),
#   会提前结束整个函数 —— 动画点火要是写在末尾, 那条分支下就永远不播,
#   可技能明明是放出来了的。放在这里两种情况都能播到。
#   执行者仍是施法者本人(skill 一路进来没换过执行者), cast_start 用的就是 @s。
function naturewind:cast_start

# ⑤ X = 术阵还能召唤几个 = 上限 - 已占用
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/check
scoreboard players set #X zx.meta 0
execute store result score #X zx.meta run data get storage manacore:out r.limit
execute store result score #cnt zx.meta run data get storage manacore:out r.count
scoreboard players operation #X zx.meta -= #cnt zx.meta
execute if score #X zx.meta matches ..0 run tellraw @s [{"text":"术阵已满 —— 这次只有技能本身生效","color":"red"}]
execute if score #X zx.meta matches ..0 run return 0

# ⑥ 把 X 个术阵建出来
#    术阵 id 用 sweetdream:wg_1 .. wg_8 按序号取 —— 同一个玩家再放会覆盖旧的,
#    等于"刷新", 不会越堆越多。
#    (框架的术阵上限默认 3、槽位最多 8 个, 所以展开到 8 段就够)
#    ⚠️ 先清掉上一轮残留的中心标记(c1..c8 全清): hit_pass 会把 c1..c8 全扫一遍,
#       如果这次只召唤了 2 个, 上一轮第 3 个中心的标签还挂在某个生物身上,
#       那一圈就会被多打一次。
tag @e[tag=zx.wg_c1] remove zx.wg_c1
tag @e[tag=zx.wg_c2] remove zx.wg_c2
tag @e[tag=zx.wg_c3] remove zx.wg_c3
tag @e[tag=zx.wg_c4] remove zx.wg_c4
tag @e[tag=zx.wg_c5] remove zx.wg_c5
tag @e[tag=zx.wg_c6] remove zx.wg_c6
tag @e[tag=zx.wg_c7] remove zx.wg_c7
tag @e[tag=zx.wg_c8] remove zx.wg_c8

data modify storage zx:work wg.uuid set from storage zx:data self.uuid
data modify storage zx:work wg.n set value 1
execute if score #X zx.meta matches 1.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 1.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 2
execute if score #X zx.meta matches 2.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 2.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 3
execute if score #X zx.meta matches 3.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 3.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 4
execute if score #X zx.meta matches 4.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 4.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 5
execute if score #X zx.meta matches 5.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 5.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 6
execute if score #X zx.meta matches 6.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 6.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 7
execute if score #X zx.meta matches 7.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 7.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg
data modify storage zx:work wg.n set value 8
execute if score #X zx.meta matches 8.. run function sweetdream:equipment/staff/wind_ontheground/summon with storage zx:work wg
execute if score #X zx.meta matches 8.. run function sweetdream:equipment/staff/wind_ontheground/pick with storage zx:work wg

# ⑦ 点火: 起"3 轮爆发"(每秒一轮, 由 second 驱动 burst_self)
#    这里只负责"开始", 伤害不在这里打 —— 3 轮打完才轮到 bonus / aura,
#    所以那两个调用都搬进了 burst_self 的最后一轮。
scoreboard players set @s zx.wg_sound 0
scoreboard players set @s zx.wg_burst 3
