# ============================================================
# sweetdream:equipment/armor/ebb_tide/sample_one —— 一只带渊海的生物: 判位移 + 补片
# ------------------------------------------------------------
# 【执行者】那只生物(@s)   【位置】at @s
# 【★ 位移判据 ★】与"上次补片锚点"比, 三轴平方和 > 6400(坐标 ×100) = 0.8 格。
#   ★ 锚点必须在**补片之前**归位(与心脉「泵动」同一条教训: 不归位的话下一刻
#     位移又立刻满, 变成每刻都补一片)。
# 【★ zx.et_ok ★】"锚点建过没有"的标记。不能直接拿"有没有 zx.et_px 分数"当判据:
#   没分数时 `if score` 一律不成立, 得先 `add 0` 补成 0, 而 0 又正好是世界坐标
#   (0,0,0) —— 会把"第一次见到"误判成"瞬移了几百万格"。所以单开一个标记位。
# ============================================================

# ① 首次见到 ⇒ 只建锚点, 不补片(免得刚进 8 格就白送一片)
execute unless score @s zx.et_ok matches 1 run function sweetdream:equipment/armor/ebb_tide/anchor_set
execute unless score @s zx.et_ok matches 1 run return 0

# ② 三轴差值（坐标 ×100）
scoreboard players set #et_d zx.meta 0
execute store result score #et_x zx.meta run data get entity @s Pos[0] 100
execute store result score #et_y zx.meta run data get entity @s Pos[1] 100
execute store result score #et_z zx.meta run data get entity @s Pos[2] 100
scoreboard players operation #et_x zx.meta -= @s zx.et_px
scoreboard players operation #et_y zx.meta -= @s zx.et_py
scoreboard players operation #et_z zx.meta -= @s zx.et_pz

# ③ ★ 先钳位再平方: 坐标 ×100 后是几百万量级, 直接平方必爆 int32(坑 R05)。
#      位移本身不可能超过 100 格(=10000), 夹到这个范围是安全的(瞬移也够用)。
#      ★ 上下界都用**动态分数**：core/load 没有 #-10000 这种负常量。
scoreboard players set #et_c zx.meta 10000
execute if score #et_x zx.meta > #et_c zx.meta run scoreboard players operation #et_x zx.meta = #et_c zx.meta
execute if score #et_y zx.meta > #et_c zx.meta run scoreboard players operation #et_y zx.meta = #et_c zx.meta
execute if score #et_z zx.meta > #et_c zx.meta run scoreboard players operation #et_z zx.meta = #et_c zx.meta
scoreboard players operation #et_c zx.meta *= #-1 zx.meta
execute if score #et_x zx.meta < #et_c zx.meta run scoreboard players operation #et_x zx.meta = #et_c zx.meta
execute if score #et_y zx.meta < #et_c zx.meta run scoreboard players operation #et_y zx.meta = #et_c zx.meta
execute if score #et_z zx.meta < #et_c zx.meta run scoreboard players operation #et_z zx.meta = #et_c zx.meta

# ④ 平方和
scoreboard players operation #et_d zx.meta = #et_x zx.meta
scoreboard players operation #et_d zx.meta *= #et_x zx.meta
scoreboard players operation #et_y zx.meta *= #et_y zx.meta
scoreboard players operation #et_z zx.meta *= #et_z zx.meta
scoreboard players operation #et_d zx.meta += #et_y zx.meta
scoreboard players operation #et_d zx.meta += #et_z zx.meta

# ⑤ 位移不够 ⇒ 收工(锚点不动: 它记的是"上次**补片**的位置", 不是"上一刻")
execute if score #et_d zx.meta matches ..6400 run return 0

# ⑥ 够了 ⇒ 先归位锚点, 再补片
function sweetdream:equipment/armor/ebb_tide/anchor_set
function sweetdream:equipment/armor/ebb_tide/wave_new
