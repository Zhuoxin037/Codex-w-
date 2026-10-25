# ============================================================
# sweetdream:equipment/axe/sunken_weight/give —— 给一件「沉砣」（稀有 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "sunken_weight" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["sunken_weight"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 砣 ｜ ✦ 主动技能
# 【底材】iron_axe（稀有 = iron）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/sunken_weight.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s iron_axe[item_name={text:"沉砣",bold:true,color:dark_gray},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次命中额外造成 4 点固定伤害（不参与","color":"gray","italic":false},{"text":"任何加成）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 砣","color":"gold","bold":true,"italic":false},{"text":"每次命中获得 1 层「砣」，最多 5 层。","color":"gray","italic":false},{"text":"每层「砣」使该固定伤害 +2 点，并使自","color":"gray","italic":false},{"text":"身移动速度降低 4%。自身受到任何伤害时，","color":"gray","italic":false},{"text":"「砣」立即清零。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"180","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"消耗全部「砣」，对前方 4 格内的全部生","color":"gray","italic":false},{"text":"物造成（10 × 层数）点固定伤害，并使其","color":"gray","italic":false},{"text":"获得缓慢Ⅱ，持续（层数）秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["sunken_weight","axe","itemreplace"],skill:"sweetdream:sunken_weight",tags:["flat","slow","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
