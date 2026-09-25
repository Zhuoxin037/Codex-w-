# ============================================================
# api/damage/apply —— 把指定数值的伤害打出去
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>",
#       target:"@e[tag=mana_target,distance=..6,limit=1]", damage:37.5}
#   function manacore:api/damage/apply
# 【字段】
#   target : 目标选择器(必填, 否则整个接口直接跳过)
#   damage : 伤害数值
#   type   : 伤害类型, 默认 minecraft:player_attack(按玩家平砍算, 吃护甲)
#            想穿甲就填 minecraft:magic, 想"无来源物理伤害"就填 minecraft:generic
#   from   : 攻击者选择器, 省略则按 uuid 自动推导(推不出来就用 @s)
# 【说明】内部用 /damage 命令实现, 因此支持伤害类型/击退/击杀归属。
# ============================================================
data modify storage manacore:work a set value {uuid:"",target:"",damage:0.0,type:"minecraft:player_attack"}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.target run function manacore:internal/damage/apply with storage manacore:work a
