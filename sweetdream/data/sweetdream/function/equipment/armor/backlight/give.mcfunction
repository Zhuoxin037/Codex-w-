# ============================================================
# sweetdream:equipment/armor/backlight/give —— 给一件「返照」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "backlight" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["backlight"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 回照
# 【底材】diamond_helmet（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_backlight
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s diamond_helmet[item_name={text:"返照",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +160。普通近战命中了附","color":"gray","italic":false},{"text":"有「夜火」且仍存活的生物后，若自身未","color":"gray","italic":false},{"text":"持有「回照」，则消耗其「夜火」，为自","color":"gray","italic":false},{"text":"身获得持续 5 秒的「回照」。该效果 20","color":"gray","italic":false},{"text":"秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 回照","color":"gold","bold":true,"italic":false},{"text":"自身下一次主动技能成功施放后，返还该","color":"gray","italic":false},{"text":"次实际消耗魔力的 25%，并使该技能冷却","color":"gray","italic":false},{"text":"时间 -8 秒，之后清除「回照」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["backlight","helmet","armor"],tags:["yehuo","max_mana","cur_mana","cd_down","consume"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_backlight",equippable={slot:"head",asset_id:"sweetdream:armor_backlight",equip_sound:"minecraft:item.armor.equip_diamond"}]
