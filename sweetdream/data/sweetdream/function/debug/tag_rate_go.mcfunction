# ============================================================
# sweetdream:debug/tag_rate_go —— 标签测速的第二半(由 tag_rate schedule 调用)
# ------------------------------------------------------------
# 【谁调它】sweetdream:debug/tag_rate 的 schedule(100 tick 后)
# 【上下文】★ schedule 是**服务器身份**执行的: 没有 @s、位置在世界出生点、
#   维度是主世界。所以下面不能写 tellraw @s(发给服务器的命令会失败),
#   采样也必须显式跨三个维度找那只被钉住的生物。
# 【会清掉自己召唤的东西】最后摘掉 zx.tr_pin, 并 kill 对照 marker 与测试猪。
#   测试猪死后它的图标由每秒的租约清扫(tag/second_dimension)自己收掉。
# ============================================================

# ---- ① 第二次采样: 三维度各试一次, 采到了就置 #tr_got = 1 ----
scoreboard players set #tr_got zx.meta 0
execute in minecraft:overworld run function sweetdream:debug/tag_rate_go_dim
execute if score #tr_got zx.meta matches 0 run execute in minecraft:the_nether run function sweetdream:debug/tag_rate_go_dim
execute if score #tr_got zx.meta matches 0 run execute in minecraft:the_end run function sweetdream:debug/tag_rate_go_dim

# ---- ② 算账: Δ刻 / Δ秒 / Δ剩余 / 倍率(×100 定点) ----
#   ★ 除数(#tr_sec)必须先确认 >= 1 再做 /=, 否则(#tr_sec 没分数 = 0)会
#     **除以 0 中断整个函数**(check 规则 28)。
scoreboard players set #tr_tps zx.meta 20
scoreboard players set #100 zx.meta 100
scoreboard players set #tr_mul zx.meta -1
scoreboard players operation #tr_dt zx.meta = #tr_t1 zx.meta
scoreboard players operation #tr_dt zx.meta -= #tr_t0 zx.meta
scoreboard players operation #tr_sec zx.meta = #tr_dt zx.meta
scoreboard players operation #tr_sec zx.meta /= #tr_tps zx.meta
scoreboard players operation #tr_dy zx.meta = #tr_y0 zx.meta
scoreboard players operation #tr_dy zx.meta -= #tr_y1 zx.meta
scoreboard players operation #tr_dl zx.meta = #tr_l0 zx.meta
scoreboard players operation #tr_dl zx.meta -= #tr_l1 zx.meta
execute if score #tr_sec zx.meta matches 1.. run scoreboard players operation #tr_mul zx.meta = #tr_dy zx.meta
execute if score #tr_sec zx.meta matches 1.. run scoreboard players operation #tr_mul zx.meta *= #100 zx.meta
execute if score #tr_sec zx.meta matches 1.. run scoreboard players operation #tr_mul zx.meta /= #tr_sec zx.meta

# ---- ③ 报告(服务器身份 -> 用 @a) ----
tellraw @a [{"text":"===== 标签测速结果 =====","color":"gold"}]
tellraw @a [{"text":"  全局刻 #now 走了 ","color":"gray"},{"score":{"name":"#tr_dt","objective":"zx.meta"},"color":"yellow"},{"text":" tick = ","color":"gray"},{"score":{"name":"#tr_sec","objective":"zx.meta"},"color":"yellow"},{"text":" 秒","color":"gray"}]
tellraw @a [{"text":"  渊海 剩余 ","color":"gray"},{"score":{"name":"#tr_y0","objective":"zx.meta"},"color":"aqua"},{"text":" -> ","color":"gray"},{"score":{"name":"#tr_y1","objective":"zx.meta"},"color":"aqua"},{"text":"    掉 ","color":"gray"},{"score":{"name":"#tr_dy","objective":"zx.meta"},"color":"yellow"}]
tellraw @a [{"text":"  流火 剩余 ","color":"gray"},{"score":{"name":"#tr_l0","objective":"zx.meta"},"color":"aqua"},{"text":" -> ","color":"gray"},{"score":{"name":"#tr_l1","objective":"zx.meta"},"color":"aqua"},{"text":"    掉 ","color":"gray"},{"score":{"name":"#tr_dl","objective":"zx.meta"},"color":"yellow"}]
tellraw @a [{"text":"  ★ 实测速率 = ","color":"gray"},{"score":{"name":"#tr_mul","objective":"zx.meta"},"color":"light_purple"},{"text":" / 100   (100 = 每秒扣 1 秒(正常); 300 = 3 倍; -1 = 采样失败)","color":"dark_gray"}]
tellraw @a [{"text":"  注: 剩余秒出现变大 = 期间被重新贴过标签, 这次不能用来判断速率","color":"dark_gray"}]

# ---- ④ 收尾: 摘临时标签 + 清掉对照 marker 与测试猪(图标由每秒租约清扫自己收) ----
tag @e[tag=zx.tr_pin] remove zx.tr_pin
kill @e[tag=zx.tag_test_r]
execute in minecraft:overworld run kill @e[distance=0..,tag=zx.dp_mk]
execute in minecraft:the_nether run kill @e[distance=0..,tag=zx.dp_mk]
execute in minecraft:the_end run kill @e[distance=0..,tag=zx.dp_mk]
