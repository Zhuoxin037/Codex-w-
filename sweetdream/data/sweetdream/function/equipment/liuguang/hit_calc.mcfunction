# ============================================================
# sweetdream:equipment/liuguang/hit_calc —— 真正打出这一击
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid,damage,u0,u1,u2,u3}; 执行者 = 被打的目标
# 【步骤】
#   ⓪ 先清标记 + 解锁施法者 + 清掉目标身上的临时数据
#   ① 伤害数字 -> 纯数字字符串(宏要拼进命令, 见 lib/num/plain)
#   ② 补上目标/伤害类型, 交给共用的 internal/damage/with_from
#      —— 它负责带上 by <攻击者>(用 u0..u3 拼), 并且选不到人时自动退化成无归属
#   ③ 命中表现: 粒子 + 音效
# 【⓪ 的清理为什么用 u0..u3 找施法者】这会儿 @s 是"被打的目标", 施法者已经
#   不在执行链上了; 但他的 UUID 四个整数就在宏参数里, 用它们反查 @a 就能
#   把他身上的 zx.lg_casting 标签摘掉。
# 【注意】particle 前要 execute at @s —— execute as 只换执行者、不换位置,
#   直接写 ~ ~1 ~ 会用错坐标系。
# ============================================================

# ⓪ 清标记 + 解锁
$tag @s remove zx.lg_$(uuid)
data remove entity @s data.zx
$tag @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] remove zx.lg_casting

data modify storage zx:work a.num set value 0.0
$data modify storage zx:work a.num set value $(damage)
function sweetdream:lib/num/plain

data modify storage zx:work a.target set value "@s"
data modify storage zx:work a.type set value "minecraft:player_attack"
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.4 0.4 0.4 0.15 30 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 1.2
