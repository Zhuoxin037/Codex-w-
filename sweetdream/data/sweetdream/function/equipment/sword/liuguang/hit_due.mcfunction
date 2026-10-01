# ============================================================
# sweetdream:equipment/sword/liuguang/hit_due —— 到点就结算(宏 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者   【数据源】zx:data lg."<uuid>"(施法者自己的记录, 见 lock_macro)
# 【★ 只依赖 $(uuid) ★】标签名固定就是 "zx.lg_<uuid>", 所以不额外传 target_tag ——
#   上一版在这里用了 $(target_tag), 而调用方传进来的节点里根本没有这个参数,
#   宏调用直接失败 -> 流光打不出伤害(这次的 bug)。
# 【判定】记录里的 due <= 框架时钟 #now 才结算; 目标还在才继续。
# ============================================================

$execute unless data storage zx:data lg."$(uuid)" run tag @s remove zx.lg_casting
$execute unless data storage zx:data lg."$(uuid)" run return 0
$execute store result score #lg_at zx.meta run data get storage zx:data lg."$(uuid)".due
execute if score #now manacore.meta < #lg_at zx.meta run return 0

data modify storage zx:work a set value {uuid:"",target_tag:"",damage:0.0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work a.uuid set value "$(uuid)"
$data modify storage zx:work a.target_tag set value "zx.lg_$(uuid)"
$data modify storage zx:work a.damage set from storage zx:data lg."$(uuid)".damage
$data modify storage zx:work a.u0 set from storage zx:data lg."$(uuid)".u0
$data modify storage zx:work a.u1 set from storage zx:data lg."$(uuid)".u1
$data modify storage zx:work a.u2 set from storage zx:data lg."$(uuid)".u2
$data modify storage zx:work a.u3 set from storage zx:data lg."$(uuid)".u3

# 目标没了(死了/被别的清了)就只把记录清掉
$execute unless entity @e[tag=zx.lg_$(uuid),limit=1] run data remove storage zx:data lg."$(uuid)"
$execute unless entity @e[tag=zx.lg_$(uuid),limit=1] run tag @s remove zx.lg_casting
$execute unless entity @e[tag=zx.lg_$(uuid),limit=1] run return 0

$execute as @e[tag=zx.lg_$(uuid),limit=1] run function sweetdream:equipment/sword/liuguang/hit_calc with storage zx:work a
$data remove storage zx:data lg."$(uuid)"