# ============================================================
# sweetdream:equipment/armor/crimson_seam/give —— 给一件「绯缝」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "crimson_seam" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["crimson_seam"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】diamond_chestplate（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ★ 盔甲同样不挂 item_model / equippable（外观未做）；底材自带原版
#   equippable，穿戴与护甲值照常。visual/armor_icon_held 的补绑名单是**按
#   id 枚举**的，本件不在名单里 => 不会被自动写上不存在的模型。
# ============================================================
give @s diamond_chestplate[item_name={text:"绯缝",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120，最大生命值 +4。","color":"gray","italic":false},{"text":"自身真实伤害命中了附有「噬心」的生物","color":"gray","italic":false},{"text":"后，为自身恢复最大生命值 5% 的生命。","color":"gray","italic":false},{"text":"该效果 6 秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 针眠","color":"gray","italic":false},{"text":"● 绯缝","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身为原本未附有「噬心」的生物成功附","color":"gray","italic":false},{"text":"加「噬心」后，积攒 1 层「绯结」（最多","color":"gray","italic":false},{"text":"3 层，6 秒内最多积攒一次）。对原本附","color":"gray","italic":false},{"text":"有「噬心」的目标造成真实伤害时，若有","color":"gray","italic":false},{"text":"「绯结」则消耗 1 层并使这一段真实伤害","color":"gray","italic":false},{"text":"提高 15%（独立乘区），并获得 2 秒抗性","color":"gray","italic":false},{"text":"提升Ⅰ。该强化 5 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["crimson_seam","chestplate","armor"],tags:["shixin","max_hp","max_mana","true_dmg","heal","buff","apply","consume","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]}]
