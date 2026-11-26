# ============================================================
# fallendream:equipment/armor/rebirth_veil/regen_one —— 超限·复纱：每秒回 8% 生命
# ------------------------------------------------------------
# 【执行者】玩家  【调用】batch21/player_tick(每刻判 rbv_rg_next 到期)
# 【文案】之后本我者和同生体每秒恢复 8% 生命值，持续 4 秒。
#   ★ "本我者和同生体"是同一个玩家的两种形态(j_form 0/1), 同一刻只有一个在场上,
#     所以给玩家自己回就同时覆盖了两者; 沉睡的本我者(j_body)是 Invulnerable 的
#     替身实体, 给它回血没有意义。
# 【★ 8% 走 lib/heal 的整点入参 ★】#max_hp 是 ×1000 定点, 先 ×8 ÷100 再交进去;
#   两个乘除都夹 INT32 上界(见 mm_add 的说明)。
# ============================================================

execute unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run scoreboard players set @s zx.rbv_rg_end 0
execute unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run return 0

function fallendream:lib/max_health_score
scoreboard players set #rbv_8 zx.meta 8
scoreboard players set #rbv_100 zx.meta 100
scoreboard players set #rbv_cap zx.meta 2147483647
scoreboard players operation #rbv_cap zx.meta /= #rbv_8 zx.meta
scoreboard players operation #rbv_pt zx.meta = #max_hp zx.meta
execute if score #rbv_pt zx.meta > #rbv_cap zx.meta run scoreboard players operation #rbv_pt zx.meta = #rbv_cap zx.meta
scoreboard players operation #rbv_pt zx.meta *= #rbv_8 zx.meta
scoreboard players operation #rbv_pt zx.meta /= #rbv_100 zx.meta

# 极低上限时 8% 会取整成 0 —— 保底 1 点, 否则"每秒恢复"整段是空转
execute if score #rbv_pt zx.meta matches ..0 run scoreboard players set #rbv_pt zx.meta 1
scoreboard players operation #heal_pt zx.meta = #rbv_pt zx.meta
function fallendream:lib/heal

scoreboard players operation @s zx.rbv_rg_next = #now manacore.meta
scoreboard players add @s zx.rbv_rg_next 20
