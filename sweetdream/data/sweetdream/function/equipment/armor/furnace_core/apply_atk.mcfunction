# ============================================================
# sweetdream:equipment/armor/furnace_core/apply_atk —— 给基础攻击力加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值   【执行者】玩家
# 【攻击力只有一处】面板的 base_attack(技能伤害公式和 debug/stats 都读它),
#   没有对应的原版属性要同步 —— 不像生命上限那样还要改 minecraft:max_health。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.fc_atk += #diff zx.meta
