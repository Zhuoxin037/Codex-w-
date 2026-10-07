# ============================================================
# sweetdream:equipment/staff/sail/whirl_draw —— 画一帧旋风(宏: 只管几何)
# ------------------------------------------------------------
# 【宏参数】zx:work slw.a = 本刻角度(0..359)
# 【画什么】三条螺旋臂 × 5 个高度点 = 15 个带色尘, 拼出一条**漏斗形旋风**:
#   半径随高度收缩(底 1.70 -> 顶 0.18), 整体绕 Y 轴转 —— 这就是"旋风状"。
# 【★ 三条臂怎么岔开 ★】`rotated ~120 0` 是**相对**旋转, 叠在 `rotated ~$(a) 0`
#   上面就是 a+120; 再叠一次就是 a+240。别写 `rotated ~$(a) 120`(那是俯仰角)。
# 【★ 为什么先 rotated 再 positioned ★】`positioned ^ ^ ^` 是本地坐标,
#   用的是**上一条 rotated 定下的朝向**; 顺序反了就全落在原地。
# 【★ 颜色不在这里 ★】`run function whirl_dot` 会把执行者与坐标一起带过去,
#   颜色由 whirl_dot 按 zx.sl_m 分支 —— 见那个文件里"为什么拆两层"的说明。
# 【底部三颗 cloud】贴地那圈用来"起沙", 让旋风看着像在吹地面, 不是悬空的一缕。
# ============================================================

# ---- 臂 ①: 角度 a ----
$execute rotated ~$(a) 0 positioned ^1.70 ^0.05 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^1.42 ^0.62 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^1.10 ^1.20 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^0.72 ^1.78 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^0.36 ^2.36 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 positioned ^0.14 ^2.94 ^0 run function sweetdream:equipment/staff/sail/whirl_dot

# ---- 臂 ②: 角度 a + 120 ----
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.70 ^0.05 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.42 ^0.62 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^1.10 ^1.20 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^0.72 ^1.78 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^0.36 ^2.36 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^0.14 ^2.94 ^0 run function sweetdream:equipment/staff/sail/whirl_dot

# ---- 臂 ③: 角度 a + 240 ----
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.70 ^0.05 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.42 ^0.62 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^1.10 ^1.20 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^0.72 ^1.78 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^0.36 ^2.36 ^0 run function sweetdream:equipment/staff/sail/whirl_dot
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^0.14 ^2.94 ^0 run function sweetdream:equipment/staff/sail/whirl_dot

# ---- 贴地起沙(半径拉到 2.05, 把"扫过地面"画出来) ----
$execute rotated ~$(a) 0 positioned ^2.05 ^0.02 ^0 run particle minecraft:cloud ~ ~ ~ 0.07 0.02 0.07 0.0 1 normal
$execute rotated ~$(a) 0 rotated ~120 0 positioned ^2.05 ^0.02 ^0 run particle minecraft:cloud ~ ~ ~ 0.07 0.02 0.07 0.0 1 normal
$execute rotated ~$(a) 0 rotated ~240 0 positioned ^2.05 ^0.02 ^0 run particle minecraft:cloud ~ ~ ~ 0.07 0.02 0.07 0.0 1 normal
