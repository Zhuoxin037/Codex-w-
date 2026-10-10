# ============================================================
# sweetdream:equipment/armor/dusk_dawn/temp_tick —— 临时上限的每秒倒计时
# ------------------------------------------------------------
# 【执行者】zx.dd_temp >= 1 的玩家
# 【到点做什么】把"已经加进去的"减回去(就是把 zx.dd_app 清零的过程), 见 temp_off。
# ============================================================

# 【穿着门控(2026-10-08 修)】临时上限是"穿着期间"的效果 —— 脱下立刻收掉。
#   原先没有这一层, 脱下后倒计时照跑, 最多残留 12 秒(+200 / +100×X)。
#   判据照 passive: 靴子槽 + 本装备的 zx 标记(~ 部分匹配)。
execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run scoreboard players set @s zx.dd_temp 0
scoreboard players remove @s zx.dd_temp 1
execute if score @s zx.dd_temp matches ..0 run function sweetdream:equipment/armor/dusk_dawn/temp_off
