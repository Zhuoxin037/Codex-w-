# ============================================================
# sweetdream:equipment/axe/charge/second —— 每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【★ 必须写 at @s ★】只写 execute as 只换了执行者, 位置还是**服务器**的
#   (也就是世界出生点)。这个技能里所有 distance=..8 / ..1 都要相对玩家算,
#   少了 at @s 会变成"在出生点附近找怪"。(风行回响踩过一模一样的坑)
# 【备份公共输入口】tick 会写 manacore:in arg(读魔力), 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# ① 被动: 主手持着它 -> 迅捷 I
execute as @a run function sweetdream:equipment/axe/charge/passive

# ② 超载状态: 每秒续迅捷 II + 召一次雷 + 倒计时
execute as @a[scores={zx.chg_on=1..}] at @s run function sweetdream:equipment/axe/charge/tick

function sweetdream:lib/in_restore
