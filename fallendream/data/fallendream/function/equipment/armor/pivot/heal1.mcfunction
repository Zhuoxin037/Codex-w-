# ============================================================
# fallendream:equipment/armor/pivot/heal1 —— 恢复 1% 最大生命值
# ------------------------------------------------------------
# 【执行者】玩家   【出参】#heal_pt(交给 lib/heal)
# 【★ 至少 1 点 ★】1% 对 20 血玩家 = 0.2, 整数除法会得到 0, lib/heal 遇到 0 直接
#   返回 ⇒ "召唤术阵回血"看起来完全没生效。所以下限夹到 1。
# ============================================================
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #heal_pt zx.meta 0
execute store result score #heal_pt zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
execute if score #heal_pt zx.meta matches ..0 run scoreboard players set #heal_pt zx.meta 1
function fallendream:lib/heal
