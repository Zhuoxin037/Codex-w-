# ============================================================
# sweetdream:overlimit/api/fit —— 这块超限石能不能敲到副手这把武器上
# ------------------------------------------------------------
# 【入参】zx:work st {of:"<武器id>"}   —— 石头上写着自己属于哪把武器
# 【出参】zx:out r = {ok:1b/0b, reason:"no_def|wrong_weapon|already"}
# 【三条规则】① 定义表里有这把武器的超限 ② 副手武器的 zx 里**有**这个武器 id
#             ③ 它还没敲过超限(没有 custom_data.ol)
# ============================================================

data modify storage zx:out r set value {ok:0b,reason:""}
$execute unless data storage zx:config oldef."$(of)" run data modify storage zx:out r.reason set value "no_def"
$execute unless data storage zx:config oldef."$(of)" run return 0
$execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(of)"]}] run data modify storage zx:out r.reason set value "wrong_weapon"
$execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(of)"]}] run return 0
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{ol:"$(of)"}] run data modify storage zx:out r.reason set value "already"
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{ol:"$(of)"}] run return 0
data modify storage zx:out r.ok set value 1b
