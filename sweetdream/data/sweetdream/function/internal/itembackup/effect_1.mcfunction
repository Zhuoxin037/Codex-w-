# ============================================================
# sweetdream:internal/itembackup/effect_1 —— 消耗触发: 安排一次"延迟回手"
# ------------------------------------------------------------
# 【触发】进度 sweetdream:itembackup/consume(consume_item) 的 rewards
# 【流程】撤进度 -> 取自己的 UUID -> 打标签 -> 延迟 1 tick 再回手
# 【为什么必须延迟】consume_item 的奖励是在"消耗还没走完"的时候触发的。
#   等奖励函数跑完, 游戏还会把主手设成消耗后的结果(空), 会把我们刚放回去的
#   剑覆盖掉 —— 现象就是"剑直接消失"。
#   所以这里只负责"预约", 真正回手交给下一 tick 的 itemreplace_return。
# 【为什么不能在这里直接调宏函数回手】就是上面那条: 太早了, 会被覆盖掉。
# ============================================================

advancement revoke @s only sweetdream:itembackup/consume
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 打标签(下一 tick 靠它把玩家找回来) + 预约回手
tag @s add test_pending_return
schedule function sweetdream:internal/itembackup/return 1t

# 顺手把技能放出去。
# 【为什么放在回手之后】回手已经预约好了, 就算技能因为冷却/魔力不足提前
#   return, 也不影响下一 tick 把刀拿回来 —— 冷却中右键不会丢刀。
# 【冷却中也回手】消耗是游戏自己做的, 我们拦不住; 但回手机制和技能是分开的,
#   所以"冷却中右键"的结果是: 刀回来了、技能没放、聊天栏提示还剩多少 tick。
function sweetdream:equipment/liuguang/damage
