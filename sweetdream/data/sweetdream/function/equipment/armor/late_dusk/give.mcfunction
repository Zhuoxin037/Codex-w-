# ============================================================
# sweetdream:equipment/armor/late_dusk/give —— 给一件「迟暮」（传说 · 护腿）
# ------------------------------------------------------------
# 【custom_data】"late_dusk" -> 装备 id; 判定写 custom_data~{zx:["late_dusk"]}
# 【机制·★ 以用户 2026-10-25 16:53 原稿为准 ★】「回光」记账 + 时停 + 伤害记录结算:
#   ① 自身给其他生物附加「白昼梦」⇒ 获得一层 8 秒「回光」（最多 3 层，重复获得刷新）;
#   ② 对附有「白昼梦」的生物造成伤害 ⇒ 消耗 1 层「回光」: 使其时停 2 秒,
#      并开始记录**接下来 5 秒**它受到的伤害;
#   ③ 5 秒后结算: 造成记录量的 30%; 若它此刻仍有「白昼梦」⇒ 消耗白昼梦 + 时停 1 秒,
#      本次伤害提升为 50%;
#   ④ 累计消耗 3 层「回光」⇒ 获得 15 秒抗性提升Ⅴ, **受到伤害立即清除**。
#   ⑤ 套装(与浮光): 魔力上限 +50; 每次消耗「回光」⇒ 立即获得一种光效(走浮光的光效池)。
# 【★ 实装必读 ★】
#   ① 「回光」是**私有资源**，不进标签词表。
#   ② 上上版(暮账/暮痕/背水)与上版(同)都是我自编的，已全部作废 —— 别再复活。
#   ③ 时停走包内既有 `zx.stop` 口径，别另造一套。
#   ④ 生命值百分比读 criterion 的 zx.hp_c（免费），**不要** `data get entity Health`。
# 【外观】未画（无 item_model / equippable）。
# ============================================================
give @s netherite_leggings[item_name={text:"迟暮",bold:true,color:dark_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +200。自身给其他生物附","color":"gray","italic":false},{"text":"加「白昼梦」时获得一层持续 8 秒的","color":"gray","italic":false},{"text":"「回光」，最多持有 3 层，重复获得刷新","color":"gray","italic":false},{"text":"持续时间。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 回光","color":"gold","bold":true,"italic":false},{"text":"自身对附有「白昼梦」的生物造成伤害时","color":"gray","italic":false},{"text":"消耗一层「回光」，之后使其时停 2 秒并","color":"gray","italic":false},{"text":"记录接下来 5 秒其受到的伤害。结束后对","color":"gray","italic":false},{"text":"其造成记录伤害的 30% 的伤害，若其有","color":"gray","italic":false},{"text":"「白昼梦」则消耗白昼梦并使其时停 1 秒，","color":"gray","italic":false},{"text":"之后使本次伤害提升为 50%。累计消耗 3","color":"gray","italic":false},{"text":"层「回光」后获得 15 秒抗性提升Ⅴ，若","color":"gray","italic":false},{"text":"受到伤害则立即清除抗性提升。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 浮光","color":"gray","italic":false},{"text":"● 迟暮","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +50。自身消耗「回光」","color":"gray","italic":false},{"text":"后使立即获得一种光效。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["late_dusk","leggings","armor"],tags:["dream","max_mana","buff"]},tooltip_display={hidden_components:["unbreakable"]}]
