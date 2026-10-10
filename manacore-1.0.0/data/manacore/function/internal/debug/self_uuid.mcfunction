# ------------------------------------------------------------
# internal/debug/self_uuid —— 把自己的 UUID 写进参数节点
# 【宏参数】manacore:work.a {i}(i = 自己的槽位号)
# 【做法】index."i".uuid -> work.a.uuid(路径拼接需要宏)
# 【用途】debug/dump、debug/selftest 这类"默认对自己操作"的入口。
# 【★ F05 修(2026-10-10)】先摘掉 a.uuid 再查 —— 原写法在"索引缺失(未注册/
#   槽位已失效)"时不会写任何东西, 于是 a.uuid 残留**上一次调用**的 UUID,
#   外层(api/player/self_uuid)见非空就当成功返回 ⇒ 未注册的玩家会拿到别人的
#   UUID(串身份)。`data remove` 对不存在的路径是空操作, 不会报错。
# ------------------------------------------------------------
data remove storage manacore:work a.uuid
$execute if data storage manacore:index "$(i)" run data modify storage manacore:work a.uuid set from storage manacore:index "$(i)".uuid
