# ============================================================
# sweetdream:equipment/sword/aftersound/recall_check —— 余响：这次被动算不算"该收回"
# ------------------------------------------------------------
# 【谁调用它】profession/singer/pulse 的最后一行（追随者刚触发过被动效果）
# 【执行者】追随者 marker（pulse 的 @s）
# 【判据】主人（zx.ub 反查到的那个玩家）在 12 秒窗口里，且自己在主人 15 格内
# ============================================================

# 【★ 追奉者不收回 ★】潮涌，潮枯 把追随者转成 zx.se_f 之后由它自己的 12 秒管，
#   不能被余响的窗口顺手收走（同一名歌者两件武器都带时才可能撞上）。
execute if entity @s[tag=zx.se_f] run return 0

execute unless entity @a[tag=zx.ub,scores={zx.as_win=1},distance=..15,limit=1] run return 0
function sweetdream:equipment/sword/aftersound/recall
