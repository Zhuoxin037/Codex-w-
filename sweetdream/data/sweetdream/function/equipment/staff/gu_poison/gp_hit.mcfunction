# ============================================================
# sweetdream:equipment/staff/gu_poison/gp_hit —— 一枚"蛊毒每秒伤害"的结算
# ------------------------------------------------------------
# 【谁调用它】gp_tick 第 ② 步; 【执行者】目标生物(打的就是它自己)
# 【伤害口径】释放者最大生命 ×0.1 -> health_ratio 通道(基数 = 面板最大生命)。
#   执行者是生物, 用身上存的释放者 uuid 查面板, 归属用 u0..u3。
# ============================================================

# ① 算伤害: 释放者最大生命 ×0.1
data modify storage manacore:in arg set value {uuid:"",health_ratio:0.1}
data modify storage manacore:in arg.uuid set from entity @s data.zx.gp.uuid
function manacore:api/damage/calc

# ② 打自己(归属 = 释放者)
data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.u0 set from entity @s data.zx.gp.u0
data modify storage zx:work a.u1 set from entity @s data.zx.gp.u1
data modify storage zx:work a.u2 set from entity @s data.zx.gp.u2
data modify storage zx:work a.u3 set from entity @s data.zx.gp.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a
