# ============================================================
# sweetdream:equipment/liuguang/hit_due —— 到点就结算(宏参数: {uuid, ok})
# ------------------------------------------------------------
# 【执行者】等结算的那个玩家
# 【三步】
#   ① 自己那个标记还在不在? 不在(目标死了/跑出加载区) -> 解锁收工
#   ② 到点了没? 拿目标身上的 lg_at 和框架时钟 #now 比
#   ③ 把目标身上的伤害/归属搬进宏节点, 再"以目标身份"交给 hit_calc
# 【为什么数据要搬一遍】hit_calc 要以被打的目标当执行者(@s), 而 /damage 的
#   目标只能是单个实体; 搬进宏节点之后, hit_calc 里的 $(damage)/$(u0..3)
#   在"调用那一刻"就固定好了, 不会再因为选择器重新求值而变。
# ============================================================

# ① 目标不在了 -> 解锁
$execute unless entity @e[tag=zx.lg_$(uuid),limit=1] run tag @s remove zx.lg_casting
$execute unless entity @e[tag=zx.lg_$(uuid),limit=1] run return 0

# ② 还没到自己那次到点时间 -> 跳过
$execute store result score #lg_at zx.meta run data get entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.lg_at
execute if score #now manacore.meta < #lg_at zx.meta run return 0

# ③ 搬数据
data modify storage zx:work a set value {uuid:"",damage:0.0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work a.uuid set value "$(uuid)"
$data modify storage zx:work a.damage set from entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.damage
$data modify storage zx:work a.u0 set from entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u0
$data modify storage zx:work a.u1 set from entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u1
$data modify storage zx:work a.u2 set from entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u2
$data modify storage zx:work a.u3 set from entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u3

$execute as @e[tag=zx.lg_$(uuid),limit=1] run function sweetdream:equipment/liuguang/hit_calc with storage zx:work a
