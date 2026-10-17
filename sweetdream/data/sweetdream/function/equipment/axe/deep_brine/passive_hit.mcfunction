# ============================================================
# sweetdream:equipment/axe/deep_brine/passive_hit —— 对被钉住的那只打被动伤害
# ------------------------------------------------------------
# 【谁调用它】hit_go ④-3: execute at @e[tag=zx.db_pass] run function ...
# 【执行者】动手的玩家   【位置】目标生物所在处
# 【目标】zx.db_pass(本轮唯一一个通过节流闸的目标; 就近 1 格内取它)
# 【伤害值与归属】都读 hit_go ④-1/④-2 备好的 zx:work dba(不是宏函数, 无 `$` 行)。
# 【为什么不用 api/damage】目标不在施法者身边、而且这里要按"已算好的数值"投递,
#   所以走 internal/damage/with_from(与神裁领域/崩裂裂缝每秒那一段同一路子)。
# ============================================================

# ① 伤害值 -> num_str
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from storage zx:work dba.dmg
function sweetdream:lib/num/plain

# ② 目标 = 被钉住的那一只(执行位置就在它身上, 所以 distance=..1 只有它)
data modify storage zx:work a.target set value "@e[tag=zx.db_pass,distance=..1,limit=1]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type

# ③ 归属: 施法者 UUID 四个整数
data modify storage zx:work a.u0 set from storage zx:work dba.u0
data modify storage zx:work a.u1 set from storage zx:work dba.u1
data modify storage zx:work a.u2 set from storage zx:work dba.u2
data modify storage zx:work a.u3 set from storage zx:work dba.u3

function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现: 渊海被压出来的一圈水花
particle minecraft:bubble ~ ~0.8 ~ 0.5 0.4 0.5 0.04 14 normal
particle minecraft:splash ~ ~0.6 ~ 0.4 0.3 0.4 0.03 10 normal
