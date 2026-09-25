# ------------------------------------------------------------
# internal/formation/find_owner —— 全服查找某 id 术阵的归属
# 【宏参数】manacore:work.a {uuid}(由 index/visit 传入, 即当前检查到的玩家)
# 【配合】ctrl.arg = 要找的术阵 id, ctrl.mode = "formation_find"
# 【流程】整轮遍历中每个玩家都会被问一次"你有这个 id 吗", 命中就写 out。
# 【为什么走 ctrl 而不是宏参数】遍历是递归的, 额外参数只能放在全局 ctrl
#   存储里才能穿过所有递归层。
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:""}
data modify storage manacore:work entry.id set from storage manacore:ctrl arg
function manacore:internal/formation/find_driver with storage manacore:work entry
