# ============================================================
# sweetdream:equipment/sword/liuguang/ol_hit_due —— 到点就结算(宏 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者   【数据源】zx:data lgo."<uuid>"(施法者自己的记录, 见 ol_lock)
# 【判定】记录里的 due <= 框架时钟 #now 才结算; 目标已经不在就只收尾。
# 【为什么逐只 as】四只各有各的"带不带流火/夜火", 翻倍要分别判 ——
#   所以把范围选择器拆成单个实体, 每只自己跑一遍 ol_hit_calc。
# ============================================================

$execute unless data storage zx:data lgo."$(uuid)" run tag @s remove zx.lgo_casting
$execute unless data storage zx:data lgo."$(uuid)" run return 0
scoreboard players set #lg_at zx.meta 0
$execute store result score #lg_at zx.meta run data get storage zx:data lgo."$(uuid)".due
execute if score #now manacore.meta < #lg_at zx.meta run return 0

# 目标全没了(死了/被清了)就只把记录收掉
$execute unless entity @e[tag=zx.lgo_$(uuid),limit=1] run data remove storage zx:data lgo."$(uuid)"
$execute unless entity @e[tag=zx.lgo_$(uuid),limit=1] run tag @s remove zx.lgo_casting
$execute unless entity @e[tag=zx.lgo_$(uuid),limit=1] run return 0

data modify storage zx:work a set value {uuid:"",damage:0.0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work a.uuid set value "$(uuid)"
$data modify storage zx:work a.damage set from storage zx:data lgo."$(uuid)".damage
$data modify storage zx:work a.u0 set from storage zx:data lgo."$(uuid)".u0
$data modify storage zx:work a.u1 set from storage zx:data lgo."$(uuid)".u1
$data modify storage zx:work a.u2 set from storage zx:data lgo."$(uuid)".u2
$data modify storage zx:work a.u3 set from storage zx:data lgo."$(uuid)".u3

$execute as @e[tag=zx.lgo_$(uuid)] run function sweetdream:equipment/sword/liuguang/ol_hit_calc with storage zx:work a

$data remove storage zx:data lgo."$(uuid)"
tag @s remove zx.lgo_casting
