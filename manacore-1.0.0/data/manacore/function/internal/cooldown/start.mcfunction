# ============================================================
# internal/cooldown/start —— 开始一段技能冷却
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,skill,cooldown,cooldown_seconds,reduce}
#    cooldown         : tick 冷却(优先, > 0 时使用)
#    cooldown_seconds : 秒级冷却(cooldown <= 0 时使用, 内部 x20 换算)
#    reduce           : 是否吃"冷却缩减"属性, 默认 1b
# 【数据格式】players."uuid".cooldowns."skill" = { end, total, start }
#    end   : 结束时刻(绝对游戏刻, 用框架的 #now 时间轴)
#    total : 本次实际冷却时长(便于 UI 画进度条)
#    start : 开始时刻
# 【为什么存绝对时刻而不是倒计时】不用每 tick 去减, 读取时算
#    end - #now 即可, 多人多技能也不会产生每刻的遍历开销。
# 【双时间轴支持】tick 冷却走 cooldown, 秒冷却走 cooldown_seconds,
#    两者都不会写死单位, 由调用方自己选。
# ============================================================
execute store result score #dur manacore.math run data get storage manacore:work a.cooldown
execute if score #dur manacore.math matches ..0 run function manacore:internal/cooldown/start_sec
execute if score #dur manacore.math matches 1.. run function manacore:internal/cooldown/start_go with storage manacore:work a
