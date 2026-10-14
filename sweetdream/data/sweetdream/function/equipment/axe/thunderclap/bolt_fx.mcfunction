# ============================================================
# sweetdream:equipment/axe/thunderclap/bolt_fx —— 威霆: 每刻劈一道真闪电
# ------------------------------------------------------------
# 【谁调用它】core/tick:
#   execute in <维度> as @e[type=marker,tag=zx.tc_strike,distance=0..] at @s run function ...
# 【执行者】"落雷排期" marker(位置 = 被击者那一刻的位置)
# 【它是什么】bolt_go 每结算一次攻击就放一个这样的 marker, 上面记着:
#   zx.tc_bs  = 还剩几道没劈(起手 = X)
#   zx.tc_ang = 下一道相对 marker 的角度(0 / 30 / 60 ... -> 每道错开, 看得出是好几道)
# 【为什么"每刻一道"而不是同刻全劈】同刻全劈会完全重叠, 视觉上只像一道;
#   每刻一道 + 每道错开 30° 才是玩家要的"一道一道劈下来"(2026-10-07 用户定)。
# 【★ 本函数在"每维度各跑一次"的链上 ★】不出现裸 @e; 只用 @s 与自己召唤的实体。
# ============================================================

# ⓪ 劈完了 -> 收掉自己(core/tick 的 tag=zx.tc_strike 筛选从此不再选中它)
execute if score @s zx.tc_bs matches ..0 run kill @s
execute if score @s zx.tc_bs matches ..0 run return 0

# ① 下一道的角度 -> 宏参数
#   ★ 为什么要 set value 整份重来 ★ work 节点是复用的, 只写 ang 会把上一道雷的
#     u0..u3 留下来 ⇒ 换了个施法者却按上一个人的 UUID 反查(共享节点串味,
#     RULES 坑 36)。所以先整体复位再逐个填; 缺键的 marker 就留 0(选不到人, 安全)。
data modify storage zx:work bs set value {ang:0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work bs.ang int 1 run scoreboard players get @s zx.tc_ang
execute if data entity @s data.zx.u0 run data modify storage zx:work bs.u0 set from entity @s data.zx.u0
execute if data entity @s data.zx.u1 run data modify storage zx:work bs.u1 set from entity @s data.zx.u1
execute if data entity @s data.zx.u2 run data modify storage zx:work bs.u2 set from entity @s data.zx.u2
execute if data entity @s data.zx.u3 run data modify storage zx:work bs.u3 set from entity @s data.zx.u3

# ② 劈一道(位置 = 本 marker, 角度按宏参数转 -> 半径 1 格处)
function sweetdream:equipment/axe/thunderclap/bolt_one with storage zx:work bs

# ③ 角度 +30°、剩余 -1
scoreboard players add @s zx.tc_ang 30
scoreboard players remove @s zx.tc_bs 1
