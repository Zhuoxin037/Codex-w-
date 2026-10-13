# ============================================================
# sweetdream:equipment/bow/cloudtrail/field_spawn —— 落空的箭 -> 在箭停留处生成领域
# ------------------------------------------------------------
# 【谁调用它】core/tick 每刻: execute in <维度> as @e[distance=0..,tag=zx.ct_live,
#   nbt={inGround:1b}] at @s run function ...
#   ★ 用 inGround:1b 判"落地"(1.21.5 原版字段: 箭插进方块后变 1b), 比看 Motion 稳;
#     本包幽匿残响(se_live)用的是同一条判据(见 RULES 第 32 条)。
# 【执行者】那支**刚落地**的箭; 位置 = 箭插住的地方
# 【为什么先摘标签再干活】本函数在"每刻"的链上 —— 不摘 zx.ct_live 的话,
#   箭还插在地上, 下一 tick 又会建一个领域(领域会刷屏)。
# 【★ 命中过生物的箭不会被这里处理 ★】hook_arrow 在"箭打中生物"时就把 zx.ct_live
#   摘掉了 —— 打中了就不是"未射中", 不该留领域。这是文案的边界, 必须守住。
# ============================================================

# ⓪ 只处理"付过钱且还没落地过"的箭
execute unless entity @s[tag=zx.ct_ok] run return 0

# ① 先取射手的 uuid 文本(箭落地时手里拿什么、人在不在都不保证, 所以 uuid 随箭走)
data modify storage zx:work ctf.uu set value ""
data modify storage zx:work ctf.uu set from entity @s data.zx.ct.uu

# ② 立刻摘干净驱动标记(免得每刻重复建领域)
tag @s remove zx.ct_live
tag @s remove zx.ct_ok
data remove entity @s data.zx.ct

# ③ uuid 取不到(极端情况: 箭不是本技能射的) -> 不建领域
execute if data storage zx:work ctf{uu:""} run return 0

# ④ 在箭停留处建领域(半径 3 / 持续 5 秒, 见 field_make)
function sweetdream:equipment/bow/cloudtrail/field_make with storage zx:work ctf
