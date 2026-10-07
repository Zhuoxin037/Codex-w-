# ============================================================
# sweetdream:equipment/armor/lightless_sea/cap —— 暗潮数量上限(同一释放者 3 片)
# ------------------------------------------------------------
# 【宏参数】u0..u3(施法者 UUID 的四个 32 位 int;
#   由调用处 `with storage zx:work cp` 绑定 —— 键名必须和 data.zx.ls 一致)
# 【干什么】数一下这个玩家名下现有几片暗潮; 已有 3 片 → 把**最早召唤**的那片 kill
#   (所有暗潮寿命都是 8 秒 → zx.ls_end 越小 = 越早 = 先来后到)。
# 【为什么按 UUID 过滤】"最多 3 个"是**每人**的份额, 不能拿全局数量封顶 ——
#   不然两个人一起穿, 先施法的人会被后施法的人挤掉暗潮。
# 【假玩家】#ls_n / #ls_old 挂在公共 zx.meta 上, 只在本函数内同步使用, 不会串。
# ============================================================

# ① 数一数名下现有几片
scoreboard players set #ls_n zx.meta 0
$execute as @e[tag=zx.ls_tide] if data entity @s data.zx.ls{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} run scoreboard players add #ls_n zx.meta 1

# ② 不到 3 片 → 直接放行
execute if score #ls_n zx.meta matches ..2 run return 0

# ③ 已有 3 片 → 找最早那片(ls_end 最小)并 kill
scoreboard players set #ls_old zx.meta 2147483647
$execute as @e[tag=zx.ls_tide] if data entity @s data.zx.ls{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} run scoreboard players operation #ls_old zx.meta < @s zx.ls_end
$execute as @e[tag=zx.ls_tide] if data entity @s data.zx.ls{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} if score @s zx.ls_end = #ls_old zx.meta run kill @s
