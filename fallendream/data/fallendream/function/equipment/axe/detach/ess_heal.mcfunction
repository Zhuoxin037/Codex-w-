# ============================================================
# fallendream:equipment/axe/detach/ess_heal —— 脱离·超限：8 秒窗口内的"回血"判定
# ------------------------------------------------------------
# 【谁调用它】detach/hit（进度 player_hurt_entity 的公共入口）里的窗口门控那一行
# 【执行者】玩家（同生体那一侧）
# 【做什么】找这次被打的生物 → 它身上还挂着 8 秒窗口吗 → 有就回 15% 最大生命
# 【★ 为什么要拆成两件 ★】`$(u)` 是宏参数，而被进度直接引用的函数里不能有宏行
#   （check.py 硬规则）⇒ 这里只做取值与派发，宏展开放在 ess_heal_go。
# ============================================================

function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work detach set value {u:""}
data modify storage zx:work detach.u set from storage zx:victim context.vx_uuid
function fallendream:equipment/axe/detach/ess_heal_go with storage zx:work detach
