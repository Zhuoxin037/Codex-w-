# ------------------------------------------------------------
# internal/formation/clear_all —— 清空某玩家的全部术阵
# 【宏参数】manacore:work.a {uuid}
# 【用途】① api/formation/clear(主动清空) ② 玩家离线时的残留清理
# 【事件】每个被清掉的术阵都会单独抛一次 formation_remove(reason="clear"),
#   所以外部包的显示实体不会残留。
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:""}
function manacore:internal/formation/clear_driver with storage manacore:work entry
