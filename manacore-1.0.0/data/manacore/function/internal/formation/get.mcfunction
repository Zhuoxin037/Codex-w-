# ------------------------------------------------------------
# internal/formation/get —— 查询某个术阵的详情
# 【宏参数】manacore:work.a {uuid,id}
# 【出参】out.found / out.index / out.formation(整份术阵数据副本)
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:"$(id)"}
function manacore:internal/formation/find_driver with storage manacore:work entry
