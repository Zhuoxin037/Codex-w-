# ============================================================
# sweetdream:equipment/bow/cloudtrail/arrow_seek —— 每刻"补认"刚射出的那支箭
# ------------------------------------------------------------
# 【谁调用它】core/tick, 排在给箭打 zx.cc_seen 那三行**之前**。
# 【执行者】带 zx.ct_seek=1.. 的玩家(刚射了一发云迹、但 shot 那一瞬没认到箭的人)
# 【★ 为什么需要这一层(坑 141) ★】
#   shot 里认箭靠的是 `tag=!zx.cc_seen`: core/tick 每刻开头给场上已有的箭都打上
#   cc_seen, 所以"还没被打标记的"理论上就是这一刻刚离弦的。但 `shot_crossbow`
#   进度的触发时机**可能早于箭进世界**(寒鸦 shot 里就记着这个已知风险) —— 那时
#   新箭还不存在, shot 那一句一个都认不到。
#   而下一刻 core/tick 开头就会给它们补 cc_seen, 之后就再也认不出来了。
#   ⇒ 唯一的机会窗口 = "箭已经生成" 之后、"打 cc_seen" 之前。也就是这里。
# 【窗口为什么是 3 刻】正常情况下一刻内就能认到; 给 3 刻是防"进度触发晚了一两刻"
#   这类抖动。认到立刻把 zx.ct_seek 清成 0, 没认到就每刻 -1, 归零放弃
#   (放弃后这一发不会建领域 —— 退化成"这一箭没有云迹", 不会误建别人的领域)。
# 【★ 只认自己身边的箭 ★】distance=..4 + 三维度各扫一次(本文件由 core/tick 在
#   每个维度里跑, 所以这里是单维度的; 裸 @e 会跨维度, 必须带 distance)。
# ============================================================

# ⓪ 先把自己的 uuid 准备好(arrow_mark 是宏函数, 要吃 zx:work ctm.uu)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work ctm.uu set from storage zx:data self.uuid

# 已经认到(data.zx.ct.ok 存在)的箭不重复写 —— 只抓"还没被写过"的那支
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,nbt=!{data:{zx:{ct:{ok:1b}}}},distance=..4] run function sweetdream:equipment/bow/cloudtrail/arrow_mark with storage zx:work ctm

# 认到了就收工(清窗口)。判据: 身边有没有一支"写着我的 uuid"的箭。
execute if entity @e[type=#sweetdream:cc_arrow,tag=zx.ct_ok,nbt={data:{zx:{ct:{ok:1b}}}},distance=..4,limit=1] run scoreboard players set @s zx.ct_seek 0

# 窗口推进: 每刻 -1, 归零放弃
#   ★ 必须带 `matches 1..` 守卫: 上面"认到了"那条把窗口清成 0, 若无条件再 -1
#     就会变成 -1(2026-10-12 存档实测 zx.ct_seek = -1)。负值虽然不会再被
#     core/tick 选中(那里是 matches 1..), 但会掩盖真实状态, 排查时误导人。
execute if score @s zx.ct_seek matches 1.. run scoreboard players remove @s zx.ct_seek 1
