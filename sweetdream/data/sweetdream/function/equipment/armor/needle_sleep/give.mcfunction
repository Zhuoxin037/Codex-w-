# ============================================================
# sweetdream:equipment/armor/needle_sleep/give —— 给一件「针眠」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "needle_sleep" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["needle_sleep"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】diamond_helmet（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_needle_sleep
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s diamond_helmet[item_name={text:"针眠",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +100。自身法杖普攻或攻","color":"gray","italic":false},{"text":"击命中了未附有「噬心」的生物后，若魔","color":"gray","italic":false},{"text":"力足够，则消耗 60 魔力并使其附加","color":"gray","italic":false},{"text":"「噬心」。该效果 10 秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 针眠","color":"gray","italic":false},{"text":"● 绯缝","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身为原本未附有「噬心」的生物成功附","color":"gray","italic":false},{"text":"加「噬心」后，积攒 1 层「绯结」（最多","color":"gray","italic":false},{"text":"3 层，6 秒内最多积攒一次）。对原本附","color":"gray","italic":false},{"text":"有「噬心」的目标造成真实伤害时，若有","color":"gray","italic":false},{"text":"「绯结」则消耗 1 层并使这一段真实伤害","color":"gray","italic":false},{"text":"提高 15%（独立乘区），并获得 2 秒抗性","color":"gray","italic":false},{"text":"提升Ⅰ。该强化 5 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["needle_sleep","helmet","armor"],tags:["shixin","max_mana","true_dmg","buff","apply","consume","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_needle_sleep",equippable={slot:"head",asset_id:"sweetdream:armor_needle_sleep",equip_sound:"minecraft:item.armor.equip_diamond"}]
