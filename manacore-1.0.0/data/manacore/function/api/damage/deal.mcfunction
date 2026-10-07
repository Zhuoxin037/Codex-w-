# ============================================================
# api/damage/deal —— 一步完成"算伤害 + 打伤害"
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", attack_mul:3.0,
#       custom_damage:5.0, target:"@e[tag=mana_target,distance=..6,limit=1]"}
#   function manacore:api/damage/deal
# 【字段】= calc 的全部字段 + target/type/from
#   倍率三条通道: max_mana_mul / attack_mul / other_mul(详见 api/damage/calc)
# 【出参】out.damage(算出的伤害)。没给 target 时只算不打。
# 【什么时候用】技能效果很简单(就是打一下)时用 deal;
#   要复杂流程(位移/多段/条件分支)时建议 calc + apply 分开调。
# ============================================================
data modify storage manacore:work a set value {uuid:"",base_attack:-1.0,other_base:-1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0,damage:0.0,target:"",type:"minecraft:player_attack"}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid run function manacore:internal/damage/deal with storage manacore:work a
