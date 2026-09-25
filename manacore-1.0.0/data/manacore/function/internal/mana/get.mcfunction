# ------------------------------------------------------------
# internal/mana/get —— 读取当前/最大魔力
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.value(当前) / out.max(最大)
# 【注意】取不到字段时保持 0.0, 不会报错。
# ------------------------------------------------------------
data modify storage manacore:out r.value set value 0.0
data modify storage manacore:out r.max set value 0.0
$execute if data storage manacore:players "$(uuid)".stats.current_mana run data modify storage manacore:out r.value set from storage manacore:players "$(uuid)".stats.current_mana
$execute if data storage manacore:players "$(uuid)".stats.max_mana run data modify storage manacore:out r.max set from storage manacore:players "$(uuid)".stats.max_mana
