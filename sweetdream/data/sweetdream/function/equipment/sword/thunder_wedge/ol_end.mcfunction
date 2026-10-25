# ============================================================
# sweetdream:equipment/sword/thunder_wedge/ol_end —— 超限·雷楔 到点: 对范围内全部生物落雷
# ------------------------------------------------------------
# 【执行者】雷楔 marker   【位置】marker   【调用方】wedge_end ②.5
# 【设计原文】"雷楔在结束后对范围内的全部生物都会释放一次闪电。"
# 【★ 这个函数在 marker 被 kill 之前跑 ★】它要读 marker 的 data.zx.{dmg,u[0..3]} 与位置。
# 【先摊开 NBT 再逐只打】ol_end_one 的 @s 会变成"被落雷的那只生物", 那时再读
#   `data.zx.dmg` 读到的是怪物自己的字段(不存在)。所以先把四样抄进 zx:work twgdot。
# 【反查施法者只需要一次】lib/find_by 会给玩家挂 zx.mc_by, 逐只的 ol_end_one 共用
#   这个标签调 lib/on_lightning(位置仍是各自的落点)。
# ============================================================

# ① marker 上的施法与伤害信息摊进 twgdot
data modify storage zx:work twgdot set value {dmg:0.0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work twgdot.dmg set from entity @s data.zx.dmg
data modify storage zx:work twgdot.u0 set from entity @s data.zx.u[0]
data modify storage zx:work twgdot.u1 set from entity @s data.zx.u[1]
data modify storage zx:work twgdot.u2 set from entity @s data.zx.u[2]
data modify storage zx:work twgdot.u3 set from entity @s data.zx.u[3]

# ② 反查施法者(on_lightning 的 @s 必须是玩家)
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb

# ③ 范围内逐只落雷(范围 = 超限的 12 格, 与 hit ⑤ 的第二行同一个数)
execute as @e[type=!#sweetdream:no_damage,distance=..12] at @s run function sweetdream:equipment/sword/thunder_wedge/ol_end_one

# ④ 表现: 整片收束
execute at @s run particle minecraft:electric_spark ~ ~0.6 ~ 1.6 1.0 1.6 0.15 60 normal
execute at @s run playsound minecraft:entity.lightning_bolt.thunder player @a ~ ~ ~ 0.9 1.1

# ⑤ 摘反查标签
tag @a remove zx.mc_by
