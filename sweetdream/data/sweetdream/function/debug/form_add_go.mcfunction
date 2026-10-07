# ============================================================
# sweetdream:debug/form_add_go —— 真的建一个术阵(宏参数 {uuid, i})
# ------------------------------------------------------------
# 【id 为什么带槽号】删的时候靠 id 找, 用槽号当后缀就不需要另外维护
#   "我建过哪些 id" 的表 —— 槽号是框架自己挑的, 同一个槽不可能建进去两次。
# 【为什么用 type:"debug"】术阵类型是自己解释的字符串, 本包没有任何地方
#   按 "debug" 这个类型做事(风行认 wind、超•负•荷认 charge), 所以它纯粹占位。
# 【永久】duration:0 + duration_seconds:0.0 -> 框架不写 end 字段, 不会自己到期。
# ============================================================

$data modify storage manacore:in arg set value {uuid:"$(uuid)",id:"sweetdream:dbg_$(i)",type:"debug",duration:0,duration_seconds:0.0}
function manacore:api/formation/create

# 再数一次(注意: create 自己写的 out.r.count 是"建之前"的数量, 直接用会少 1)
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/formation/count

execute if data storage manacore:out r{success:1b} run tellraw @s [{"text":"[术阵] +1 -> ","color":"light_purple"},{"nbt":"r.count","storage":"manacore:out","color":"white"},{"text":" / ","color":"dark_gray"},{"nbt":"r.limit","storage":"manacore:out","color":"light_purple"},{"text":"   (不会自己消失, 用完记得按「术阵 -1」摘掉)","color":"dark_gray"}]
execute unless data storage manacore:out r{success:1b} run tellraw @s [{"text":"[术阵] 没加上 —— 已到上限: ","color":"red"},{"nbt":"r.count","storage":"manacore:out","color":"white"},{"text":" / ","color":"dark_gray"},{"nbt":"r.limit","storage":"manacore:out","color":"red"}]
