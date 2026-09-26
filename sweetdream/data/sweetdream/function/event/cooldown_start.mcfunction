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

# 【两个坑都在这一行】
#   ① 这一行里没有 $(变量), 所以不能加 $ 前缀。
#   ② if data storage 后面必须跟一个"路径", 不能只写存储 ID ——
#      只写 manacore:ctx 会报"错误的命令参数", 整个函数加载失败。
#   ③ 存储 ID 和路径之间是【空格】, 不是点:
#      storage manacore:ctx uuid   ✔
#      storage manacore:ctx.uuid   ✘(会被当成一个叫 manacore:ctx.uuid 的存储)
execute if data storage manacore:ctx uuid run function sweetdream:event/cooldown_start_go with storage manacore:ctx
