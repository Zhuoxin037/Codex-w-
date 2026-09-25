# ------------------------------------------------------------
# internal/formation/refresh_prep —— 重新计算到期时间
# 【前置】out.found 已由 find_driver 填好, out.index = 命中的槽位号
# 【步骤】① 把 out.index 写回 work.entry.i(供 refresh_write 拼路径)
#         ② 算时长: duration(tick) 或 duration_seconds x20
#         ③ <= 0 -> 去掉 end 字段(改为永久)
#         ④ >  0 -> end = #now + duration
# 【为什么只改 end】start 保持不变, 于是还能知道"这个术阵最初何时放的"。
# ------------------------------------------------------------
execute if data storage manacore:out r.found run data modify storage manacore:work entry.i set from storage manacore:out r.index
execute store result score #dur manacore.math run data get storage manacore:work a.duration
execute if score #dur manacore.math matches ..0 run function manacore:internal/formation/dur_sec
execute if score #dur manacore.math matches ..0 if data storage manacore:work entry.end run data remove storage manacore:work entry.end
execute if score #dur manacore.math matches 1.. run scoreboard players operation #dur manacore.math += #now manacore.meta
execute if score #dur manacore.math matches 1.. run execute store result storage manacore:work entry.end int 1 run scoreboard players get #dur manacore.math
execute if data storage manacore:out r.found run function manacore:internal/formation/refresh_write with storage manacore:work entry
