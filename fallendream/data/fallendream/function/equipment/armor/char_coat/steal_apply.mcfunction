# ============================================================
# fallendream:equipment/armor/char_coat/steal_apply —— 超限·焦衣：把偷来的 20% 基础攻击力加上面板
# ------------------------------------------------------------
# 【执行者】施法者（穿超限焦衣的那个玩家）   【入参】#cc_a zx.meta = 偷到的量（×1000）
# 【谁调它】char_coat/on_skill_hit ⑧.5
# 【账本】zx.cc_ba = 已经加在面板上的量（×1000）；zx.cc_end = 到期刻（8 秒 = 160 刻）
# 【★ 重入先退旧的一份 ★】10 秒节流虽然比 8 秒长，但中途换装/掉线会让账本残留；
#   一律"先退、后加"，差值制不会漂。
# ============================================================

scoreboard players add @s zx.cc_ba 0

# ---- ① 退掉上一份（如果还在）----
scoreboard players set #cc_neg zx.meta 0
execute if score @s zx.cc_ba matches 1.. run scoreboard players operation #cc_neg zx.meta -= @s zx.cc_ba
execute if score @s zx.cc_ba matches 1.. run function fallendream:lib/uuid
execute if score @s zx.cc_ba matches 1.. run data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
execute if score @s zx.cc_ba matches 1.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.cc_ba matches 1.. run execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #cc_neg zx.meta
execute if score @s zx.cc_ba matches 1.. run function manacore:api/stats/add
scoreboard players set @s zx.cc_ba 0

# ---- ② 加上新偷到的这一份 ----
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #cc_a zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.cc_ba = #cc_a zx.meta
scoreboard players operation @s zx.cc_end = #now manacore.meta
scoreboard players add @s zx.cc_end 160
