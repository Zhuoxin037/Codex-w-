# ============================================================
# sweetdream:equipment/armor/candle_step/give —— 给一件「烛跬」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "candle_step" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["candle_step"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】diamond_boots（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_candle_step
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s diamond_boots[item_name={text:"烛跬",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +90。自身技能消费生物","color":"gray","italic":false},{"text":"的「夜火」后，恢复 18 点魔力值；消费","color":"gray","italic":false},{"text":"生物的「流火」后，恢复 8 点魔力值。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 焦衣","color":"gray","italic":false},{"text":"● 烛跬","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身技能成功消费「夜火」后，自身基础","color":"gray","italic":false},{"text":"攻击力 +10%，持续 4 秒，并获得 3 秒迅","color":"gray","italic":false},{"text":"捷Ⅱ。该效果 8 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["candle_step","boots","armor"],tags:["liuhuo","yehuo","max_mana","base_atk","buff","consume"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_candle_step",equippable={slot:"feet",asset_id:"sweetdream:armor_candle_step",equip_sound:"minecraft:item.armor.equip_diamond"}]
