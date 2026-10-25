# ============================================================
# sweetdream:equipment/staff/bent_ray/ball_hit —— 折径普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点
# 【技能原文】"每次普攻命中后使其附加「折光」。"
# 【★ 为什么不需要反查发射者 ★】附加「折光」只是给目标打标 + 写到期刻,
#   不涉及玩家的面板/归属, 所以在球的执行者身份下直接做就行 —— 不像回魔/追加伤害
#   那样必须换回玩家。
# 【★ "折光"为什么不用 tag/mark ★】tag/mark 的五状态是**受管词表**
#   (mark_one 逐字校验 yuanhai/liuhuo/yehuo/shixin/dream), 「折光」不在里面,
#   走它会被静默拒绝。这里用**独立标签 + 到期刻**自成一套:
#     zx.br_g    = 身上有折光(选择器用)
#     zx.br_gl   = 到期绝对刻(> #now 才有效)
#   ★ 过期不主动清标签: 所有判定都同时看"到期刻 > #now", 标签残留不会造成误判;
#     真被消耗时会一起清掉。这样不必为它加一条每秒扫描。
# ============================================================

# ⓪ 分档: 这一发是不是超限版(从球的 data.ol 读回来, 理由见 attack ①.3)
#   ⇒ mark_zg 用它决定「折光」上限(原版 1 层 / 超限 3 层)。
scoreboard players set #br_ol zx.meta 0
execute if data entity @s data{ol:1b} run scoreboard players set #br_ol zx.meta 1

# ① 这一发命中的每只都附加(刷新)折光
execute as @e[tag=zx.ball_hit,distance=0..] at @s run function sweetdream:equipment/staff/bent_ray/mark_zg
