# ============================================================
# sweetdream:equipment/tool/wrath/give —— 给一件「愠怒」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"wrath" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["wrath"]}]
# 【数值要和实现对上】血量低于 20% -> 常态抗性提升Ⅰ + 最大魔力值技能伤害 +20%(独立乘区)。
# 【★ 效果已实装(2026-10-06 晚)】
#   抗性: equipment/tool/wrath/second(+second_one) —— 每秒按血量续 2 秒抗性Ⅰ。
#   伤害: equipment/tool/wrath/hook_calc(挂 #manacore:event/damage_calc),
#     按通道判 —— 只乘 max_mana_mul 那条通道的技能, r.damage ×1.20(独立乘区)。
#   血量判据复用 equipment/tool/wrath/low_hp(Health×100 对比 max_health×100)。
#   面板: equipment/tool/wrath/scan_mul(由 lib/skill_mul/scan ②¾¾ 调用) ——
#     折的是面板「独立乘区」那一行(pl.independent_multiplier), **不是**通道倍率行。
# 【★ "常态" = 条件满足期间一直续】血量回到 20% 以上就不续, 最多 2 秒自然过期。
# 【"独立乘区"】乘的是最终 r.damage(所有加成算完之后再乘一次), 不是丢进加法槽。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"愠怒",bold:true,color:dark_red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，若自身血量低于 20%，则自","color":"gray","italic":false},{"text":"身获得常态的抗性提升Ⅰ，之后自身有关","color":"gray","italic":false},{"text":"最大魔力值的技能伤害提升 20%","color":"gray","italic":false},{"text":"（独立乘区）。","color":"gray","italic":false}],custom_data={zx:["wrath","tool"]}]
