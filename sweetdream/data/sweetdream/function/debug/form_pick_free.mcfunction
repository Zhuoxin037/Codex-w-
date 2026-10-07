# ============================================================
# sweetdream:debug/form_pick_free —— 找第一个**空**的术阵槽位(宏参数 {uuid})
# ------------------------------------------------------------
# 【出参】#fm_slot = 槽号 0..7;  -1 = 八个槽都有东西
# 【为什么不用 api/formation/list】formations 在存储里是**复合标签**(键是 "0".."7"
#   这种带引号的数字), 不是数组 —— 下标 [i] 那种写法取不到, 只能按名字读。
#   按名字读又必须拼 uuid, 所以整件事只能放在宏里做。
# 【为什么要一行行展开】宏里没有循环, 八个槽就是八行。
#   ⚠️ 后面七行都带 `if score #fm_slot matches -1` 的前置: 不加的话最后一行会
#      把前面求到的槽号冲掉(八行是顺序执行的, 不是"谁先命中谁停")。
#   ⚠️ 每行都含 $(uuid) -> 每行都要有 $ 前缀(漏一个 $ 那行就当普通命令解析,
#      直接报"字符不允许"并让整个函数作废)。
# ============================================================

scoreboard players set #fm_slot zx.meta -1
$execute unless data storage manacore:players "$(uuid)".formations."0".id run scoreboard players set #fm_slot zx.meta 0
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."1".id run scoreboard players set #fm_slot zx.meta 1
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."2".id run scoreboard players set #fm_slot zx.meta 2
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."3".id run scoreboard players set #fm_slot zx.meta 3
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."4".id run scoreboard players set #fm_slot zx.meta 4
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."5".id run scoreboard players set #fm_slot zx.meta 5
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."6".id run scoreboard players set #fm_slot zx.meta 6
$execute if score #fm_slot zx.meta matches -1 unless data storage manacore:players "$(uuid)".formations."7".id run scoreboard players set #fm_slot zx.meta 7
