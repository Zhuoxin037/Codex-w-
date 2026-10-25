# ============================================================
# sweetdream:equipment/sword/gousi/land —— 拉到位（宏）
# ------------------------------------------------------------
# 【执行者】玩家
# 【宏参数】sweetdream:work gs {own}
# 【结算】缓慢Ⅱ 3 秒 + 最大魔力值 ×0.12 的伤害 + 自身 zx.mm_add +10
# 【★ 0.12 的定点算法】r.max 是 double，先 ×10 取成整数（一位小数），
#   再 ×12 ÷1000 = ×0.12。避免 12 点精度全丢（直接 ÷100 会把 48 变成 4）。
# ============================================================
$effect give @e[tag=zx.gs_$(own)] minecraft:slowness 3 1 true

function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run function sweetdream:equipment/sword/gousi/land_hit with storage zx:work gs
execute if data storage zx:data self{ok:1b} run scoreboard players add @s zx.mm_add 10

$execute at @e[tag=zx.gs_$(own),limit=1] run particle minecraft:crit ~ ~0.9 ~ 0.5 0.6 0.5 0.1 20 normal
$execute at @e[tag=zx.gs_$(own),limit=1] run particle minecraft:enchanted_hit ~ ~0.9 ~ 0.4 0.5 0.4 0.08 12 normal
$execute at @e[tag=zx.gs_$(own),limit=1] run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.9 1.0
$execute at @e[tag=zx.gs_$(own),limit=1] run playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.4 1.6

$tag @e[tag=zx.gs_$(own)] remove zx.gs_$(own)
scoreboard players set @s zx.gs_st 0
scoreboard players set @s zx.gs_own 0
