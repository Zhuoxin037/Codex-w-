# ------------------------------------------------------------
# internal/formation/refresh —— 刷新术阵持续时间
# 【宏参数】manacore:work.a {uuid,id,duration,duration_seconds}
# 【流程】先 find_driver 找到槽位(顺便填好 out.index), 再转 refresh_prep。
# 【用途】支持续时(把 end 往后推), 也支持改成永久术阵。
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:"$(id)"}
function manacore:internal/formation/find_driver with storage manacore:work entry
execute if data storage manacore:out r.found run function manacore:internal/formation/refresh_prep
