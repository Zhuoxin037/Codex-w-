# ------------------------------------------------------------
# internal/debug/self_uuid —— 把自己的 UUID 写进参数节点
# 【宏参数】manacore:work.a {i}(i = 自己的槽位号)
# 【做法】index."i".uuid -> work.a.uuid(路径拼接需要宏)
# 【用途】debug/dump、debug/selftest 这类"默认对自己操作"的入口。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run data modify storage manacore:work a.uuid set from storage manacore:index "$(i)".uuid
