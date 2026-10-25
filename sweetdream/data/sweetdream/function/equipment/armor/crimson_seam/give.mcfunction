# ============================================================
# sweetdream:equipment/armor/crimson_seam/give —— 给一件「绯缝」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "crimson_seam" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["crimson_seam"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 绯结 ｜ ✦ 套装效果
# 【底材】diamond_chestplate（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_crimson_seam
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s diamond_chestplate[item_name={text:"绯缝",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120，最大生命值 +4。","color":"gray","italic":false},{"text":"自身真实伤害命中了附有「噬心」的生物","color":"gray","italic":false},{"text":"后，为自身恢复最大生命值 5% 的生命。","color":"gray","italic":false},{"text":"该效果 6 秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 绯结","color":"gold","bold":true,"italic":false},{"text":"套装激活时，自身为原本未附有「噬心」","color":"gray","italic":false},{"text":"的生物成功附加「噬心」后，积攒 1 层","color":"gray","italic":false},{"text":"「绯结」（最多 3 层，6 秒内最多积攒一","color":"gray","italic":false},{"text":"次）。对原本附有「噬心」的目标造成真","color":"gray","italic":false},{"text":"实伤害时，若有「绯结」则消耗 1 层并使","color":"gray","italic":false},{"text":"这一段真实伤害提高 15%（独立乘区），","color":"gray","italic":false},{"text":"并获得 2 秒抗性提升Ⅰ。绯结增伤效果 5","color":"gray","italic":false},{"text":"秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 针眠","color":"gray","italic":false},{"text":"● 绯缝","color":"gray","italic":false},{"text":" ","italic":false},{"text":"激活「绯结」机制。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["crimson_seam","chestplate","armor"],tags:["shixin","max_hp","max_mana","true_dmg","heal","buff","apply","consume","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_crimson_seam",equippable={slot:"chest",asset_id:"sweetdream:armor_crimson_seam",equip_sound:"minecraft:item.armor.equip_diamond"}]
