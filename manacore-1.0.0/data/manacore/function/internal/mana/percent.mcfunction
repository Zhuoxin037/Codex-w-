# ------------------------------------------------------------
# internal/mana/percent —— 当前魔力百分比
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.value = current / max (0..1 的小数, x1000 定点后还原)
# 【除零保护】max <= 0 时直接返回 0, 不会调用 percent_calc。
# 【用途】做魔力条 UI: 只要把 out.value 乘上条长即可。
# ------------------------------------------------------------
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
$execute store result score #max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
scoreboard players set #pct manacore.math 0
execute if score #max manacore.math matches 1.. run function manacore:internal/mana/percent_calc
execute store result storage manacore:out r.value double 0.001 run scoreboard players get #pct manacore.math
