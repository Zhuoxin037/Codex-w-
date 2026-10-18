# ============================================================
# sweetdream:equipment/armor/cross_dream/give —— 给一件「渡梦」（罕见 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "cross_dream" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["cross_dream"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】iron_boots（罕见 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_cross_dream
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_boots[item_name={text:"渡梦",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120。受到附有","color":"gray","italic":false},{"text":"「白昼梦」的生物造成的近战伤害后，若","color":"gray","italic":false},{"text":"其仍存活且在自身 3 格内，则消耗其","color":"gray","italic":false},{"text":"「白昼梦」，使自身沿视线反方向水平后","color":"gray","italic":false},{"text":"撤最多 1.5 格，并获得 2 秒迅捷Ⅰ。遇","color":"gray","italic":false},{"text":"到障碍即停，该效果 10 秒内不可再次触","color":"gray","italic":false},{"text":"发。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["cross_dream","boots","armor"],tags:["dream","max_mana","dash","buff","consume"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_cross_dream",equippable={slot:"feet",asset_id:"sweetdream:armor_cross_dream",equip_sound:"minecraft:item.armor.equip_iron"}]
