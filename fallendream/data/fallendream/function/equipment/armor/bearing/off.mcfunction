# ============================================================
# fallendream:equipment/armor/bearing/off —— 摘下「承」：撤属性 + 清套装状态
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 只撤自己挂过的 ★】三个账本为 0 就一条 attribute 都不发（remove 不存在的会失败）。
#   套装状态（阵成/满档记录）也一起清 —— 否则摘了腿还留着 8 秒增伤。
# 【★ br_spd 现在是"档位"不是 0/1 ★】超限档是 2(8%)，所以判 `matches 1..`。
# ============================================================

execute if score @s zx.br_a matches 1.. run attribute @s minecraft:armor modifier remove fallendream:br_arm
execute if score @s zx.br_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove fallendream:br_tou
execute if score @s zx.br_spd matches 1.. run attribute @s minecraft:movement_speed modifier remove fallendream:br_spd

scoreboard players set @s zx.br_a 0
scoreboard players set @s zx.br_t 0
scoreboard players set @s zx.br_spd 0
scoreboard players set @s zx.br_full 0
scoreboard players set @s zx.br_zc 0

# 超限账本一并清掉（保留窗口/满计数/自演阵成），否则下次穿回来会带着旧窗口
scoreboard players set @s zx.brx_ol 0
scoreboard players set @s zx.brx_keep 0
scoreboard players set @s zx.brx_kn 0
scoreboard players set @s zx.brx_hold 0
scoreboard players set @s zx.brx_zc 0
scoreboard players set @s zx.brx_cd 0
scoreboard players set @s zx.brx_pu 0
scoreboard players set @s zx.brx_pn 0
