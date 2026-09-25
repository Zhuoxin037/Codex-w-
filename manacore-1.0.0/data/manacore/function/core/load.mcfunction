# ============================================================
# core/load —— 加载入口(刻意写得极短)
# ------------------------------------------------------------
# 【触发】data/minecraft/tags/function/load.json -> manacore:core/load
# 【为什么不用 scoreboard objectives add】
#   add 在"目标已存在"时会报错, 而报错会中断整个函数 —— 第二次 /reload
#   之后后面的初始化就全不执行了(常量没有、秒循环不跑、新人注册不上)。
#   scoreboard players set 会自动创建 dummy 目标(getOrCreateObjective),
#   且重复执行完全无害, 所以用它隐式建目标。
# 【为什么这里只有 5 行】
#   函数只要引用到"加载失败的函数", 自己也会跟着加载失败。所以入口只做
#   最低限度的事, 其余全部交给 core/boot。这样即使 boot 出问题,
#   core/load 依然会出现在 /function 补全里, 一眼就能区分问题层级。
# 【排错】/scoreboard players get #loads manacore.meta 可确认 boot 是否跑完
# ============================================================
function manacore:core/init
function manacore:core/boot
