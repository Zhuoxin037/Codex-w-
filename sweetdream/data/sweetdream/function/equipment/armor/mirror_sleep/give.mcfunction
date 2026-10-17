# ============================================================
# sweetdream:equipment/armor/mirror_sleep/give —— 给一件「镜寐」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "mirror_sleep" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["mirror_sleep"]}(部分匹配 + 独有标记)
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
give @s iron_leggings[item_name={text:"镜寐",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +60。自身每攻击 3 次生","color":"gray","italic":false},{"text":"物后，若自身魔力足够，则消耗 30 魔力","color":"gray","italic":false},{"text":"并对下一个攻击且未附有「白昼梦」的生","color":"gray","italic":false},{"text":"物附加「白昼梦」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 镜寐","color":"gray","italic":false},{"text":"● 轻枕","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身为原本未附有「白昼梦」的生物成功","color":"gray","italic":false},{"text":"附加「白昼梦」后，获得 4 秒迅捷Ⅰ，并","color":"gray","italic":false},{"text":"在这 4 秒内每秒额外恢复 5 点魔力值。","color":"gray","italic":false},{"text":"该效果 10 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["mirror_sleep","leggings","armor"],tags:["dream","max_mana","buff","apply"]},tooltip_display={hidden_components:["unbreakable"]}]
