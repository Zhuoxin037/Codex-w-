# ============================================================
# fallendream:equipment/armor/breath_hold/regen —— 把本秒回魔量打进魔力面板
# ------------------------------------------------------------
# 【执行者】玩家   【入参】#bh_re = 回魔量(单位 1/1000 点)
# 【量纲】两档统一成 1/1000: 基础 2 点 = 2000 / 超限 0.5% 也是 ×1000 定点
#   ⇒ 这里只需要一种换算(×0.001), 不必再分支。
# ============================================================
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bh_re zx.meta
function manacore:api/mana/add
