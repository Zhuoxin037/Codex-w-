# ------------------------------------------------------------
# internal/formation/refresh_write —— 写入新的 end
# 【宏参数】manacore:work.entry {uuid,i}(end 可选)
# 【逻辑】有 end -> 覆盖; 没有 end -> 删掉原 end(转永久术阵)。
#   删除前先 if data 判断, 避免对永久术阵重复删除导致命令报错中断。
# ------------------------------------------------------------
$execute if data storage manacore:work entry.end run data modify storage manacore:players "$(uuid)".formations."$(i)".end set from storage manacore:work entry.end
$execute unless data storage manacore:work entry.end if data storage manacore:players "$(uuid)".formations."$(i)".end run data remove storage manacore:players "$(uuid)".formations."$(i)".end
data modify storage manacore:out r.success set value 1b
