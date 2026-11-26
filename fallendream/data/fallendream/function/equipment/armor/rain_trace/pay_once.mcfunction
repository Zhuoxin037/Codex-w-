# ============================================================
# fallendream:equipment/armor/rain_trace/pay_once —— 基础档: 一次 基础攻击力 ×2 的伤害
# ------------------------------------------------------------
# 【执行者】水迹点实体   【目标】@e[tag=zx.rt_pay]（这一拍刚被判定"停够了"的那一批）
# 【谁调用它】pay ②（#rt_olp = 0 时）
# 【为什么拆出来】超限档走的是另一条路（ol_link → 每秒持续伤害），两条分支各自的
#   输入准备只在一个文件里，看代码时不用来回跳。
# ============================================================

data modify storage zx:work a set value {target:"@e[tag=zx.rt_pay,distance=..16]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from entity @s data.zx.dmg
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from entity @s data.zx.s2_b_dmg
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function fallendream:internal/attack/submit_extra
