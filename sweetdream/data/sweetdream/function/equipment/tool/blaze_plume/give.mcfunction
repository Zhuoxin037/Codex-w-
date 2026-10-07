# ============================================================
# sweetdream:equipment/tool/blaze_plume/give —— 给一件「炽翎」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"blaze_plume" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["blaze_plume"]}]
# 【数值要和实现对上】攻击燃烧中的目标 -> 燃烧时间 +1 秒;
#   攻击带「流火」的目标 -> 使其燃烧 1 秒(是"给 1 秒"不是"+1 秒")。
# 【★ 效果已实装(2026-10-06 深夜)★】hit + find_victim 就位; 进度
#   sweetdream:equipment/tool/blaze_plume_hit(player_hurt_entity + is_player_attack)
#   驱动, 已登记进 lib/rearm。定位受害者复用 styx_walk 的 last_hurt_by_player 手法,
#   但标签用自己的 zx.bp_t。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键(见 thunder/give 注释)。
# 【两条是独立的】燃烧目标和「流火」目标分别判, 不是"既要燃烧又要流火"。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"炽翎",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身攻击处于燃烧状态的生","color":"gray","italic":false},{"text":"物后会使其燃烧状态 +1 秒。攻击有","color":"gray","italic":false},{"text":"「流火」效果的生物时使其燃烧 1 秒。","color":"gray","italic":false}],custom_data={zx:["blaze_plume","tool"]}]
