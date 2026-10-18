# ============================================================
# sweetdream:equipment/sword/backflow_tide/give —— 给一件「退汐」（稀有 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "backflow_tide" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["backflow_tide"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】iron_sword（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:backflow_tide
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s iron_sword[item_name={text:"退汐",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"40","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向前方 4 格内斩出一道水刃，对范","color":"gray","italic":false},{"text":"围内全部生物造成一次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.08 的伤害。若命中了附有","color":"gray","italic":false},{"text":"「渊海」的生物，则清除其「渊海」，将","color":"gray","italic":false},{"text":"其 2 格内的其他生物向外击退最多 2 格，","color":"gray","italic":false},{"text":"并额外造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.07 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["backflow_tide","sword","itemreplace"],skill:"sweetdream:backflow_tide",tags:["yuanhai","max_mana","debuff","consume","dash"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:backflow_tide"]
