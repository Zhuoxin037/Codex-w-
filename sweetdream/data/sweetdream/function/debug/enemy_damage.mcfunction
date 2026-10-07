# ============================================================
# sweetdream:debug/enemy_damage —— 「敌方技能伤害」通道自检(会真的打一下)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/enemy_damage
# 【它做什么】对 8 格内最近的一只生物打 **1.0** 点 src="enemy" 的技能伤害,
#   然后把接口出参打回聊天栏(重点看 src 是不是 enemy)。
# 【怎么验证标签分流】
#   · 给那只生物贴「夜火」(function sweetdream:tag/mark {target:"@e[...]",mark:"yehuo"})
#     -> 它实际会掉 **1.15** 血(受技能伤 +15%)。
#     ⚠️ 面板上的 r.damage 是**加乘前的基数**(api/damage 在逐目标处理之前就写好了),
#        所以别拿它当"最终伤害"看 —— 要看得看那只生物掉了几格血。
#   · 「噬心」不受影响(它只认真实伤害)。
#   · 「白昼梦」减的是**施法者自己**的技能伤害 —— 玩家当施法者时恒不触发;
#     要验它得让带白昼梦的怪当施法者。
# 【★ 它是"预留通道"的第一手验证 ★】敌方技能实装后, 官方路径就是
#   `zx:in arg` + `function sweetdream:api/enemy_damage`, 与这里一模一样。
# ============================================================

tellraw @s [{"text":"===== 敌方技能伤害通道自检 =====","color":"gold","bold":true}]

# 先钉死"这一只"(sort=nearest 每次求值都会重挑, 不能在同一条链里引用两次)
tag @e[type=!#sweetdream:no_damage,distance=..8,sort=nearest,limit=1] add zx.ed_t
scoreboard players set #ed_ok zx.meta 0
execute if entity @e[tag=zx.ed_t,limit=1] run scoreboard players set #ed_ok zx.meta 1
scoreboard players set #ed_ye zx.meta 0
execute if entity @e[tag=zx.ed_t,tag=zx.status.yehuo] run scoreboard players set #ed_ye zx.meta 1
tellraw @s [{"text":"8 格内有目标? ","color":"gray"},{"score":{"name":"#ed_ok","objective":"zx.meta"},"color":"white"},{"text":"   它带夜火? ","color":"gray"},{"score":{"name":"#ed_ye","objective":"zx.meta"},"color":"red"}]

data modify storage zx:in arg set value {target:"@e[tag=zx.ed_t]",damage:1.0}
function sweetdream:api/enemy_damage
tag @e[tag=zx.ed_t] remove zx.ed_t

tellraw @s [{"text":"applied ","color":"gray"},{"nbt":"r.applied","storage":"zx:out","color":"yellow"},{"text":"   src ","color":"dark_gray"},{"nbt":"r.src","storage":"zx:out","color":"aqua"},{"text":"   基数 ","color":"dark_gray"},{"nbt":"r.damage","storage":"zx:out","color":"white"}]
tellraw @s [{"text":"  src 应为 enemy; 目标带夜火时应掉 1.15 血(基数不含标签加乘)","color":"dark_gray"}]
