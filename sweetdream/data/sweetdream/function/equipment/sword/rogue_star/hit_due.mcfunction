# ============================================================
# sweetdream:equipment/sword/rogue_star/hit_due —— 3 秒到点结算(宏 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者   【数据源】zx:data rs."<uuid>"(见 lock)
# 【★ 只依赖 $(uuid) ★】记录路径固定就是 rs."<uuid>", 不额外传别的参数
#   (流光曾在这里多传一个目标标签参数 -> 调用方没给 -> 宏调用整条失败 -> 打不出伤害)。
# 【判定】记录里的 due <= 框架时钟 #now 才结算; 目标没了就只清记录。
# ============================================================

# 记录都不在了(重复扫/已被清) -> 摘掉"等结算"标签收工
$execute unless data storage zx:data rs."$(uuid)" run tag @s remove zx.rs_casting
$execute unless data storage zx:data rs."$(uuid)" run return 0

# 到点了吗?
$execute store result score #rs_at zx.meta run data get storage zx:data rs."$(uuid)".due
execute if score #now manacore.meta < #rs_at zx.meta run return 0

# 把这一批的伤害值(以及"超限与否")抄进临时节点, 交给 aoe 宏
data modify storage zx:work rsh set value {damage:0.0,ol:0b}
$data modify storage zx:work rsh.damage set from storage zx:data rs."$(uuid)".damage
$data modify storage zx:work rsh.ol set from storage zx:data rs."$(uuid)".ol

# 对**每个被锁目标**各结算一次: 以目标为圆心, 2 格内的全部生物吃这一下
$execute at @e[tag=zx.rs_$(uuid),distance=0..] run function sweetdream:equipment/sword/rogue_star/aoe with storage zx:work rsh

# 清理: 摘目标标签 + 删记录 + 摘"等结算"标签
$tag @e[tag=zx.rs_$(uuid)] remove zx.rs_$(uuid)
$data remove storage zx:data rs."$(uuid)"
tag @s remove zx.rs_casting
