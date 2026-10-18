# ============================================================
# sweetdream:equipment/armor/tide_watch/give —— 给一件「候潮」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "tide_watch" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["tide_watch"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】iron_chestplate（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_tide_watch
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_chestplate[item_name={text:"候潮",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +60。自身主动技能命中","color":"gray","italic":false},{"text":"生物后，若魔力足够，则消耗 30 魔力并","color":"gray","italic":false},{"text":"使其附加「渊海」。该效果 10 秒内最多","color":"gray","italic":false},{"text":"触发一次，同次施放最多附加一个目标。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 候潮","color":"gray","italic":false},{"text":"● 滩纹","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身技能伤害命中了附有「渊海」的生物","color":"gray","italic":false},{"text":"后，若当前主手装备的主动技能正在冷却，","color":"gray","italic":false},{"text":"则使其冷却时间 -2 秒。该效果 6 秒内最","color":"gray","italic":false},{"text":"多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tide_watch","chestplate","armor"],tags:["yuanhai","max_mana","apply","cd_down"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_tide_watch",equippable={slot:"chest",asset_id:"sweetdream:armor_tide_watch",equip_sound:"minecraft:item.armor.equip_iron"}]
