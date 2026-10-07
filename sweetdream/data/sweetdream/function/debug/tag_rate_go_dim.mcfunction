# distance=0.. 将选择器限定到当前执行维度，避免三维度循环重复处理同一实体。
# ============================================================
# sweetdream:debug/tag_rate_go_dim —— 在**当前执行维度**里给被钉住的生物采第二次样
# ------------------------------------------------------------
# 【谁调它】tag_rate_go 三维度各调一次(显式 execute in <维度>, 所以这里
#   无论 @e 是否被维度限制, 语义都是确定的)
# 【做什么】找到 zx.tr_pin -> 记 #tr_t1(全局刻) + 五个 zx.tt.* 剩余秒;
#   找到过就置 #tr_got = 1, 让调用方不再试下一个维度。
# 【只读】纯读。
# ============================================================

execute if entity @e[distance=0..,tag=zx.tr_pin] run scoreboard players set #tr_got zx.meta 1
execute store result score #tr_t1 zx.meta run scoreboard players get #now manacore.meta
scoreboard players set #tr_y1 zx.meta -1
scoreboard players set #tr_l1 zx.meta -1
scoreboard players set #tr_e1 zx.meta -1
scoreboard players set #tr_s1 zx.meta -1
scoreboard players set #tr_d1 zx.meta -1
execute if score @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.yuanhai matches -2147483648.. run scoreboard players operation #tr_y1 zx.meta = @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.yuanhai
execute if score @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.liuhuo matches -2147483648.. run scoreboard players operation #tr_l1 zx.meta = @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.liuhuo
execute if score @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.yehuo matches -2147483648.. run scoreboard players operation #tr_e1 zx.meta = @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.yehuo
execute if score @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.shixin matches -2147483648.. run scoreboard players operation #tr_s1 zx.meta = @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.shixin
execute if score @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.dream matches -2147483648.. run scoreboard players operation #tr_d1 zx.meta = @e[distance=0..,tag=zx.tr_pin,limit=1] zx.tt.dream
