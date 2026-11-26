# ============================================================
# fallendream:equipment/armor/lvshuang/tick —— 履霜（钻石靴 · 被动）每刻
# ------------------------------------------------------------
# 【执行者】玩家（core/tick 每刻 as @a 调一次；第一行判装备，不穿就退出）
# 【机制】每移动 1 格，在脚下留一片霜（最多同时 6 片，各自 5 秒消失）。
#   敌人踩到霜 → 缓慢Ⅱ 2 秒；自己踩到自己的霜 → 迅捷Ⅰ 2 秒（不消耗霜）。
# 【★ "移动 1 格"怎么判】比这次的采样位置和**上次撒点位置**的水平距离平方，
#   >= 10000（即 1 格×100 的平方）才撒一片。不是"每走一步"，是"每走过 1 格"。
# 【★ 为什么不复用 lib/step】那是雨迹的整套状态机（zx.sm_*，含补点自递归），
#   绑死在"穿雨迹的玩家"上；这里只要一个距离比较，独立更不容易互相踩。
# 【★ 贴花还没做】现在只用粒子表现（雪片 + 白尘）。等外观批次出 rain_puddle
#   同款贴花再挂 item_display，功能判定不需要改。
# ============================================================
# ① 位移技能窗口递减（on_cast 打 20 刻；窗口内撒的霜直接 3 档，见 spawn ④）
#   ★ 放在装备门控**之前**：脱了靴子窗口也要照样走完，否则残留一个十几刻的
#     "3 档窗口"，再穿回来时凭空多出几片满档霜。
execute if score @s zx.lsh_dash matches 1.. run scoreboard players remove @s zx.lsh_dash 1

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"]}] run return 0

# ============================================================
# ⓪ 超限·站桩加档（必须放在下面的距离判据之前 —— 站在霜上时位移为 0，
#    本函数原本会在下面那行 `return 0`，站多久都不加档）
#   ★ 用全局刻 #now % 10 当节拍，不给每个玩家再开一个计数器。
#   ★ 只在超限档做：基础档根本没有"档位"这回事。
# ============================================================
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"],ol:"lvshuang"}] run scoreboard players set #lsh_10 zx.meta 10
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"],ol:"lvshuang"}] run scoreboard players operation #lsh_m zx.meta = #now manacore.meta
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"],ol:"lvshuang"}] run scoreboard players operation #lsh_m zx.meta %= #lsh_10 zx.meta
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"],ol:"lvshuang"}] if score #lsh_m zx.meta matches 0 run function fallendream:equipment/armor/lvshuang/layer_add

execute store result score #lsh_x zx.meta run data get entity @s Pos[0] 100
execute store result score #lsh_z zx.meta run data get entity @s Pos[2] 100

scoreboard players add @s zx.lsh_i 0
scoreboard players add @s zx.lsh_px 0
scoreboard players add @s zx.lsh_pz 0
# 第一次采样只建立基准（用临时标记判，避免"set 之后又判 0"的死分支）
scoreboard players set #lsh_first zx.meta 0
execute if score @s zx.lsh_i matches 0 run scoreboard players set #lsh_first zx.meta 1
execute if score #lsh_first zx.meta matches 1 run scoreboard players operation @s zx.lsh_px = #lsh_x zx.meta
execute if score #lsh_first zx.meta matches 1 run scoreboard players operation @s zx.lsh_pz = #lsh_z zx.meta
execute if score #lsh_first zx.meta matches 1 run scoreboard players set @s zx.lsh_i 1
execute if score #lsh_first zx.meta matches 1 run return 0

scoreboard players operation #lsh_dx zx.meta = #lsh_x zx.meta
scoreboard players operation #lsh_dx zx.meta -= @s zx.lsh_px
scoreboard players operation #lsh_dz zx.meta = #lsh_z zx.meta
scoreboard players operation #lsh_dz zx.meta -= @s zx.lsh_pz
scoreboard players operation #lsh_d zx.meta = #lsh_dx zx.meta
scoreboard players operation #lsh_d zx.meta *= #lsh_dx zx.meta
scoreboard players operation #lsh_t zx.meta = #lsh_dz zx.meta
scoreboard players operation #lsh_t zx.meta *= #lsh_dz zx.meta
scoreboard players operation #lsh_d zx.meta += #lsh_t zx.meta
execute if score #lsh_d zx.meta matches ..9999 run return 0

scoreboard players operation @s zx.lsh_px = #lsh_x zx.meta
scoreboard players operation @s zx.lsh_pz = #lsh_z zx.meta
function fallendream:equipment/armor/lvshuang/spawn
