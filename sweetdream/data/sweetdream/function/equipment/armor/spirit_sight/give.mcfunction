# ============================================================
# sweetdream:equipment/armor/spirit_sight/give —— 给一件「灵视」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "spirit_sight" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["spirit_sight"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【纯被动 + 触发】魔力上限 +70。8 格内若有带渊海/流火/夜火/白昼梦/噬心的生物 -> 令其发光,
#   且自身每秒回 1 魔力。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_helmet[item_name={text:"灵视",bold:true,color:yellow},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +70。自身 8 格内若有带","color":"gray","italic":false},{"text":"有「渊海」、「流火」、「夜火」、","color":"gray","italic":false},{"text":"「白昼梦」、「噬心」任一标签的生物则","color":"gray","italic":false},{"text":"使其发光，且自身每秒恢复一点魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["spirit_sight","helmet","armor"],tags:["liuhuo","yehuo","yuanhai","dream","shixin","max_mana","debuff"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_spirit_sight",equippable={slot:"head",asset_id:"sweetdream:armor_spirit_sight",equip_sound:"minecraft:item.armor.equip_iron"}]
