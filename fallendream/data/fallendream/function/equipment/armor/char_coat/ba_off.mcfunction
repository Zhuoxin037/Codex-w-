# ============================================================
# fallendream:equipment/armor/char_coat/ba_off —— 超限·焦衣：偷来的基础攻击力到期退还
# ------------------------------------------------------------
# 【谁调它】lib/second：`as @a[scores={zx.cc_ba=1..}]`（每秒只扫有账本的人）
# 【执行者】玩家
# 【★ 差值制退还 ★】按账本 zx.cc_ba（×1000）取负写回面板，然后清账。
#   不按"当时的百分比"回算 —— 期间面板可能被别的装备改过。
# ============================================================

execute if score @s zx.cc_end > #now manacore.meta run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
scoreboard players set #cc_neg zx.meta 0
scoreboard players operation #cc_neg zx.meta -= @s zx.cc_ba
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #cc_neg zx.meta
function manacore:api/stats/add

scoreboard players set @s zx.cc_ba 0
scoreboard players set @s zx.cc_end 0
