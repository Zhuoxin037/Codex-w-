# ============================================================
# sweetdream:equipment/armor/fade/passive —— 息影·每秒倒计时与兑现
# ------------------------------------------------------------
# 【执行者】玩家(second 用 `as @a at @s` 送进来)
# 【计时口径】on_cast 把 zx.fd_t 拉满 10; 这里每秒 -1;
#   减到 0 的那一刻 = 最后一次施法满 10 秒 -> 兑现(共 10 次递减)。
# 【★ 脱下就清零 ★】不然脱了又穿上会接着上一次的残值提前兑现。
# ============================================================

# ① 穿着门控(认装备用 ~ 部分匹配 + 独有标记)
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"]}] run scoreboard players set @s zx.fd_t 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"]}] run return 0

# ② 没在计时就不做事
execute unless score @s zx.fd_t matches 1.. run return 0

# ③ -1 秒; 还没到 0 就继续等
scoreboard players remove @s zx.fd_t 1
execute if score @s zx.fd_t matches 1.. run return 0

# ④ 到点了: 兑现
function sweetdream:equipment/armor/fade/go
