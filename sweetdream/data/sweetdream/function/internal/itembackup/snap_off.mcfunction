# ============================================================
# sweetdream:internal/itembackup/snap_off —— 玩家副手 -> zx:ret 快照(宏 {uuid})
# ------------------------------------------------------------
# 【为什么必须中转盔甲架】见 snap_main 头部(坑 95): 玩家的副手物品同样
#   不在 equipment 复合(实测 playerdata: equipment 只存穿戴盔甲),
#   `from entity @s equipment.offhand` = 路径不存在 ⇒ 静默失败。
# 【宏参数】zx:work a {uuid}    【执行者】玩家本人(@s)
# 【谁调用它】backup(门控: 副手有 itemreplace 武器才调)
# ============================================================

# ① 防串味: 清掉可能残留的临时架
kill @e[tag=zx.snap_tmp]

# ② 就地召临时架
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.snap_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}

# ③ 玩家副手 -> 临时架主手
item replace entity @e[tag=zx.snap_tmp,limit=1] weapon.mainhand from entity @s weapon.offhand

# ④ 临时架(生物) -> 存储
$data modify storage zx:ret p."$(uuid)".offhand set from entity @e[tag=zx.snap_tmp,limit=1] equipment.mainhand

# ⑤ 收尾
kill @e[tag=zx.snap_tmp]
