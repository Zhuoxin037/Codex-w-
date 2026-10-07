# ============================================================
# sweetdream:equipment/sword/everfrost/hit_due —— 3 秒到点结算(宏 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者   【数据源】zx:data ef."<uuid>"(见 lock)
# 【★ 伤害基数 = "自身当前剩余魔力值" ★】-> 走 other_mul 通道(基数默认当前魔力),
#   且必须在**这一刻**才算(施法后 3 秒里魔力会变, 用结算当时的当前值)。
# 【只打被冻住的那批】target = 标签 zx.ef_<uuid>(就是锁定的那 8 只)。
# ============================================================

# 记录不在了 -> 摘标签收工
$execute unless data storage zx:data ef."$(uuid)" run tag @s remove zx.ef_casting
$execute unless data storage zx:data ef."$(uuid)" run return 0

# 到点了吗?
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
$execute at @e[tag=zx.ef_$(uuid)] run playsound minecraft:block.glass.break player @a ~ ~ ~ 0.8 0.7

# 清理
$tag @e[tag=zx.ef_$(uuid)] remove zx.ef_$(uuid)
$data remove storage zx:data ef."$(uuid)"
tag @s remove zx.ef_casting
