# ============================================================
# sweetdream:equipment/staff/final_revelation/scan —— 把「光柱」范围内的生物打上标签
# ------------------------------------------------------------
# 【执行者】施法玩家; 【位置】玩家身上(调用方已 at @s)
# 【范围 4×16 怎么实现】原版选择器只有 x/y/z 轴对齐的盒子(dx/dy/dz),
#   拿不到"跟着朝向旋转的矩形" ⇒ 改用**沿朝向的 9 个采样球**拼一根柱体:
#   球半径 2(= 宽 4), 圆心在 ^2/^3.5/^5/^6.5/^8/^9.5/^11/^12.5/^14 ——
#   首尾两球(半径 2)正好覆盖 0..16; 相邻圆心间距 1.5 < 2×2, 重叠充分,
#   最细处(两球中点)也有 3.7 宽, 所以合起来 ≈ 长 16、宽 4。
#   ★ 截面是圆的不是方的(近似)。间距一旦 ≥ 2×半径, 中点会**掐出一个腰**
#     (半径 2 / 间距 4 时中点宽度是 0) —— 改半径必须同步改点数。
# 【为什么跟随玩家】用户 2026-10-06 定: 光柱跟着玩家位置/朝向走(可扫射)。
#   所以这里每一秒都按**当前**朝向重新铺 —— 不存任何快照。
# 【★ `positioned ^ ^ ^N` 用的是执行者的朝向 ★】外层是 `at @s`(玩家),
#   所以 ^ 方向 = 玩家视线方向, 不需要额外 rotated。
# 【★ 采样球必须带 distance ★】`distance` 是"位置类参数", 带上才把实体搜索
#   锁在当前维度(不带就跨维度搜, 见 RULES 坑 55)。
# 【★ 判定不跟着视觉偏 ★】表现层(beam)整体在视线下方 —— 那是为了让第一人称
#   看得见(坑 69); 判定必须留在准星轴上, 打哪儿就是哪儿。
# 【出参】给范围内生物打上临时标签 zx.fr_in(调用方负责清理)。
# ============================================================

# ① 先清掉上一秒的(不管它现在还在不在范围内)
tag @e[tag=zx.fr_in,distance=0..] remove zx.fr_in

# ② 沿朝向 9 个采样球(半径 2 = 宽 4; 首尾覆盖 0..16)
execute positioned ^ ^ ^2 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^3.5 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^5 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^6.5 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^8 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^9.5 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^11 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^12.5 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
execute positioned ^ ^ ^14 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.fr_in
