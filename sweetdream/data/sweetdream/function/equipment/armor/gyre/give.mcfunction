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
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ★ 盔甲同样不挂 item_model / equippable（外观未做）；底材自带原版
#   equippable，穿戴与护甲值照常。visual/armor_icon_held 的补绑名单是**按
#   id 枚举**的，本件不在名单里 => 不会被自动写上不存在的模型。
# ============================================================
give @s diamond_leggings[item_name={text:"回旋",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +140。自身技能成功消费","color":"gray","italic":false},{"text":"一个生物的「渊海」后，为自身获得持续","color":"gray","italic":false},{"text":"6 秒的「旋步」。该效果 12 秒内最多触","color":"gray","italic":false},{"text":"发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 旋步","color":"gold","bold":true,"italic":false},{"text":"下一次普通近战命中生物后消耗「旋步」，","color":"gray","italic":false},{"text":"使自身呈圆形轨迹移动至命中生物的背后，","color":"gray","italic":false},{"text":"并对本次命中的生物额外造成一次 24 点","color":"gray","italic":false},{"text":"固定伤害，对移动过程中碰到的生物造成","color":"gray","italic":false},{"text":"一次 30 点固定伤害。遇到障碍即停。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["gyre","leggings","armor"],tags:["yuanhai","max_mana","flat","dash","consume"]},tooltip_display={hidden_components:["unbreakable"]}]
