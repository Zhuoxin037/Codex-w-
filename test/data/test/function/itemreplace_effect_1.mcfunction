# ============================================================
# test:itemreplace_effect_1 —— 消耗触发: 安排一次"延迟回手"
# ------------------------------------------------------------
# 【触发】进度 test:itemreplace(consume_item) 的 rewards
# 【流程】撤进度 -> 取自己的 UUID -> 打标签 -> 延迟 1 tick 再回手
# 【为什么必须延迟】consume_item 的奖励是在"消耗还没走完"的时候触发的。
#   等奖励函数跑完, 游戏还会把主手设成消耗后的结果(空), 会把我们刚放回去的
#   剑覆盖掉 —— 现象就是"剑直接消失"。
#   所以这里只负责"预约", 真正回手交给下一 tick 的 itemreplace_return。
# 【为什么不能在这里直接调宏函数回手】就是上面那条: 太早了, 会被覆盖掉。
# ============================================================

advancement revoke @s only test:itemreplace
function test:uuid
execute unless data storage test:data self{ok:1b} run return fail

# 打标签(下一 tick 靠它把玩家找回来) + 预约回手
tag @s add test_pending_return
schedule function test:itemreplace_return 1t
