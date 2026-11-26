# ============================================================
# fallendream:equipment/armor/cease_war/deb_off —— 止战(超限)：摘掉目标身上的 -20% 护甲/韧性
# ------------------------------------------------------------
# 【谁调它】lib/second 的三维度扫描 `as @e[tag=zx.cw_deb]`
# 【执行者】被扣了护甲的那只生物
# 【何时】zx.cw_deb_end（= 施加者那一次余勇的结束刻）已经过去
# 【★ 为什么不是"余勇 end 时去扫一遍" ★】
#   end 可能在玩家死亡/换职业时被调起，那时执行者已经离开原地、甚至已不是玩家；
#   而"余勇结束"这件事对每只受害者都是一样的截止时刻，把时间写在受害者自己身上
#   最省事，也不受 end 的上下文影响。
# ============================================================

execute if score @s zx.cw_deb_end matches 1.. if score @s zx.cw_deb_end > #now manacore.meta run return 0

attribute @s minecraft:armor modifier remove fallendream:cw_deb
attribute @s minecraft:armor_toughness modifier remove fallendream:cw_deb_t
tag @s remove zx.cw_deb
scoreboard players set @s zx.cw_deb_end 0
