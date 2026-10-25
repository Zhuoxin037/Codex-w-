# ============================================================
# sweetdream:equipment/tool/sip_frost/give —— 给一件「饮霜」（稀有 · 副手）
# ------------------------------------------------------------
# 【custom_data】
#   "sip_frost" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["sip_frost"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】recovery_compass（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/tool_sip_frost.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s recovery_compass[item_name={text:"饮霜",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身每恢复 10 点生命值，","color":"gray","italic":false},{"text":"便使自身 5 格内最近的 2 个生物获得 3","color":"gray","italic":false},{"text":"秒缓慢Ⅱ。该效果 4 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["sip_frost","tool"],tags:["heal","slow","debuff"]},tooltip_display={hidden_components:["unbreakable"]},max_stack_size=1]
