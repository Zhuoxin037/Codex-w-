# ------------------------------------------------------------
# internal/cooldown/start_go —— 冷却写入(共用流程)
# 【宏参数】manacore:work.a {uuid,skill,reduce}; #dur = 换算好的 tick 数
# 【步骤】
#   ① reduce=1b 时按玩家 cooldown_reduction 打折(见 apply_reduce)
#   ② 若打完折 <= 0 -> start_done(直接不算冷却, 并清掉旧记录)
#   ③ #total = #dur; #dur += #now 得到绝对结束时刻
#   ④ 写入 end/total/start, out.remaining = 本次总时长
#   ⑤ 抛 #manacore:event/cooldown_start(可用于同步客户端 UI)
# 【重复释放怎么算】再次 start 会直接覆盖旧记录 —— 也就是"刷新/重置冷却"。
#   真正的"冷却中禁止释放"由 api/skill/cast 的前置检查保证。
# ============================================================
execute if data storage manacore:work a{reduce:1b} run function manacore:internal/cooldown/apply_reduce with storage manacore:work a
execute if score #dur manacore.math matches ..0 run function manacore:internal/cooldown/start_done with storage manacore:work a
scoreboard players operation #total manacore.math = #dur manacore.math
scoreboard players operation #dur manacore.math += #now manacore.meta
$execute store result storage manacore:players "$(uuid)".cooldowns."$(skill)".end int 1 run scoreboard players get #dur manacore.math
$execute store result storage manacore:players "$(uuid)".cooldowns."$(skill)".total int 1 run scoreboard players get #total manacore.math
$execute store result storage manacore:players "$(uuid)".cooldowns."$(skill)".start int 1 run scoreboard players get #now manacore.meta
execute store result storage manacore:out r.remaining int 1 run scoreboard players get #total manacore.math
$data modify storage manacore:ctx skill set value "$(skill)"
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "start"
function #manacore:event/cooldown_start
