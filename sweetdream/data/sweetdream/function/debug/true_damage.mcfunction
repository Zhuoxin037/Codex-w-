# ============================================================
# sweetdream:debug/true_damage —— "真实伤害"为什么打不出来?
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/true_damage
# 【它查三件事】
#   ① sweetdream:true_damage 这个伤害类型**有没有真的注册进世界**
#   ② 最近一次 /damage 用的数字、类型、打向谁对不对
#   ③ 那一次 /damage 成功没有(0 = 命令没跑成)
#
# 【★ 最可能的结论 ★】没看到绿色的「① 已注册 ✓」→ 类型没注册。
#   damage_type 属于**注册表**内容, 只在**进世界**时加载一次, /reload 不会补上。
#   新增 true_damage 之后必须**退出世界重进**(不是 /reload、也不是重启客户端),
#   之后永久生效。
# 【为什么 ① 放在最后】探测这个动作本身就带着那个类型 —— 类型不在时, 探测用的
#   那个函数(Minecraft 里一个函数有一行解析不了就整体不跑)会整个不执行, 所以
#   绿色那行会缺席。把探测放最后, 是为了"缺席"这件事本身好读: 前面该打的都打完了。
#   详见 sweetdream:debug/true_damage_probe。
# 【如果 ① 是「已注册」但仍然没伤害】按顺序看:
#   · ② 的数字是 0        -> 上游数值没算出来(面板 base_attack 读不到 / 计分板是 0)
#   · ③ 是 0              -> 那一次的目标没匹配上, 或类型在这次调用时才出问题
#   · ② 有值且 ③ 是 1     -> 伤害打出去了; 觉得"没伤害"可能是被护甲/抗性吃掉
#                            (true_damage 走了 bypasses_armor, 但抗性提升吃不掉)
# ============================================================

tellraw @s [{"text":"===== 真实伤害自检 =====","color":"gold","bold":true}]

# ② 最近一次 /damage 的参数
execute if data storage zx:data last.num run tellraw @s [{"text":"② 最近一次: 数字 ","color":"gray"},{"nbt":"last.num","storage":"zx:data","color":"white"},{"text":"   类型 ","color":"dark_gray"},{"nbt":"last.type","storage":"zx:data","color":"white"}]
execute if data storage zx:data last.target run tellraw @s [{"text":"   打向: ","color":"gray"},{"nbt":"last.target","storage":"zx:data","color":"white"}]
execute unless data storage zx:data last.num run tellraw @s [{"text":"② 还没有任何 /damage 被调用过 —— 说明链路压根没走到","color":"red"}]

# ③ 那一次的成败
tellraw @s [{"text":"③ 那次 /damage 是否成功 ","color":"gray"},{"score":{"name":"#dbg_dmg","objective":"zx.meta"},"color":"white"},{"text":"   (1=成功 0=失败; 目标多只时只看最后一只)","color":"dark_gray"}]

# ④ 谁在用这个类型
tellraw @s [{"text":"用 true_damage 的只有两处: 异彩的效果二(无来源真实伤害) 和 幻昼的时停结束伤害","color":"dark_gray"}]
tellraw @s [{"text":"其它技能走 sweetdream:skill(已注册), 所以只有这两处会一起没伤害","color":"dark_gray"}]

# ① 探测(放最后, 见文件头说明)
tellraw @s [{"text":"① 探测伤害类型…… 下面如果","color":"gray"},{"text":"没有","color":"yellow"},{"text":"出现绿色一行, 就是这个类型","color":"gray"},{"text":"没注册进这个世界","color":"red"},{"text":" → 退出世界再重进一次(/reload 不行)","color":"yellow"}]
data modify storage zx:work tp set value {type:"sweetdream:true_damage"}
function sweetdream:debug/true_damage_probe with storage zx:work tp
