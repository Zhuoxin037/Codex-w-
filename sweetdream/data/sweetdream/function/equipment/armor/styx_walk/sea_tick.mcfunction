# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_tick —— 一片「暗海」的每秒结算
# ------------------------------------------------------------
# 【谁调用它】second ③: execute as @e[tag=zx.sea] at @s(执行者 = 暗海, 位置 = 中心)
# 【顺序很重要】
#   ① 到期 -> 启动退场动画(当拍不再结算; 判定标签 zx.sea 当场摘掉, 之后只播收拢动画)
#   ② 把自己的归属抄进 zx:work sea —— 后面 sea_hurt / sea_bind_one 要宏反查释放者,
#      子函数执行时 @s 已经不是"这片暗海"了, 归属只能靠这个存储带过去。
#      ★ 逐片暗海原子执行: 处理完 A 才轮到 B, 中间的覆写不会串味。
#   ③ 清三张临时标签(上一片/上一秒的残留), 再圈本片范围内的活体
#   ④ 分流: 带噬心 -> 缓慢+虚弱; 不带 -> 进目标表 + 停留计时
#   ⑤ 伤害一次打完(释放者归属)
#   ⑥ 停留够 2 秒的 -> 结附+拉次级片+延长
#   ⑦ 表现
# 【★ 为什么每片暗海各自圈各自打 ★】一个生物可能同时踩在两片暗海里,
#   两片各打一次 = 伤害叠加 —— 这是"每片暗海每秒一次"的字面含义, 不是重复扣血。
# 【△ 临时标签是全局共用的】zx.sea_hit / zx.sea_hurt_t / zx.sea_bind 都会被
#   下一片暗海在 ③ 清掉, 所以必须"一片一套、用完即弃", 不能跨片复用。
# ============================================================

# ① 到期 -> **启动退场动画**(不是直接 kill): 摘判定标签 zx.sea, 按半径换成
#   sea_out6 / sea_out4 收拢轨道, dir 改 "out", 由 lib/anim_step 走完最后一帧收掉。
#   ★ 摘 zx.sea 是硬要求: 不摘的话 hook_calc(暗海内 +30%)与 sea_bind(延长寿命)
#     还会认这片正在消失的暗海, 而且 second 每秒会再进这里一次、把退场重启一遍。
#   ★ 轨道按半径二选一(主片 6 / 次级片 4, 数组帧值不同, 不能共用)。
execute if score @s zx.sea_end <= #now manacore.meta run tag @s remove zx.sea
execute if score @s zx.sea_end <= #now manacore.meta run scoreboard players set @s zx.sea_anim 14
execute if score @s zx.sea_end <= #now manacore.meta if data entity @s data.zx.sea{r:3} run data modify entity @s data.zx.anim set value {field:"scale",track:"sea_out6",key:"zx.sea_anim",dir:"out"}
execute if score @s zx.sea_end <= #now manacore.meta if data entity @s data.zx.sea{r:2} run data modify entity @s data.zx.anim set value {field:"scale",track:"sea_out4",key:"zx.sea_anim",dir:"out"}
# 兜底: 半径既不是 3 也不是 2(理论上不可能) -> 没有可用轨道, 直接收掉, 别让它永留
execute if score @s zx.sea_end <= #now manacore.meta unless data entity @s data.zx.sea{r:3} unless data entity @s data.zx.sea{r:2} run kill @s
execute if score @s zx.sea_end <= #now manacore.meta run tag @s add zx.anim
execute if score @s zx.sea_end <= #now manacore.meta run particle minecraft:squid_ink ~ ~0.2 ~ 2.0 0.2 2.0 0.02 20 normal
execute if score @s zx.sea_end <= #now manacore.meta run particle minecraft:sculk_soul ~ ~0.3 ~ 1.6 0.2 1.6 0.02 14 normal
execute if score @s zx.sea_end <= #now manacore.meta run return 0

# ② 归属 -> zx:work sea
data modify storage zx:work sea set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work sea.uuid set from entity @s data.zx.sea.uuid
data modify storage zx:work sea.u0 set from entity @s data.zx.sea.u0
data modify storage zx:work sea.u1 set from entity @s data.zx.sea.u1
data modify storage zx:work sea.u2 set from entity @s data.zx.sea.u2
data modify storage zx:work sea.u3 set from entity @s data.zx.sea.u3

# ③ 圈范围
tag @e[tag=zx.sea_hit] remove zx.sea_hit
tag @e[tag=zx.sea_hurt_t] remove zx.sea_hurt_t
tag @e[tag=zx.sea_bind] remove zx.sea_bind
function sweetdream:equipment/armor/styx_walk/sea_area with entity @s data.zx.sea

# ④ 分流
execute as @e[tag=zx.sea_hit] if entity @s[tag=zx.status.shixin] run function sweetdream:equipment/armor/styx_walk/sea_veil
execute as @e[tag=zx.sea_hit] unless entity @s[tag=zx.status.shixin] run function sweetdream:equipment/armor/styx_walk/sea_enter

# ⑤ 伤害(一次打完本片所有未附噬心的目标)
execute if entity @e[tag=zx.sea_hurt_t] run function sweetdream:equipment/armor/styx_walk/sea_hurt with storage zx:work sea

# ⑥ 结附(每只各触发一次: 结附噬心 + 已有暗海 +2 秒 + 拉次级片)
execute if entity @e[tag=zx.sea_bind] as @e[tag=zx.sea_bind] at @s run function sweetdream:equipment/armor/styx_walk/sea_bind_one with storage zx:work sea
tag @e[tag=zx.sea_bind] remove zx.sea_bind

# ⑦ 表现(墨黑 + 幽蓝魂火; 每秒一轮, 量给得省)
particle minecraft:squid_ink ~ ~0.2 ~ 1.6 0.2 1.6 0.005 6 normal
particle minecraft:sculk_soul ~ ~0.3 ~ 1.6 0.2 1.6 0.01 4 normal
