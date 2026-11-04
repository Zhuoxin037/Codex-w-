# ============================================================
# sweetdream:equipment/armor/bearing/off —— 摘下「承」：撤属性 + 清套装状态
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 只撤自己挂过的 ★】三个账本为 0 就一条 attribute 都不发（remove 不存在的会失败）。
#   套装状态（阵成/满档记录）也一起清 —— 否则摘了腿还留着 8 秒增伤。
# ============================================================

execute if score @s zx.br_a matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:br_arm
execute if score @s zx.br_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:br_tou
execute if score @s zx.br_spd matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:br_spd

scoreboard players set @s zx.br_a 0
scoreboard players set @s zx.br_t 0
scoreboard players set @s zx.br_spd 0
scoreboard players set @s zx.br_full 0
scoreboard players set @s zx.br_zc 0
