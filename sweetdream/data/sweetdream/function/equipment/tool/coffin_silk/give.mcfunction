# ============================================================
# sweetdream:equipment/tool/coffin_silk/give —— 给一件「殓丝」（史诗 · 副手）
# ------------------------------------------------------------
# 【custom_data】
#   "coffin_silk" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["coffin_silk"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 殓结
# 【底材】recovery_compass（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:tool_coffin_silk
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"殓丝",bold:true,color:dark_red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身真实伤害命中了附有","color":"gray","italic":false},{"text":"「噬心」且仍存活的生物后，若自身未持","color":"gray","italic":false},{"text":"有「殓结」且魔力足够，则额外消耗 80","color":"gray","italic":false},{"text":"魔力与该生物的「噬心」，为自身获得持","color":"gray","italic":false},{"text":"续 8 秒的「殓结」。该效果 12 秒内最多","color":"gray","italic":false},{"text":"触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 殓结","color":"gold","bold":true,"italic":false},{"text":"下一次受到伤害后消耗「殓结」，为自身","color":"gray","italic":false},{"text":"恢复最大生命值 30% 的生命，并获得 2","color":"gray","italic":false},{"text":"秒抗性提升Ⅱ。移走副手后「殓结」消失。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["coffin_silk","tool","itemreplace"],tags:["shixin","max_hp","max_mana","true_dmg","heal","buff","consume"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:tool_coffin_silk"]
