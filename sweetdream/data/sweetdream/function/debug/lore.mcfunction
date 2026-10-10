# ============================================================
# sweetdream:debug/lore —— 重刷**副手**物品的描述(lore)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/lore    （物品拿在副手）
# 【什么时候用】世界里已经敲过升级 / 超限的老物品, 它们的描述是**旧版**规则
#   写的(那时候超限只追加一行, 不会整段换掉)。改完规则之后老物品不会自己变,
#   用它刷一遍就行 —— 不用重新给、也不用重新敲。
# 【它做的事】副手 -> **临时盔甲架** -> station/api/lore_refresh -> 回到副手。
#   和敲装备走的是同一条重建线, 所以结果是幂等的: 刷几次都一样。
# 【★ 不会白吃材料 ★】这里不调 fit, 也不动 up / ol, 只重建描述。
# 【★ 不在世界里放任何方块 ★】(2026-10-08 改)
#   以前这里借的是强化台那个 0,-59,2 的箱子(没有就现场 setblock 一个)。
#   那个箱子是上古版本"用箱子做强化台"的残留, 已经整条删掉了 —— 现在和
#   station/api/apply_go 一样用临时盔甲架中转(见 apply_go 头注释)。
# ============================================================

execute unless items entity @s weapon.offhand * run tellraw @s [{"text":"[调试] 副手是空的 —— 把要刷新描述的装备拿在副手","color":"red"}]
execute unless items entity @s weapon.offhand * run return 0

kill @e[tag=zx.st_tmp]
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.st_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}
item replace entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand from entity @s weapon.offhand

execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run kill @e[tag=zx.st_tmp]
execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run return 0

#   (本函数已经没有宏参数了 —— 改哪一件全靠 zx.st_tmp 这个中转架认, 不用再传坐标)
function sweetdream:station/api/lore_refresh

execute if items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run item replace entity @s weapon.offhand from entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand
kill @e[tag=zx.st_tmp]

tellraw @s [{"text":"[调试] 副手物品的描述已按当前规则重建","color":"green"}]
