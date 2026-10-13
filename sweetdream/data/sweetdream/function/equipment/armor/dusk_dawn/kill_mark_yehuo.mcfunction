# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark_yehuo
#   进度 dusk_dawn_kill_mark_yehuo 的奖励入口。
# ------------------------------------------------------------
# 【为什么一个标签一个 wrapper】进度的 rewards.function 必须**首行 revoke 自己**那条
#   (自撤销型契约, 见 lib/rearm 与 check.py 的 selfrev 规则) —— 共享函数做不到
#   "revoke 自己"(它不知道是谁调它), 所以每个标签配一个 2 行的入口。
# 【记账】revoke 之后一律交给共享的 kill_mark: 它按 `@s zx.dd_n` 数"本刻进来几次",
#   = 死者身上有几个通用标签 = X(超限版 100×X, 基础版固定 100)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark_yehuo
function sweetdream:equipment/armor/dusk_dawn/kill_mark
