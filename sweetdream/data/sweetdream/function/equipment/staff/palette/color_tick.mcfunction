# ============================================================
# sweetdream:equipment/staff/palette/color_tick —— “色彩”每刻推进(执行者 = 色彩 item_display)
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度各一行: execute in <维> as @e[tag=zx.pal_col,distance=0..] at @s run ...)
#   ★ 选择器**只按标签认人**(不带 type=): 光球的实体类型将来再换(贴图/模型形态)也不用改这里。
#   ★ 本函数是「色彩」**唯一**的每刻驱动(原来还有一条 palette/second 的每秒兜底, 2026-10-08 已删 ——
#     用户要求严格按文案: 光球没有时间寿命, 只有"出界 / 打满阀值"两个自毁条件)。
# 【它做什么】
#   ① 反查释放者(lib/find_by) —— 释放者离线就自毁
#   ② 把光球自己的参数组装成宏节点(给 color_body 拼选择器用)
#   ③ 交给 color_body 做: 出界自毁 / 挑目标 / 移动 / 命中结算
# 【★ 所有 @e 都带位置参数 ★】本函数挂在"每维度各跑一次"的链上, 裸 @e 会跨维度重复处理。
# 【公共输入口】color_hit 要用 manacore:in arg(算伤害 / 回蓝 / 冷却), 所以整段夹在
#   in_bak / in_restore 之间(和 wind_ontheground/second 同款)。
# ============================================================

function sweetdream:lib/in_bak

# ① 反查释放者(uuid 四个 int 存在光球的 data.zx.pal 里)
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
execute if entity @s[tag=zx.pal_col] if score @s zx.pv_wait matches 1.. run function sweetdream:equipment/staff/palette/visual/color_wait
execute if entity @s[tag=zx.pal_col] unless score @s zx.pv_wait matches 1.. run function sweetdream:equipment/staff/palette/color_body with storage zx:work pc

execute if entity @s[tag=zx.pal_col] unless score @s zx.pv_wait matches 1.. run function sweetdream:equipment/staff/palette/visual/color_tick

# ④ 清反查标记(无条件, 免得残留)
tag @a remove zx.mc_by

function sweetdream:lib/in_restore
