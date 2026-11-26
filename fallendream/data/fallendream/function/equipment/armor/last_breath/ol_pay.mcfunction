# ============================================================
# fallendream:equipment/armor/last_breath/ol_pay —— 超限·归息：兑现 30% 生命 + 3% 魔力 + 分支奖励
# ------------------------------------------------------------
# 【执行者】动手的那个玩家（穿超限归息、刚刚消耗掉目标身上的一个状态）
# 【调用点】hit/victim_body ⑦（已经过完"满血不触发 / 8 秒节流 / 消耗成功"三道门）
# 【入参】#lb_mk zx.meta = 刚被消耗掉的那一种（1 = 渊海 / 2 = 噬心，由 ⑤ 定下来）
# 【文案(逐字)】"…消耗其一种效果，并为自身恢复 30% 生命值及 3% 魔力值（优先消耗
#   「渊海」）…消耗的若是「渊海」，则额外使自身移速提高 20%，持续 8 秒。消耗的若是
#   「噬心」，则使自身下一次其他技能伤害 +10%。"
# 【★ 百分比一律走 lib/math/mul_permille ★】它内部做了分段长乘, 不会越过 int32。
# 【★ 移速那条必须放在最后 ★】`attribute … modifier remove` 对**不存在**的 id 会
#   失败并**截断整个函数**, 所以它带账本门控、并且放在所有兑现动作之后 —— 万一失败,
#   前面已经发出去的回血/回蓝不受影响。
# ============================================================

# ---- ① 恢复 30% 生命值 ----
#   ★ 用 lib/max_health_score 而不是裸 attribute get: 它会把 lib/heal 的临时压低
#     上限撤掉, 免得"同刻两笔治疗"时按被压低的上限算(见 lib/heal 头 2026-10-19 那段)。
function fallendream:lib/max_health_score
execute if score #max_hp zx.meta matches 1.. run scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
execute if score #max_hp zx.meta matches 1.. run scoreboard players set #mp_mul zx.meta 300
execute if score #max_hp zx.meta matches 1.. run function fallendream:lib/math/mul_permille
execute if score #max_hp zx.meta matches 1.. run scoreboard players set #lb_1000 zx.meta 1000
execute if score #max_hp zx.meta matches 1.. run scoreboard players operation #mp_out zx.meta /= #lb_1000 zx.meta
execute if score #max_hp zx.meta matches 1.. run scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
execute if score #max_hp zx.meta matches 1.. run function fallendream:lib/heal

# ---- ② 恢复 3% 最大魔力值 ----
#   ★ ×1000 定点读面板, ×3 前夹 INT32 上界(R05) —— 面板上限可以很可观。
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #lb_mm zx.meta 0
execute store result score #lb_mm zx.meta run data get storage manacore:out r.value 1000

#   ★ 读不到就不做这一步, 但**不能 return** ★ ③④ 两条分支还在后面, 不该被它连累。
scoreboard players set #lb_3 zx.meta 3
scoreboard players set #lb_100 zx.meta 100
scoreboard players set #lb_cap zx.meta 2147483647
execute if score #lb_mm zx.meta matches 1.. run scoreboard players operation #lb_cap zx.meta /= #lb_3 zx.meta
execute if score #lb_mm zx.meta matches 1.. if score #lb_mm zx.meta > #lb_cap zx.meta run scoreboard players operation #lb_mm zx.meta = #lb_cap zx.meta
execute if score #lb_mm zx.meta matches 1.. run scoreboard players operation #lb_mm zx.meta *= #lb_3 zx.meta
execute if score #lb_mm zx.meta matches 1.. run scoreboard players operation #lb_mm zx.meta /= #lb_100 zx.meta

execute if score #lb_mm zx.meta matches 1.. run data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute if score #lb_mm zx.meta matches 1.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #lb_mm zx.meta matches 1.. store result storage manacore:in arg.value double 0.001 run scoreboard players get #lb_mm zx.meta
execute if score #lb_mm zx.meta matches 1.. run function manacore:api/mana/add

# ---- ③ 噬心分支: 下一次其他技能伤害 +10% ----
#   「其他技能伤害」= 只认 oth 通道(当前魔力 / 生命值等倍率), 与「剖面」同口径:
#   挂上去之后**一直保留**到真的打出一次走 oth 通道的技能 —— 见 last_breath/hook_oth。
execute if score #lb_mk zx.meta matches 2 run scoreboard players set @s zx.lb_om 10

# ---- ④ 渊海分支: 移速 +20%, 8 秒 ----
#   账本 zx.lb_spd_end 同时当"modifier 挂没挂"的标记(1.. = 挂着, 0 = 没挂),
#   到期由 batch21/player_tick 每刻扫掉。
execute if score #lb_mk zx.meta matches 1 if score @s zx.lb_spd_end matches 1.. run attribute @s minecraft:movement_speed modifier remove fallendream:lb_spd
execute if score #lb_mk zx.meta matches 1 run attribute @s minecraft:movement_speed modifier add fallendream:lb_spd 0.2 add_multiplied_total
execute if score #lb_mk zx.meta matches 1 run scoreboard players operation @s zx.lb_spd_end = #now manacore.meta
execute if score #lb_mk zx.meta matches 1 run scoreboard players add @s zx.lb_spd_end 160
