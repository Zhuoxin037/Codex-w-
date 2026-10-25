# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_hit —— 决堤超限：单个水流点的每秒结算
# ------------------------------------------------------------
# 【执行者】水流点 marker（由 wet_all 用 execute as 送进来）
# 【宏参数】zx:work bbw（dmg = 每秒伤害整数值；u0..u3 = 施法者 UUID）
# 【伤害口径】文案"每秒受到相当于消耗魔力值 ×0.08 的伤害" ⇒ 每点都是独立的一笔，
#   走 sweetdream:skill 类型（吃正常乘区，不是固定伤害）。
# 【缓慢Ⅰ是"常态"】每秒续 1 秒 —— 离开水面自然到期，不需要额外的撤销动作。
# ============================================================
data modify storage zx:work a set value {channel_atk:0.0,target:"@e[type=!#sweetdream:no_damage,distance=..1.5]",type:"sweetdream:skill"}
$data modify storage zx:work a.num set value $(dmg)
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
$data modify storage zx:work a.u0 set value $(u0)
$data modify storage zx:work a.u1 set value $(u1)
$data modify storage zx:work a.u2 set value $(u2)
$data modify storage zx:work a.u3 set value $(u3)
function sweetdream:internal/damage/with_from with storage zx:work a

effect give @e[type=!#sweetdream:no_damage,distance=..1.5] minecraft:slowness 1 0 true
execute at @s run particle minecraft:dust{color:[0.2,0.65,0.9],scale:1.0} ~ ~0.2 ~ 1.3 0.15 1.3 0.01 10 normal
