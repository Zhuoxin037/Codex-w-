# ============================================================
# fallendream:equipment/sword/chengxing/base_sync —— 秤星超限「主手持时护甲 +1」
# ------------------------------------------------------------
# 【执行者】玩家（由 second 每秒 as @a 送进来）
# 【文案】"主手持时自身护甲值 +1。"
# 【为什么每秒而不是每刻】这是纯面板量，不影响命中判定；每秒一次最多慢 1 秒，
#   比每刻对每个玩家做两次 items 判定便宜得多（与 ebb_tide/base_sync 同策）。
# 【账本 zx.cx_b】1 = 当前挂着 fallendream:cx_arm。只在 want 变化时动 modifier，
#   平时一次整数比较就早退。
# 【★ 变化时先无条件 remove 再 add ★】同 ID 的 modifier 不能重复挂；若重生 /
#   reload 把账本清了但 modifier 还留着，不先摘就会 add 失败，护甲白少 1 点。
# 【★ 只认主手 ★】文案写"主手持时"，副手挂着不算。
# ============================================================

scoreboard players set #cx_want zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chengxing"],ol:"chengxing"}] run scoreboard players set #cx_want zx.meta 1
execute if score @s zx.cx_b = #cx_want zx.meta run return 0

attribute @s minecraft:armor modifier remove fallendream:cx_arm
scoreboard players operation @s zx.cx_b = #cx_want zx.meta
execute if score @s zx.cx_b matches 1 run attribute @s minecraft:armor modifier add fallendream:cx_arm 1 add_value
