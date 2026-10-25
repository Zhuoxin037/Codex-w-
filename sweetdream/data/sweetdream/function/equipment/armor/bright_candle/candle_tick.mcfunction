# ============================================================
# sweetdream:equipment/armor/bright_candle/candle_tick —— 「烛火」每秒一跳
# ------------------------------------------------------------
# 【谁调用它】lib/second: 三维度各一行 `in <dim> as @e[tag=zx.bc_fire,distance=0..] at @s`
# 【执行者】烛火(item_display)   【位置】烛火自己
# 【文案】
#   · 在「烛火」3 格内附有「流火」的生物累计停留 3 秒后 ⇒ 「流火」转化为「夜火」
#   · 在「烛火」3-5 格内附有「流火」的生物累计停留 5 秒后 ⇒ 同样转化
#   · 自身在「烛火」5 格内时每秒额外恢复 最大魔力值 ×0.5% 的魔力
#   · 持续 10 秒
# 【★ 两档共用一个 dwell 计数 ★】3 格内阈值 3、3–5 格阈值 5, 计数本身只有一份
#   (zx.bc_dw, 每秒 +1)。"内圈"的那只同时也在"外圈"里 ⇒ 判定必须先内后外,
#   外圈那条要 `unless entity @s[tag=zx.bc_in3]` 排除掉内圈(否则内圈 3 秒时
#   外圈条件还没到 5, 但内圈已经该转化了 —— 两条不冲突, 但排除掉更直观)。
# 【★ 转化 = 摘流火 + 上夜火, 不是叠加 ★】叠加会让"流火+夜火"双持变成刷魔力的
#   漏洞(余烬 burned_out 的老教训); 这里是**替换**。
# 【★ dwell 记在生物身上的安全性 ★】临时分数打在生物身上会留在存档 ——
#   所以: ① core/load 有三维度兜底清洗; ② 这条分数**只用于计时**, 不挂任何
#   判死 / 击杀逻辑(残留最坏的结果是"下次进烛火少烤一两秒", 不会误杀)。
# ============================================================

# ① 寿命 10 秒(每秒 -1)
scoreboard players remove @s zx.bc_life 1
execute if score @s zx.bc_life matches ..0 run return run kill @s

# ② 表现: 烛芯上一小簇火
particle minecraft:small_flame ~ ~0.5 ~ 0.06 0.1 0.06 0.01 4 normal
particle minecraft:smoke ~ ~0.55 ~ 0.04 0.04 0.04 0.005 1 normal

# ③ 圈里谁带着「流火」? 内圈(3 格) / 外圈(5 格)各打一个标签
tag @e[tag=zx.bc_in5,distance=0..] remove zx.bc_in5
tag @e[tag=zx.bc_in3,distance=0..] remove zx.bc_in3
execute as @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=..5] run tag @s add zx.bc_in5
execute as @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=..3] run tag @s add zx.bc_in3

# ④ 累计停留 +1(只给"在 5 格内"的算)
execute as @e[tag=zx.bc_in5,distance=0..] unless score @s zx.bc_touch = #now manacore.meta run scoreboard players add @s zx.bc_dw 1
execute as @e[tag=zx.bc_in5,distance=0..] run scoreboard players operation @s zx.bc_touch = #now manacore.meta

# ⑤ 到点判定: 内圈 3 秒 / 外圈 5 秒
tag @e[tag=zx.bc_cvt,distance=0..] remove zx.bc_cvt
execute as @e[tag=zx.bc_in3,distance=0..] if score @s zx.bc_dw >= #3 zx.meta run tag @s add zx.bc_cvt
execute as @e[tag=zx.bc_in5,distance=0..] unless entity @s[tag=zx.bc_in3] if score @s zx.bc_dw >= #5 zx.meta run tag @s add zx.bc_cvt
execute if entity @e[tag=zx.bc_cvt,distance=0..,limit=1] run function sweetdream:equipment/armor/bright_candle/convert

# ⑥ 收尾: 三个临时标签用完即摘(不然下一支烛火会把它们当自己人)
tag @e[tag=zx.bc_cvt,distance=0..] remove zx.bc_cvt
tag @e[tag=zx.bc_in3,distance=0..] remove zx.bc_in3
tag @e[tag=zx.bc_in5,distance=0..] remove zx.bc_in5

# ⑦ 主人在 5 格内 ⇒ 每秒回 最大魔力 ×0.5%
data modify storage zx:work ub set value {}
data modify storage zx:work ub.u0 set from entity @s data.zx.u[0]
data modify storage zx:work ub.u1 set from entity @s data.zx.u[1]
data modify storage zx:work ub.u2 set from entity @s data.zx.u[2]
data modify storage zx:work ub.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,distance=..5,limit=1] run function sweetdream:equipment/armor/bright_candle/regen
