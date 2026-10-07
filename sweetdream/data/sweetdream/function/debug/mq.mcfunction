# ============================================================
# sweetdream:debug/mq —— 超限·万念 / 千散 的**实时状态自查**
# ------------------------------------------------------------
# 【怎么用】聊天栏 /function sweetdream:debug/mq(以自己身份)。
#   排查"在领域里打了半天没反应"时, 这一屏就能分清是**哪一段**没走通:
#     超限?   = 0  -> 手里那把不是超限版(is_ol 没认出来 / 换手没把 ol 写回去)
#     领域中? = 0  -> 不在这只领域 marker 的 5 格内(走开了 / 领域被别人认错)
#     命中/5  -> 一直不到 5, 大概率是上面两个有一个为 0, 或者每次都没真打中生物
#     窗口    -> 已经是 2 却没有提示 = 提示那段没跑到; 是 -1 = 已放过/已过期
# 【为什么不用 schedule / 不常驻】这是"卡住时手动拉一次"的排查工具,
#   挂每秒会在聊天栏刷屏, 反而淹掉正常的战斗提示。
# ============================================================

tellraw @s [{"text":"── 超限·万念 / 千散 ──","color":"dark_gray"}]

function sweetdream:equipment/sword/myriad/is_ol
scoreboard players set #dbg_ol zx.meta 0
scoreboard players operation #dbg_ol zx.meta = #mq_ol zx.meta

function sweetdream:equipment/sword/myriad/in_domain
scoreboard players set #dbg_in zx.meta 0
scoreboard players operation #dbg_in zx.meta = #mq_in zx.meta

scoreboard players add @s zx.mq_h5 0
scoreboard players add @s zx.mq_win 0
scoreboard players add @s zx.mq_soul 0
scoreboard players add @s zx.mq_ju 0
scoreboard players add @s zx.mq_jb 0

scoreboard players set #dbg_h5 zx.meta 0
scoreboard players set #dbg_win zx.meta 0
scoreboard players set #dbg_soul zx.meta 0
scoreboard players set #dbg_ju zx.meta 0
scoreboard players set #dbg_jb zx.meta 0
scoreboard players operation #dbg_h5 zx.meta = @s zx.mq_h5
scoreboard players operation #dbg_win zx.meta = @s zx.mq_win
scoreboard players operation #dbg_soul zx.meta = @s zx.mq_soul
scoreboard players operation #dbg_ju zx.meta = @s zx.mq_ju
scoreboard players operation #dbg_jb zx.meta = @s zx.mq_jb

tellraw @s [{"text":"超限?  ","color":"gray"},{"score":{"name":"#dbg_ol","objective":"zx.meta"},"color":"white"},{"text":"   （0 = 手里那把不是超限版, 领域/剑魂/居合全不会走）","color":"dark_gray"}]
tellraw @s [{"text":"领域中? ","color":"gray"},{"score":{"name":"#dbg_in","objective":"zx.meta"},"color":"white"},{"text":"   命中/5 ","color":"gray"},{"score":{"name":"#dbg_h5","objective":"zx.meta"},"color":"yellow"},{"text":"   窗口 ","color":"gray"},{"score":{"name":"#dbg_win","objective":"zx.meta"},"color":"gold"},{"text":" 秒(-1 = 无窗口)","color":"dark_gray"}]
tellraw @s [{"text":"剑魂 ","color":"gray"},{"score":{"name":"#dbg_soul","objective":"zx.meta"},"color":"light_purple"},{"text":"/5","color":"dark_gray"},{"text":"   居合剩余 ","color":"gray"},{"score":{"name":"#dbg_ju","objective":"zx.meta"},"color":"gold"},{"text":" 秒   下一次增伤 +","color":"gray"},{"score":{"name":"#dbg_jb","objective":"zx.meta"},"color":"yellow"},{"text":" 层","color":"dark_gray"}]
tellraw @s [{"text":"   ·  ","color":"dark_gray"},{"text":"在圈内命中 5 次 -> 2 秒窗口 -> 立刻再按一次右键 = 放特殊技能(会切回另一把)","color":"dark_gray"}]
