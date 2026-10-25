# ============================================================
# sweetdream:equipment/axe/deep_brine/field_end_go —— 领域结束时那一下"超大力"拉动(宏)
# ------------------------------------------------------------
# 【谁调用它】field_end ②: function ... with storage zx:work dbr
# 【宏参数】zx:work dbr {r}
# 【执行者】领域 marker   【位置】领域中心
# 【只有超限领域才拉】`execute if entity @s[tag=zx.db_olm]` 挡在最前面 —— 普通版
#   (半径 3、持续 4 秒的那些) 结束时不该多这一下。
# 【2.5 格怎么来的】普通每秒 0.5 格, 这里 5 倍 = 明摆着的"超大力"。
# ============================================================

# ① 钉住圆心(临时标签, 立刻摘)
tag @e[tag=zx.db_ec,distance=0..] remove zx.db_ec
tag @s add zx.db_ec

# ② 超限领域: 半径内(离中心 0.5 格以上, 免得贴脸那只朝向退化)全部猛拉一次
$execute if entity @s[tag=zx.db_olm] as @e[type=!#sweetdream:no_damage,distance=0.5..$(r)] at @s facing entity @e[tag=zx.db_ec,distance=0..,limit=1] feet positioned ^ ^ ^2.5 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~

# ③ 表现: 一下猛吸的水压 + 收尾
$execute if entity @s[tag=zx.db_olm] run particle minecraft:bubble ~ ~0.4 ~ $(r) 0.4 $(r) 0.15 40 normal
$execute if entity @s[tag=zx.db_olm] run particle minecraft:splash ~ ~0.2 ~ $(r) 0.2 $(r) 0.05 24 normal
execute if entity @s[tag=zx.db_olm] run playsound minecraft:block.conduit.attack player @a ~ ~ ~ 1.0 0.6
tag @e[tag=zx.db_ec,distance=0..] remove zx.db_ec
