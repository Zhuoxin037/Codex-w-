# ============================================================
# sweetdream:equipment/tool/retro_shine/give —— 给一件「反照」（稀有 · 副手）
# ------------------------------------------------------------
# 【custom_data】
#   "retro_shine" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["retro_shine"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】recovery_compass（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/tool_retro_shine.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s recovery_compass[item_name={text:"反照",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身受到生物造成的伤害后，","color":"gray","italic":false},{"text":"对伤害来源造成该次伤害 30% 的真实伤害，","color":"gray","italic":false},{"text":"每次最多 12 点，每 2 秒最多触发一次。","color":"gray","italic":false},{"text":"若伤害来源不是生物，则不触发。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["retro_shine","tool"],tags:["true_dmg"]},enchantments={"sweetdream:retro_shine":1},enchantment_glint_override=false,tooltip_display={hidden_components:["unbreakable","enchantments"]},max_stack_size=1]
