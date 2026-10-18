# ============================================================
# sweetdream:equipment/armor/thorn_vein/give —— 给一件「刺纹」（罕见 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "thorn_vein" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["thorn_vein"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】iron_leggings（罕见 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_thorn_vein
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_leggings[item_name={text:"刺纹",bold:true,color:dark_red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +60。自身生命值低于最","color":"gray","italic":false},{"text":"大生命值的 50% 时，攻击命中了未附有","color":"gray","italic":false},{"text":"「噬心」的生物后则为其附加「噬心」，","color":"gray","italic":false},{"text":"并获得 3 秒抗性提升Ⅰ。该效果 10 秒内","color":"gray","italic":false},{"text":"最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["thorn_vein","leggings","armor"],tags:["shixin","max_mana","buff","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_thorn_vein",equippable={slot:"legs",asset_id:"sweetdream:armor_thorn_vein",equip_sound:"minecraft:item.armor.equip_iron"}]
