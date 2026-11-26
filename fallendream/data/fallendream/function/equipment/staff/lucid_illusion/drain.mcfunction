# ============================================================
# fallendream:equipment/staff/lucid_illusion/drain —— 清醒与幻觉：额外法球的反噬
# ------------------------------------------------------------
# 【执行者】玩家   【文案】每额外生成一个，自身每秒受到相当于自身最大生命值 ×0.08×X 的伤害
# 【★ 真伤 ★】文案没写"真实伤害"，但这是"自身受到"的反噬，且必须绕开护甲/减伤
#   才符合"每多一个球就更疼"的设计意图（同 肉盾/牺牲 的自伤口径）。
# 【★ 不改玩家 Health ★】原版禁止，走 damage + fallendream:parallel_true_damage。
# ============================================================

function fallendream:lib/max_health_score

# 千分比倍率 = 80 × X（0.08 × X）
scoreboard players set #li_m zx.meta 80
scoreboard players operation #li_m zx.meta *= @s zx.li_x

scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players operation #mp_mul zx.meta = #li_m zx.meta
function fallendream:lib/math/mul_permille
execute store result storage zx:work li.v double 0.001 run scoreboard players get #mp_out zx.meta

function fallendream:equipment/staff/lucid_illusion/self_hurt with storage zx:work li

# 【2026-11-01 补：让"正在反噬"持续可见】
#   超限法球是纯计分项，没有任何实体/掉落物可看。原来每秒只有一次结算动画，
#   玩家分不清"掉血是因为超限"还是"被别的东西打了"。
#   这里每人每秒冒紫点，数量随超限球数走（1/2/3 个球 = 4/7/10 点）。
#   ★ particle 的 count 只能是整数字面量，不能挂计分项，所以按档各写一条。
execute if score @s zx.li_x matches 1 at @s run particle minecraft:witch ~ ~1 ~ 0.45 0.6 0.45 0.02 4 normal
execute if score @s zx.li_x matches 2 at @s run particle minecraft:witch ~ ~1 ~ 0.45 0.6 0.45 0.02 7 normal
execute if score @s zx.li_x matches 3.. at @s run particle minecraft:witch ~ ~1 ~ 0.45 0.6 0.45 0.02 10 normal
