# ============================================================
# sweetdream:equipment/armor/gyre/target_deal —— 对本次命中的目标 24 点固定伤害
# ------------------------------------------------------------
# 【谁调用它】arc ④（执行者 = 玩家）
# 【目标】zx.gyr_t（hit ⑤ 钉死的那只）
# 【★ 固定伤害 ★】文案「额外造成一次 24 点固定伤害」⇒ 直接投递，不过乘区。
# 【★ 目标已经死了也没关系 ★】选择器选空时 with_from 整条空转，不会报错。
# ============================================================

execute unless entity @e[tag=zx.gyr_t,distance=..32] run return 0

data modify storage zx:work a set value {target:"@e[tag=zx.gyr_t,distance=..32]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 24.0
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @e[tag=zx.gyr_t,limit=1,distance=..32] run particle minecraft:crit ~ ~1 ~ 0.3 0.3 0.3 0 10 normal
