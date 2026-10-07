# ============================================================
# sweetdream:equipment/tool/seraph_wing/give —— 给一件「炽天使之翼」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"seraph_wing" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["seraph_wing"]}]
# 【数值要和实现对上】基础攻击力类技能伤害 +50%。
# 【★ 效果已实装(2026-10-06 晚)】
#   结算: equipment/tool/seraph_wing/hook_calc(挂 #manacore:event/damage_calc),
#     按通道判 —— 只乘 attack_mul 那条通道的技能, 伤害 ×1.50(加算)。
#   面板: equipment/tool/seraph_wing/scan_mul(由 lib/skill_mul/scan ②¾½ 调用)。
# 【★ 注意口径】是"**有关基础攻击力**的技能"伤害 +50%, 不是全部技能 +50%。
#   包里技能分两类通道: 基础攻击力(atk) 和 最大魔力值(mm) —— 本件只吃前者。
#   (对照: 愠怒 wrath 吃的是后者。) 判据见 hook_calc 头注释。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"炽天使之翼",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身有关基础攻击力的技能","color":"gray","italic":false},{"text":"伤害提升 50%。","color":"gray","italic":false}],custom_data={zx:["seraph_wing","tool"]}]
