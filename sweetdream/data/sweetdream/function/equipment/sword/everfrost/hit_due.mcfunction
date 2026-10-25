# ============================================================
# sweetdream:equipment/sword/everfrost/hit_due —— 到点结算(宏 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者   【数据源】zx:data ef."<uuid>"(见 lock)
# 【谁调用它】core/tick -> hit_self(**每 tick**, 只对带 zx.ef_casting 的玩家)
# 【两条时间线】
#   · 基础版: 施法后 60 tick(3 秒)一次性结算 —— 当前剩余魔力 ×0.1, 打给被冻过的那批。
#   · 超限版: 施法后立刻开始(见 pulse_ol), 本函数只负责每 tick 把它叫进去, 然后 return。
# 【★ 伤害基数 = "自身当前剩余魔力值" ★】-> 走 other_mul 通道(基数默认当前魔力),
#   且必须在**这一刻**才算(施法后 3 秒里魔力会变, 用结算当时的当前值)。
# 【只打被冻住的那批】target = 标签 zx.ef_<uuid>(就是锁定的那 8 只)。
# ============================================================

# 记录不在了 -> 摘标签收工
$execute unless data storage zx:data ef."$(uuid)" run tag @s remove zx.ef_casting
$execute unless data storage zx:data ef."$(uuid)" run return 0

# ★★ 超限版走另一条时间线(2026-10-08 按用户口径重写) ★★
#   它**不等 3 秒** —— 施法后第 1 秒就开始"每秒 ×0.03", 并且每 tick 都要进来
#   查"有没有目标已经解冻了"(解冻的就地收尾 ×0.15)。节拍/拍数/收尾全在 pulse_ol 里。
#   ★ return 必须用计分项当判据, 不能用 `if data ...{ol:1b}` ★
#     pulse_ol 可能已经把记录删了(那批收完了), 那样 `if data` 就不成立,
#     接着会漏进下面基础版那段 —— 于是超限版收完尾又被基础版再结算一遍 ×0.1。
scoreboard players set #ef_ol zx.meta 0
$execute if data storage zx:data ef."$(uuid)"{ol:1b} run scoreboard players set #ef_ol zx.meta 1
execute if score #ef_ol zx.meta matches 1 run function sweetdream:equipment/sword/everfrost/pulse_ol with storage zx:work ef
execute if score #ef_ol zx.meta matches 1 run return 0

# 到点了吗(基础版: 施法后 3 秒)
$execute store result score #ef_at zx.meta run data get storage zx:data ef."$(uuid)".due
execute if score #now manacore.meta < #ef_at zx.meta run return 0

# 算伤害: 当前剩余魔力 ×0.1(other_mul 通道, 基数默认当前魔力)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# 对被冻住的那批打
$data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.ef_$(uuid),distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# 表现: 冰壳碎裂
$execute at @e[tag=zx.ef_$(uuid)] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.6 0.4 0.04 24 normal
$execute at @e[tag=zx.ef_$(uuid)] run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.8 0.7

# 清理
$tag @e[tag=zx.ef_$(uuid)] remove zx.ef_$(uuid)
$data remove storage zx:data ef."$(uuid)"
tag @s remove zx.ef_casting
