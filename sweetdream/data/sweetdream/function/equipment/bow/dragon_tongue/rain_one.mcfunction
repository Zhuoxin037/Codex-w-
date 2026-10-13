# ============================================================
# sweetdream:equipment/bow/dragon_tongue/rain_one —— 箭雨循环的一步(普通函数)
# ------------------------------------------------------------
# 【执行者】射手(玩家); 由 fire 直接调, 递归到第 ns 根箭为止。
# 【为什么用"计数 + 递归"而不是宏参数 $(i)】宏参数在**调用那一刻**就冻结,
#   "同一个函数里既写宏源又读 $(i)"是经典 off-by-one 坑(坑 96)。这里循环变量
#   走计分项 #dt_i(不是宏参数), 所以递归每层读到的都是最新值, 不会漏末位。
# 【为什么 rain_one 不是宏函数】它一个宏参数都不需要 —— 箭数在 #dt_n,
#   其余数据在 zx:work dt。递归调用就是普通 `function ...`, 不带 storage。
# ============================================================

scoreboard players add #dt_i zx.meta 1
execute if score #dt_i zx.meta > #dt_n zx.meta run return 0
function sweetdream:equipment/bow/dragon_tongue/rain_deal
function sweetdream:equipment/bow/dragon_tongue/rain_one
