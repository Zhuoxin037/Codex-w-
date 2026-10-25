# ============================================================
# sweetdream:equipment/bow/lianshi/give —— 给一件「连矢」（稀有 · 弩）
# ------------------------------------------------------------
# 【custom_data】
#   "lianshi" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["lianshi"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】crossbow（稀有 = iron）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/crossbow_lianshi.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s crossbow[item_name={text:"连矢",bold:true,color:yellow},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"120","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击命中后，若命中位置 4 格内存在","color":"gray","italic":false},{"text":"另一个生物，则箭矢弹向其中一个，对其","color":"gray","italic":false},{"text":"造成一次相当于自身当前魔力值 ×0.15 的","color":"gray","italic":false},{"text":"伤害（已扣除本次射击消耗）。每支箭最","color":"gray","italic":false},{"text":"多弹射一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["lianshi","bow"],tags:["cur_mana","base_atk"]},enchantments={"sweetdream:lianshi":1},enchantment_glint_override=false,tooltip_display={hidden_components:["unbreakable","enchantments"]}]
