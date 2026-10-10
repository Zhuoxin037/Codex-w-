# ============================================================
# sweetdream:equipment/armor/blaze_armor/give —— 给一件「焱」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "blaze_armor" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["blaze_armor"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【纯被动】常态抗火 + 视为金甲 + 魔力上限 +100。
#   打你的生物未燃烧 -> 给它 5 秒燃烧 +「流火」; 已燃烧 -> 自己得再生Ⅱ + 力量Ⅲ 3 秒。
# 【id 用 blaze_armor】避开工具「炽翎」blaze_plume。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s diamond_chestplate[item_name={text:"焱",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"获得常态的抗火效果，且视为金甲。自身","color":"gray","italic":false},{"text":"魔力值上限 +100。攻击自身的生物若未处","color":"gray","italic":false},{"text":"于燃烧状态，则使其获得 5 秒的燃烧状态","color":"gray","italic":false},{"text":"并使其获得「流火」效果。若其已处于燃","color":"gray","italic":false},{"text":"烧状态则自身获得再生Ⅱ效果及力量Ⅲ效","color":"gray","italic":false},{"text":"果，持续 3 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["blaze_armor","chestplate","armor"],tags:["liuhuo","max_mana","buff","debuff","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_blaze_armor",equippable={slot:"chest",asset_id:"sweetdream:armor_blaze_armor",equip_sound:"minecraft:item.armor.equip_diamond"}]
