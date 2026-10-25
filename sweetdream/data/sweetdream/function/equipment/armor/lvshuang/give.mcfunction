# ============================================================
# sweetdream:equipment/armor/lvshuang/give —— 给一件「履霜」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "lvshuang" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["lvshuang"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】diamond_boots（史诗 = diamond）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/armor_lvshuang.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ★ 盔甲本批不挂 equippable（外观层 armor_<id>.json 还没做，asset_id 会悬空）。
#   穿戴效果与触发逻辑仍可正常工作，只是外观是原版底材。
# ============================================================
give @s diamond_boots[item_name={text:"履霜",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每移动 1 格，在脚下留下一片霜，最多同","color":"gray","italic":false},{"text":"时存在 6 片，每片持续 5 秒。生物踩到","color":"gray","italic":false},{"text":"霜时获得 2 秒缓慢Ⅱ；自身踩到霜时获得","color":"gray","italic":false},{"text":"2 秒迅捷Ⅰ，且不消耗该片霜。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["lvshuang","boots","armor"],tags:["slow","debuff","buff"]},tooltip_display={hidden_components:["unbreakable"]}]
