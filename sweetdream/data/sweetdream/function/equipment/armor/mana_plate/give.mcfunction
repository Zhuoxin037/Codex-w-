# ============================================================
# sweetdream:equipment/armor/mana_plate/give —— 给一件「聚魔胸甲」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "mana_plate" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["mana_plate"]}(部分匹配 + 独有标记)
# 【纯被动 + 二件套】魔力值上限 +20; 与「聚魔头盔」同穿再 +20。
#   ★ 套装成员只有这两件(见 mana_helm 的注)。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_chestplate[item_name={text:"聚魔胸甲",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +20。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 聚魔头盔","color":"gray","italic":false},{"text":"● 聚魔胸甲","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +20。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["mana_plate","chestplate","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
