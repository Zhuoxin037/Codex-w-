# ============================================================
# sweetdream:internal/itembackup/effect_1 —— 消耗触发: 记下"用的哪只手" + 预约回手
# ------------------------------------------------------------
# 【触发】进度 sweetdream:itembackup/consume(consume_item) 的 rewards
# 【流程】撤进度 -> 取自己的 UUID -> 判定槽位 -> 快照 -> 打标签 -> 延迟 1 tick 回手
# ------------------------------------------------------------
# 【为什么必须延迟】consume_item 的奖励是在"消耗还没走完"的时候触发的。
#   等奖励函数跑完, 游戏还会把那个槽位设成消耗后的结果(空), 会把我们刚放回去的
#   剑覆盖掉 —— 现象就是"剑直接消失"。
#   所以这里只负责"记账 + 预约", 真正回手交给下一 tick。
# 【为什么不能在这里直接调宏函数回手】就是上面那条: 太早了, 会被覆盖掉。
# ------------------------------------------------------------
# 【★ 为什么要记录"用的哪只手" ★】本次修复的重点
#   item replace 是覆盖式的: 写哪个槽位, 那个槽位原来的东西就**直接没了**
#   (不会掉在地上, 也找不回来)。老版本无条件写回 weapon.mainhand, 于是
#   "武器放副手右键"会连着出两件事:
#       副手那把没备份过     -> 消耗后没人还它        -> 武器消失
#       架子里的旧备份被塞进主手 -> 主手的装备被顶掉 -> 又消失一件
#   现在趁"消耗还没走完、物品还在手上"这一刻判定槽位, 存进标签 zx.ret_off,
#   下一 tick 由 effect_2 按它决定写回哪只手。
# 【怎么判】原版的使用顺序是"主手物品可用就先用主手", 所以先看主手:
#       主手是 itemreplace                 -> 主手触发(不打标签)
#       主手不是、副手是 itemreplace       -> 副手触发(打 zx.ret_off)
# ============================================================

advancement revoke @s only sweetdream:itembackup/consume
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 判定槽位: 默认当主手, 只有"主手不是、副手是"时才记为副手
tag @s remove zx.ret_off
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tag @s add zx.ret_off

# ② 立刻快照一次
#   每刻那条 tick 备份已经够了, 但碰上"刚把武器换到副手就右键"这种极限时序,
#   它有可能还没跑到。而此刻消耗还没走完、东西还在手上, 是【最准】的备份时机。
#   两份备份写进架子的同一个槽位, 内容一致, 不会互相打架。
data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/backup with storage zx:work a

# ③ 打标签(下一 tick 靠它把玩家找回来) + 预约回手
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
