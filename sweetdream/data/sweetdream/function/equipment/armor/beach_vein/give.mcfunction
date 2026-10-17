# ============================================================
# sweetdream:equipment/armor/beach_vein/give —— 给一件「滩纹」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "beach_vein" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["beach_vein"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】iron_leggings（稀有 = iron）
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
give @s iron_leggings[item_name={text:"滩纹",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +40。自身 5 格内有附有","color":"gray","italic":false},{"text":"「渊海」的生物时，自身护甲值 +2；若自","color":"gray","italic":false},{"text":"身当前魔力值低于最大魔力值的 50%，则","color":"gray","italic":false},{"text":"每秒额外恢复 4 点魔力值。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 候潮","color":"gray","italic":false},{"text":"● 滩纹","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身技能伤害命中了附有「渊海」的生物","color":"gray","italic":false},{"text":"后，若当前主手装备的主动技能正在冷却，","color":"gray","italic":false},{"text":"则使其冷却时间 -2 秒。该效果 6 秒内最","color":"gray","italic":false},{"text":"多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["beach_vein","leggings","armor"],tags:["yuanhai","max_mana","cur_mana","buff","cd_down"]},tooltip_display={hidden_components:["unbreakable"]}]
