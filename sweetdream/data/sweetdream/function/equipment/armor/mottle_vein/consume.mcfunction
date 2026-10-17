# ============================================================
# sweetdream:equipment/armor/mottle_vein/consume —— 杂纹: 记录"这一次消费的是哪一种"
# ------------------------------------------------------------
# 【谁调用它】lib/on_consume ③(技能/装备被动**真把**一个状态标签摘掉之后)
#   调用点已判过"腿上穿着杂纹", 本文件不再判(只做记录与兑现)。
# 【执行者】**消耗者**玩家(由 lib/on_consume 的 as $(by) 保证)
# 【宏参数】zx:work mc.mark = 刚被消耗掉的那个标签名(liuhuo/yehuo/shixin/yuanhai/dream)
# 【技能原文】"自身魔力值上限 +150。从自身第一次成功消费状态标签开始，记录接下来
#   8 秒内消费过的不同种类：流火、夜火、噬心、渊海、白昼梦。同一种类只计一次。
#   累计消耗 3 种后，清空记录，立即恢复 20 点魔力值，并获得 3 秒迅捷Ⅱ和抗性提升Ⅰ；
#   若消耗了「流火」则额外恢复 30 点魔力值；若消耗了「夜火」则下一次技能伤害 +20%；
#   若消耗了「噬心」则自身恢复 15% 最大生命值；若消耗了「渊海」则使自身 3 格内的
#   全部生物击退 1 格；若消耗了「白昼梦」则使自身下一次攻击到的生物时停 1 秒。"
# 【★ 只认"真摘掉" ★】lib/on_consume 只在「永恒」没把标签补回来时才跑 ⇒
#   "成功消费"的语义天然对上; 被永恒补回的那次不计(同余烬/回潮扣)。
# 【★ 8 秒窗口怎么记 ★】zx.mv_end = 窗口的**到期绝对刻**(> #now 就是窗口还开着)。
#   没有每秒递减、也不需要 lib/second —— 过期就"下次消费时重新开窗"(open)。
# 【★ "同一种类只计一次"怎么记 ★】每记下一个种类就给玩家打一个 zx.mv.<种类> 标签;
#   已有该标签 = 这一类本轮已经计过, 不重复加数。
# 【★ 为什么这里不按 src 过滤 ★】回潮扣/烛跬 的文案写"自身**技能**消耗", 所以它们
#   在 on_consume 里按 src:"skill" 过滤; 杂纹的文案写的是"**消费**状态标签", 没有
#   限定来源 ⇒ 技能消耗与装备被动顺手消耗(归息/殓丝/失血)都算。
# ============================================================

# ① 窗口没开(没记过 / 已过期) -> 重开一个 8 秒窗口, 并清掉上一轮的记录
scoreboard players add @s zx.mv_end 0
execute unless score @s zx.mv_end > #now manacore.meta run function sweetdream:equipment/armor/mottle_vein/open

# ② 这一种本轮还没记过 -> 计数 +1 并打上种类标签
#    ★ 第一行**故意不带 $** —— `$` 只允许加在含 $(变量) 的行上, 加了却没有变量
#      会让整个函数作废(check 规则 dollar / RULES 16)。
scoreboard players add @s zx.mv_n 0
$execute unless entity @s[tag=zx.mv.$(mark)] run scoreboard players add @s zx.mv_n 1
$execute unless entity @s[tag=zx.mv.$(mark)] run tag @s add zx.mv.$(mark)

# ③ 满 3 种 -> 兑现(清空记录、给奖励)
execute if score @s zx.mv_n matches 3.. run function sweetdream:equipment/armor/mottle_vein/reward
