# ============================================================
# sweetdream:equipment/armor/fade/give —— 给一件「息影」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "fade" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["fade"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【纯被动 + 触发】魔力上限 +90。放技能后 10 秒没再放 -> 当前手持装备冷却 -10 秒 + 回 50 魔力。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_leggings[item_name={text:"息影",bold:true,color:dark_gray},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +90。自身释放技能后若","color":"gray","italic":false},{"text":"在 10 秒内没有再次释放技能则使当前手","color":"gray","italic":false},{"text":"持装备冷却时间 -10 秒且自身恢复 50 魔","color":"gray","italic":false},{"text":"力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["fade","leggings","armor"],tags:["max_mana","cd_down"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_fade",equippable={slot:"legs",asset_id:"sweetdream:armor_fade",equip_sound:"minecraft:item.armor.equip_iron"}]
