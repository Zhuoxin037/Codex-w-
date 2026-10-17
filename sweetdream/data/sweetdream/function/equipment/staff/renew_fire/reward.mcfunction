# ============================================================
# sweetdream:equipment/staff/renew_fire/reward —— 续火: 累计命中与回血
# ------------------------------------------------------------
# 【谁调用它】ball_hit ③   【执行者】**发射者玩家**   【位置】玩家所在
# 【技能原文】"每次普攻命中后累计一次，每累计 3 次则恢复自身 1 点生命值。
#   切换武器后清空次数。"
# 【★ 满 3 次就清零, 不是"每 3 次永久保留" ★】文案是"每累计 3 次" ⇒ 循环计数。
#   ("清零"必须和"刚满 3"分开判 —— 直接把 zx.rf_n 置 0 之后就分不清"本来 0"
#    和"刚满 3", 所以先用临时开关 #rf_go 拍下来。)
# 【★ 回血走 lib/heal ★】给玩家写 Health 是原版禁止的(lib/heal 文件头有完整取证),
#   这里只给"整点数 1"。
# ============================================================

# ① 累计一次
scoreboard players add @s zx.rf_n 1

# ② 满 3 次 -> 标记兑现, 然后清零(先标记再清, 顺序不能反)
scoreboard players set #rf_go zx.meta 0
execute if score @s zx.rf_n matches 3.. run scoreboard players set #rf_go zx.meta 1
execute if score #rf_go zx.meta matches 1 run scoreboard players set @s zx.rf_n 0

# ③ 恢复 1 点生命值
execute if score #rf_go zx.meta matches 1 run scoreboard players set #heal_pt zx.meta 1
execute if score #rf_go zx.meta matches 1 run function sweetdream:lib/heal

# ④ 表现: 一小簇火星往上飘(看得见"攒满了")
execute if score #rf_go zx.meta matches 1 at @s run particle minecraft:dust{color:[1.0,0.62,0.18],scale:0.9} ~ ~1 ~ 0.3 0.4 0.3 0.01 8 normal
execute if score #rf_go zx.meta matches 1 at @s run particle minecraft:flame ~ ~1 ~ 0.2 0.3 0.2 0.005 5 normal
execute if score #rf_go zx.meta matches 1 run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.35 1.9
