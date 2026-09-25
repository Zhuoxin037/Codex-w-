# ------------------------------------------------------------
# internal/formation/find_hit —— 命中: 写出查询结果
# 【宏参数】manacore:work.entry {uuid,id,i}
# 【出参】out.found / out.uuid(归属玩家) / out.index(槽位号) / out.formation
# 【用途】让使用方既知道"这是谁的术阵", 也能拿到槽位号做后续操作。
# ------------------------------------------------------------
data modify storage manacore:out r.found set value 1b
$data modify storage manacore:out r.uuid set value "$(uuid)"
execute store result storage manacore:out r.index int 1 run data get storage manacore:work entry.i
$data modify storage manacore:out r.formation set from storage manacore:players "$(uuid)".formations."$(i)"
