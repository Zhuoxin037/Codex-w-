# 风行枝冠动画的实际运行时依赖，不能作为建模临时文件删除。
# objectives add 重载时已存在会提示失败，但不会中止后续命令。
scoreboard objectives add nw.anim dummy
scoreboard players set #clock nw.anim 0
scoreboard players add #frame nw.anim 0
execute unless score #frame nw.anim matches 0..15 run scoreboard players set #frame nw.anim 0

# 「释放动画」的运行时依赖
#   nw.cast_t —— 每人的释放动画帧号：0..25 = cast_00..cast_25，26 = 已归位。
#                由 naturewind:cast_start 起步、cast_tick 每 tick 推进，
#                记在**玩家自己**身上（不是 #假玩家），所以多人同时施法各播各的。
#   #nwidle   —— 常数 26，给 item_modifier naturewind:cast_idle 当
#                "把法杖写回待机"用的值。
#   #castnow  —— 不必在这里初始化：cast_tick 每 tick 用 operation 覆盖，
#                它只是"把某个玩家的 cast_t 传给 item_modifier"的临时中转站
#                （item_modifier 的 score provider 只认写死的名字，见 cast_tick 注释）。
#   这两个常数写成计分项、而不是 JSON 里的数字字面量，是因为这套
#   score provider + fixed 的路子已经在 animation_frame 上跑通了。
scoreboard objectives add nw.cast_t dummy
scoreboard players set #nwidle nw.anim 26
