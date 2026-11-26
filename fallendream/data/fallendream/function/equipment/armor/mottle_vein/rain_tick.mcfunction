# ============================================================
# fallendream:equipment/armor/mottle_vein/rain_tick —— 超限·杂纹: 「标签雨」每秒一跳
# ------------------------------------------------------------
# 【谁调用它】lib/second（`as @a[scores={zx.mv_rain=1..}]`，每秒一次）
# 【执行者】玩家（@s）
# 【文案(lore 逐字)】…若本次消耗的标签超过 4 种，则每秒使自身 8 格内的随机 3 个生物
#   附加一个随机标签，持续 4 秒。
# 【★ 随机挑人怎么挑 ★】`at @s as @e[…,sort=random,limit=3]` —— sort=random 是原版
#   选择器自带的洗牌, 不用自己打标签(打标签要扫全场生物, 白花性能)。
# 【★ 中途脱裤子就停 ★】zx.mv_rain 一归零 lib/second 就不会再进来。
# ============================================================

# ⓪ 还穿着超限杂纹吗（脱了就地停雨）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run scoreboard players set @s zx.mv_rain 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run return 0

# ① 8 格内随机 3 只, 各附一个随机标签（distance 从 0.01 起: 不给自己挂）
execute at @s as @e[type=!#fallendream:no_damage,distance=0.01..8,sort=random,limit=3] run function fallendream:equipment/armor/mottle_vein/rain_one

# ② 表现 + 计时
execute at @s run particle minecraft:dust{color:[0.42,0.1,0.62],scale:1.2} ~ ~1 ~ 7 1.2 7 0.02 40 normal
scoreboard players remove @s zx.mv_rain 1
