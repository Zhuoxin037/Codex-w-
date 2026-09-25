# ============================================================
# sweetdream:event/cooldown_start —— 记住"最近一次进入冷却的技能"
# ------------------------------------------------------------
# 【谁调用它】挂在 manacore 的标签上传 #manacore:event/cooldown_start 上,
#   每次任何技能开始冷却都会触发(以事件的方式, 不需要改技能函数)。
# 【为什么要记】数值面板要显示"你刚放的那个技能还剩多久"。
#   面板打开时手里拿的是观测镜而不是武器, 所以不能靠"看主手物品"来判断。
# 【为什么拆两层】标签只能按名字调用、传不了参数; 而按玩家存储需要
#   拿 UUID 拼路径。所以第一层把 manacore:ctx 当宏参数递给第二层。
# ============================================================

# 这一行里没有 $(变量): 参数是通过 "with storage" 传给下一层的, 所以不能加 $。
execute if data storage manacore:ctx run function sweetdream:event/cooldown_start_go with storage manacore:ctx
