# ============================================================
# sweetdream:equipment/tool/nullify/give —— 给一件「无效」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"nullify" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["nullify"]}]
# 【数值要和实现对上】召唤术阵后, 下一次最大魔力值技能伤害 +20%(不可叠加)。
# 【★ 效果已实装(2026-10-06 晚)★】
#   · "若自身召唤了一个术阵" -> 挂前置包事件 #manacore:event/formation_create
#     (equipment/tool/nullify/{on_create,on_create_go} 只按 ctx.uuid 记一个标记 ——
#      事件里没有玩家实体, 判不了副手, 所以判定与兑现挪到 second/on_second)。
#   · "+20% 下一次最大魔力值技能" -> 2026-10-07 起并入全包通用的
#     「最大魔力值技能倍率」加成槽 zx.mm_add(风行「风声」、
#     套装「忘川彼岸」也用它), 由 lib/mm_add/hook_calc 在每次
#     api/damage/calc 时折进 mm 加算池; 拿到后一直挂着, 打出一次
#     最大魔力值技能时清零(见 lib/mm_add/take)。
#     (旧版那个 zx:data wg_bonus + lib/max_mana_bonus 的一次性槽位已整体去掉。)
#   · "不可叠加" = 已有 mm_add 时不写(照 armor/lethe_shore/set_bonus 的定式)。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"无效",bold:true,color:dark_gray},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身若召唤了一个术阵，则","color":"gray","italic":false},{"text":"自身下一次有关最大魔力值的技能伤害提","color":"gray","italic":false},{"text":"升 20%（不可叠加）。","color":"gray","italic":false}],custom_data={zx:["nullify","tool"],tags:["max_mana","formation","indep_mul"]},minecraft:item_model="sweetdream:tool_nullify"]
