# ============================================================
# sweetdream:equipment/staff/fate_thread/give —— 给一件「命缕」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "fate_thread" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["fate_thread"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:fate_thread
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"命缕",bold:true,color:dark_red},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"1","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后都会在其身上留下持续 5","color":"gray","italic":false},{"text":"秒的血色丝线。期间若普攻命中了其 5 格","color":"gray","italic":false},{"text":"内的另一个生物，则对二者分别造成一次","color":"gray","italic":false},{"text":"相当于自身最大魔力值 ×0.05 的伤害，并","color":"gray","italic":false},{"text":"使最初的生物附加「噬心」，之后丝线消","color":"gray","italic":false},{"text":"失。该效果 8 秒内不可再次触发。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"240","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后选中自身 10 格内最近的一个附有","color":"gray","italic":false},{"text":"「噬心」的生物，使其及 6 格内最多 2","color":"gray","italic":false},{"text":"个其他生物以绯色丝线相连，持续 7 秒。","color":"gray","italic":false},{"text":"期间其每次受到自身造成的伤害后，相连","color":"gray","italic":false},{"text":"的其他生物分别受到一次相当于本次伤害","color":"gray","italic":false},{"text":"×0.3 的真实伤害（最多触发 6 次）。若","color":"gray","italic":false},{"text":"其死亡或失去「噬心」，则丝线断开；若","color":"gray","italic":false},{"text":"与相连生物的距离超过 12 格，则对应丝","color":"gray","italic":false},{"text":"线断开。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["fate_thread","staff","itemreplace"],skill:"sweetdream:fate_thread",tags:["shixin","max_mana","true_dmg","apply"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:fate_thread"]
