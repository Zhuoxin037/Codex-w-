# ============================================================
# sweetdream:equipment/armor/breathing_soil/give —— 给一件「息土」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "breathing_soil" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["breathing_soil"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】diamond_chestplate（史诗 = diamond）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/armor_breathing_soil.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ★ 盔甲本批不挂 equippable（外观层 armor_<id>.json 还没做，asset_id 会悬空）。
#   穿戴效果与触发逻辑仍可正常工作，只是外观是原版底材。
# ============================================================
give @s diamond_chestplate[item_name={text:"息土",bold:true,color:green},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身生命值降至最大生命值 30% 以下时，","color":"gray","italic":false},{"text":"召唤一个术阵，之后召唤一个半径 8 格的","color":"gray","italic":false},{"text":"领域，持续 12 秒。该效果 60 秒内最多","color":"gray","italic":false},{"text":"触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"在领域中自身每秒恢复 3 点生命值；每次","color":"gray","italic":false},{"text":"受到伤害时恢复 1 点生命值，该效果 2","color":"gray","italic":false},{"text":"秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["breathing_soil","chestplate","armor"],tags:["heal","formation","field","max_hp"]},tooltip_display={hidden_components:["unbreakable"]}]
