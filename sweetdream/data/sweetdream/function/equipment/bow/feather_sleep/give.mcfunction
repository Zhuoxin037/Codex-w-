# ============================================================
# sweetdream:equipment/bow/feather_sleep/give —— 给一件「眠羽」（罕见 · 弩）
# ------------------------------------------------------------
# 【custom_data】
#   "feather_sleep" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["feather_sleep"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】crossbow（罕见 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ★ 弩的命中结算要靠 sweetdream:feather_sleep 附魔的 post_attack 回调（坑 138：回调
#   只读**攻击者主手物品**上的附魔）=> **必须挂 enchantments**；漏了它整把弩
#   会"射得出去、什么都不发生"且零日志。
#   ★ 附魔属于**注册表**内容：第一次加载（或改动它）之后要**退出世界再进**，
#     光 /reload 不够（坑 153）；改动前发出的旧件也要**重新 give**（坑 144）。
#   ★ enchantment_glint_override=false + tooltip 里藏掉 enchantments：
#     让附魔生效但不显示附魔名与紫色光效（与既有 10 把弩同一套写法）。
# ============================================================
give @s crossbow[item_name={text:"眠羽",bold:true,color:white},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击命中了附有「白昼梦」的生物后，","color":"gray","italic":false},{"text":"消耗其「白昼梦」，并使箭矢分裂出 2 枚","color":"gray","italic":false},{"text":"半透明的羽箭。羽箭分别追踪命中位置 6","color":"gray","italic":false},{"text":"格内最近的其他生物，对其造成一次相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.08 的伤害，并使其","color":"gray","italic":false},{"text":"获得 3 秒缓慢Ⅱ。若只有一个生物，则 2","color":"gray","italic":false},{"text":"枚羽箭合为一枚，伤害改为相当于自身最","color":"gray","italic":false},{"text":"大魔力值 ×0.18。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:feather_sleep":1},enchantment_glint_override=false,custom_data={zx:["feather_sleep","bow"],tags:["dream","max_mana","debuff","slow","consume"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
