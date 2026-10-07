# ============================================================
# sweetdream:equipment/sword/myriad/soul_fx —— 「剑魂」的每刻视觉
# ------------------------------------------------------------
# 【谁调用它】core/tick(只对 zx.mq_soul >= 1 的玩家, 每刻一次)
# 【执行者】玩家
# 【为什么每刻】每秒画一次的话 20 fps 里 19 帧是空的, 看着就是"凭空闪一下",
#   转不起来。角度存玩家计分项 zx.mq_sa(每刻 +5 => 72 刻转一圈 = 3.6 秒)。
# 【★ 画几个由剑魂数决定 ★】0 个不画(函数根本不会被挑出来), 5 个画满一圈。
# 【★ 怎么用一条宏参数画出 5 个方位 ★】rotated 是**相对旋转、会累积**,
#   所以 `rotated ~$(a) 0 rotated ~72 0` 就是在 $(a) 的基础上再转 72° ——
#   一个 $(a) 就能画出 5 个均匀分布的槽位, 不用传 5 个角度。
# ============================================================

scoreboard players add @s zx.mq_sa 5
execute if score @s zx.mq_sa matches 360.. run scoreboard players remove @s zx.mq_sa 360

execute store result storage zx:work mqs.a int 1 run scoreboard players get @s zx.mq_sa
function sweetdream:equipment/sword/myriad/soul_draw with storage zx:work mqs
