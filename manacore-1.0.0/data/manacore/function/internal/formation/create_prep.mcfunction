# ------------------------------------------------------------
# internal/formation/create_prep —— 计算到期时间并准备写入
# 【前置】#free 已由 slot_driver 求出
# 【步骤】① #dur = duration(tick); 若 <= 0 再用 duration_seconds x20
#         ② 清掉 work.a.end 残留
#         ③ duration > 0 -> end = #now + duration; 否则不写 end(永久术阵)
#         ④ 把 #free 写进 work.a.i, 交给 create_write
# 【永久术阵】不写 end 字段, 于是每秒的到期检查永远不会命中它,
#   只能靠 remove/clear/玩家离线来清除。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.duration
execute if score #dur manacore.math matches ..0 run function manacore:internal/formation/dur_sec
execute if data storage manacore:work a.end run data remove storage manacore:work a.end
execute if score #dur manacore.math matches 1.. run scoreboard players operation #dur manacore.math += #now manacore.meta
execute if score #dur manacore.math matches 1.. run execute store result storage manacore:work a.end int 1 run scoreboard players get #dur manacore.math
execute store result storage manacore:work a.i int 1 run scoreboard players get #free manacore.math
function manacore:internal/formation/create_write with storage manacore:work a
