# ============================================================
# sweetdream:equipment/armor/hex_belt/give —— 给一件「魔化腰带」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "hex_belt" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["hex_belt"]}(部分匹配 + 独有标记)
# 【纯被动 + 二件套】魔力值上限 +60; 与「血肉磨坊」同穿再 +80 且每秒额外 +1 魔力。
#   ★ 本套 =【魔化腰带 + 血肉磨坊】两件, 与「聚魔」(头盔+胸甲)是【两套独立】的。
#   2026-10-08 事故: 我曾把这两套揉成一个"聚魔四件套", 已拆回两套。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_leggings[item_name={text:"魔化腰带",bold:true,color:dark_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +60。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 魔化腰带","color":"gray","italic":false},{"text":"● 血肉磨坊","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +80。每秒额外获得 1 魔","color":"gray","italic":false},{"text":"力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["hex_belt","leggings","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
