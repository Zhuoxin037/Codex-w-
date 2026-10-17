# ============================================================
# sweetdream:equipment/bow/reverse_string/give —— 给一件「逆弦」（史诗 · 弩）
# ------------------------------------------------------------
# 【custom_data】
#   "reverse_string" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["reverse_string"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】crossbow（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ★ 弩的命中结算要靠 sweetdream:reverse_string 附魔的 post_attack 回调（坑 138：回调
#   只读**攻击者主手物品**上的附魔）=> **必须挂 enchantments**；漏了它整把弩
#   会"射得出去、什么都不发生"且零日志。
#   ★ 附魔属于**注册表**内容：第一次加载（或改动它）之后要**退出世界再进**，
#     光 /reload 不够（坑 153）；改动前发出的旧件也要**重新 give**（坑 144）。
#   ★ enchantment_glint_override=false + tooltip 里藏掉 enchantments：
#     让附魔生效但不显示附魔名与紫色光效（与既有 10 把弩同一套写法）。
# ============================================================
give @s crossbow[item_name={text:"逆弦",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"100","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击命中生物后，额外造成一次相当","color":"gray","italic":false},{"text":"于自身基础攻击力 ×2 的伤害。若自身当","color":"gray","italic":false},{"text":"前魔力值不高于最大魔力值的 25%，则该","color":"gray","italic":false},{"text":"段技能伤害提高 50%（独立乘区）；若强","color":"gray","italic":false},{"text":"化段击杀了生物，则返还 40 魔力。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:reverse_string":1},enchantment_glint_override=false,custom_data={zx:["reverse_string","bow"],tags:["base_atk","max_mana","cur_mana","indep_mul"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
