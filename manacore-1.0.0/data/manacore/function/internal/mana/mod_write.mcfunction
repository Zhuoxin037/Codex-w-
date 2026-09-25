# ------------------------------------------------------------
# internal/mana/mod_write —— 真正写入修正数据
# 【宏参数】manacore:work.a {uuid,id,type,value,i}
# 【写入结构】regen_mods[i] = { id, type, value }   ← 永久修正
#                             { id, type, value, end } ← 临时修正
# 【临时判定】duration > 0 -> end = #now + duration; 否则不写 end(永久)。
# 【为什么先 remove end】槽位是复用的, 上一次的 end 不清掉会把新的永久
#         修正立刻判成"已过期"。
# 【出参】out.success = 1b / out.index = 槽位号
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".regen_mods."$(i)".id set value "$(id)"
$data modify storage manacore:players "$(uuid)".regen_mods."$(i)".type set value "$(type)"
$data modify storage manacore:players "$(uuid)".regen_mods."$(i)".value set from storage manacore:work a.value
$execute if data storage manacore:players "$(uuid)".regen_mods."$(i)".end run data remove storage manacore:players "$(uuid)".regen_mods."$(i)".end
execute store result score #dur manacore.math run data get storage manacore:work a.duration
execute if score #dur manacore.math matches ..0 run function manacore:internal/mana/mod_dur_sec
execute if score #dur manacore.math matches 1.. run scoreboard players operation #dur manacore.math += #now manacore.meta
$execute if score #dur manacore.math matches 1.. store result storage manacore:players "$(uuid)".regen_mods."$(i)".end int 1 run scoreboard players get #dur manacore.math
data modify storage manacore:out r.success set value 1b
execute store result storage manacore:out r.index int 1 run data get storage manacore:work a.i
