# ============================================================
# sweetdream:equipment/armor/zhuzu/give —— 给一件「驻足」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "zhuzu" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["zhuzu"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】iron_boots（稀有 = iron）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/armor_zhuzu.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ★ 盔甲本批不挂 equippable（外观层 armor_<id>.json 还没做，asset_id 会悬空）。
#   穿戴效果与触发逻辑仍可正常工作，只是外观是原版底材。
# ============================================================
give @s iron_boots[item_name={text:"驻足",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"受到伤害后开始计时。若 1.5 秒内没有移","color":"gray","italic":false},{"text":"动，则在脚下展开半径 3 格的领域，持续","color":"gray","italic":false},{"text":"10 秒。领域内的生物每秒受到 5 点固定","color":"gray","italic":false},{"text":"伤害，并获得 1 秒缓慢Ⅰ。自身移动即收","color":"gray","italic":false},{"text":"起领域。该效果 30 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["zhuzu","boots","armor"],tags:["field","flat","debuff"]},tooltip_display={hidden_components:["unbreakable"]}]
