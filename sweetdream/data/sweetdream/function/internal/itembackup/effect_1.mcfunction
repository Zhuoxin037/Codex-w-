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

# 【技能不在这里放】本函数只管"把刀弄回来", 一个技能都不放。
#   技能由每把武器自己的进度触发: advancement/equipment/<武器>.json,
#   条件是物品 custom_data.zx 里带上武器自己的标记, 奖励指向它自己的 cast。
#   —— 这样加新武器不用改这里。
#   (以前这里是写死的 function sweetdream:equipment/sword/liuguang/cast,
#    结果所有带 itemreplace 的物品右键都放流光。)
# 【为什么把回手和技能分成两件事】回手是"消耗型物品的通用机制", 技能是"武器
#   自己的行为"。分开之后: 冷却中右键 = 刀回来了、技能没放、聊天栏提示还剩多久;
#   某个武器的 cast 写坏了也不会连带把回手机制弄坏。
