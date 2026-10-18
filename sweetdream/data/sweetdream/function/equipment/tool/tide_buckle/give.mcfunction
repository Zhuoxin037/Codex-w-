# ============================================================
# sweetdream:equipment/tool/tide_buckle/give —— 给一件「回潮扣」（稀有 · 副手）
# ------------------------------------------------------------
# 【custom_data】
#   "tide_buckle" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["tide_buckle"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】recovery_compass（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:tool_tide_buckle
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"回潮扣",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"}]},{"text":" ","italic":false},{"text":"持于副手时，自身技能消耗一个生物的","color":"gray","italic":false},{"text":"「渊海」后，将其 2 格内最多 2 个其他","color":"gray","italic":false},{"text":"生物向其拉近最多 0.75 格。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tide_buckle","tool","itemreplace"],tags:["yuanhai","consume","attract"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:tool_tide_buckle"]
