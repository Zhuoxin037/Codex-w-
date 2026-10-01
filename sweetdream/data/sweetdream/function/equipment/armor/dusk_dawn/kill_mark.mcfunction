# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark —— 进度入口: 击杀带通用标签的怪 +100
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/dusk_dawn_kill_mark(5 个标签各一条条件)
# 【为什么真正的逻辑在 kill_mark_go】"技能击杀"那条路也要记这笔账(见
#   internal/damage/one), 所以记账逻辑只留一份, 进度和伤害接口都调它。
#   那边用的是差值账本(zx.dd_app), 因此重复调用、两个来源同时命中, 都只会加一次。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark
function sweetdream:equipment/armor/dusk_dawn/kill_mark_go
