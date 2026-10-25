# ============================================================
# sweetdream:equipment/armor/zhuzu/field_tick —— 领域每秒结算（执行者 = marker）
# ------------------------------------------------------------
# 【谁调】lib/second 每秒一次（三维度各一行）
# 【机制】半径 3 内敌人：5 点固定伤害 + 缓慢Ⅰ 1 秒（每刻刷新 ⇒ 离开就恢复）
# 【为什么是固定伤害】驻足是铁档领域，数值不参与乘区、不随武器涨；
#   它照样吃护甲减伤（用户 10-20 定稿：5 点/秒不改）。
# ============================================================
data modify storage zx:work a set value {fixed:1b,target:"@e[type=!#sweetdream:no_damage,distance=..3]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 5.0
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

effect give @e[type=!#sweetdream:no_damage,distance=..3] minecraft:slowness 1 0 true

particle minecraft:dust{color:[0.62,0.72,0.55],scale:0.8} ~ ~0.1 ~ 2.4 0.08 2.4 0.005 16 normal
particle minecraft:end_rod ~ ~0.1 ~ 1.6 0.05 1.6 0.01 6 normal

scoreboard players remove @s zx.zz_ft 1
execute if score @s zx.zz_ft matches ..0 run function sweetdream:equipment/armor/zhuzu/field_end
