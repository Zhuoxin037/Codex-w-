# ============================================================
# sweetdream:equipment/bow/sculk_echo/path_roll —— 悲鸣三倍判定(路径每刻伤用)
# ------------------------------------------------------------
# 【谁调它】tick_live ⑤; #se_pcry = 本发悲鸣值, #se_pdmg = 路径伤(×100 定点)
# 【判定】同 fire 的 roll_triple: #rnd % 除数, 若 < 悲鸣值则三倍 + 清射手悲鸣。
#   ★ 除数 = **100**(基础: 每点 1%) / **200**(超限: 每点 0.5%); 读箭自带快照的 ol。
# 【执行者】那支箭(@s = 箭), 用箭自带 u0..u3 反查射手。
# ============================================================

execute if score #se_pcry zx.meta matches ..0 run return 0
function sweetdream:lib/rnd
scoreboard players set #se_ptry zx.meta 0
scoreboard players operation #se_ptry zx.meta = #rnd zx.meta
scoreboard players set #se_ol zx.meta 0
execute store result score #se_ol zx.meta run data get entity @s data.zx.se.ol 1
scoreboard players set #se_div zx.meta 100
execute if score #se_ol zx.meta matches 1 run scoreboard players set #se_div zx.meta 200
scoreboard players operation #se_ptry zx.meta %= #se_div zx.meta
execute unless score #se_ptry zx.meta < #se_pcry zx.meta run return 0

# 触发: 三倍
scoreboard players set #3 zx.meta 3
scoreboard players operation #se_pdmg zx.meta *= #3 zx.meta

# 清除射手的悲鸣(用箭自带 u0..u3 反查)
data modify storage zx:work se_clear set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work se_clear.u0 int 1 run data get entity @s data.zx.se.u0
execute store result storage zx:work se_clear.u1 int 1 run data get entity @s data.zx.se.u1
execute store result storage zx:work se_clear.u2 int 1 run data get entity @s data.zx.se.u2
execute store result storage zx:work se_clear.u3 int 1 run data get entity @s data.zx.se.u3
function sweetdream:equipment/bow/sculk_echo/clear_cry with storage zx:work se_clear
