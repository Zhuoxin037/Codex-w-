# ============================================================
# version —— 版本自检(证明数据包已被游戏加载)
# ------------------------------------------------------------
# 【怎么用】/function manacore:version
# 【输出】会在聊天栏打印框架版本与关键常量。
# 【为什么需要这个函数】如果连这条命令都补全不出来 / 找不到,
#         说明数据包根本没被游戏加载(见 README 顶部的排查清单);
#         如果能调用但数值不对, 说明 load 没有跑完。
# ============================================================
tellraw @s [{"text":"==== ManaCore ====","color":"aqua","bold":true}]
tellraw @s [{"text":"版本: ","color":"gray"},{"text":"1.0.0","color":"white"},{"text":"  目标: MC 1.21.5 (datapack 71 (仅 1.21.5))","color":"dark_gray"}]
tellraw @s [{"text":"load 执行次数(#loads): ","color":"gray"},{"score":{"name":"#loads","objective":"manacore.meta"}}]
tellraw @s [{"text":"关键常量: ","color":"gray"},{"text":"#interval=","color":"dark_gray"},{"score":{"name":"#interval","objective":"manacore.meta"}},{"text":"  #scale=","color":"dark_gray"},{"score":{"name":"#scale","objective":"manacore.meta"}},{"text":"  #max_slots=","color":"dark_gray"},{"score":{"name":"#max_slots","objective":"manacore.meta"}}]
tellraw @s [{"text":"已登记玩家槽位(#next_slot): ","color":"gray"},{"score":{"name":"#next_slot","objective":"manacore.meta"}}]
tellraw @s [{"text":"若上面数字全部为空(没显示), 说明 core/load 没有跑完, 请把 /reload 后的日志报错发出来。","color":"yellow"}]
