# ============================================================
# sweetdream:equipment/tool/frostmirror/give —— 给一件「冰鉴」（副手 · 过渡）
# ------------------------------------------------------------
# 【custom_data】"frostmirror" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["frostmirror"]}]
# 【数值要和实现对上】自身 3 格内最近的 1 个生物冰冻 **1 秒**; 当前**主手**装备
#   的主动技能冷却 **-1 秒**; **内置冷却 4 秒**(全局, 不看是谁打的)。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【触发链】进度 equipment/tool/frostmirror_hurt(entity_hurt_player)
#   -> on_hurt: 判副手 -> 判内置 CD -> 冰冻 + 减 CD -> 打到期时刻。
#   ★ 原版没有 is_melee 伤害类型标签(实测 1.21.5 jar 的 damage_type 标签表里
#     没有它), 所以进度**不带** damage 条件、改为在函数里"圈身边最近的生物"
#     —— 近战攻击者必然在身边; 摔落/窒息这种没有攻击者的伤害圈不到人, 自然收工。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch*.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"冰鉴",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身受到伤害后使自身 3 格","color":"gray","italic":false},{"text":"内最近的一个生物冰冻 1 秒，并使当前主","color":"gray","italic":false},{"text":"手装备的主动技能冷却时间 -1 秒。该效","color":"gray","italic":false},{"text":"果每 4 秒至多触发一次。","color":"gray","italic":false}],custom_data={zx:["frostmirror","tool"],tags:["freeze","cd_down","debuff"]},minecraft:item_model="sweetdream:tool_frostmirror"]
