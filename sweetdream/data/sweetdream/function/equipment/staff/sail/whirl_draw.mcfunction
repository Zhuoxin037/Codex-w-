# ============================================================
# sweetdream:equipment/staff/sail/whirl_draw —— 画一帧旋风(宏: 只管几何)
# ------------------------------------------------------------
# 【宏参数】zx:work slw.a = 本刻角度(0..359)
# 【画什么】三条螺旋臂 × 6 个高度点 = 18 个带色尘, 拼出一条**漏斗形龙卷**:
#   半径随高度**张开**(接地 0.20 -> 顶部 1.80), 整体绕 Y 轴转 —— 这才是"龙卷风"。
# 【★ 2026-10-08 修: 形状是反的 ★】
#   原先是"底 1.70 -> 顶 0.14"(宽底 + 尖顶 = 一顶尖帽子), 玩家反馈
#   "旋风反过来了, 完全不像龙卷风, 像个帽子"。改成现实里龙卷的锥形:
#   接地处最细、往上逐渐张开。
# 【★ 同时把整条几何下移到地面 ★】
#   旋风 marker 在 ~+1(它的位置要用来算 5 格吸引范围, 不能挪), 所以 h 从 -0.95 起 ——
#   否则整个漏斗会**悬在半空**, 也是一个"帽子"的观感。接地那一点现在贴到 y≈0.05。
# 【★ 三条臂怎么岔开 ★】`rotated ~120 0` 是**相对**旋转, 叠在 `rotated ~$(a) 0`
#   上面就是 a+120; 再叠一次就是 a+240。别写 `rotated ~$(a) 120`(那是俯仰角)。
# 【★ 为什么先 rotated 再 positioned ★】`positioned ^ ^ ^` 是本地坐标,
#   用的是**上一条 rotated 定下的朝向**; 顺序反了就全落在原地。
# 【★ 颜色不在这里 ★】`run function whirl_dot` 会把执行者与坐标一起带过去,
#   颜色由 whirl_dot 按 zx.sl_m 分支 —— 见那个文件里"为什么拆两层"的说明。
# 【接地三颗 cloud】贴近地面那一圈用来"起沙", 让旋风看着像在吹地面, 不是悬空的一缕。
# ============================================================

# ---- 臂 ①: 角度 a ----
$execute rotated ~$(a) 0 positioned ^0.20 ^-0.95 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^0.44 ^-0.40 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^0.74 ^0.20 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^1.06 ^0.80 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^1.42 ^1.40 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^1.80 ^2.05 ^0 run function sweetdream:equipment/staff/sail/whirl_dot

# ---- 臂 ②: 角度 a + 120 ----
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^0.20 ^-0.95 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^0.44 ^-0.40 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^0.74 ^0.20 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.06 ^0.80 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.42 ^1.40 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.80 ^2.05 ^0 run function sweetdream:equipment/staff/sail/whirl_dot

# ---- 臂 ③: 角度 a + 240 ----
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^0.20 ^-0.95 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^0.44 ^-0.40 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^0.74 ^0.20 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.06 ^0.80 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.42 ^1.40 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.80 ^2.05 ^0 run function sweetdream:equipment/staff/sail/whirl_dot

# ---- 贴地起沙(半径 1.10, 落在真正的地面上 —— 接地处的"沙尘圈") ----
$execute rotated ~$(a) 0 positioned ^1.10 ^-0.98 ^0 run particle minecraft:cloud ~ ~ ~ 0.07 0.02 0.07 0.0 1 normal
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.10 ^-0.98 ^0 run particle minecraft:cloud ~ ~ ~ 0.07 0.02 0.07 0.0 1 normal
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.10 ^-0.98 ^0 run particle minecraft:cloud ~ ~ ~ 0.07 0.02 0.07 0.0 1 normal
