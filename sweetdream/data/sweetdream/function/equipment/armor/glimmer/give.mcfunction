# ============================================================
# sweetdream:equipment/armor/glimmer/give —— 给一件「浮光」（传说 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"glimmer" -> 装备 id; 判定写 custom_data~{zx:["glimmer"]}
# 【机制·★ 以用户 2026-10-25 16:53 原稿为准 ★】红/绿/黄三色随机 + 集齐转白:
#   ① 8 秒未受伤 ⇒ **随机**获得一种光效(红/绿/黄, 等概率, 重复不叠);
#   ② 红: 技能伤害 +20%; 绿: 每秒 1% 最大生命 + 0.5% 最大魔力; 黄: 移速 +20%, 最近 3 个生物 -40%;
#   ③ 三色集齐 ⇒ 全部转白: 技能伤害 +30%(独立乘区), 每秒 3% 生命 + 0.8% 魔力, 移速 +30%,
#      最近 5 个生物 -45%, 每 3 秒对 5 格内随机 4 个生物附加「白昼梦」并时停 1 秒;
#   ④ 自身生命值减少 ⇒ **失去全部光效**(不是碎一道)。
# 【★ 实装必读 ★】
#   ① 「光效」「回光」是**私有资源**，不进标签词表（状态只有五个）。
#   ② 上上版(碎光/合光/暗期)与上版(优先补缺色)都是我自编的，已全部作废 —— 别再复活。
# 【外观】未画（无 item_model / equippable）。
# ============================================================
give @s netherite_helmet[item_name={text:"浮光",bold:true,color:yellow},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +180。自身若 8 秒内没","color":"gray","italic":false},{"text":"有受到伤害则自身随机获得一种光效。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 光效","color":"gold","bold":true,"italic":false},{"text":"● 红：自身技能伤害 +20%。","color":"gray","italic":false},{"text":"● 绿：自身每秒恢复 1% 最大生命值与","color":"gray","italic":false},{"text":"   0.5% 最大魔力值。","color":"gray","italic":false},{"text":"● 黄：自身移动速度 +20%，离自身最近","color":"gray","italic":false},{"text":"   的 3 个生物移速 -40%。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 白光","color":"gold","bold":true,"italic":false},{"text":"当全部光效集齐后则全部转变为白，持续","color":"gray","italic":false},{"text":"12 秒后清除全部光效：自身技能伤害","color":"gray","italic":false},{"text":"+30%（独立乘区），自身每秒恢复 3% 最","color":"gray","italic":false},{"text":"大生命值与 0.8% 最大魔力值，自身移动","color":"gray","italic":false},{"text":"速度 +30%，离自身最近的 5 个生物移速","color":"gray","italic":false},{"text":"-45%，每 3 秒对自身 5 格内的随机 4 个","color":"gray","italic":false},{"text":"生物附加「白昼梦」并使其时停 1 秒。自","color":"gray","italic":false},{"text":"身生命值减少后则失去全部光效。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 浮光","color":"gray","italic":false},{"text":"● 迟暮","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +50。自身消耗「回光」","color":"gray","italic":false},{"text":"后使立即获得一种光效。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["glimmer","helmet","armor"],tags:["dream","max_mana","cur_mana","indep_mul","heal","buff","debuff"]},tooltip_display={hidden_components:["unbreakable"]}]
