# ============================================================
# sweetdream:equipment/sword/everfrost/finish_one —— 超限·永霜: 给"刚解冻的那几只"
#                                                    结算最后一下(当前魔力 ×0.15)
# ------------------------------------------------------------
# 【原文】"…并在结束后对被冰冻的生物造成相当于自身当前魔力值 ×0.15 的伤害。"
# 【和 finish_ol 的分工】
#   · 本函数 = **逐批(可能只有一只)就地收尾**: 谁解冻了就先收谁(目标带 zx.ef_fin)。
#   · finish_ol = 打满 10 拍 / 到 10 秒硬上限时, 把**剩下全部**一次收尾。
#   分开写是因为"不同目标在不同时刻解冻" —— 一次性收尾做不到(2026-10-08 用户指出)。
# 【执行者】**玩家**(由 pulse_ol 直接调用, 没换 @s)  【入参】storage zx:work ef.uuid
#   ★ 必须以玩家身份打: api/damage 靠 @s 是不是玩家来带 UUID(击杀归属),
#     换成被打的那只去打就会丢归属(掉落/进度/影刃这类"击杀"判定全哑火)。
#   ★ 目标怎么认: 临时标签 zx.ef_fin(pulse_ol 打的, 本函数末尾统一摘)。
# ============================================================

# ① 伤害 = 当前魔力 ×0.15(走 other_mul: 基数默认就是当前魔力, 结算那一刻才取)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.15}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打给这批(距离锁当前维度: distance=0.. 不过滤、只当位置基准)
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.ef_fin,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ③ 表现: 冰壳碎裂
execute at @e[tag=zx.ef_fin,distance=0..] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.6 0.4 0.04 24 normal
execute at @e[tag=zx.ef_fin,distance=0..] run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.8 0.7

# ④ 收尾: 摘掉"本轮标记"(它们已经吃到最后一下了, 之后的每秒那下不再算它们)
#    再摘掉临时标签 —— 这两行不动施法者记录: 别的还冻着的目标要继续打。
$execute as @e[tag=zx.ef_fin,distance=0..] run tag @s remove zx.ef_$(uuid)
tag @e[tag=zx.ef_fin] remove zx.ef_fin
