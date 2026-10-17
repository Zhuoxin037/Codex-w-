# ============================================================
# sweetdream:equipment/armor/empty_pillow/give —— 给一件「空枕」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "empty_pillow" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["empty_pillow"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 静息
# 【底材】iron_helmet（稀有 = iron）
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
give @s iron_helmet[item_name={text:"空枕",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +50。自身连续 4 秒没有","color":"gray","italic":false},{"text":"造成伤害后，获得「静息」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 静息","color":"gold","bold":true,"italic":false},{"text":"下一次攻击生物时，若目标未附有","color":"gray","italic":false},{"text":"「白昼梦」则使其附加「白昼梦」，之后","color":"gray","italic":false},{"text":"清除「静息」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["empty_pillow","helmet","armor"],tags:["dream","max_mana","consume","apply"]},tooltip_display={hidden_components:["unbreakable"]}]
