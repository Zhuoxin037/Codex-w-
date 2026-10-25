# ============================================================
# sweetdream:equipment/sword/yebu/slow —— 给被曳步命中的生物上（或升级）缓慢
# ------------------------------------------------------------
# 【执行者】被命中的生物（不是玩家）
# 【入参】zx.yb（到期刻）/ zx.ybu（升级冷却到期刻），缺省 0
# 【三档判定】
#   ① zx.yb > 现在 且 zx.ybu <= 现在  → 升级：缓慢Ⅱ 3 秒，ybu = 现在 + 80
#   ② zx.yb > 现在 且 zx.ybu > 现在   → 已是Ⅱ级，只刷新 Ⅱ 3 秒（不重设 ybu）
#   ③ 其余（没记过账 / 已过期）       → 缓慢Ⅰ 4 秒，yb = 现在 + 80
# 【为什么 ② 不降级】effect give 是覆盖式：给 Ⅰ 会把 Ⅱ 顶掉，等于"连击反而变弱"。
# ============================================================
scoreboard players add @s zx.yb 0
scoreboard players add @s zx.ybu 0
scoreboard players operation #yb_now zx.meta = #now manacore.meta

# 【超限分流】(批 K1) #yb_ol 由 hit 那边按"主/副手是不是超限·曳步"置好:
#   超限 = 6 秒 Ⅰ / 3 秒 Ⅲ 可叠至 12 秒 / 叠满再给一次移速 -50%。见 ol_slow。
execute if score #yb_ol zx.meta matches 1 run function sweetdream:equipment/sword/yebu/ol_slow
execute if score #yb_ol zx.meta matches 1 run return 0

# ① 升级
execute if score @s zx.yb > #yb_now zx.meta if score @s zx.ybu <= #yb_now zx.meta run function sweetdream:equipment/sword/yebu/upgrade
execute if score @s zx.yb > #yb_now zx.meta if score @s zx.ybu <= #yb_now zx.meta run return 0

# ② 已在Ⅱ级、升级冷却内 → 只续时长
execute if score @s zx.yb > #yb_now zx.meta run effect give @s minecraft:slowness 3 1 true
execute if score @s zx.yb > #yb_now zx.meta run scoreboard players operation @s zx.yb = #yb_now zx.meta
execute if score @s zx.yb > #yb_now zx.meta run scoreboard players add @s zx.yb 60
execute if score @s zx.yb > #yb_now zx.meta run return 0

# ③ 初次 → 缓慢Ⅰ 4 秒
effect give @s minecraft:slowness 4 0 true
scoreboard players operation @s zx.yb = #yb_now zx.meta
scoreboard players add @s zx.yb 80
execute at @s run particle minecraft:dust{color:[0.55,0.62,0.72],scale:0.9} ~ ~0.35 ~ 0.4 0.4 0.4 0.005 8 normal
