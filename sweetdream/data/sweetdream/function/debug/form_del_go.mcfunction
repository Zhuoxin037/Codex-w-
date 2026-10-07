# ============================================================
# sweetdream:debug/form_del_go —— 摘掉指定槽位的术阵(宏参数 {uuid, i})
# ------------------------------------------------------------
# 【为什么先抄 id 再删】api/formation/remove 只认 id, 不认槽号 —— 所以先把这一槽
#   里现在存着的 id 抄一份出来: 一是要拿它去删, 二是要在回执里报出"删的是哪个"
#   (不然只能干巴巴说"删了", 分不清删掉的是调试术阵还是技能的术阵)。
#   ⚠️ 抄出来这份要放在 manacore:in arg 之外 —— 下面还会用 arg 去调 count,
#      一覆盖 id 就没了。
# 【为什么删完要再数一次】remove 只回执 removed, 不回数量。
# ⚠️ 【$ 前缀的两条规矩】含 $( ) 的行**必须**带 $; 不含 $( ) 的行**不能**带 $
#   (带了反而会让整行走宏解析器, 是另一种作废)。
# ============================================================

# ① 抄出 id(槽里没东西时保持空串, 后面 remove 会安全地什么也不做)
data modify storage zx:work fm.id set value ""
$execute if data storage manacore:players "$(uuid)".formations."$(i)".id run data modify storage zx:work fm.id set from storage manacore:players "$(uuid)".formations."$(i)".id

# ② 删
$data modify storage manacore:in arg set value {uuid:"$(uuid)",id:""}
data modify storage manacore:in arg.id set from storage zx:work fm.id
function manacore:api/formation/remove

# ③ 重新数
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/formation/count

execute if data storage manacore:out r{removed:1b} run tellraw @s [{"text":"[术阵] 摘掉 ","color":"light_purple"},{"nbt":"fm.id","storage":"zx:work","color":"gray"},{"text":" -> 现在 ","color":"light_purple"},{"nbt":"r.count","storage":"manacore:out","color":"white"},{"text":" / ","color":"dark_gray"},{"nbt":"r.limit","storage":"manacore:out","color":"light_purple"}]
execute unless data storage manacore:out r{removed:1b} run tellraw @s [{"text":"[术阵] 没摘掉 —— 那个槽位是空的, 现在还是 ","color":"red"},{"nbt":"r.count","storage":"manacore:out","color":"white"},{"text":" / ","color":"dark_gray"},{"nbt":"r.limit","storage":"manacore:out","color":"red"}]
