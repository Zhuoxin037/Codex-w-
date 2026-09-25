# ============================================================
# test:itemreplace_return —— 延迟 1 tick 后执行回手(由 schedule 调用)
# ------------------------------------------------------------
# 【为什么需要它】consume_item 进度的奖励函数是在"消耗还没走完"时触发的。
#   奖励跑完后, 游戏还会把主手设置成消耗后的结果(空), 把我们刚放回去的
#   剑又覆盖掉 —— 现象就是"剑直接消失"。
#   所以必须等这一 tick 彻底结束, 下一 tick 再把备份放回手里。
# 【为什么不能直接 schedule 那个宏函数】schedule 出来的函数既没有 @s,
#   也没有宏参数。所以这里用标签把玩家找回来, 再用 execute as 让 @s
#   重新变成他, 然后在下一级里重新取 UUID。
# ============================================================

execute as @a[tag=test_pending_return] run function test:itemreplace_return_go
tag @a[tag=test_pending_return] remove test_pending_return
