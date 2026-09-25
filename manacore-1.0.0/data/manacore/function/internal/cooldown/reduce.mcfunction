# ------------------------------------------------------------
# internal/cooldown/reduce —— 减少当前剩余冷却
# 【宏参数】manacore:work.a {uuid,skill,ticks,seconds}
# 【单位】ticks 优先; ticks <= 0 时用 seconds x20。
# 【语义】把 end 往前推 #amt 刻 —— 注意推过头(end < #now)也不会立刻
#         清记录, 下一次 check 时会判定就绪并顺手删除。
# 【典型用途】"技能冷却减少"道具、连击奖励、天赋触发。
# ------------------------------------------------------------
execute store result score #amt manacore.math run data get storage manacore:work a.ticks
execute if score #amt manacore.math matches ..0 run function manacore:internal/cooldown/reduce_sec
execute if score #amt manacore.math matches 1.. run function manacore:internal/cooldown/reduce_body with storage manacore:work a
