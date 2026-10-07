# ============================================================
# sweetdream:debug/form_pick_last —— 找最后一个**非空**的术阵槽位(宏参数 {uuid})
# ------------------------------------------------------------
# 【出参】#fm_slot = 槽号 0..7;  -1 = 一个术阵都没有
# 【为什么这八行**不**加 `if score matches` 前置】这里要的就是"最后一个":
#   八行顺序执行, 后面命中会覆盖前面, 跑完留下的自然是编号最大的那个非空槽。
#   (对比 form_pick_free: 那边要"第一个", 所以必须挡住后面的覆盖。)
#   ⚠️ 每行都含 $(uuid) -> 每行都要有 $ 前缀。
# ============================================================

scoreboard players set #fm_slot zx.meta -1
$execute if data storage manacore:players "$(uuid)".formations."0".id run scoreboard players set #fm_slot zx.meta 0
$execute if data storage manacore:players "$(uuid)".formations."1".id run scoreboard players set #fm_slot zx.meta 1
$execute if data storage manacore:players "$(uuid)".formations."2".id run scoreboard players set #fm_slot zx.meta 2
$execute if data storage manacore:players "$(uuid)".formations."3".id run scoreboard players set #fm_slot zx.meta 3
$execute if data storage manacore:players "$(uuid)".formations."4".id run scoreboard players set #fm_slot zx.meta 4
$execute if data storage manacore:players "$(uuid)".formations."5".id run scoreboard players set #fm_slot zx.meta 5
$execute if data storage manacore:players "$(uuid)".formations."6".id run scoreboard players set #fm_slot zx.meta 6
$execute if data storage manacore:players "$(uuid)".formations."7".id run scoreboard players set #fm_slot zx.meta 7
