# ============================================================
# sweetdream:equipment/armor/gyre/give —— 给一件「回旋」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "gyre" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["gyre"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 旋步
# 【底材】diamond_leggings（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_gyre
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s diamond_leggings[item_name={text:"回旋",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +140。自身技能成功消费","color":"gray","italic":false},{"text":"一个生物的「渊海」后，为自身获得持续","color":"gray","italic":false},{"text":"6 秒的「旋步」。该效果 12 秒内最多触","color":"gray","italic":false},{"text":"发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 旋步","color":"gold","bold":true,"italic":false},{"text":"下一次普通近战命中生物后消耗「旋步」，","color":"gray","italic":false},{"text":"使自身呈圆形轨迹移动至命中生物的背后，","color":"gray","italic":false},{"text":"并对本次命中的生物额外造成一次 24 点","color":"gray","italic":false},{"text":"固定伤害，对移动过程中碰到的生物造成","color":"gray","italic":false},{"text":"一次 30 点固定伤害。遇到障碍即停。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["gyre","leggings","armor"],tags:["yuanhai","max_mana","flat","dash","consume"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_gyre",equippable={slot:"legs",asset_id:"sweetdream:armor_gyre",equip_sound:"minecraft:item.armor.equip_diamond"}]
