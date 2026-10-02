# ============================================================
# sweetdream:internal/itembackup/mainhand_1 —— 每刻把手里的武器备份一份
# ------------------------------------------------------------
# 【触发】进度 sweetdream:itembackup/mainhand(trigger: tick), 函数第一行撤销它,
#   于是下一 tick 又会被授予 —— 这是"用进度做每刻循环"的经典写法。
#   (名字还叫 mainhand 是历史原因, 现在主手/副手都备份, 见 backup.mcfunction)
# 【为什么每刻都备份】下一 tick 右键消耗掉之后, 靠这份备份才能把武器还回来。
#   真正的"最准时机"是消耗触发的那一刻(effect_1 里也备份了一次),
#   这一条是兜底: 保证架子里永远是手上的最新状态。
# ============================================================

advancement revoke @s only sweetdream:itembackup/mainhand
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/backup with storage zx:work a
