# 只由单笔实际耗魔事件调用。高额扣费不积压多面水墙。
function sweetdream:equipment/armor/tide_fold/new
# 满4面时保留一份待触发进度，须下次真实扣费再尝试；不会自动排队补墙。
execute unless score #tf_ok zx.meta matches 1 run scoreboard players set @s zx.tf_sum 150000
execute unless score #tf_ok zx.meta matches 1 run return 0
scoreboard players set #tf_threshold zx.meta 150000
# 一次扣费跨过多个门槛也只生成一面；只保留不足150的零头。
scoreboard players operation @s zx.tf_sum %= #tf_threshold zx.meta
