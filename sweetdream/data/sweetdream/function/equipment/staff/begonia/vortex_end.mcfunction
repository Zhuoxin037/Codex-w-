# ============================================================
# sweetdream:equipment/staff/begonia/vortex_end —— 漩涡消失: 中心结算 + 清「渊海」
# ------------------------------------------------------------
# 【谁调用它】vortex_tick 第 ④ 步(寿命归 0); 【执行者/位置】漩涡 marker
# 【技能原文(lore 逐字)】漩涡消失后会对处于中心的生物造成相当于释放者最大魔力值
#   ×0.15 的伤害。之后清除「渊海」。
# 【"处于中心的生物"= 中心 2 格内的生物】
# 【伤害口径】释放者最大魔力 ×0.15 -> max_mana_mul 通道; 执行者是 marker, 用
#   marker 里存的释放者 uuid 查面板, 归属用 u0..u3(和 color_hit 同款)。
# 【清「渊海」走统一入口】让余烬/永恒的消耗被动收得到信号。
# ============================================================

# ① 圈"处于中心的生物"(中心 2 格内)
tag @e[tag=zx.bg_cen,distance=0..] remove zx.bg_cen
tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.bg_cen

# ② 算伤害: 释放者最大魔力 ×0.15
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.15}
data modify storage manacore:in arg.uuid set from entity @s data.zx.bg.uuid
function manacore:api/damage/calc

# ③ 打成伤害(归属 = 释放者)
data modify storage zx:work a set value {target:"@e[tag=zx.bg_cen]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.u0 set from entity @s data.zx.bg.u0
data modify storage zx:work a.u1 set from entity @s data.zx.bg.u1
data modify storage zx:work a.u2 set from entity @s data.zx.bg.u2
data modify storage zx:work a.u3 set from entity @s data.zx.bg.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 清除「渊海」(中心 2 格内带渊海的生物)
data modify storage zx:work a set value {target:"@e[tag=zx.bg_cen,tag=zx.status.yuanhai]",mark:"yuanhai"}
function sweetdream:lib/mark_consume

# ⑤ 表现 + 收尾
particle minecraft:nautilus ~ ~0.5 ~ 1.5 0.6 1.5 0.05 24 normal
particle minecraft:splash ~ ~0.5 ~ 1.5 0.5 1.5 0.02 30 normal
playsound minecraft:entity.elder_guardian.hurt player @a ~ ~ ~ 0.7 1.0
tag @e[tag=zx.bg_cen,distance=0..] remove zx.bg_cen
kill @s
