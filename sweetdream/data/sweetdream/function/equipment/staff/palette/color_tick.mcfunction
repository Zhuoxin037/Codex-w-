# ============================================================
# sweetdream:equipment/staff/palette/color_tick —— “色彩”每刻推进(执行者 = 色彩 marker)
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度各一行: execute in <维> as @e[tag=zx.pal_col,distance=0..] at @s run ...)
# 【它做什么】
#   ① 反查释放者(lib/find_by) —— 释放者离线就自毁
#   ② 把 marker 的参数组装成宏节点(给 color_body 拼选择器用)
#   ③ 交给 color_body 做: 寿命 / 出界 / 挑目标 / 移动 / 命中
# 【★ 所有 @e 都带位置参数 ★】本函数挂在"每维度各跑一次"的链上, 裸 @e 会跨维度重复处理。
# 【公共输入口】color_hit 要用 manacore:in arg(算伤害 / 回蓝 / 冷却), 所以整段夹在
#   in_bak / in_restore 之间(和 wind_ontheground/second 同款)。
# ============================================================

function sweetdream:lib/in_bak

# ① 反查释放者(uuid 四个 int 存在 marker 的 data.zx.pal 里)
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from entity @s data.zx.pal.u0
data modify storage zx:work fb.u1 set from entity @s data.zx.pal.u1
data modify storage zx:work fb.u2 set from entity @s data.zx.pal.u2
data modify storage zx:work fb.u3 set from entity @s data.zx.pal.u3
function sweetdream:lib/find_by with storage zx:work fb

# ② 释放者不在(离线) -> 自毁
execute unless entity @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/palette/color_end

# ③ 组装宏参数 + 推进(还活着才走)
scoreboard players operation #pal_id zx.meta = @s zx.pal_id
data modify storage zx:work pc set value {id:0,rng:12}
execute store result storage zx:work pc.id int 1 run scoreboard players get @s zx.pal_id
execute store result storage zx:work pc.rng int 1 run scoreboard players get @s zx.pal_rng
execute if entity @s[tag=zx.pal_col] run function sweetdream:equipment/staff/palette/color_body with storage zx:work pc

# ④ 清反查标记(无条件, 免得残留)
tag @a remove zx.mc_by

function sweetdream:lib/in_restore
