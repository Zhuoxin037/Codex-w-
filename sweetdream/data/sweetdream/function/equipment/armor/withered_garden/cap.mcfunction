# ============================================================
# sweetdream:equipment/armor/withered_garden/cap —— 朽木数量上限(同一释放者 3 棵)
# ------------------------------------------------------------
# 【宏参数】u0..u3(施法者 UUID 的四个 32 位 int;
#   由调用处 `with storage zx:work cp` 绑定 —— 键名必须和 data.zx.gd 一致)
# 【干什么】数一下这个玩家名下现有几棵朽木; 已有 3 棵 → 把**最早召唤**的那棵 kill
#   (所有朽木寿命都是 8 秒 → zx.gw_end 越小 = 越早 = 先来后到)。
# 【为什么按 UUID 过滤】"最多 3 个"是**每人**的份额, 不能拿全局数量封顶 ——
#   不然两个人一起穿, 先施法的人会被后施法的人挤掉朽木。
# 【NBT 匹配】data.zx.gd{u0:..,u1:..,u2:..,u3:..} 是 compound 部分匹配:
#   只比对这四个键, uuid 字符串不用管 —— 四个 int 合起来就等价于 UUID。
# 【假玩家】#gw_n / #gw_old 挂在公共 zx.meta 上, 只在本函数内同步使用, 不会串。
# ============================================================

# ① 数一数名下现有几棵
scoreboard players set #gw_n zx.meta 0
$execute as @e[tag=zx.gw_wood] if data entity @s data.zx.gd{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} run scoreboard players add #gw_n zx.meta 1

# ② 不到 3 棵 → 直接放行
execute if score #gw_n zx.meta matches ..2 run return 0

# ③ 已有 3 棵 → 找最早那棵(gw_end 最小)并 kill
scoreboard players set #gw_old zx.meta 2147483647
$execute as @e[tag=zx.gw_wood] if data entity @s data.zx.gd{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} run scoreboard players operation #gw_old zx.meta < @s zx.gw_end
$execute as @e[tag=zx.gw_wood] if data entity @s data.zx.gd{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} if score @s zx.gw_end = #gw_old zx.meta run kill @s
