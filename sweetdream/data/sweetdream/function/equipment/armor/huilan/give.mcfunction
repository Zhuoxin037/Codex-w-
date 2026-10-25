# ============================================================
# sweetdream:equipment/armor/huilan/give —— 给一件「回澜」（传说 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "huilan" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["huilan"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】netherite_chestplate（传说 = netherite）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/armor_huilan.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ★ 盔甲本批不挂 equippable（外观层 armor_<id>.json 还没做，asset_id 会悬空）。
#   穿戴效果与触发逻辑仍可正常工作，只是外观是原版底材。
# ============================================================
give @s netherite_chestplate[item_name={text:"回澜",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次受到伤害时记录该次伤害。若 3 秒内","color":"gray","italic":false},{"text":"没有再次受到伤害，则恢复该次伤害 50%","color":"gray","italic":false},{"text":"的生命值（保底 4 点）。若 3 秒内再次","color":"gray","italic":false},{"text":"受到伤害，则覆盖上一次的记录，永远只","color":"gray","italic":false},{"text":"结算最后一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["huilan","chestplate","armor"],tags:["heal","max_hp"]},tooltip_display={hidden_components:["unbreakable"]}]
