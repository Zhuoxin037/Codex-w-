# ============================================================
# sweetdream:upgrade/api/fit_slot_free —— 不同系时检查"还有没有空槽"(非宏)
# ------------------------------------------------------------
# 【谁调用它】upgrade/api/fit ③ —— 新石头的系列不在身上(ser_check 没命中)时,
#   才要求有空槽; 同系走替换, 不占新槽。
# 【口径】2 个自由槽 = 已有不同系列 < 2。读不到 up = 0 条(先归零防旧分)。
# 【出参】#up_full = 1 表示"槽满了"。**归零 <- fit**, 这里只负责置 1。
# 【 ★ 为什么这里绝对不能写 `return` ★ 】
#   它是被 `execute ... run function fit_slot_free` 调用的 —— 在它里面 `return`,
#   只结束**它自己这次调用**, 控制权回到 fit 继续往下执行, 最后那句
#   `data modify storage zx:out r.ok set value 1b` 照样跑 ⇒ "槽满"被静默吞掉,
#   玩家可以无限敲(2026-10-07 真实事故, 用户报"不限多少都可以敲")。
#   ⇔ 同族反例: `execute ... run return 0`(return 内联在 fit 自己的命令行里)才是
#     真正中断 fit; 跨函数只能靠"标记分 + 调用方判"。
# ------------------------------------------------------------
# 【为什么单独一层】fit 的主体是宏函数, 而这段没有宏参数 —— 拆出来还能少一份
#   "宏参数没绑 = 整函数作废"的暴露面。
# ============================================================

scoreboard players set #up_have zx.meta 0
execute store result score #up_have zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_data".up
execute if score #up_have zx.meta matches 2.. run scoreboard players set #up_full zx.meta 1
